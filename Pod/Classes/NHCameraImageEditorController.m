//
//  NHCameraImageEditorController.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHCameraImageEditorController.h"

@interface NHCameraImageEditorController ()

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) SCFilterSelectorView *filterImageView;

@property (nonatomic, strong) UIView *menuContainer;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *cropButton;
@property (nonatomic, strong) UIButton *optionsButton;

@property (nonatomic, strong) UIView *menuContentContainer;

@end

@implementation NHCameraImageEditorController

- (instancetype)initWithUIImage:(UIImage*)image {
    self = [super init];
    
    if (self) {
        _image = image;
        [self commonInit];
    }
    
    return self;
}
//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    
//    if (self) {
//        [self commonInit];
//    }
//    
//    return self;
//}

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    
//    if (self) {
//        [self commonInit];
//    }
//    
//    return self;
//}

- (void)commonInit {
    self.view.backgroundColor = [UIColor whiteColor];
    
//    self.cameraRecorder = [SCRecorder recorder];
//    self.cameraRecorder.session = [SCRecordSession recordSession];
//    self.cameraRecorder.maxRecordDuration = CMTimeMake(15, 1);
//    self.cameraRecorder.autoSetVideoOrientation = YES;
//    if (![self.cameraRecorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
//        self.cameraRecorder.captureSessionPreset = AVCaptureSessionPresetPhoto;
//        self.cameraRecorder.flashMode = SCFlashModeAuto;
//        self.flashMode = SCFlashModeAuto;
//    }
//    
//    //video configuration
//    self.cameraRecorder.videoConfiguration.sizeAsSquare = NO;
//    //photo configuration
//    self.cameraRecorder.photoConfiguration.enabled = YES;
//    //audio configuration
//    self.cameraRecorder.audioConfiguration.enabled = YES;
//    
//    [self setupRecorderView];
//    self.cameraRecorder.previewView = self.cameraRecorderView;
//
    
    [self setupFilterView];
//    [self setupToolsView];
//    self.cameraRecorderToolsView.recorder = self.cameraRecorder;
//    
    [self setupMenuContentView];
//    [self setupGridView];
    [self setupMenuView];
//
//    [self resetCameraMode];
//    
//    [self.cameraRecorder prepare:nil];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)setupFilterView {
    self.filterImageView = [[SCFilterSelectorView alloc] init];
    self.filterImageView.backgroundColor = [UIColor redColor];
    [self.filterImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.filterImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.filterImageView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
}

- (void)setupMenuContentView {
    
    self.menuContentContainer = [[UIView alloc] init];
    [self.menuContentContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.menuContentContainer.backgroundColor = [UIColor greenColor];
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
}

- (void)setupMenuView {
    self.menuContainer = [[UIView alloc] init];
    [self.menuContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.menuContainer.backgroundColor = [UIColor blueColor];
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.menuContainer
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
