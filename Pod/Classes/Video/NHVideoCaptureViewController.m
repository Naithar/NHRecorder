//
//  NHVideoCaptureViewController.m
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

#import "NHVideoCaptureViewController.h"
#import "CaptureManager.h"
#import "NHCameraGridView.h"
#import "NHPhotoCaptureViewController.h"
#import "NHVideoCropView.h"
#import "NHVideoFocusView.h"
#import "AVCamRecorder.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHVideoCaptureViewController class]]\
pathForResource:name ofType:@"png"]]

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHVideoCaptureViewController class]], nil)

const NSTimeInterval kNHVideoTimerInterval = 0.01;
const NSTimeInterval kNHVideoMaxDuration = 15.0;
const NSTimeInterval kNHVideoMinDuration = 2.0;

@interface NHVideoCaptureViewController ()<CaptureManagerDelegate>

@property (nonatomic, strong) CaptureManager *captureManager;
@property (nonatomic, strong) UIView *videoCameraView;
@property (nonatomic, strong) NHCameraGridView *cameraGridView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic, strong) id enterForegroundNotification;
@property (nonatomic, strong) id resignActiveNotification;

@property (nonatomic, strong) id orientationChange;

@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) NHRecorderButton *removeFragmentButton;
@property (nonatomic, strong) UIButton *captureButton;


@property (nonatomic, strong) NHRecorderButton *backButton;
@property (nonatomic, strong) NHRecorderButton *gridButton;
@property (nonatomic, strong) NHRecorderButton *switchButton;

@property (nonatomic, strong) UIProgressView *durationProgressView;

@property (nonatomic, assign) NSTimeInterval currentDuration;

@property (nonatomic, strong) NHVideoCropView *cropView;

@property (nonatomic, strong) NHVideoFocusView *cameraFocusView;

@property (nonatomic, strong) NSTimer *recordTimer;
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
    self.view.backgroundColor = [UIColor blackColor];
    
    self.videoCameraView = [[UIView alloc] init];
    self.videoCameraView.backgroundColor = [UIColor blackColor];
    self.videoCameraView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoCameraView.userInteractionEnabled = NO;
    self.videoCameraView.clipsToBounds = YES;
    self.videoCameraView.layer.masksToBounds = YES;
    [self.view addSubview:self.videoCameraView];
    
    self.bottomContainerView = [[UIView alloc] init];
    self.bottomContainerView.backgroundColor = [UIColor blackColor];
    self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bottomContainerView];
    
    [self setupBottomContainerViewContraints];
    [self setupVideoViewConstraints];
    
    self.cameraFocusView = [[NHVideoFocusView alloc] init];
    self.cameraFocusView.backgroundColor = [UIColor clearColor];
    self.cameraFocusView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.cameraFocusView];
    [self setupCameraFocusViewConstraints];
    
    self.cameraGridView = [[NHCameraGridView alloc] init];
    self.cameraGridView.backgroundColor = [UIColor clearColor];
    self.cameraGridView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraGridView.userInteractionEnabled = NO;
    self.cameraGridView.numberOfRows = 2;
    self.cameraGridView.numberOfColumns = 2;
    self.cameraGridView.hidden = YES;
    [self.view addSubview:self.cameraGridView];

    [self setupCameraGridViewConstraints];
    
    self.cropView = [[NHVideoCropView alloc] init];
    self.cropView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cropView.userInteractionEnabled = NO;
    self.cropView.backgroundColor = [UIColor clearColor];
    self.cropView.cropBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:self.cropView];
    [self setupCropViewConstraints];
    
    self.removeFragmentButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.removeFragmentButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.removeFragmentButton.backgroundColor = [UIColor greenColor];
    [self.removeFragmentButton setTitle:nil forState:UIControlStateNormal];
    [self.removeFragmentButton addTarget:self action:@selector(removeFragmentButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.removeFragmentButton.layer.cornerRadius = 5;
    self.removeFragmentButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.removeFragmentButton];
    
    self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.captureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.captureButton setTitle:nil forState:UIControlStateNormal];
    self.captureButton.backgroundColor = [UIColor whiteColor];
    [self.captureButton addTarget:self action:@selector(captureButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [self.captureButton addTarget:self action:@selector(captureButtonFinished:)
                 forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDragExit];
    self.captureButton.layer.cornerRadius = kNHRecorderCaptureButtonHeight / 2;
    self.captureButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.captureButton];
    
    [self setupRemoveFragmentButtonConstraints];
    [self setupCaptureButtonConstraints];
    
    self.durationProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.durationProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationProgressView.progressTintColor = [UIColor redColor];
    self.durationProgressView.backgroundColor = [UIColor darkGrayColor];
    [self.bottomContainerView addSubview:self.durationProgressView];
    
    [self setupDurationProgressViewConstraints];
    
    self.captureManager = [[CaptureManager alloc] init];
    self.captureManager.delegate = self;
    
    if ([self.captureManager setupSession]) {
        self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureManager.session];
        
        if ([self.videoPreviewLayer.connection isVideoOrientationSupported]) {
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        
        [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [self.videoCameraView.layer insertSublayer:self.videoPreviewLayer atIndex:0];
        
        self.cameraFocusView.captureManager = self.captureManager;
    }
    
    self.backButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(0, 0, 44, 44);
    self.backButton.tintColor = [UIColor whiteColor];
    [self.backButton setImage:image(@"NHRecorder.back") forState:UIControlStateNormal];
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.backButton addTarget:self action:@selector(backButtonTouch:) forControlEvents:UIControlEventTouchUpInside];

    self.switchButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.switchButton.frame = CGRectMake(0, 0, 44, 44);
    self.switchButton.tintColor = [UIColor whiteColor];
    self.switchButton.customAlignmentInsets = UIEdgeInsetsMake(0, 22, 0, 0);
    [self.switchButton setImage:image(@"NHRecorder.switch") forState:UIControlStateNormal];
    self.switchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.switchButton addTarget:self action:@selector(switchButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.gridButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.gridButton.frame = CGRectMake(0, 0, 44, 44);
    self.gridButton.tintColor = [UIColor whiteColor];
    self.gridButton.customAlignmentInsets = UIEdgeInsetsMake(0, 0, 0, 22);
    [self.gridButton setImage:[image(@"NHRecorder.grid")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.gridButton setImage:[image(@"NHRecorder.grid-active")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    self.gridButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.gridButton addTarget:self action:@selector(gridButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    UIBarButtonItem *gridBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.gridButton];
    UIBarButtonItem *switchBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.switchButton];
    
    self.navigationItem.leftBarButtonItems = @[closeBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               switchBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               gridBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil]];


    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:localization(@"NHRecorder.button.done", @"NHRecorder")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(nextButtonTouch:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@" "
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    [self resetGrid];
    self.currentDuration = 0;
    
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
                                             [strongSelf stopCapture];
//                                             [strongSelf stopCamera];
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

- (void)startCamera {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureManager.session startRunning];
    });
}

- (void)stopCamera {
    [self.captureManager.session stopRunning];
}

- (void)startCapture {
    if (![self.captureManager.recorder isRecording]
        && self.currentDuration < kNHVideoMaxDuration) {
//        [self deviceOrientationChange];
        [self.captureManager startRecording];
        self.captureButton.selected = YES;
    }
    
    
}

- (void)stopCapture {
    if ([self.captureManager.recorder isRecording]) {
        [self.captureManager stopRecording];
        self.captureButton.selected = NO;
    }
    
    [self stopTimer];
}

- (void)startTimer {
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:kNHVideoTimerInterval target:self
                                                      selector:@selector(updateCaptureDuration:)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopTimer {
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}

- (void)saveVideo {
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startCamera];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopCapture];
    [self stopCamera];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.videoPreviewLayer.frame = self.videoCameraView.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupBottomContainerViewContraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:0 constant:kNHRecorderBottomViewHeight]];
}

- (void)setupRemoveFragmentButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.removeFragmentButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.removeFragmentButton
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:25]];
    
    [self.removeFragmentButton addConstraint:[NSLayoutConstraint constraintWithItem:self.removeFragmentButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.removeFragmentButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:kNHRecorderSideButtonHeight]];
    
    [self.removeFragmentButton addConstraint:[NSLayoutConstraint constraintWithItem:self.removeFragmentButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.removeFragmentButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
}

- (void)setupCaptureButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0 constant:0]];
    
    [self.captureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.captureButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:kNHRecorderCaptureButtonHeight]];
    
    [self.captureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.captureButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
    UIView *captureButtonBorder = [[UIView alloc] init];
    captureButtonBorder.translatesAutoresizingMaskIntoConstraints = NO;
    captureButtonBorder.layer.borderWidth = 2;
    captureButtonBorder.layer.borderColor = [UIColor whiteColor].CGColor;
    captureButtonBorder.layer.cornerRadius = (kNHRecorderCaptureButtonHeight + 2 * kNHRecorderCaptureButtonBorderOffset) / 2;
    captureButtonBorder.userInteractionEnabled = NO;
    captureButtonBorder.backgroundColor = [UIColor clearColor];
    [self.bottomContainerView addSubview:captureButtonBorder];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureButton
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:-kNHRecorderCaptureButtonBorderOffset]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureButton
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:-kNHRecorderCaptureButtonBorderOffset]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureButton
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:kNHRecorderCaptureButtonBorderOffset]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureButton
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0 constant:kNHRecorderCaptureButtonBorderOffset]];
}

- (void)setupDurationProgressViewConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationProgressView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationProgressView
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationProgressView
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:0]];
    
    [self.durationProgressView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationProgressView
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.durationProgressView
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:0 constant:1.5]];
}

- (void)setupVideoViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:-1]];
    
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
                                                             toItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraGridViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraFocusViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCropViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0 constant:0]];
}

- (void)deviceOrientationChange {
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    CGFloat angle = 0;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            self.captureManager.orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.captureManager.orientation = AVCaptureVideoOrientationLandscapeRight;
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            self.captureManager.orientation = AVCaptureVideoOrientationLandscapeLeft;
            angle = -M_PI_2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.captureManager.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            angle = M_PI;
            break;
        default:
            return;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.gridButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.switchButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.removeFragmentButton.transform = CGAffineTransformMakeRotation(angle);
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)backButtonTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gridButtonTouch:(id)sender {
    self.cameraGridView.hidden = !self.cameraGridView.hidden;
    [self resetGrid];
}

- (void)switchButtonTouch:(id)sender {
    [self.captureManager switchCamera];
}


- (void)nextButtonTouch:(id)sender {
    [self.captureManager saveVideoWithCompletionBlock:^(BOOL success) {
        if (success) {
            NSLog(@"suc");
            
            [self resetRecorder];
        }
        else {
            NSLog(@"fail");
        }
    }];
}

- (void)captureButtonPressed:(id)sender {
    [self startCapture];
}

- (void)captureButtonFinished:(id)sender {
    [self stopCapture];
}

- (void)removeFragmentButtonTouch:(id)sender {
    [self.captureManager deleteLastAsset];
}

- (void)removeTimeFromDuration:(float)removeTime {
    self.currentDuration = MAX(0, self.currentDuration - removeTime);
}

- (void)captureManagerRecordingBegan:(CaptureManager *)captureManager {
    NSLog(@"st");
    [self startTimer];
    self.captureButton.backgroundColor = [UIColor redColor];
    
    //delegate for start
}

- (void)updateCaptureDuration:(NSTimer *)timer {
    if ([[[self captureManager] recorder] isRecording])
    {
        self.currentDuration += kNHVideoTimerInterval;
    }
    else
    {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
}

- (void)captureManagerRecordingFinished:(CaptureManager *)captureManager {
    NSLog(@"fi");
    self.captureButton.backgroundColor = [UIColor whiteColor];
    
    //delegate for end
}

- (void)updateProgress {
 //self.captureManager.exportSession.progress
}

- (void)removeProgress {
    NSLog(@"Saving to Camera Roll");
}

- (void)resetGrid {
    self.gridButton.selected = !self.cameraGridView.hidden;
}

- (void)resetRecorder {
    [self stopCapture];
    self.currentDuration = 0;
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

- (void)setCurrentDuration:(NSTimeInterval)currentDuration {
    [self willChangeValueForKey:@"currentDuration"];
    _currentDuration = currentDuration;
    
    self.durationProgressView.progress = currentDuration / kNHVideoMaxDuration;
    self.navigationItem.rightBarButtonItem.enabled = currentDuration >= kNHVideoMinDuration;
    if (self.currentDuration >= kNHVideoMaxDuration) {
        [self stopCapture];
    }
    [self didChangeValueForKey:@"currentDuration"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
