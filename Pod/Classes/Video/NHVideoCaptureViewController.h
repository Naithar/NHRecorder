//
//  NHVideoCaptureViewController.h
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

#import <UIKit/UIKit.h>

#import "NHRecorderButton.h"

@class NHCameraGridView;

@interface NHVideoCaptureViewController : UIViewController

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;

@property (nonatomic, readonly, strong) UIView *videoCameraView;
@property (nonatomic, readonly, strong) NHCameraGridView *cameraGridView;

@property (nonatomic, readonly, strong) UIView *bottomContainerView;
@property (nonatomic, readonly, strong) NHRecorderButton *removeFragmentButton;
@property (nonatomic, readonly, strong) UIButton *captureButton;

@property (nonatomic, readonly, strong) NHRecorderButton *backButton;
@property (nonatomic, readonly, strong) NHRecorderButton *gridButton;
@property (nonatomic, readonly, strong) NHRecorderButton *switchButton;

@property (nonatomic, readonly, strong) UIProgressView *durationProgressView;

@end
