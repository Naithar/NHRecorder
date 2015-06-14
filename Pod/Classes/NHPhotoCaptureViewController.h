//
//  NHCameraViewController.h
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

@class NHCameraFocusView;
@class NHCameraGridView;

@class NHPhotoCaptureViewController;

@protocol NHPhotoCaptureViewControllerDelegate <NSObject>

@optional
- (BOOL)photoCapture:(NHPhotoCaptureViewController*)controller shouldEditImage:(UIImage*)image;
- (CGSize)imageSizeToFitForPhotoCapture:(NHPhotoCaptureViewController*)controller;
@end

@interface NHPhotoCaptureViewController : UIViewController

@property (nonatomic, readonly, strong) GPUImageView *photoCameraView;
@property (nonatomic, readonly, strong) NHCameraGridView *cameraGridView;
@property (nonatomic, readonly, strong) NHCameraFocusView *cameraFocusView;
@property (nonatomic, readonly, strong) UIView *bottomContainerView;

@property (nonatomic, readonly, strong) UIBarButtonItem *closeButton;
@property (nonatomic, readonly, strong) UIBarButtonItem *flashButton;
@property (nonatomic, readonly, strong) UIBarButtonItem *gridButton;
@property (nonatomic, readonly, strong) UIBarButtonItem *switchButton;

@property (nonatomic, readonly, strong) UIButton *captureButton;
@property (nonatomic, readonly, strong) UIButton *libraryButton;

@property (nonatomic, weak) id<NHPhotoCaptureViewControllerDelegate> nhDelegate;

@end
