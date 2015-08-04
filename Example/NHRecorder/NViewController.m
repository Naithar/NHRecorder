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
@interface NViewController ()

@end

@implementation NViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NHCaptureNavigationController *cameraViewController = [[NHCaptureNavigationController alloc] initWithType:NHCaptureTypePhotoCamera];
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
