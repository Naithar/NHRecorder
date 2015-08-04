//
//  NHPhotoDefaultCaptureView.h
//  Pods
//
//  Created by Sergey Minakov on 31.07.15.
//
//

#import "NHPhotoCaptureView.h"

@class NHCameraGridView;
@class NHPhotoFocusView;

@interface NHPhotoDefaultCaptureView : NHPhotoCaptureView

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
