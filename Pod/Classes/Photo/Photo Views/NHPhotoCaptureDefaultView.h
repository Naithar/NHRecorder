//
//  NHPhotoDefaultCaptureView.h
//  Pods
//
//  Created by Sergey Minakov on 31.07.15.
//
//

#import "NHPhotoCaptureView.h"

extern const CGFloat kNHRecorderBottomViewHeight;
extern const CGFloat kNHRecorderCaptureButtonHeight;
extern const CGFloat kNHRecorderSideButtonHeight;
extern const CGFloat kNHRecorderCaptureButtonBorderOffset;

@class NHCameraGridView;
@class NHPhotoFocusView;
@class NHRecorderButton;

@interface NHPhotoCaptureDefaultView : NHPhotoCaptureView

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;

@property (nonatomic, readonly, strong) NHCameraGridView *cameraGridView;
@property (nonatomic, readonly, strong) NHPhotoFocusView *cameraFocusView;
@property (nonatomic, readonly, strong) UIView *bottomContainerView;

@property (nonatomic, readonly, strong) NHRecorderButton *closeButton;
@property (nonatomic, readonly, strong) NHRecorderButton *flashButton;
@property (nonatomic, readonly, strong) NHRecorderButton *gridButton;
@property (nonatomic, readonly, strong) NHRecorderButton *switchButton;

@property (nonatomic, readonly, strong) UIButton *captureButton;
@property (nonatomic, readonly, strong) NHRecorderButton *libraryButton;
@property (nonatomic, readonly, strong) NHRecorderButton *videoCaptureButton;

@end
