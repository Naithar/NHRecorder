//
//  NHVideoCaptureViewController.h
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

@import UIKit;
@import AVFoundation;

@class CaptureManager;
@class NHVideoCaptureViewController;
@class NHVideoCaptureView;

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

@property (nonatomic, readonly, strong) CaptureManager *captureManager;
@property (nonatomic, readonly, strong) NHVideoCaptureView *captureView;

+ (Class)nhPhotoCaptureClass;
+ (Class)nhVideoEditorClass;
+ (Class)nhMediaPickerClass;

+ (Class)nhVideoCaptureViewClass;


- (void)closeController;
- (void)startCapture;
- (void)stopCapture;
- (void)switchCamera;

- (void)processCapturedVideo;
- (void)openVideoPicker;
- (void)deleteVideoFragment;

@end
