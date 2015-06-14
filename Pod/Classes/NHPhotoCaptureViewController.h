//
//  NHCameraViewController.h
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import <UIKit/UIKit.h>

@class NHPhotoCaptureViewController;

@protocol NHPhotoCaptureViewControllerDelegate <NSObject>

@optional
- (BOOL)photoCapture:(NHPhotoCaptureViewController*)controller shouldEditImage:(UIImage*)image;
- (CGSize)imageSizeToFitForPhotoCapture:(NHPhotoCaptureViewController*)controller;
@end

@interface NHPhotoCaptureViewController : UIViewController

@property (nonatomic, weak) id<NHPhotoCaptureViewControllerDelegate> nhDelegate;

@end
