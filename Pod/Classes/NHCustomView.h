//
//  NHCustomView.h
//  Pods
//
//  Created by Sergey Minakov on 31.07.15.
//
//

#import <UIKit/UIKit.h>

@interface NHCustomView : UIView


- (void)setupView;
- (void)showView;
- (void)hideView;
- (void)changeOrientationTo:(UIDeviceOrientation)orientation;
- (BOOL)statusBarHidden;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;

@end
