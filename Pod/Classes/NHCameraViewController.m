//
//  NHCameraViewController.m
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import "NHCameraViewController.h"
#import "NHCameraGridView.h"

@interface NHCameraViewController ()

@property (nonatomic, strong) UIView *cameraRecorderView;
@property (nonatomic, strong) SCRecorderToolsView *cameraRecorderToolsView;
@property (nonatomic, strong) SCRecorder *cameraRecorder;

@property (nonatomic, strong) UIView *menuContainer;
@property (nonatomic, strong) UIButton *gridButton;
@property (nonatomic, strong) UIButton *frontCameraButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, assign) SCFlashMode flashMode;

@property (nonatomic, strong) NHCameraGridView *gridView;

@property (nonatomic, strong) UIView *menuContentContainer;

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
        self.flashMode = SCFlashModeAuto;
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
 
    [self setupMenuContentView];
    [self setupGridView];
    [self setupMenuView];
    
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
    self.cameraRecorderToolsView.insideFocusTargetImage = [UIImage imageNamed:@"NHRecorder.focus"];
    self.cameraRecorderToolsView.outsideFocusTargetImage = [UIImage imageNamed:@"NHRecorder.focus"];
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

- (void)setupMenuView {
    self.menuContainer = [[UIView alloc] init];
    [self.menuContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.menuContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    [self.view addSubview:self.menuContainer];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuContainer
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.menuContentContainer
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuContainer
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuContainer
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.menuContainer
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.menuContainer
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:0 constant:45]];
    
    self.gridButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.gridButton setTitle:@"gn" forState:UIControlStateNormal];
    [self.gridButton setTitle:@"g" forState:UIControlStateSelected];
    [self.gridButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.gridButton.backgroundColor = [UIColor redColor];
    [self.gridButton addTarget:self action:@selector(gridButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContainer addSubview:self.gridButton];
    [self resetGrid];
    
    self.frontCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.frontCameraButton setTitle:@"cn" forState:UIControlStateNormal];
    [self.frontCameraButton setTitle:@"c" forState:UIControlStateSelected];
    [self.frontCameraButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.frontCameraButton.backgroundColor = [UIColor greenColor];
    [self.frontCameraButton addTarget:self action:@selector(frontCameraButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContainer addSubview:self.frontCameraButton];
    [self resetCamera];
    
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.flashButton.backgroundColor = [UIColor blueColor];
    [self.flashButton addTarget:self action:@selector(flashButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContainer addSubview:self.flashButton];
    [self resetFlash];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.gridButton
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.gridButton
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.frontCameraButton
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.frontCameraButton
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.flashButton
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.flashButton
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.gridButton
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.gridButton
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.frontCameraButton
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.frontCameraButton
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.flashButton
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.flashButton
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.gridButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.frontCameraButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.frontCameraButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.flashButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
}

- (void)setupMenuContentView {
    self.menuContentContainer = [[UIView alloc] init];
    [self.menuContentContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.menuContentContainer.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.menuContentContainer];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuContentContainer
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuContentContainer
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuContentContainer
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.menuContentContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.menuContentContainer
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.menuContentContainer
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:0 constant:100]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.menuContentContainer
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)setupGridView {
    self.gridView = [[NHCameraGridView alloc] init];
    [self.gridView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.numberOfColumns = 2;
    self.gridView.numberOfRows = 2;
    [self.view addSubview:self.gridView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.menuContentContainer
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}


//MARK: Menu buttons

- (void)gridButtonTouch:(id)sender {
    self.gridButton.selected = !self.gridButton.selected;
    [self resetGrid];
}

- (void)frontCameraButtonTouch:(id)sender {
    self.frontCameraButton.selected = !self.frontCameraButton.selected;
    [self resetCamera];
}

- (void)flashButtonTouch:(id)sender {
    switch (self.flashMode) {
        case SCFlashModeAuto:
            self.flashMode = SCFlashModeOn;
            break;
        case SCFlashModeOn:
            self.flashMode = SCFlashModeOff;
            break;
        default:
            self.flashMode = SCFlashModeAuto;
            break;
    }
    
    [self resetFlash];
}

- (void)resetGrid {
    self.gridView.hidden = !self.gridButton.selected;
}

- (void)resetCamera {
    AVCaptureDevicePosition newPosition = self.frontCameraButton.selected
    ? AVCaptureDevicePositionFront
    : AVCaptureDevicePositionBack;
    
    if (self.cameraRecorder.device != newPosition) {
        self.cameraRecorder.device = newPosition;
    }
}

- (void)resetFlash {
    switch (self.flashMode) {
        case SCFlashModeOn:
            [self.flashButton setTitle:@"on" forState:UIControlStateNormal];
            break;
        case SCFlashModeOff:
            [self.flashButton setTitle:@"off" forState:UIControlStateNormal];
            break;
        default:
            [self.flashButton setTitle:@"auto" forState:UIControlStateNormal];
            break;
    }
    
    self.cameraRecorder.flashMode = self.flashMode;
}

//MARK: Menu container buttons

//MARK: View overrides

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
