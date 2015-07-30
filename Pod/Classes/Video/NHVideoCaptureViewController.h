//
//  NHVideoCaptureViewController.h
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

@import UIKit;
@import AVFoundation;

@class NHRecorderButton;
@class CaptureManager;
@class NHCameraGridView;
@class NHVideoCaptureViewController;
@class NHRecorderProgressView;
@class NHCameraCropView;

extern const NSTimeInterval kNHVideoTimerInterval;
extern const NSTimeInterval kNHVideoMaxDuration;
extern const NSTimeInterval kNHVideoMinDuration;

@protocol NHVideoCaptureViewControllerDelegate <NSObject>

@optional
- (void)nhVideoCaptureDidStart:(NHVideoCaptureViewController*)videoCapture;
- (void)nhVideoCaptureDidFinish:(NHVideoCaptureViewController*)videoCapture;

- (void)nhVideoCapture:(NHVideoCaptureViewController*)videoCapture exportProgressChanged:(float)progress;
- (void)nhVideoCaptureDidStartExporting:(NHVideoCaptureViewController*)videoCapture;
- (void)nhVideoCaptureDidStartSaving:(NHVideoCaptureViewController*)videoCapture;
- (void)nhVideoCapture:(NHVideoCaptureViewController *)videoCapture didFinishExportingWithSuccess:(BOOL)success;

- (void)nhVideoCapture:(NHVideoCaptureViewController *)videoCapture didFailWithError:(NSError*)error;

- (BOOL)nhVideoCapture:(NHVideoCaptureViewController*)videoCapture shouldEditVideoAtURL:(NSURL *)videoURL;
- (BOOL)nhVideoCapture:(NHVideoCaptureViewController*)videoCapture cameraAvailability:(AVAuthorizationStatus)status;

- (void)nhVideoCaptureDidReset:(NHVideoCaptureViewController*)videoCapture;

- (BOOL)nhVideoCaptureShouldSaveNonFilteredVideo:(NHVideoCaptureViewController*)videoCapture;

@end

@interface NHVideoCaptureViewController : UIViewController

@property (nonatomic, weak) id<NHVideoCaptureViewControllerDelegate> nhDelegate;

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;

@property (nonatomic, readonly, strong) CaptureManager *captureManager;
@property (nonatomic, readonly, strong) UIView *videoCameraView;
@property (nonatomic, readonly, strong) NHCameraGridView *cameraGridView;

@property (nonatomic, readonly, strong) UIView *bottomContainerView;
@property (nonatomic, readonly, strong) NHRecorderButton *removeFragmentButton;
@property (nonatomic, readonly, strong) UIButton *captureButton;

@property (nonatomic, readonly, strong) NHRecorderButton *libraryButton;

@property (nonatomic, readonly, strong) NHRecorderButton *closeButton;
@property (nonatomic, readonly, strong) NHRecorderButton *gridButton;
@property (nonatomic, readonly, strong) NHRecorderButton *switchButton;

@property (nonatomic, readonly, strong) NHRecorderProgressView *durationProgressView;

@property (nonatomic, readonly, strong) NHCameraCropView *cropView;

@property (nonatomic, assign) BOOL firstController;

+ (Class)nhVideoEditorClass;
+ (Class)nhMediaPickerClass;
@end
