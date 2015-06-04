//
//  NHCameraNavigationController.h
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHCameraViewController.h"

@interface NHCameraNavigationController : UINavigationController

@property (nonatomic, readonly, strong) NHCameraViewController *cameraViewController;

@end
