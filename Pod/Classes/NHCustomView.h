//
//  NHCustomView.h
//  Pods
//
//  Created by Sergey Minakov on 31.07.15.
//
//

#import <UIKit/UIKit.h>

@interface NHCustomView : NSObject

@property (nonatomic, assign) BOOL isFirstController;

- (void)setupView;
- (void)willShowView;
- (void)willHideView;
- (void)showView;
- (void)hideView;
- (void)changeOrientationTo:(UIDeviceOrientation)orientation;
- (BOOL)statusBarHidden;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;

@end
