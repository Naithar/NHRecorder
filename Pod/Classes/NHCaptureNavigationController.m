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


@interface NHCaptureNavigationController ()<UINavigationControllerDelegate>

@end

@implementation NHCaptureNavigationController

+ (Class)nhPhotoCaptureClass {
    return [NHPhotoCaptureViewController class];
}
+ (Class)nhVideoCaptureClass {
    return [NHVideoCaptureViewController class];
}
+ (Class)nhMediaPickerClass {
    return [NHMediaPickerViewController class];
}

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
            Class viewControllerClass = [[self class] nhPhotoCaptureClass];
            
            if (![viewControllerClass isSubclassOfClass:[NHPhotoCaptureViewController class]]) {
                viewControllerClass = [NHPhotoCaptureViewController class];
            }
            
            viewController = [[viewControllerClass alloc] init];
        } break;
        case NHCaptureTypeVideoCamera: {
            Class viewControllerClass = [[self class] nhVideoCaptureClass];
            
            if (![viewControllerClass isSubclassOfClass:[NHVideoCaptureViewController class]]) {
                viewControllerClass = [NHVideoCaptureViewController class];
            }
            
            viewController = [[viewControllerClass alloc] init];
            //            ((NHVideoCaptureViewController*)viewController).firstController = YES;
        } break;
        case NHCaptureTypeMediaPicker: {
            Class viewControllerClass = [[self class] nhMediaPickerClass];
            
            if (![viewControllerClass isSubclassOfClass:[NHMediaPickerViewController class]]) {
                viewControllerClass = [NHMediaPickerViewController class];
            }
            
            viewController = [[viewControllerClass alloc] init];
            //            ((NHMediaPickerViewController*)viewController).firstController = YES;
            ((NHMediaPickerViewController*)viewController).linksToCamera = YES;
        } break;
        default:
            break;
    }
    
    self.delegate = self;
    
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationBar.backIndicatorImage = image(@"NHRecorder.back");
    self.navigationBar.backIndicatorTransitionMaskImage = image(@"NHRecorder.back");
    
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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL nonInteractiveDismissal = YES;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        nonInteractiveDismissal = self.interactivePopGestureRecognizer.state == UIGestureRecognizerStatePossible;
    }
    
    if (self.view.window
        && nonInteractiveDismissal) {
            self.view.userInteractionEnabled = NO;
        }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.view.userInteractionEnabled = YES;
}

@end
