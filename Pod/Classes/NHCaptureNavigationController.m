//
//  NHCameraNavigationController.m
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import "NHCaptureNavigationController.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHCaptureNavigationController class]]\
pathForResource:name ofType:@"png"]]


@interface NHCaptureNavigationController ()

@end

@implementation NHCaptureNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithType:NHCaptureTypePhotoCamera];
}

- (instancetype)initWithType:(NHCaptureType)type {
    self = [super init];
    
    if (self) {
        [self commonInitWithType:type];
    }
    
    return self;
}

- (void)commonInit {
    [self commonInitWithType:NHCaptureTypePhotoCamera];
}

- (void)commonInitWithType:(NHCaptureType)type {
    
    UIViewController *viewController;
    
    switch (type) {
        case NHCaptureTypePhotoCamera: {
            viewController = [[NHPhotoCaptureViewController alloc] init];
            ((NHPhotoCaptureViewController*)viewController).firstController = YES;
        } break;
        case NHCaptureTypeMediaPicker:
            viewController = [[NHMediaPickerViewController alloc] init];
            ((NHMediaPickerViewController*)viewController).firstController = YES;
            ((NHMediaPickerViewController*)viewController).linksToCamera = YES;
            break;
        default:
            break;
    }
    
     self.navigationBar.translucent = NO;
     self.navigationBar.barTintColor = [UIColor blackColor];
     self.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationBar.backIndicatorImage = image(@"NHRecorder.back");//[UIImage imageNamed:@"NHRecorder.back.png"];
    self.navigationBar.backIndicatorTransitionMaskImage = image(@"NHRecorder.back");//[UIImage imageNamed:@"NHRecorder.back.png"];
    
             if (viewController) {
    [self setViewControllers:@[viewController]];
             }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
