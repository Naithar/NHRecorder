//
//  NViewController.m
//  NHRecorder
//
//  Created by Naithar on 06/04/2015.
//  Copyright (c) 2014 Naithar. All rights reserved.
//

#import "NViewController.h"
#import <NHCaptureNavigationController.h>
#import <NHPhotoCaptureViewController.h>
#import <NHPhotoCaptureView.h>
@interface NViewController ()

@end

@interface CustomNHPhotoCaptureView : NHPhotoCaptureView

@end

@interface CustomNHPhotoCaptureView ()

@property (nonatomic, strong) GPUImageView *photoView;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) GPUImageFilter *filter;
@end

@implementation CustomNHPhotoCaptureView

- (instancetype)initWithCaptureViewController:(NHPhotoCaptureViewController *)photoCapture {
    self = [super initWithCaptureViewController:photoCapture];
    
    if (self) {
        [self skCommonInit];
    }
    
    return self;
}

- (void)skCommonInit {
    
}

- (void)buttonTouch:(id)s {
    [self.viewController capturePhoto];
}

- (GPUImageFilter *)lastFilter {
    return self.filter;
}

- (void)setupView {
    self.photoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    
    self.filter = [[GPUImageFilter alloc] init];
    [self.viewController.view addSubview:self.photoView];

    [self.viewController.photoCamera addTarget:self.filter];
        [self.filter addTarget:self.photoView];
    
    self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.photoButton.backgroundColor = [UIColor whiteColor];
    self.photoButton.frame = CGRectMake(0, 300, 300, 50);
    
    [self.viewController.view addSubview:self.photoButton];
    
    [self.photoButton addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
}

- (GPUImageView *)photoCaptureView {
    return self.photoView;
}

@end


@interface CustomNHPhotoCaptureViewController : NHPhotoCaptureViewController


@end

@implementation CustomNHPhotoCaptureViewController

+ (Class)nhPhotoCaptureViewClass {
    return [CustomNHPhotoCaptureView class];
}

@end

@interface CustomNHCaptureNavigationController : NHCaptureNavigationController

@end

@implementation CustomNHCaptureNavigationController

+ (Class)nhPhotoCaptureClass {
    return [CustomNHPhotoCaptureViewController class];
}

@end

@implementation NViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NHCaptureNavigationController *cameraViewController = [[CustomNHCaptureNavigationController alloc] initWithType:NHCaptureTypePhotoCamera];
//        ((NHPhotoCaptureViewController*)cameraViewController.topViewController).videoCaptureEnabled = YES;
        [self presentViewController:cameraViewController animated:YES completion:nil];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
