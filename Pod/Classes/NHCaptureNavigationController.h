//
//  NHCameraNavigationController.h
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHPhotoCaptureViewController.h"

@interface NHCaptureNavigationController : UINavigationController

@property (nonatomic, readonly, strong) NHPhotoCaptureViewController *cameraViewController;

@end
