//
//  NHVideoCaptureView.h
//  Pods
//
//  Created by Sergey Minakov on 28.08.15.
//
//

#import "NHCustomView.h"
#import "NHVideoCaptureViewController.h"

@interface NHVideoCaptureView : NHCustomView

@property (nonatomic, readonly, weak) NHVideoCaptureViewController *viewController;
@property (nonatomic, readonly, strong) UIView *videoCaptureView;

- (instancetype)initWithCaptureViewController:(NHVideoCaptureViewController*)videoCapture;


@end
