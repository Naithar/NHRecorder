//
//  NHPhotoCaptureView.m
//  Pods
//
//  Created by Sergey Minakov on 31.07.15.
//
//

#import "NHPhotoCaptureView.h"

@implementation NHPhotoCaptureView

- (instancetype)initWithCaptureViewController:(NHPhotoCaptureViewController*)photoCapture {
    self = [super init];
    
    if (self) {
        _viewController = photoCapture;
    }
    
    return self;
}

- (GPUImageFilter*)lastFilter {
    return nil;
}

@end
