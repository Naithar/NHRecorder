//
//  NHPhotoDefaultCaptureView.m
//  Pods
//
//  Created by Sergey Minakov on 31.07.15.
//
//

#import "NHPhotoCaptureDefaultView.h"
#import "NHCameraGridView.h"
#import "NHPhotoFocusView.h"

@import AssetsLibrary;

const CGFloat kNHRecorderBottomViewHeight = 90;
const CGFloat kNHRecorderCaptureButtonHeight = 60;
const CGFloat kNHRecorderSideButtonHeight = 50;
const CGFloat kNHRecorderCaptureButtonBorderOffset = 5;

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHPhotoCaptureDefaultView class]]\
pathForResource:name ofType:@"png"]]

@interface NHPhotoCaptureDefaultView ()

@property (nonatomic, strong) GPUImageView *photoView;

@property (nonatomic, strong) NHCameraGridView *cameraGridView;
@property (nonatomic, strong) NHPhotoFocusView *cameraFocusView;
@property (nonatomic, strong) UIView *bottomContainerView;

@property (nonatomic, strong) NHRecorderButton *closeButton;
@property (nonatomic, strong) NHRecorderButton *flashButton;
@property (nonatomic, strong) NHRecorderButton *gridButton;
@property (nonatomic, strong) NHRecorderButton *switchButton;

@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) NHRecorderButton *libraryButton;
@property (nonatomic, strong) NHRecorderButton *videoCaptureButton;

@property (nonatomic, strong) GPUImageCropFilter *photoCropFilter;

@end

@implementation NHPhotoCaptureDefaultView

- (void)setupNavigationItem {
    self.closeButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.frame = CGRectMake(0, 0, 44, 44);
    self.closeButton.tintColor = [UIColor whiteColor];
    [self.closeButton setImage:([self.viewController.navigationController.viewControllers count] == 1
                                ? image(@"NHRecorder.close")
                                : image(@"NHRecorder.back")) forState:UIControlStateNormal];
    self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.closeButton addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.flashButton.frame = CGRectMake(0, 0, 44, 44);
    self.flashButton.tintColor = [UIColor whiteColor];
    [self.flashButton setImage:[image(@"NHRecorder.flash")
                                imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    self.flashButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.flashButton addTarget:self action:@selector(flashButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.gridButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.gridButton.frame = CGRectMake(0, 0, 44, 44);
    self.gridButton.tintColor = [UIColor whiteColor];
    [self.gridButton setImage:[image(@"NHRecorder.grid")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.gridButton setImage:[image(@"NHRecorder.grid-active")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    self.gridButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.gridButton addTarget:self action:@selector(gridButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.switchButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.switchButton.frame = CGRectMake(0, 0, 44, 44);
    self.switchButton.tintColor = [UIColor whiteColor];
    [self.switchButton setImage:image(@"NHRecorder.switch") forState:UIControlStateNormal];
    self.switchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.switchButton addTarget:self action:@selector(switchButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.closeButton];
    UIBarButtonItem *flashBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.flashButton];
    UIBarButtonItem *gridBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.gridButton];
    UIBarButtonItem *switchBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.switchButton];
    
    self.viewController.navigationItem.leftBarButtonItems = @[closeBarButton,
                                                              [[UIBarButtonItem alloc]
                                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                               target:nil action:nil],
                                                              flashBarButton,
                                                              [[UIBarButtonItem alloc]
                                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                               target:nil action:nil],
                                                              gridBarButton,
                                                              [[UIBarButtonItem alloc]
                                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                               target:nil action:nil],
                                                              switchBarButton];
    
    
    
    self.viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                            initWithTitle:@" "
                                                            style:UIBarButtonItemStylePlain
                                                            target:nil
                                                            action:nil];
}

- (void)setupCameraView {
    self.photoView = [[GPUImageView alloc] init];
    self.photoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.photoView.backgroundColor = [UIColor blackColor];
    self.photoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoView.userInteractionEnabled = NO;
    [self.viewController.view addSubview:self.photoView];
    [self.photoCropFilter addTarget:self.photoView];
    
    self.bottomContainerView = [[UIView alloc] init];
    self.bottomContainerView.backgroundColor = [UIColor blackColor];
    self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.viewController.view addSubview:self.bottomContainerView];
    
    [self setupBottomContainerViewContraints];
    [self setupCameraViewConstraints];
    
}

- (void)setupFocusAndGridView {
    self.cameraFocusView = [[NHPhotoFocusView alloc] init];
    self.cameraFocusView.backgroundColor = [UIColor clearColor];
    self.cameraFocusView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraFocusView.camera = self.viewController.photoCamera;
    self.cameraFocusView.cropFilter = self.photoCropFilter;
    [self.viewController.view addSubview:self.cameraFocusView];
    
    self.cameraGridView = [[NHCameraGridView alloc] init];
    self.cameraGridView.backgroundColor = [UIColor clearColor];
    self.cameraGridView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraGridView.userInteractionEnabled = NO;
    self.cameraGridView.numberOfRows = 2;
    self.cameraGridView.numberOfColumns = 2;
    self.cameraGridView.hidden = YES;
    [self.viewController.view addSubview:self.cameraGridView];
    
    [self setupCameraFocusViewConstraints];
    [self setupCameraGridViewConstraints];
}

- (void)setupView {
    self.viewController.view.backgroundColor = [UIColor blackColor];
    
    self.photoCropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];
    [self.viewController.photoCamera addTarget:self.photoCropFilter];
    
    [self setupNavigationItem];
    [self setupCameraView];
    [self setupFocusAndGridView];
    
    self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.captureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.captureButton setTitle:nil forState:UIControlStateNormal];
    self.captureButton.backgroundColor = [UIColor whiteColor];
    [self.captureButton addTarget:self action:@selector(captureButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.captureButton.layer.cornerRadius = kNHRecorderCaptureButtonHeight / 2;
    self.captureButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.captureButton];
    
    self.libraryButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.libraryButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.libraryButton.backgroundColor = [UIColor clearColor];
    [self.libraryButton setTitle:nil forState:UIControlStateNormal];
    [self.libraryButton addTarget:self action:@selector(libraryButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.libraryButton.layer.cornerRadius = 5;
    self.libraryButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.libraryButton];
    
    self.videoCaptureButton = [NHRecorderButton buttonWithType:UIButtonTypeCustom];
    self.videoCaptureButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoCaptureButton.backgroundColor = [UIColor clearColor];
    [self.videoCaptureButton setTitle:nil forState:UIControlStateNormal];
    [self.videoCaptureButton setImage:image(@"NHRecorder.video") forState:UIControlStateNormal];
    [self.videoCaptureButton addTarget:self action:@selector(videoCaptureButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.videoCaptureButton.layer.cornerRadius = 5;
    self.videoCaptureButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.videoCaptureButton];
    
    [self setupCaptureButtonConstraints];
    [self setupLibraryButtonConstraints];
    [self setupVideoCaptureButtonConstraints];
    [self resetLibrary];
}

- (void)closeButtonTouch:(id)sender {
    [self.viewController closeController];
}

- (void)flashButtonTouch:(id)sender {
    if ([self.viewController cameraPosition] == AVCaptureDevicePositionFront) {
        return;
    }
    
    [self.viewController switchFlashMode];
    [self resetFlash];
}

- (void)gridButtonTouch:(id)sender {
    self.cameraGridView.hidden = !self.cameraGridView.hidden;
    [self resetGrid];
}

- (void)switchButtonTouch:(id)sender {
    [self.viewController switchCameraPosition];
    
    self.flashButton.enabled = [self.viewController flashEnabled];
    
    [self resetFlash];
}

- (void)captureButtonTouch:(id)sender {
    
    [self.viewController capturePhoto];
}

- (void)libraryButtonTouch:(id)sender {
    [self.viewController openPhotoPicker];
}

- (void)videoCaptureButtonTouch:(id)sender {
    [self.viewController openVideoCapture];
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

- (void)setupCameraViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:-1]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:0]];
}

- (void)setupCameraFocusViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.photoView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.photoView
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.photoView
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.photoView
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0 constant:0]];
}

- (void)setupCameraGridViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.photoView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.photoView
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.photoView
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.photoView
                                                                         attribute:NSLayoutAttributeBottom
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

- (void)setupLibraryButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:25]];
    
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

- (void)setupVideoCaptureButtonConstraints {
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCaptureButton
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0 constant:0]];
    
    [self.bottomContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCaptureButton
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomContainerView
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:-25]];
    
    [self.videoCaptureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCaptureButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.videoCaptureButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0 constant:kNHRecorderSideButtonHeight]];
    
    [self.videoCaptureButton addConstraint:[NSLayoutConstraint constraintWithItem:self.videoCaptureButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.videoCaptureButton
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0 constant:0]];
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


- (void)resetFlash {
    NSString *imageName;
    switch ([self.viewController flashMode]) {
        case AVCaptureFlashModeAuto:
            imageName = @"NHRecorder.flash-auto";
            break;
        case AVCaptureFlashModeOn:
            imageName = @"NHRecorder.flash-active";
            break;
        case AVCaptureFlashModeOff:
            imageName = @"NHRecorder.flash";
            break;
        default:
            break;
    }
    
    
    if (imageName) {
        [self.flashButton setImage:[image(imageName)
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                          forState:UIControlStateNormal];
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
                                                                  isEqualToString:ALAssetTypePhoto]) {
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
                               [self.libraryButton setImage:image(@"NHRecorder.library.error") forState:UIControlStateNormal];
                           }];
}


- (void)showView {
    [self resetGrid];
    [self resetFlash];
    [self resetLibrary];
}

- (void)willShowView {
    self.viewController.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor blackColor];
    self.viewController.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor whiteColor];
    
    [self.viewController.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.viewController.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (GPUImageView *)photoCaptureView {
    return self.photoView;
}


- (void)changeOrientationTo:(UIDeviceOrientation)orientation {
    CGFloat angle = 0;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        default:
            return;
    }
    
    self.flashButton.imageView.transform = CGAffineTransformMakeRotation(angle);
    self.gridButton.imageView.transform = CGAffineTransformMakeRotation(angle);
    self.switchButton.imageView.transform = CGAffineTransformMakeRotation(angle);
    self.libraryButton.transform = CGAffineTransformMakeRotation(angle);
    self.videoCaptureButton.transform = CGAffineTransformMakeRotation(angle);
}

- (GPUImageFilter *)lastFilter {
    return self.photoCropFilter;
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

- (BOOL)statusBarHidden {
    return YES;
}

- (void)dealloc {
}
@end
