//
//  NHCameraViewController.m
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import "NHPhotoCaptureViewController.h"
#import "NHCameraGridView.h"
#import "NHPhotoEditorViewController.h"
#import <GPUImage.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface NHPhotoCaptureViewController ()

@property (nonatomic, strong) GPUImageView *photoCameraView;
@property (nonatomic, strong) GPUImageStillCamera *photoCamera;

@property (nonatomic, strong) UIView *menuContainer;
@property (nonatomic, strong) UIView *menuSeparator;
@property (nonatomic, strong) UIButton *gridButton;
@property (nonatomic, strong) UIButton *frontCameraButton;
@property (nonatomic, strong) UIButton *flashButton;

//@property (nonatomic, assign) SCFlashMode flashMode;

@property (nonatomic, strong) NHCameraGridView *gridView;

@property (nonatomic, strong) UIView *menuContentContainer;

@property (nonatomic, strong) UIButton *libraryButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *cameraModeButton;

@property (nonatomic, strong) GPUImageFilter *emptyFilter;
@property (nonatomic, strong) GPUImageTransformFilter *transformFilter;
@end

@implementation NHPhotoCaptureViewController

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
//
    self.photoCamera = [[GPUImageStillCamera alloc] init];
    self.emptyFilter = [[GPUImageFilter alloc] init];
    self.transformFilter = [[GPUImageTransformFilter alloc] init];
//    [self.transformFilter setAffineTransform:CGAffineTransformMakeRotation(M_PI)];
    [self.photoCamera addTarget:self.emptyFilter];
    [self.emptyFilter addTarget:self.transformFilter];

    
    self.photoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//
    [self setupRecorderView];
//    self.cameraRecorder.previewView = self.cameraRecorderView;
    
//    [self setupToolsView];
//    self.cameraRecorderToolsView.recorder = self.cameraRecorder;
 
    [self setupMenuContentView];
    [self setupGridView];
    [self setupMenuView];
    
//    [self resetCameraMode];
    
    
    [self.photoCamera addTarget:self.photoCameraView];
    
//    [self.photoCamera.inputCamera setfocus]
    
//    [self.cameraRecorder prepare:nil];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

- (void)setupRecorderView {
    self.photoCameraView = [[GPUImageView alloc] init];
    [self.photoCameraView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.photoCameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:self.photoCameraView];
    self.photoCameraView.backgroundColor = [UIColor redColor];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    
}

//- (void)setupToolsView {
//    self.cameraRecorderToolsView = [[SCRecorderToolsView alloc] init];
//    [self.cameraRecorderToolsView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    self.cameraRecorderToolsView.insideFocusTargetImage = [UIImage imageNamed:@"NHRecorder.focus"];
//    self.cameraRecorderToolsView.outsideFocusTargetImage = [UIImage imageNamed:@"NHRecorder.focus"];
//    [self.cameraRecorderView addSubview:self.cameraRecorderToolsView];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderToolsView
//                                                          attribute:NSLayoutAttributeTop
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.cameraRecorderView
//                                                          attribute:NSLayoutAttributeTop
//                                                         multiplier:1.0 constant:0]];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderToolsView
//                                                          attribute:NSLayoutAttributeBottom
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.cameraRecorderView
//                                                          attribute:NSLayoutAttributeBottom
//                                                         multiplier:1.0 constant:0]];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderToolsView
//                                                          attribute:NSLayoutAttributeLeft
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.cameraRecorderView
//                                                          attribute:NSLayoutAttributeLeft
//                                                         multiplier:1.0 constant:0]];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraRecorderToolsView
//                                                          attribute:NSLayoutAttributeRight
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.cameraRecorderView
//                                                          attribute:NSLayoutAttributeRight
//                                                         multiplier:1.0 constant:0]];
//}

- (void)setupMenuView {
    self.menuContainer = [[UIView alloc] init];
    [self.menuContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.menuContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.menuContainer
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    self.gridButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.gridButton setTitle:@"gn" forState:UIControlStateNormal];
    [self.gridButton setTitle:@"g" forState:UIControlStateSelected];
    [self.gridButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.gridButton.backgroundColor = [UIColor clearColor];
    [self.gridButton addTarget:self action:@selector(gridButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContainer addSubview:self.gridButton];
    [self resetGrid];
    
    self.frontCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.frontCameraButton setTitle:@"cn" forState:UIControlStateNormal];
    [self.frontCameraButton setTitle:@"c" forState:UIControlStateSelected];
    [self.frontCameraButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.frontCameraButton.backgroundColor = [UIColor clearColor];
    [self.frontCameraButton addTarget:self action:@selector(frontCameraButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContainer addSubview:self.frontCameraButton];
    [self resetCamera];
    
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.flashButton.backgroundColor = [UIColor clearColor];
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
    
    self.menuSeparator = [[UIView alloc] init];
    self.menuSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    self.menuSeparator.backgroundColor = [UIColor whiteColor];
    
    [self.menuContainer addSubview:self.menuSeparator];
    
    [self.menuSeparator addConstraint:[NSLayoutConstraint constraintWithItem:self.menuSeparator
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuSeparator
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:0.5]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.menuSeparator
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.menuSeparator
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0 constant:0]];
    
    [self.menuContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.menuSeparator
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.menuContainer
                                                                   attribute:NSLayoutAttributeRight
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
                                                                         multiplier:0 constant:80]];
    

    
    self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.captureButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.captureButton addTarget:self action:@selector(captureButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.captureButton.backgroundColor = [UIColor redColor];
    
    [self.menuContentContainer addSubview:self.captureButton];
    
    [self.menuContentContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.menuContentContainer
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0 constant:0]];
    
    [self.menuContentContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.menuContentContainer
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0 constant:0]];
    
    [self.captureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.captureButton
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:0 constant:75]];

    
    [self.captureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButton
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.captureButton
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:1.0 constant:0]];
    
    self.libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.libraryButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.libraryButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.libraryButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.libraryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.libraryButton.backgroundColor = [UIColor clearColor];
    self.libraryButton.layer.cornerRadius = 5;
    self.libraryButton.clipsToBounds = YES;
    [self.libraryButton addTarget:self action:@selector(libraryButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuContentContainer addSubview:self.libraryButton];
    [self resetLibrary];
    
    [self.menuContentContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeLeft
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.menuContentContainer
                                                                          attribute:NSLayoutAttributeLeft
                                                                         multiplier:1.0 constant:15]];
    
    [self.menuContentContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.menuContentContainer
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0 constant:0]];
    
    [self.libraryButton addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.libraryButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:0 constant:50]];
    
    
    [self.libraryButton addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.libraryButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
    
    self.cameraModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cameraModeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.cameraModeButton.backgroundColor = [UIColor blueColor];
    [self.menuContentContainer addSubview:self.cameraModeButton];
    [self.cameraModeButton addTarget:self action:@selector(cameraModeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];

    [self.menuContentContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraModeButton
                                                                          attribute:NSLayoutAttributeRight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.menuContentContainer
                                                                          attribute:NSLayoutAttributeRight
                                                                         multiplier:1.0 constant:-15]];
    
    [self.menuContentContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraModeButton
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.menuContentContainer
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0 constant:0]];
    
    [self.cameraModeButton addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraModeButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.cameraModeButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:0 constant:50]];
    
    
    [self.cameraModeButton addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraModeButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.cameraModeButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
    
}

- (void)setupGridView {
    self.gridView = [[NHCameraGridView alloc] init];
    self.gridView.userInteractionEnabled = NO;
    [self.gridView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.numberOfColumns = 2;
    self.gridView.numberOfRows = 2;
    [self.view addSubview:self.gridView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0.5]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0.5]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0.5]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.gridView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:-0.5]];
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
//    switch (self.flashMode) {
//        case SCFlashModeAuto:
//            self.flashMode = SCFlashModeOn;
//            break;
//        case SCFlashModeOn:
//            self.flashMode = SCFlashModeOff;
//            break;
//        default:
//            self.flashMode = SCFlashModeAuto;
//            break;
//    }
    
    [self resetFlash];
}

- (void)resetGrid {
    self.gridView.hidden = !self.gridButton.selected;
}

- (void)resetCamera {
    AVCaptureDevicePosition newPosition = self.frontCameraButton.selected
    ? AVCaptureDevicePositionFront
    : AVCaptureDevicePositionBack;
    
    if (self.photoCamera.cameraPosition != newPosition) {
        [self.photoCamera rotateCamera];
    }
}

- (void)resetFlash {
//    switch (self.flashMode) {
//        case SCFlashModeOn:
//            [self.flashButton setTitle:@"on" forState:UIControlStateNormal];
//            break;
//        case SCFlashModeOff:
//            [self.flashButton setTitle:@"off" forState:UIControlStateNormal];
//            break;
//        default:
//            [self.flashButton setTitle:@"auto" forState:UIControlStateNormal];
//            break;
//    }
//    
//    self.cameraRecorder.flashMode = self.flashMode;
}

//MARK: Menu container buttons


- (void)captureButtonTouch:(id)sender {
//    if ([self.cameraRecorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
//        
//        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    
//    self.photoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
    
//    [self.emptyFilter useNextFrameForImageCapture];
//    UIImage* image = [self.emptyFilter imageFromCurrentFramebuffer];
//    
//    if (image) {
//        
//        UIImage *resultImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeft];
//        NHPhotoEditorViewController *controller = [[NHPhotoEditorViewController alloc] initWithUIImage:resultImage];
//        [self.navigationController pushViewController:controller animated:YES];
//    }

    

    [self.photoCamera capturePhotoAsImageProcessedUpToFilter:self.transformFilter
                                       withCompletionHandler:^(UIImage *image, NSError *error) {
        if (error
            || !image) {
            return;
        }
                                           
                                           
                                           NHPhotoEditorViewController *controller = [[NHPhotoEditorViewController alloc] initWithUIImage:image];
                                           [self.navigationController pushViewController:controller animated:YES];

    }];
//        [self.cameraRecorder capturePhoto:^(NSError *error, UIImage *image) {
//            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
//            if (error
//                || !image) {
//                return;
//            }
//            NHPhotoEditorViewController *controller = [[NHPhotoEditorViewController alloc] initWithUIImage:image];
//            [self.navigationController pushViewController:controller animated:YES];
//        }];
//    }
//    else {
//        if (!self.cameraRecorder.isRecording) {
//            [self.cameraRecorder.session cancelSession:nil];
//            self.cameraRecorder.session = nil;
//            SCRecordSession *session = [SCRecordSession recordSession];
//            session.fileType = AVFileTypeQuickTimeMovie;
//            self.cameraRecorder.session = session;
//            
//            
//            self.captureButton.backgroundColor = [UIColor brownColor];
//            self.cameraModeButton.enabled = NO;
//            [self.cameraRecorder record];
//        }
//        else {
//            self.captureButton.backgroundColor = [UIColor redColor];
//            self.cameraModeButton.enabled = YES;
//            [self.cameraRecorder pause:^{
//                
//                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];                
//                void(^completionHandler)(NSURL *url, NSError *error) = ^(NSURL *url, NSError *error) {
//                    if (error == nil) {
//                        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, @selector(savedCapturedVideo:didFinishSavingWithError:contextInfo:), nil);
//                    } else {
//                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//                        
//                        [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//                    }
//                };
//                
//                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//                
//                SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.cameraRecorder.session.assetRepresentingSegments];
//                exportSession.videoConfiguration.preset = SCPresetHighestQuality;
//                exportSession.audioConfiguration.preset = SCPresetHighestQuality;
//                exportSession.videoConfiguration.maxFrameRate = 35;
//                exportSession.outputUrl = self.cameraRecorder.session.outputUrl;
//                exportSession.outputFileType = AVFileTypeMPEG4;
//                
//                exportSession.videoConfiguration.sizeAsSquare = NO;
//                [exportSession exportAsynchronouslyWithCompletionHandler:^{
//                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//                    completionHandler(exportSession.outputUrl, exportSession.error);
//                }];
//            }];
//        }
//
//    }
}


- (void)savedCapturedVideo:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (error == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)libraryButtonTouch:(id)sender {
    
}

- (void)resetLibrary {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                      usingBlock:^(ALAsset *result,
                                                                   NSUInteger index,
                                                                   BOOL *stop) {
                                                          
                                                          if (result) {
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
                               NSLog(@"resetLibrary - enumerate groups - %@", error);
                           }];
}

- (void)cameraModeButtonTouch:(id)sender {
//    NSString *newCameraPreset;
    
//    if ([self.cameraRecorder.captureSessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
//        newCameraPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
//    }
//    else {
//        newCameraPreset = AVCaptureSessionPresetPhoto;
//    }
//    
//    self.cameraRecorder.captureSessionPreset = newCameraPreset;
    
//    [self resetCameraMode];
}

//MARK: View overrides


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.photoCamera startCameraCapture];
    [self resetLibrary];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.photoCamera stopCameraCapture];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)dealloc {
}



@end
