//
//  NHDefaultVideoCaptureView.h
//  Pods
//
//  Created by Sergey Minakov on 28.08.15.
//
//

#import "NHVideoCaptureView.h"
#import "CaptureManager.h"

@class NHRecorderButton;
@class NHCameraGridView;
@class NHRecorderProgressView;
@class NHCameraCropView;
@class NHVideoCaptureView;

extern const NSTimeInterval kNHVideoTimerInterval;
extern const NSTimeInterval kNHVideoMaxDuration;
extern const NSTimeInterval kNHVideoMinDuration;

@interface NHVideoCaptureDefaultView : NHVideoCaptureView

//@property (nonatomic, readonly, strong) UIView *videoCameraView;
@property (nonatomic, readonly, strong) NHCameraGridView *cameraGridView;

@property (nonatomic, readonly, strong) UIView *bottomContainerView;
@property (nonatomic, readonly, strong) NHRecorderButton *removeFragmentButton;
@property (nonatomic, readonly, strong) UIView *captureView;

@property (nonatomic, readonly, strong) NHRecorderButton *libraryButton;

@property (nonatomic, readonly, strong) NHRecorderButton *closeButton;
@property (nonatomic, readonly, strong) NHRecorderButton *gridButton;
@property (nonatomic, readonly, strong) NHRecorderButton *switchButton;

@property (nonatomic, readonly, strong) NHRecorderProgressView *durationProgressView;

@property (nonatomic, readonly, strong) NHCameraCropView *cropView;

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;


@end
