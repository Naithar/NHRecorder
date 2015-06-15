//
//  NHCameraNavigationController.m
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import "NHCaptureNavigationController.h"

@interface NHCaptureNavigationController ()

//@property (nonatomic, strong) NHPhotoCaptureViewController *photoCameraViewController;
//@property (nonatomic, strong) NHPhotoEditorViewController *photoEditorViewController;

@end

@implementation NHCaptureNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    NHPhotoCaptureViewController *photoCameraViewController = [[NHPhotoCaptureViewController alloc] init];
    photoCameraViewController.firstController = YES;
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationBar.backIndicatorImage = [UIImage imageNamed:@"NHRecorder.back.png"];
    self.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"NHRecorder.back.png"];
    
    [self setViewControllers:@[photoCameraViewController]];
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
