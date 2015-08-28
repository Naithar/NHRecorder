//
//  NHVideoEditorViewController.m
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import "NHVideoEditorViewController.h"
#import "NHPhotoEditorViewController.h"
#import "NHVideoEditorDefaultView.h"

@import AssetsLibrary;

@interface NHVideoEditorViewController ()

@property (nonatomic, strong) NSURL *assetURL;

@property (nonatomic, strong) id enterForegroundNotification;
@property (nonatomic, strong) id resignActiveNotification;

@property (nonatomic, strong) id orientationChange;

@end

@implementation NHVideoEditorViewController

+ (Class)nhVideoEditorViewClass {
    return [NHVideoEditorDefaultView class];
}

- (instancetype)initWithAssetURL:(NSURL*)url {
    self = [super init];
    
    if (self) {
        _assetURL = url;
        [self commonInit];
    }
    
    return self;
}

- (NSString *)filteredVideoPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
}

- (void)commonInit {
    
    Class viewClass = [[self class] nhVideoEditorViewClass];
    
    if (![viewClass isSubclassOfClass:[NHVideoEditorView class]]) {
        viewClass = [NHVideoEditorDefaultView class];
    }
    
    self.editorView = [[viewClass alloc] initWithEditorViewController:self andAssetURL:self.assetURL];

    __weak __typeof(self) weakSelf = self;
    self.enterForegroundNotification = [[NSNotificationCenter defaultCenter]
                                        addObserverForName:UIApplicationWillEnterForegroundNotification
                                        object:nil
                                        queue:nil
                                        usingBlock:^(NSNotification *note) {
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            if (strongSelf
                                                && strongSelf.view.window) {
                                                [self startVideo];
                                            }
                                        }];
    
    self.resignActiveNotification = [[NSNotificationCenter defaultCenter]
                                     addObserverForName:UIApplicationWillResignActiveNotification
                                     object:nil
                                     queue:nil
                                     usingBlock:^(NSNotification *note) {
                                         __strong __typeof(weakSelf) strongSelf = weakSelf;
                                         if (strongSelf
                                             && strongSelf.view.window) {
                                         }
                                     }];
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.editorView setupView];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.editorView showView];
    [self startVideo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.editorView willShowView];
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.editorView hideView];
}

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



- (void)startSaving {
    
    __weak __typeof(self) weakSelf = self;
    
    [self.editorView.videoEditorView processVideoToPath:[self filteredVideoPath]
                             withBlock:^(NSURL *videoURL) {
        weakSelf.navigationController.view.userInteractionEnabled = YES;
        
                                 
                                 if (!videoURL) {
#ifdef DEBUG
                                     NSLog(@"video url is nil");
#endif
                                     return;
                                 }
        
        BOOL shouldSave = YES;
        NSURL *outputURL = videoURL;
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:shouldSaveFilteredVideoAtURL:)]) {
            shouldSave = [weakSelf.nhDelegate nhVideoEditor:weakSelf shouldSaveFilteredVideoAtURL:outputURL];
        }
        
        if (shouldSave) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
                [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                    if (!error
                        && assetURL) {
#ifdef DEBUG
                        NSLog(@"saved");
#endif
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didSaveAtURL:)]) {
                            [weakSelf.nhDelegate nhVideoEditor:weakSelf didSaveAtURL:assetURL];
                        }
                        
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didFinishExportingAtURL:)]) {
                            [weakSelf.nhDelegate nhVideoEditor:weakSelf didFinishExportingAtURL:assetURL];
                        }
                    }
                    else {
#ifdef DEBUG
                        NSLog(@"error = %@", error);
#endif
                        
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didFailWithError:)]) {
                            [weakSelf.nhDelegate nhVideoEditor:weakSelf didFailWithError:error];
                        }
                        
                        BOOL shouldContinue = YES;
                        
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditorShouldContinueAfterSaveFail:)]) {
                            shouldContinue = [weakSelf.nhDelegate nhVideoEditorShouldContinueAfterSaveFail:weakSelf];
                        }
                        
                        if (shouldContinue) {
                            if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didFinishExportingAtURL:)]) {
                                [weakSelf.nhDelegate nhVideoEditor:weakSelf
                                           didFinishExportingAtURL:outputURL];
                            }
                        }
                    }
                }];
            }
            
        }
        else {
            
            if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditor:didFinishExportingAtURL:)]) {
                [weakSelf.nhDelegate nhVideoEditor:weakSelf didFinishExportingAtURL:outputURL];
            }
        }
    }];
}

- (void)processVideo {
    
    if ([self.editorView canProcessVideo]) {
        self.navigationController.view.userInteractionEnabled = NO;
        
        [self startSaving];
        
        __weak __typeof(self) weakSelf = self;
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoEditorDidStartExporting:)]) {
            [weakSelf.nhDelegate nhVideoEditorDidStartExporting:weakSelf];
        }
    }
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.editorView.videoEditorView sizeContent];
}


- (void)startVideo {
    [self.editorView.videoEditorView startVideo];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
