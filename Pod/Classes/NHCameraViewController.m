//
//  NHCameraViewController.m
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import "NHCameraViewController.h"

@interface NHCameraViewController ()

@property (nonatomic, strong) UIView *cameraRecorderView;
@property (nonatomic, strong) SCRecorderToolsView *cameraRecorderToolsView;
@property (nonatomic, strong) SCRecorder *cameraRecorder;

@end

@implementation NHCameraViewController

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
    
    self.cameraRecorder = [SCRecorder recorder];
    self.cameraRecorder.session = [SCRecordSession recordSession];
    self.cameraRecorder.maxRecordDuration = CMTimeMake(15, 1);
    self.cameraRecorder.autoSetVideoOrientation = YES;
    if (![self.cameraRecorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        self.cameraRecorder.captureSessionPreset = AVCaptureSessionPresetPhoto;
        self.cameraRecorder.flashMode = SCFlashModeAuto;
    }
    
    //video configuration
    self.cameraRecorder.videoConfiguration.sizeAsSquare = NO;
    //photo configuration
    self.cameraRecorder.photoConfiguration.enabled = YES;
    //audio configuration
    self.cameraRecorder.audioConfiguration.enabled = YES;
    
    [self setupRecorderView];
    self.cameraRecorder.previewView = self.cameraRecorderView;
    
    [self setupToolsView];
    self.cameraRecorderToolsView.recorder = self.cameraRecorder;
 
    [self.cameraRecorder prepare:nil];
}

- (void)setupRecorderView {
    self.cameraRecorderView = [[UIView alloc] init];
    [self.cameraRecorderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.cameraRecorderView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.cameraRecorderView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
}

- (void)setupToolsView {
    self.cameraRecorderToolsView = [[SCRecorderToolsView alloc] init];
    [self.cameraRecorderToolsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.cameraRecorderView addSubview:self.cameraRecorderToolsView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderToolsView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cameraRecorderView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderToolsView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cameraRecorderView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderToolsView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cameraRecorderView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderToolsView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cameraRecorderView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.cameraRecorder startRunning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.cameraRecorder.previewView = self.cameraRecorderView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
