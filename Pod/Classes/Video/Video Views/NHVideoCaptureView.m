//
//  NHVideoCaptureView.m
//  Pods
//
//  Created by Sergey Minakov on 28.08.15.
//
//

#import "NHVideoCaptureView.h"

@implementation NHVideoCaptureView

- (instancetype)initWithCaptureViewController:(NHVideoCaptureViewController *)videoCapture {
    self = [super init];
    
    if (self) {
        _viewController = videoCapture;
    }
    
    return self;
}

- (void)startedCapture {
    
}

- (void)stopedCapture {
    
}

- (BOOL)canCaptureVideo {
    return YES;
}

@end
