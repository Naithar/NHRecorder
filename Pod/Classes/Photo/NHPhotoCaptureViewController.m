//
//  NHCameraViewController.m
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import "NHPhotoCaptureViewController.h"
#import "NHPhotoFocusView.h"
#import "NHCameraGridView.h"
#import "NHPhotoEditorViewController.h"
#import "NHPhotoCaptureDefaultView.h"
#import "NHVideoCaptureViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImage+Resize.h"
#import "NHMediaPickerViewController.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHPhotoCaptureViewController class]]\
pathForResource:name ofType:@"png"]]


const CGFloat kNHRecorderBottomViewHeight = 90;
const CGFloat kNHRecorderCaptureButtonHeight = 60;
const CGFloat kNHRecorderSideButtonHeight = 50;
const CGFloat kNHRecorderCaptureButtonBorderOffset = 5;

@interface NHPhotoCaptureViewController ()

@property (nonatomic, strong) GPUImageStillCamera *photoCamera;
@property (nonatomic, strong) NHPhotoCaptureView *captureView;

@property (nonatomic, strong) id enterForegroundNotification;
@property (nonatomic, strong) id resignActiveNotification;

@property (nonatomic, strong) id orientationChange;

@end

@implementation NHPhotoCaptureViewController

+ (Class)nhVideoCaptureClass {
    return [NHVideoCaptureViewController class];
}
+ (Class)nhPhotoEditorClass {
    return [NHPhotoEditorViewController class];
}
+ (Class)nhMediaPickerClass {
    return [NHMediaPickerViewController class];
}

+ (Class)nhPhotoCaptureViewClass {
    return [NHPhotoCaptureDefaultView class];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.photoCamera = [[GPUImageStillCamera alloc]
                        initWithSessionPreset:AVCaptureSessionPresetPhoto
                        cameraPosition:AVCaptureDevicePositionBack];
    
    self.photoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.photoCamera.horizontallyMirrorFrontFacingCamera = YES;
    if ([self.photoCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeAuto]) {
        [self.photoCamera.inputCamera lockForConfiguration:nil];
        [self.photoCamera.inputCamera setFlashMode:AVCaptureFlashModeAuto];
        [self.photoCamera.inputCamera unlockForConfiguration];
    }
    
    Class viewClass = [[self class] nhPhotoCaptureViewClass];
    
    if (![viewClass isSubclassOfClass:[NHPhotoCaptureView class]]) {
        viewClass = [NHPhotoCaptureDefaultView class];
    }
    
    self.captureView = [[viewClass alloc] initWithCaptureViewController:self];
    
    __weak __typeof(self) weakSelf = self;
    self.enterForegroundNotification = [[NSNotificationCenter defaultCenter]
                                        addObserverForName:UIApplicationWillEnterForegroundNotification
                                        object:nil
                                        queue:nil
                                        usingBlock:^(NSNotification *note) {
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            if (strongSelf
                                                && strongSelf.view.window) {
                                                [strongSelf startCamera];
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

- (void)deviceOrientationChange {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.captureView changeOrientationTo:deviceOrientation];
                     } completion:nil];

}
//
//

//MARK: Buttons


//MARK: resets

- (void)openPhotoPicker {
    Class viewControllerClass = [[self class] nhMediaPickerClass];
    
    if (![viewControllerClass isSubclassOfClass:[NHMediaPickerViewController class]]) {
        viewControllerClass = [NHMediaPickerViewController class];
    }
    
    NHMediaPickerViewController *viewController = [[viewControllerClass alloc]
                                                   initWithMediaType:NHMediaPickerTypePhoto];
    viewController.linksToCamera = NO;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)openVideoCapture {
    Class viewControllerClass = [[self class] nhVideoCaptureClass];
    
    if (![viewControllerClass isSubclassOfClass:[NHVideoCaptureViewController class]]) {
        viewControllerClass = [NHVideoCaptureViewController class];
    }
    
    NHVideoCaptureViewController *viewController = [[viewControllerClass alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)closeController {
    if ([self.navigationController.viewControllers count] == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//MARK: View overrides


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.captureView setupView];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startCamera];
    [self.captureView showView];
}


- (void)startCamera {
    
    [self.photoCamera stopCameraCapture];    
    [self.photoCamera.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    [self.photoCamera startCameraCapture];
}

- (void)stopCamera {
    [self.photoCamera stopCameraCapture];
    
    [self.captureView hideView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.captureView hideView];
    [self stopCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.captureView willShowView];
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.captureView willHideView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return [self.captureView statusBarHidden];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [self.captureView supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.captureView interfaceOrientation];
}

- (BOOL)shouldAutorotate {
    return [self.captureView shouldAutorotate];
}

- (void)capturePhoto {
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    __weak __typeof(self) weakSelf = self;
    
    if (cameraStatus != AVAuthorizationStatusAuthorized) {
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhPhotoCapture:cameraAvailability:)]) {
            [weakSelf.nhDelegate
             nhPhotoCapture:weakSelf
             cameraAvailability:cameraStatus];
        }
        return;
    }
    
    self.navigationController.view.userInteractionEnabled = NO;
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhPhotoCaptureDidStartExporting:)]) {
        [weakSelf.nhDelegate nhPhotoCaptureDidStartExporting:weakSelf];
    }
    
    [self.photoCamera capturePhotoAsImageProcessedUpToFilter:[self.captureView lastFilter]
                                       withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                                           @autoreleasepool {
                                               
                                               weakSelf.navigationController.view.userInteractionEnabled = YES;
                                               
                                               if (error
                                                   || !processedImage) {
                                                   NSLog(@"error - %@", error);
                                                   return;
                                               }
                                               
                                               UIImage *resultImage;
                                               
                                               CGSize imageSizeToFit = CGSizeZero;
                                               
                                               if ([weakSelf.nhDelegate respondsToSelector:@selector(imageSizeToFitForNHPhotoCapture:)]) {
                                                   imageSizeToFit = [weakSelf.nhDelegate imageSizeToFitForNHPhotoCapture:weakSelf];
                                               }
                                               
                                               if (CGSizeEqualToSize(imageSizeToFit, CGSizeZero)) {
                                                   resultImage = processedImage;
                                               }
                                               else {
                                                   resultImage = [processedImage nhr_rescaleToFit:imageSizeToFit];
                                               }
                                               
                                               if (resultImage) {
                                                   BOOL shouldEdit = YES;
                                                   
                                                   __weak __typeof(self) weakSelf = self;
                                                   if ([weakSelf.nhDelegate respondsToSelector:@selector(nhPhotoCapture:shouldEditImage:)]) {
                                                       shouldEdit = [weakSelf.nhDelegate nhPhotoCapture:weakSelf shouldEditImage:resultImage];
                                                   }
                                                   
                                                   if (shouldEdit) {
                                                       Class viewControllerClass = [[self class] nhPhotoEditorClass];
                                                       
                                                       if (![viewControllerClass isSubclassOfClass:[NHPhotoEditorViewController class]]) {
                                                           viewControllerClass = [NHPhotoEditorViewController class];
                                                       }
                                                       
                                                       NHPhotoEditorViewController *viewController = [[viewControllerClass alloc]
                                                                                                      initWithUIImage:resultImage];
                                                       [self.navigationController pushViewController:viewController animated:YES];
                                                   }
                                               }
                                               
                                               if ([weakSelf.nhDelegate respondsToSelector:@selector(photoCaptureDidFinishExporting:)]) {
                                                   [weakSelf.nhDelegate photoCaptureDidFinishExporting:weakSelf];
                                               }
                                           }
                                       }];
}
- (void)switchCameraPosition {
    [self.photoCamera rotateCamera];
}
- (AVCaptureDevicePosition)cameraPosition {
    return self.photoCamera.cameraPosition;
}
- (void)switchFlashMode {
    AVCaptureFlashMode newFlashMode = AVCaptureFlashModeAuto;
    
    switch (self.photoCamera.inputCamera.flashMode) {
        case AVCaptureFlashModeAuto:
            newFlashMode = AVCaptureFlashModeOff;
            break;
        case AVCaptureFlashModeOff:
            newFlashMode = AVCaptureFlashModeOn;
            break;
        case AVCaptureFlashModeOn:
            newFlashMode = AVCaptureFlashModeAuto;
            break;
        default:
            break;
    }
    
    if ([self.photoCamera.inputCamera isFlashModeSupported:newFlashMode]) {
        [self.photoCamera.inputCamera lockForConfiguration:nil];
        [self.photoCamera.inputCamera setFlashMode:newFlashMode];
        [self.photoCamera.inputCamera unlockForConfiguration];
    }
}
- (AVCaptureFlashMode)flashMode {
    return self.photoCamera.inputCamera.flashMode;
}
- (BOOL)flashEnabled {
    return [self cameraPosition] != AVCaptureDevicePositionFront;
}

- (void)dealloc {
    [self stopCamera];
    self.photoCamera = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}



@end

