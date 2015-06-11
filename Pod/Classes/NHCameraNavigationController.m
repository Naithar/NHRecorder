//
//  NHCameraNavigationController.m
//  Pods
//
//  Created by Sergey Minakov on 04.06.15.
//
//

#import "NHCameraNavigationController.h"

@interface NHCameraNavigationController ()

@property (nonatomic, strong) NHCameraViewController *cameraViewController;

@end

@implementation NHCameraNavigationController

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
    self.cameraViewController = [[NHCameraViewController alloc] init];
    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationBar.backIndicatorImage = [UIImage imageNamed:@"NHRecorder.back.png"];
    self.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"NHRecorder.back.png"];
    
    self.cameraViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NHRecorder.close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeNavigationButtonTouch:)];
    
    [self setViewControllers:@[self.cameraViewController]];
}

- (void)closeNavigationButtonTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
