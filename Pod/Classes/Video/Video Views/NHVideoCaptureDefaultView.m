//
//  NHDefaultVideoCaptureView.m
//  Pods
//
//  Created by Sergey Minakov on 28.08.15.
//
//

#import "NHVideoCaptureDefaultView.h"
#import "NHVideoFocusView.h"
#import "NHCameraGridView.h"
#import "NHRecorderProgressView.h"
#import "NHCameraCropView.h"
#import "NHRecorderButton.h"
#import "AVCamRecorder.h"
#import "NHPhotoCaptureDefaultView.h"

@import AVFoundation;
@import AssetsLibrary;

const NSTimeInterval kNHVideoTimerInterval = 0.05;
const NSTimeInterval kNHVideoMaxDuration = 15.0;
const NSTimeInterval kNHVideoMinDuration = 2.0;

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHVideoCaptureDefaultView class]]\
pathForResource:name ofType:@"png"]]

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHVideoCaptureDefaultView class]], nil)

@interface NHVideoCaptureDefaultView ()

@property (nonatomic, strong) UIView *videoCameraView;
@property (nonatomic, strong) NHCameraGridView *cameraGridView;


@property (nonatomic, strong) UIView *bottomContainerView;
@property (nonatomic, strong) NHRecorderButton *removeFragmentButton;
@property (nonatomic, strong) UIView *captureView;

@property (nonatomic, strong) NHRecorderButton *libraryButton;

@property (nonatomic, strong) NHRecorderButton *closeButton;
@property (nonatomic, strong) NHRecorderButton *gridButton;
@property (nonatomic, strong) NHRecorderButton *switchButton;

@property (nonatomic, strong) NHRecorderProgressView *durationProgressView;

@property (nonatomic, assign) NSTimeInterval currentDuration;

@property (nonatomic, strong) NHCameraCropView *cropView;

@property (nonatomic, strong) NHVideoFocusView *focusView;

@property (nonatomic, strong) NSTimer *recordTimer;

@property (nonatomic, strong) UILongPressGestureRecognizer *longGestureRecognizer;

@end

@implementation NHVideoCaptureDefaultView


- (void)willShowView {
    self.viewController.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor blackColor];
    self.viewController.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor whiteColor];

    [self.viewController.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.viewController.navigationController.navigationBar setShadowImage:[UIImage new]];
}


- (void)changeOrientationTo:(UIDeviceOrientation)orientation {

        CGFloat angle = 0;
    
        switch (orientation) {
            case UIDeviceOrientationPortrait:
//                self.captureManager.orientation = AVCaptureVideoOrientationPortrait;
                break;
            case UIDeviceOrientationLandscapeLeft:
//                self.captureManager.orientation = AVCaptureVideoOrientationLandscapeRight;
                angle = M_PI_2;
                break;
            case UIDeviceOrientationLandscapeRight:
//                self.captureManager.orientation = AVCaptureVideoOrientationLandscapeLeft;
                angle = -M_PI_2;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
//                self.captureManager.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
                angle = M_PI;
                break;
            default:
                return;
        }
                         self.gridButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.switchButton.imageView.transform = CGAffineTransformMakeRotation(angle);
                         self.removeFragmentButton.transform = CGAffineTransformMakeRotation(angle);
                         self.libraryButton.transform = CGAffineTransformMakeRotation(angle);
}

- (void)setupView {
    
    self.viewController.view.backgroundColor = [UIColor blackColor];
    
        self.videoCameraView = [[UIView alloc] init];
        self.videoCameraView.backgroundColor = [UIColor blackColor];
        self.videoCameraView.translatesAutoresizingMaskIntoConstraints = NO;
        self.videoCameraView.userInteractionEnabled = NO;
        self.videoCameraView.clipsToBounds = YES;
        self.videoCameraView.layer.masksToBounds = YES;
        [self.viewController.view addSubview:self.videoCameraView];
    
        self.bottomContainerView = [[UIView alloc] init];
        self.bottomContainerView.backgroundColor = [UIColor blackColor];
        self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.viewController.view addSubview:self.bottomContainerView];
    
        [self setupBottomContainerViewContraints];
        [self setupVideoViewConstraints];
    
        self.focusView = [[NHVideoFocusView alloc] init];
        self.focusView.backgroundColor = [UIColor clearColor];
        self.focusView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.viewController.view addSubview:self.focusView];
    self.focusView.captureManager = self.viewController.captureManager;
        [self setupCameraFocusViewConstraints];
    
        self.cameraGridView = [[NHCameraGridView alloc] init];
        self.cameraGridView.backgroundColor = [UIColor clearColor];
        self.cameraGridView.translatesAutoresizingMaskIntoConstraints = NO;
        self.cameraGridView.userInteractionEnabled = NO;
        self.cameraGridView.numberOfRows = 2;
        self.cameraGridView.numberOfColumns = 2;
        self.cameraGridView.hidden = YES;
        [self.viewController.view addSubview:self.cameraGridView];
    
        [self setupCameraGridViewConstraints];
    
        self.cropView = [[NHCameraCropView alloc] init];
        self.cropView.cropType = NHPhotoCropTypeSquare;
        self.cropView.translatesAutoresizingMaskIntoConstraints = NO;
        self.cropView.userInteractionEnabled = NO;
        self.cropView.backgroundColor = [UIColor clearColor];
        self.cropView.cropBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self.viewController.view addSubview:self.cropView];
        [self setupCropViewConstraints];
    
        self.removeFragmentButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
        self.removeFragmentButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.removeFragmentButton.backgroundColor = [UIColor clearColor];
        [self.removeFragmentButton setImage:image(@"NHRecorder.remove") forState:UIControlStateNormal];
        [self.removeFragmentButton setTitle:nil forState:UIControlStateNormal];
        [self.removeFragmentButton addTarget:self action:@selector(removeFragmentButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        self.removeFragmentButton.layer.cornerRadius = 5;
        self.removeFragmentButton.clipsToBounds = YES;
        [self.bottomContainerView addSubview:self.removeFragmentButton];
    
        self.captureView = [[UIView alloc] init];
        self.captureView.translatesAutoresizingMaskIntoConstraints = NO;
        self.captureView.backgroundColor = [UIColor whiteColor];
        self.longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(captureGestureAction:)];
        self.longGestureRecognizer.minimumPressDuration = 0.15;
        self.longGestureRecognizer.numberOfTouchesRequired = 1;
        [self.captureView addGestureRecognizer:self.longGestureRecognizer];
        self.captureView.layer.cornerRadius = kNHRecorderCaptureButtonHeight / 2;
        self.captureView.clipsToBounds = YES;
        [self.bottomContainerView addSubview:self.captureView];
    
        self.libraryButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
        self.libraryButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.libraryButton.backgroundColor = [UIColor clearColor];
        [self.libraryButton setTitle:nil forState:UIControlStateNormal];
        [self.libraryButton addTarget:self action:@selector(libraryButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        self.libraryButton.layer.cornerRadius = 5;
        self.libraryButton.clipsToBounds = YES;
        [self.bottomContainerView addSubview:self.libraryButton];
    
        [self setupRemoveFragmentButtonConstraints];
        [self setupLibraryButtonConstraints];
        [self setupCaptureButtonConstraints];
        [self resetLibrary];
    
        self.durationProgressView = [[NHRecorderProgressView alloc] init];
        self.durationProgressView.translatesAutoresizingMaskIntoConstraints = NO;
        self.durationProgressView.progressColor = [UIColor redColor];
        self.durationProgressView.backgroundColor = [UIColor darkGrayColor];
        self.durationProgressView.minValue = kNHVideoMinDuration / kNHVideoMaxDuration;
        self.durationProgressView.minValueColor = [UIColor lightGrayColor];
    
        [self.bottomContainerView addSubview:self.durationProgressView];
    
        [self setupDurationProgressViewConstraints];
    
        self.closeButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
        self.closeButton.frame = CGRectMake(0, 0, 44, 44);
        self.closeButton.tintColor = [UIColor whiteColor];
        [self.closeButton setImage:([self.viewController.navigationController.viewControllers count] == 1 ? image(@"NHRecorder.close") : image(@"NHRecorder.back")) forState:UIControlStateNormal];
        self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.closeButton addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
        self.switchButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
        self.switchButton.frame = CGRectMake(0, 0, 44, 44);
        self.switchButton.tintColor = [UIColor whiteColor];
        self.switchButton.customAlignmentInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.switchButton setImage:image(@"NHRecorder.switch") forState:UIControlStateNormal];
        self.switchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.switchButton addTarget:self action:@selector(switchButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
        self.gridButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
        self.gridButton.frame = CGRectMake(0, 0, 44, 44);
        self.gridButton.tintColor = [UIColor whiteColor];
        self.gridButton.customAlignmentInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [self.gridButton setImage:[image(@"NHRecorder.grid")
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.gridButton setImage:[image(@"NHRecorder.grid-active")
                                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        self.gridButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.gridButton addTarget:self action:@selector(gridButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.closeButton];
        UIBarButtonItem *gridBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.gridButton];
        UIBarButtonItem *switchBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.switchButton];
    
        self.viewController.navigationItem.leftBarButtonItems = @[backBarButton,
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
    
    
    
        self.viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:localization(@"NHRecorder.button.next", @"NHRecorder")
                                                  style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(nextButtonTouch:)];
        
        self.viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithTitle:@" "
                                                 style:UIBarButtonItemStylePlain
                                                 target:nil
                                                 action:nil];
        
        [self resetGrid];
        self.currentDuration = 0;
}

- (void)nextButtonTouch:(id)sender {
    [self.viewController processCapturedVideo];
}

- (void)removeFragmentButtonTouch:(id)sender {
    [self.viewController removeVideoFragment];
    self.currentDuration = [self.viewController.captureManager currentDuration];
}

- (void)libraryButtonTouch:(id)sender {
    [self.viewController openVideoPicker];
}

- (void)switchButtonTouch:(id)sender {
    [self.viewController switchCamera];
}

- (void)closeButtonTouch:(id)sender {
    [self.viewController closeController];
}

- (void)stopedCapture {
    self.captureView.backgroundColor = [UIColor whiteColor];
    self.currentDuration = [self.viewController.captureManager currentDuration];
    [self.durationProgressView addSeparatorAtProgress:self.durationProgressView.progress];
}

- (void)startedCapture {
        [self startTimer];
        self.captureView.backgroundColor = [UIColor redColor];
    
}

- (BOOL)canCaptureVideo {
    return ![self.viewController.captureManager.recorder isRecording]
    && self.currentDuration < kNHVideoMaxDuration;
}


- (void)setupBottomContainerViewContraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.viewController.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.viewController.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.viewController.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];

    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:0 constant:kNHRecorderBottomViewHeight]];
}

- (void)setupLibraryButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];

    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:-25]];

    [self.libraryButton addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:0 constant:kNHRecorderSideButtonHeight]];

    [self.libraryButton addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:1.0 constant:0]];
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
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.captureView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];

    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.captureView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0 constant:0]];

    [self.captureView addConstraint:[NSLayoutConstraint constraintWithItem:self.captureView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.captureView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:kNHRecorderCaptureButtonHeight]];

    [self.captureView addConstraint:[NSLayoutConstraint constraintWithItem:self.captureView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.captureView
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
                                                                            toItem:self.captureView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:-kNHRecorderCaptureButtonBorderOffset]];

    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureView
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:-kNHRecorderCaptureButtonBorderOffset]];

    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureView
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:kNHRecorderCaptureButtonBorderOffset]];

    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:captureButtonBorder
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.captureView
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
                                                                         multiplier:0 constant:3]];
}

- (void)setupVideoViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.viewController.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:-1]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.viewController.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.viewController.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraGridViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraFocusViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.focusView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.focusView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.focusView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.focusView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.videoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCropViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0 constant:0]];

    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cropView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.videoCameraView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0 constant:0]];
}



- (void)gridButtonTouch:(id)sender {
    self.cameraGridView.hidden = !self.cameraGridView.hidden;
    [self resetGrid];
}


- (void)captureGestureAction:(UILongPressGestureRecognizer*)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            if (CGRectContainsPoint(self.captureView.bounds, [recognizer locationInView:self.captureView])) {
                [self.viewController startCapture];
            }
            else {
                [self.viewController stopCapture];
            }
            break;
        default:
            [self.viewController stopCapture];
            break;
    }
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

- (void)updateCaptureDuration:(NSTimer *)timer {
    if ([[self.viewController.captureManager recorder] isRecording])
    {
        self.currentDuration += kNHVideoTimerInterval;
    }
    else
    {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
}

- (void)resetGrid {
    self.gridButton.selected = !self.cameraGridView.hidden;
}


- (void)resetLibrary {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                      usingBlock:^(ALAsset *result,
                                                                   NSUInteger index,
                                                                   BOOL *stop) {

                                                          if (result
                                                              && [[result valueForProperty:ALAssetPropertyType]
                                                                  isEqualToString:ALAssetTypeVideo]) {
                                                                  UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];

                                                                  if (image) {
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          [self.libraryButton setImage:image forState:UIControlStateNormal];
                                                                      });

                                                                      *stop = YES;
                                                                  }
                                                              }

                                                      }];
                           } failureBlock:^(NSError *error) {
                               [self.libraryButton setImage:image(@"NHRecorder.video.error") forState:UIControlStateNormal];
                           }];
}


- (void)setCurrentDuration:(NSTimeInterval)currentDuration {
    [self willChangeValueForKey:@"currentDuration"];
    _currentDuration = currentDuration;

    self.durationProgressView.progress = currentDuration / kNHVideoMaxDuration;
    self.viewController.navigationItem.rightBarButtonItem.enabled = [self nextButtonEnabled];
    if (self.currentDuration >= kNHVideoMaxDuration) {
        [self.viewController stopCapture];
    }
    [self didChangeValueForKey:@"currentDuration"];
}

- (BOOL)nextButtonEnabled {
    return self.currentDuration >= kNHVideoMinDuration;
}


- (UIView *)videoCaptureView {
    return self.videoCameraView;
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barTintColor = barTintColor;
    self.viewController.navigationController.navigationBar.barTintColor = barTintColor ?: [UIColor blackColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setBarButtonTintColor:(UIColor *)barButtonTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barButtonTintColor = barButtonTintColor;
    self.viewController.navigationController.navigationBar.tintColor = barButtonTintColor ?: [UIColor whiteColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (BOOL)statusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
