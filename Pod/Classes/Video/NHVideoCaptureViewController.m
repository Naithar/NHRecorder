//
//  NHVideoCaptureViewController.m
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

#import "NHVideoCaptureViewController.h"
#import "CaptureManager.h"
#import "NHPhotoCaptureViewController.h"
#import "AVCamRecorder.h"
#import "NHVideoEditorViewController.h"
#import "NHRecorderProgressView.h"
#import "NHMediaPickerViewController.h"
#import "NHVideoCaptureDefaultView.h"

@import AssetsLibrary;

@interface NHVideoCaptureViewController ()<CaptureManagerDelegate>

@property (nonatomic, strong) CaptureManager *captureManager;
@property (nonatomic, strong) NHVideoCaptureView *captureView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic, strong) id enterForegroundNotification;
@property (nonatomic, strong) id resignActiveNotification;

@property (nonatomic, strong) id orientationChange;

@end

@implementation NHVideoCaptureViewController

+ (Class)nhPhotoCaptureClass {
    return [NHPhotoCaptureViewController class];
}

+ (Class)nhVideoEditorClass {
    return [NHVideoEditorViewController class];
}


+ (Class)nhMediaPickerClass {
    return [NHMediaPickerViewController class];
}

+ (Class)nhVideoCaptureViewClass {
    return [NHVideoCaptureDefaultView class];
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
    self.captureManager = [[CaptureManager alloc] init];
    self.captureManager.delegate = self;
    
    Class viewClass = [[self class] nhVideoCaptureViewClass];
    
    if (![viewClass isSubclassOfClass:[NHVideoCaptureView class]]) {
        viewClass = [NHVideoCaptureDefaultView class];
    }
    
    self.captureView = [[viewClass alloc] initWithCaptureViewController:self];
    
    
    
    if ([self.captureManager setupSession]) {
        self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureManager.session];
        
        if ([self.videoPreviewLayer.connection isVideoOrientationSupported]) {
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        
        [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        
    }
    
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
                                                [strongSelf.captureView showView];
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
                                             [strongSelf stopCapture];
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
    
    [self.captureView setupView];
    
    [self.captureView.videoCaptureView.layer insertSublayer:self.videoPreviewLayer atIndex:0];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}


- (void)startCamera {
    [self.captureManager.session setSessionPreset:AVCaptureSessionPresetHigh];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        [self.captureManager.session startRunning];
}

- (void)stopCamera {
    [self.captureManager.session stopRunning];
}

- (void)startCapture {
    
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (cameraStatus != AVAuthorizationStatusAuthorized) {
        
        __weak __typeof(self) weakSelf = self;
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:cameraAvailability:)]) {
            [weakSelf.nhDelegate
             nhVideoCapture:weakSelf
             cameraAvailability:cameraStatus];
        }
        return;
    }
    
    if ([self.captureView canCaptureVideo]) {
        [self.captureManager startRecording];
    }
}

- (void)stopCapture {
    if ([self.captureManager.recorder isRecording]) {
        [self.captureManager stopRecording];
    }
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startCamera];
    [self.captureView showView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopCapture];
    [self stopCamera];
    [self.captureView hideView];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.videoPreviewLayer.frame = self.captureView.videoCaptureView.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)deviceOrientationChange {
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];

    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            self.captureManager.orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.captureManager.orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            self.captureManager.orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.captureManager.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            return;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.captureView changeOrientationTo:deviceOrientation];

                     } completion:nil];
}

- (void)closeController {
    if ([self.navigationController.viewControllers count] == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)switchCamera {
    [self.captureManager switchCamera];
}


- (void)processCapturedVideo {
    
    [self stopCapture];
    
    __weak __typeof(self) weakSelf = self;
    
    BOOL isExporting = [self.captureManager saveVideoWithCompletionBlock:^(NSURL *assetURL) {
        
#ifdef DEBUG
        NSLog(@"save with url = %@", assetURL);
#endif
        
        weakSelf.navigationController.view.userInteractionEnabled = YES;
        
        if (assetURL) {
            
            BOOL shouldEdit = YES;
            if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:shouldEditVideoAtURL:)]) {
                shouldEdit = [weakSelf.nhDelegate nhVideoCapture:weakSelf shouldEditVideoAtURL:assetURL];
            }
            
            if (shouldEdit) {
                Class viewControllerClass = [[self class] nhVideoEditorClass];
                
                if (![viewControllerClass isSubclassOfClass:[NHVideoEditorViewController class]]) {
                    viewControllerClass = [NHVideoEditorViewController class];
                }
                
                NHVideoEditorViewController *editViewController = [[viewControllerClass alloc] initWithAssetURL:assetURL];
                [self.navigationController pushViewController:editViewController animated:YES];
            }
        }
        
        if (weakSelf
            && [weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:didFinishExportingWithSuccess:)]) {
            [weakSelf.nhDelegate nhVideoCapture:weakSelf didFinishExportingWithSuccess:assetURL != nil];
        }
    }];
    
    if (isExporting) {
        self.navigationController.view.userInteractionEnabled = NO;
        
        __weak __typeof(self) weakSelf = self;
        
        if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureDidStartExporting:)]) {
            [weakSelf.nhDelegate nhVideoCaptureDidStartExporting:weakSelf];
        }
    }
    else {
        self.navigationController.view.userInteractionEnabled = YES;
    }
}


- (void)openVideoPicker {
    Class viewControllerClass = [[self class] nhVideoEditorClass];
    
    if (![viewControllerClass isSubclassOfClass:[NHMediaPickerViewController class]]) {
        viewControllerClass = [NHMediaPickerViewController class];
    }
    
    NHMediaPickerViewController *viewController = [[viewControllerClass alloc]
                                                   initWithMediaType:NHMediaPickerTypeVideo];
    
    viewController.linksToCamera = NO;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)removeVideoFragment {
    [self.captureManager deleteLastAsset];
}

- (void)removeTimeFromDuration:(float)removeTime {
}

- (void)captureManagerRecordingBegan:(CaptureManager *)captureManager {
    
    [self.captureView startedCapture];
    
    __weak __typeof(self) weakSelf = self;
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureDidStart:)]) {
        [weakSelf.nhDelegate nhVideoCaptureDidStart:weakSelf];
    }
}


- (void)captureManagerRecordingFinished:(CaptureManager *)captureManager {
    
    [self.captureView stopedCapture];
    
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureDidFinish:)]) {
        [weakSelf.nhDelegate nhVideoCaptureDidFinish:weakSelf];
    }
}

- (void)updateProgress {
    
    NSLog(@"progress");
    
    __weak __typeof(self) weakSelf = self;
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:exportProgressChanged:)]) {
        [weakSelf.nhDelegate nhVideoCapture:weakSelf exportProgressChanged:weakSelf.captureManager.exportSession.progress];
    }
}

- (void)removeProgress {
    __weak __typeof(self) weakSelf = self;
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureDidStartSaving:)]) {
        [weakSelf.nhDelegate nhVideoCaptureDidStartSaving:weakSelf];
    }
}

- (void)captureManager:(CaptureManager *)captureManager didFailWithError:(NSError *)error {
    __weak __typeof(self) weakSelf = self;
#ifdef DEBUG
    NSLog(@"fail with: %@", error);
#endif
    
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCapture:didFailWithError:)]) {
        [weakSelf.nhDelegate nhVideoCapture:weakSelf didFailWithError:error];
    }
}

- (BOOL)captureManagerShouldSaveToCameraRoll:(CaptureManager *)captureManager {
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(nhVideoCaptureShouldSaveNonFilteredVideo:)]) {
        return [weakSelf.nhDelegate nhVideoCaptureShouldSaveNonFilteredVideo:weakSelf];
    }
    
    return YES;
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

- (void)dealloc {
    [self stopCapture];
    [self stopCamera];
    self.captureManager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
