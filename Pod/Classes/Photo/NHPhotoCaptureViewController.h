//
//  NHCameraViewController.h
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>
#import "NHRecorderButton.h"

extern const CGFloat kNHRecorderBottomViewHeight;

@class NHCameraGridView;
@class NHCameraFocusView;
@class NHPhotoCaptureViewController;

@protocol NHPhotoCaptureViewControllerDelegate <NSObject>

@optional
- (BOOL)photoCapture:(NHPhotoCaptureViewController*)controller shouldEditImage:(UIImage*)image;
- (BOOL)photoCapture:(NHPhotoCaptureViewController*)controller cameraAvailability:(AVAuthorizationStatus)status;
- (CGSize)imageSizeToFitForPhotoCapture:(NHPhotoCaptureViewController*)controller;
@end

@interface NHPhotoCaptureViewController : UIViewController

@property (nonatomic, assign) BOOL firstController;

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;

@property (nonatomic, readonly, strong) GPUImageView *photoCameraView;
@property (nonatomic, readonly, strong) NHCameraGridView *cameraGridView;
@property (nonatomic, readonly, strong) NHCameraFocusView *cameraFocusView;
@property (nonatomic, readonly, strong) UIView *bottomContainerView;

@property (nonatomic, readonly, strong) NHRecorderButton *closeButton;
@property (nonatomic, readonly, strong) NHRecorderButton *flashButton;
@property (nonatomic, readonly, strong) NHRecorderButton *gridButton;
@property (nonatomic, readonly, strong) NHRecorderButton *switchButton;

@property (nonatomic, readonly, strong) UIButton *captureButton;
@property (nonatomic, readonly, strong) NHRecorderButton *libraryButton;

@property (nonatomic, weak) id<NHPhotoCaptureViewControllerDelegate> nhDelegate;

@end