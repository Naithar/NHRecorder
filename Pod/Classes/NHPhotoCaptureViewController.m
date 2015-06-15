//
//  NHCameraViewController.m
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import "NHPhotoCaptureViewController.h"
#import "NHCameraFocusView.h"
#import "NHCameraGridView.h"
#import "NHPhotoEditorViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImage+Resize.h"
#import "NHMediaPickerViewController.h"

@implementation AlignmentButton

- (UIEdgeInsets)alignmentRectInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(self.customAlignmentInsets, UIEdgeInsetsZero)) {
        return [super alignmentRectInsets];
    }
        
    return self.customAlignmentInsets;
}

@end

const CGFloat kNHRecorderBottomViewHeight = 90;
const CGFloat kNHRecorderCaptureButtonHeight = 60;
const CGFloat kNHRecorderLibraryButtonHeight = 50;
const CGFloat kNHRecorderCaptureButtonBorderOffset = 5;

@interface NHPhotoCaptureViewController ()

@property (nonatomic, strong) GPUImageStillCamera *photoCamera;
@property (nonatomic, strong) GPUImageCropFilter *photoCropFilter;
@property (nonatomic, strong) GPUImageView *photoCameraView;

@property (nonatomic, strong) NHCameraGridView *cameraGridView;
@property (nonatomic, strong) NHCameraFocusView *cameraFocusView;

@property (nonatomic, strong) UIView *bottomContainerView;

@property (nonatomic, strong) AlignmentButton *closeButton;
@property (nonatomic, strong) UIBarButtonItem *flashButton;
@property (nonatomic, strong) UIBarButtonItem *gridButton;
@property (nonatomic, strong) UIBarButtonItem *switchButton;

@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *libraryButton;

@property (nonatomic, strong) id enterForegroundNotification;
@property (nonatomic, strong) id resignActiveNotification;

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
    
    self.photoCropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];
    
    [self.photoCamera addTarget:self.photoCropFilter];
    
    self.photoCameraView = [[GPUImageView alloc] init];
    self.photoCameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.photoCameraView.backgroundColor = [UIColor blackColor];
    self.photoCameraView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoCameraView.userInteractionEnabled = NO;
    [self.view addSubview:self.photoCameraView];
    [self.photoCropFilter addTarget:self.photoCameraView];
    
    self.bottomContainerView = [[UIView alloc] init];
    self.bottomContainerView.backgroundColor = [UIColor blackColor];
    self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bottomContainerView];
    
    [self setupBottomContainerViewContraints];
    [self setupCameraViewConstraints];
    
    self.cameraFocusView = [[NHCameraFocusView alloc] init];
    self.cameraFocusView.backgroundColor = [UIColor clearColor];
    self.cameraFocusView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraFocusView.camera = self.photoCamera;
    self.cameraFocusView.cropFilter = self.photoCropFilter;
    [self.view addSubview:self.cameraFocusView];
    
    self.cameraGridView = [[NHCameraGridView alloc] init];
    self.cameraGridView.backgroundColor = [UIColor clearColor];
    self.cameraGridView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraGridView.userInteractionEnabled = NO;
    self.cameraGridView.numberOfRows = 2;
    self.cameraGridView.numberOfColumns = 2;
    self.cameraGridView.hidden = YES;
    [self.view addSubview:self.cameraGridView];
    
    [self setupCameraFocusViewConstraints];
    [self setupCameraGridViewConstraints];
    
    self.closeButton = [AlignmentButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.frame = CGRectMake(0, 0, 44, 44);
    self.closeButton.customAlignmentInsets = UIEdgeInsetsMake(0, 11, 0, 0);
    self.closeButton.tintColor = [UIColor whiteColor];
    
    [self.closeButton setImage:[UIImage imageNamed:@"NHRecorder.close.png"] forState:UIControlStateNormal];
    self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [self.closeButton addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flashButton = [[UIBarButtonItem alloc]
                        initWithImage:[[UIImage imageNamed:@"NHRecorder.flash.png"]
                                       imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                        style:UIBarButtonItemStylePlain
                        target:self
                        action:@selector(flashButtonTouch:)];
    
    self.gridButton = [[UIBarButtonItem alloc]
                       initWithImage:[[UIImage imageNamed:@"NHRecorder.grid.png"]
                                      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(gridButtonTouch:)];

    self.switchButton = [[UIBarButtonItem alloc]
                       initWithImage:[UIImage imageNamed:@"NHRecorder.switch.png"]
                         style:UIBarButtonItemStylePlain
                         target:self
                         action:@selector(switchButtonTouch:)];
    
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.closeButton];
    
    self.navigationItem.leftBarButtonItems = @[closeBarButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               self.flashButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               self.gridButton,
                                               [[UIBarButtonItem alloc]
                                                initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                target:nil action:nil],
                                               self.switchButton];
    

    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@" "
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    [self resetFocus];
    [self resetGrid];
    
    self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.captureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.captureButton setTitle:nil forState:UIControlStateNormal];
    self.captureButton.backgroundColor = [UIColor whiteColor];
    [self.captureButton addTarget:self action:@selector(captureButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.captureButton.layer.cornerRadius = kNHRecorderCaptureButtonHeight / 2;
    self.captureButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.captureButton];
    
    self.libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.libraryButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.libraryButton.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.libraryButton setTitle:nil forState:UIControlStateNormal];
    [self.libraryButton addTarget:self action:@selector(libraryButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.libraryButton.layer.cornerRadius = 5;
    self.libraryButton.clipsToBounds = YES;
    [self.bottomContainerView addSubview:self.libraryButton];
    
    [self setupCaptureButtonConstraints];
    [self setupLibraryButtonConstraints];
    [self resetLibrary];
   
    __weak __typeof(self) weakSelf = self;
    self.enterForegroundNotification = [[NSNotificationCenter defaultCenter]
                                        addObserverForName:UIApplicationWillEnterForegroundNotification
                                        object:nil
                                        queue:nil
                                        usingBlock:^(NSNotification *note) {
                                            __strong __typeof(weakSelf) strongSelf = weakSelf;
                                            if (strongSelf
                                                && strongSelf.view.window) {
                                                [strongSelf.photoCamera startCameraCapture];
                                                [strongSelf resetLibrary];
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
                                             [strongSelf.photoCamera stopCameraCapture];
                                         }
                                     }];
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

- (void)setupCameraViewConstraints {
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.bottomContainerView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraFocusViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraFocusView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)setupCameraGridViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraGridView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoCameraView
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
                                                                        multiplier:0 constant:kNHRecorderLibraryButtonHeight]];
    
    [self.libraryButton addConstraint:[NSLayoutConstraint constraintWithItem:self.libraryButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.libraryButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0 constant:0]];
}

//MARK: Buttons

- (void)closeButtonTouch:(id)sender {
    if (self.firstController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)flashButtonTouch:(id)sender {
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
    
    [self resetFocus];
}

- (void)gridButtonTouch:(id)sender {
    self.cameraGridView.hidden = !self.cameraGridView.hidden;
    [self resetGrid];
}

- (void)switchButtonTouch:(id)sender {
    [self.photoCamera rotateCamera];
}

- (void)captureButtonTouch:(id)sender {
    
    [self.photoCamera capturePhotoAsImageProcessedUpToFilter:self.photoCropFilter
                                       withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                                           @autoreleasepool {
                                               
                                               if (error
                                                   || !processedImage) {
                                                   NSLog(@"error - %@", error);
                                                   return;
                                               }
                                               
                                               UIImage *resultImage;
                                               
                                               CGSize imageSizeToFit = CGSizeZero;
                                               
                                               __weak __typeof(self) weakSelf = self;
                                               if ([weakSelf.nhDelegate respondsToSelector:@selector(imageSizeToFitForPhotoCapture:)]) {
                                                   imageSizeToFit = [weakSelf.nhDelegate imageSizeToFitForPhotoCapture:weakSelf];
                                               }
                                               
                                               if (CGSizeEqualToSize(imageSizeToFit, CGSizeZero)) {
                                                   resultImage = processedImage;
                                               }
                                               else {
                                                   resultImage = [processedImage resizedImageToFitInSize:imageSizeToFit scaleIfSmaller:YES];
                                               }
                                               
                                               if (resultImage) {
                                                   BOOL shouldEdit = YES;
                                                   
                                                   __weak __typeof(self) weakSelf = self;
                                                   if ([weakSelf.nhDelegate respondsToSelector:@selector(photoCapture:shouldEditImage:)]) {
                                                       shouldEdit = [weakSelf.nhDelegate photoCapture:weakSelf shouldEditImage:resultImage];
                                                   }
                                                   
                                                   if (shouldEdit) {
                                                       NHPhotoEditorViewController *viewController = [[NHPhotoEditorViewController alloc] initWithUIImage:resultImage];
                                                       [self.navigationController pushViewController:viewController animated:YES];
                                                   }
                                               }
                                           }
                                       }];
}

- (void)libraryButtonTouch:(id)sender {
    NHMediaPickerViewController *viewController = [[NHMediaPickerViewController alloc] init];
    viewController.firstController = NO;
    viewController.linksToCamera = NO;
    [self.navigationController pushViewController:viewController animated:YES];
}

//MARK: resets

- (void)resetFocus {
    NSString *imageName;
    switch (self.photoCamera.inputCamera.flashMode) {
        case AVCaptureFlashModeAuto:
            imageName = @"NHRecorder.flash-auto.png";
            break;
        case AVCaptureFlashModeOn:
            imageName = @"NHRecorder.flash-active.png";
            break;
        case AVCaptureFlashModeOff:
            imageName = @"NHRecorder.flash.png";
            break;
        default:
            break;
    }
    
    if (imageName
        && [self.flashButton respondsToSelector:@selector(setImage:)]) {
        [self.flashButton
         setImage:[[UIImage imageNamed: imageName]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    }
}

- (void)resetGrid {
    if ([self.gridButton respondsToSelector:@selector(setImage:)]) {
        [self.gridButton
         setImage:[[UIImage imageNamed: self.cameraGridView.hidden ? @"NHRecorder.grid.png" : @"NHRecorder.grid-active.png"]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }
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
                               NSLog(@"resetLibrary - enumerate groups - %@", error);
                           }];
}


//MARK: Setters

- (void)setBarTintColor:(UIColor *)barTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barTintColor = barTintColor;
    self.navigationController.navigationBar.barTintColor = barTintColor ?: [UIColor blackColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setBarButtonTintColor:(UIColor *)barButtonTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barButtonTintColor = barButtonTintColor;
    self.navigationController.navigationBar.tintColor = barButtonTintColor ?: [UIColor whiteColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setFirstController:(BOOL)firstController {
    [self willChangeValueForKey:@"firstController"];
    _firstController = firstController;
    
    [self.closeButton setImage:(firstController ? [UIImage imageNamed:@"NHRecorder.close.png"] : [UIImage imageNamed:@"NHRecorder.back.png"]) forState:UIControlStateNormal];
    [self didChangeValueForKey:@"firstController"];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor whiteColor];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActiveNotification];
}



@end

