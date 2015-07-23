//
//  NHVideoCaptureViewController.m
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

#import "NHVideoCaptureViewController.h"

@interface NHVideoCaptureViewController ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageCropFilter *videoCropFilter;
@property (nonatomic, strong) GPUImageView *videoCameraView;
@property (nonatomic, strong) GPUImageMovieWriter *videoMovieWriter;

@property (nonatomic, strong) id enterForegroundNotification;
@property (nonatomic, strong) id resignActiveNotification;

@property (nonatomic, strong) id orientationChange;

@property (nonatomic, assign) CGAffineTransform videoWriterOrientation;

@end

@implementation NHVideoCaptureViewController


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
    self.view.backgroundColor = [UIColor blueColor];
    
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetMedium
                                                           cameraPosition:AVCaptureDevicePositionBack];
    self.videoWriterOrientation = CGAffineTransformMakeRotation(0);
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    self.videoCropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];
//
    [self.videoCamera addTarget:self.videoCropFilter];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    //1280x720
    self.videoMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    self.videoMovieWriter.encodingLiveVideo = YES;
    
    [self.videoCropFilter addTarget:self.videoMovieWriter];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"start");
        
        [self startCapture];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"done1");
//            [self.videoMovieWriter finishRecording];
            
            
            [self.videoMovieWriter setPaused:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"start1");
                
                [self.videoMovieWriter setPaused:NO];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"done2");
                    //            [self.videoMovieWriter finishRecording];
                    
                    
                    [self stopCapture];
                    [self saveVideo];
                });
            });
            
            
        });
    });
    
    self.videoCameraView = [[GPUImageView alloc] init];
    self.videoCameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.videoCameraView.backgroundColor = [UIColor blackColor];
    self.videoCameraView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoCameraView.userInteractionEnabled = NO;
    [self.view addSubview:self.videoCameraView];
    [self.videoCropFilter addTarget:self.videoCameraView];
    
    [self setupVideoViewConstraints];
    
//    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.closeButton];
//    UIBarButtonItem *flashBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.flashButton];
//    UIBarButtonItem *gridBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.gridButton];
//    UIBarButtonItem *switchBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.switchButton];
//    
//    self.navigationItem.leftBarButtonItems = @[closeBarButton,
//                                               [[UIBarButtonItem alloc]
//                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                target:nil action:nil],
//                                               flashBarButton,
//                                               [[UIBarButtonItem alloc]
//                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                target:nil action:nil],
//                                               gridBarButton,
//                                               [[UIBarButtonItem alloc]
//                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                target:nil action:nil],
//                                               switchBarButton];
//    
//    
//    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@" "
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    __weak __typeof(self) weakSelf = self;
    self.enterForegroundNotification = [[NSNotificationCenter defaultCenter]
                                        addObserverForName:UIApplicationWillEnterForegroundNotification
                                        object:nil
                                        queue:nil
                                        usingBlock:^(NSNotification *note) {
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            if (strongSelf
                                                && strongSelf.view.window) {
                                                [strongSelf.videoCamera startCameraCapture];
//                                                [strongSelf resetLibrary];
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
                                             [strongSelf.videoCamera stopCameraCapture];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor whiteColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

- (void)startCapture {
    if (self.videoMovieWriter.assetWriter.status == AVAssetWriterStatusWriting) {
        NSLog(@"already writing");
        return;
    }
    self.videoCamera.audioEncodingTarget = self.videoMovieWriter;
    [self.videoMovieWriter startRecordingInOrientation:self.videoWriterOrientation];
}

- (void)stopCapture {
    if (self.videoMovieWriter.assetWriter.status != AVAssetWriterStatusWriting) {
        NSLog(@"not writing");
        return;
    }
    
    [self.videoMovieWriter finishRecording];
    self.videoCamera.audioEncodingTarget = nil;
}

- (void)pauseCapture {
}

- (void)saveVideo {
        UISaveVideoAtPathToSavedPhotosAlbum([NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"], nil, nil, nil);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.videoCamera startCameraCapture];
//    [self resetLibrary];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.videoCamera stopCameraCapture];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupVideoViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)deviceOrientationChange {
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            self.videoWriterOrientation = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            self.videoWriterOrientation = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.videoWriterOrientation = CGAffineTransformMakeRotation(M_PI);
            break;
        default:
            break;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
