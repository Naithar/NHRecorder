//
//  NHCameraViewController.h
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "NHRecorderButton.h"


extern const CGFloat kNHRecorderBottomViewHeight;
extern const CGFloat kNHRecorderCaptureButtonHeight;
extern const CGFloat kNHRecorderSideButtonHeight;
extern const CGFloat kNHRecorderCaptureButtonBorderOffset;

@class NHCameraGridView;
@class NHPhotoFocusView;
@class NHPhotoCaptureViewController;
@class NHPhotoCaptureView;

@protocol NHPhotoCaptureViewControllerDelegate <NSObject>

@optional

- (void)nhPhotoCaptureDidStartExporting:(NHPhotoCaptureViewController*)photoCapture;
- (void)photoCaptureDidFinishExporting:(NHPhotoCaptureViewController*)photoCapture;

- (BOOL)nhPhotoCapture:(NHPhotoCaptureViewController*)photoCapture shouldEditImage:(UIImage*)image;
- (BOOL)nhPhotoCapture:(NHPhotoCaptureViewController*)photoCapture cameraAvailability:(AVAuthorizationStatus)status;
- (CGSize)imageSizeToFitForNHPhotoCapture:(NHPhotoCaptureViewController*)photoCapture;
@end

@interface NHPhotoCaptureViewController : UIViewController



@property (nonatomic, readonly, strong) GPUImageStillCamera *photoCamera;
@property (nonatomic, readonly, strong) NHPhotoCaptureView *captureView;

@property (nonatomic, weak) id<NHPhotoCaptureViewControllerDelegate> nhDelegate;

+ (Class)nhVideoCaptureClass;
+ (Class)nhPhotoEditorClass;
+ (Class)nhMediaPickerClass;

- (void)capturePhoto;
- (void)switchCameraPosition;
- (AVCaptureDevicePosition)cameraPosition;
- (void)switchFlashMode;
- (AVCaptureFlashMode)flashMode;
- (BOOL)flashEnabled;
- (void)openPhotoPicker;
- (void)openVideoCapture;
- (void)closeController;

+ (Class)nhPhotoCaptureViewClass;
@end
