//
//  NHPhotoCaptureView.h
//  Pods
//
//  Created by Sergey Minakov on 31.07.15.
//
//

#import <UIKit/UIKit.h>
#import "NHPhotoCaptureViewController.h"
#import "NHCustomView.h"
#import <GPUImage/GPUImage.h>


@interface NHPhotoCaptureView : NHCustomView

@property (nonatomic, readonly, weak) NHPhotoCaptureViewController *viewController;
@property (nonatomic, readonly, strong) GPUImageView *photoCaptureView;

- (instancetype)initWithCaptureViewController:(NHPhotoCaptureViewController*)photoCapture;

@end
