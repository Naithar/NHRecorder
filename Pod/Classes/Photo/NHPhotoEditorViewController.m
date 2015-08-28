//
//  NHCameraImageEditorController.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHPhotoEditorViewController.h"
#import "UIImage+Resize.h"
#import "NHPhotoDefaultEditorView.h"

const CGFloat kNHRecorderSelectorViewHeight = 40;
const CGFloat kNHRecorderSelectionContainerViewHeight = 80;

@interface NHPhotoEditorViewController ()

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NHPhotoEditorView *editorView;

@property (nonatomic, strong) id orientationChange;

@end

@implementation NHPhotoEditorViewController

+ (Class)nhPhotoEditorViewClass {
    return [NHPhotoDefaultEditorView class];
}

- (instancetype)initWithUIImage:(UIImage*)image {
    self = [super init];
    
    if (self) {
        _image = image;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
    Class viewClass = [[self class] nhPhotoEditorViewClass];
    
    if (![viewClass isSubclassOfClass:[NHPhotoEditorView class]]) {
        viewClass = [NHPhotoDefaultEditorView class];
    }
    
    self.editorView = [[viewClass alloc] initWithEditorViewController:self andImage:self.image];
    
    __weak __typeof(self) weakSelf = self;
    self.orientationChange = [[NSNotificationCenter defaultCenter]
                              addObserverForName:UIDeviceOrientationDidChangeNotification
                              object:nil
                              queue:nil
                              usingBlock:^(NSNotification *note) {
                                  __strong __typeof(weakSelf) strongSelf = weakSelf;
                                  if (strongSelf
                                      && strongSelf.view.window) {
                                      [strongSelf deviceOrientationChange];
                                  }
                              }];

    
}


//MARK: setup


- (void)deviceOrientationChange {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.editorView changeOrientationTo:deviceOrientation];
                     }
     completion:nil];
}

- (void)processPhoto {
    
    if ([self.editorView canProcessPhoto]) {
        self.navigationController.view.userInteractionEnabled = NO;
        __weak __typeof(self) weakSelf = self;
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhPhotoEditorDidStartExporting:)]) {
            [weakSelf.nhDelegate nhPhotoEditorDidStartExporting:weakSelf];
        }
        
        [self.editorView.photoEditorView processImageWithBlock:^(UIImage *image) {
            
            weakSelf.navigationController.view.userInteractionEnabled = YES;
            
            if (image) {
                UIImage *resultImage;
                
                CGSize imageSizeToFit = CGSizeZero;
                
                if ([weakSelf.nhDelegate respondsToSelector:@selector(imageSizeToFitForNHPhotoEditor:)]) {
                    imageSizeToFit = [weakSelf.nhDelegate imageSizeToFitForNHPhotoEditor:weakSelf];
                }
                
                if (CGSizeEqualToSize(imageSizeToFit, CGSizeZero)) {
                    resultImage = image;
                }
                else {
                    resultImage = [image nhr_rescaleToFit:imageSizeToFit];
                }
                
                if (resultImage) {
                    BOOL shouldSave = YES;
                    
                    __weak __typeof(self) weakSelf = self;
                    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhPhotoEditor:shouldSaveImage:)]) {
                        shouldSave = [weakSelf.nhDelegate nhPhotoEditor:weakSelf shouldSaveImage:resultImage];
                    }
                    
                    if (shouldSave) {
                        UIImageWriteToSavedPhotosAlbum(resultImage, self, @selector(savedCapturedImage:error:context:), nil);
                    }
                }
                
                if ([weakSelf.nhDelegate respondsToSelector:@selector(nhPhotoEditorDidFinishExporting:)]) {
                    [weakSelf.nhDelegate nhPhotoEditorDidFinishExporting:weakSelf];
                }
            }
        }];

    }
}

- (void)savedCapturedImage:(UIImage*)image error:(NSError*)error context:(void*)context {
    BOOL shouldContinue = YES;
    __weak __typeof(self) weakSelf = self;
    if (error) {
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhPhotoEditor:receivedErrorOnSave:)]) {
            [weakSelf.nhDelegate nhPhotoEditor:weakSelf receivedErrorOnSave:error];
        }
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhPhotoEditorShouldContinueAfterSaveFail:)]) {
            shouldContinue = [weakSelf.nhDelegate nhPhotoEditorShouldContinueAfterSaveFail:weakSelf];
        }
    }
    
    if (shouldContinue
        && [weakSelf.nhDelegate respondsToSelector:@selector(nhPhotoEditor:savedImage:)]) {
        [weakSelf.nhDelegate nhPhotoEditor:weakSelf savedImage:image];
    }
}

//MARK: view overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.editorView setupView];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.editorView.photoEditorView sizeContent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.editorView showView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.editorView hideView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.editorView willShowView];
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.editorView willHideView];
}

- (BOOL)prefersStatusBarHidden {
    return [self.editorView statusBarHidden];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [self.editorView supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.editorView interfaceOrientation];
}

- (BOOL)shouldAutorotate {
    return [self.editorView shouldAutorotate];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
