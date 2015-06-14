//
//  NHCameraNavigationController.h
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHPhotoCaptureViewController.h"
#import "NHPhotoEditorViewController.h"

@interface NHCaptureNavigationController : UINavigationController

@property (nonatomic, readonly, strong) NHPhotoCaptureViewController *photoCameraViewController;
@property (nonatomic, readonly, strong) NHPhotoEditorViewController *photoEditorViewController;

@end
