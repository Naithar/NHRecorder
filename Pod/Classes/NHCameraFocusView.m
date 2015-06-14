//
//  NHCameraFocusView.m
//  Pods
//
//  Created by Sergey Minakov on 13.06.15.
//
//

#import "NHCameraFocusView.h"

@interface NHCameraFocusView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UIView *focusView;

@property (nonatomic, assign) CGFloat currentZoom;
@property (nonatomic, assign) CGFloat prevZoom;
@end

@implementation NHCameraFocusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    
    self.focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.focusView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    [self addSubview:self.focusView];
    self.focusView.hidden = YES;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:self.tapGesture];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    [self addGestureRecognizer:self.pinchGesture];
    
    self.currentZoom = 1;
    self.prevZoom = 1;
}

- (void)tapGestureAction:(UITapGestureRecognizer*)recognizer {
    
    CGPoint focusPoint = [recognizer locationInView:self];
    
    [self setFocusPoint:focusPoint withMode:AVCaptureFocusModeAutoFocus];
    
    self.focusView.center = focusPoint;
    self.focusView.hidden = NO;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.focusView.hidden = YES;
    });
}

- (void)pinchGestureAction:(UIPinchGestureRecognizer*)recognizer {
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self];
        
        if (![self.layer containsPoint:location]) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        self.currentZoom = self.prevZoom * recognizer.scale;
        
        if (self.currentZoom < 1) {
            self.currentZoom = 1;
        }
        if (self.currentZoom > 5) {
            self.currentZoom = 5;
        }
        
        [self setZoom:self.currentZoom];
    }
    
    if ( [recognizer state] == UIGestureRecognizerStateEnded ||
        [recognizer state] == UIGestureRecognizerStateCancelled ||
        [recognizer state] == UIGestureRecognizerStateFailed) {
        self.prevZoom = self.currentZoom;
    }
}

- (void)setZoom:(CGFloat)zoomValue {
    CGFloat len = 1 / zoomValue; // notice: zoomValue >= 1
    CGFloat pos = (1 - len) * .5f;
    
    CGRect cropRect = CGRectMake(pos, pos, len, len);
    NSLog(@"%@", NSStringFromCGRect(cropRect));
    [self.cropFilter setCropRegion:cropRect];
}

- (void)setFocusPoint:(CGPoint)point {
    [self setFocusPoint:point withMode:AVCaptureFocusModeContinuousAutoFocus];
}

- (void)setFocusPoint:(CGPoint)point withMode:(AVCaptureFocusMode)mode {
    AVCaptureDevice *camera = self.camera.inputCamera;
    if ([camera isFocusModeSupported:mode]) {
        [camera lockForConfiguration:nil];
        [camera setFocusMode:mode];
        [camera setFocusPointOfInterest:point];
        [camera unlockForConfiguration];
    }
}

@end
