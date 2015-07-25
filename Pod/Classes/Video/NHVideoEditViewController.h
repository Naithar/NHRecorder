//
//  NHVideoEditViewController.h
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@class NHRecorderButton;
@class NHVideoEditViewController;

@protocol NHVideoEditViewControllerDelegate <NSObject>

@optional
//didsave
//didstart processing
//didfinish processing
//file path?
//error

@end

@interface NHVideoEditViewController : UIViewController

@property (nonatomic, weak) id<NHVideoEditViewControllerDelegate> nhDelegate;

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;

@property (nonatomic, readonly, strong) NHRecorderButton *backButton;
@property (nonatomic, readonly, strong) GPUImageView *videoEditView;

- (instancetype)initWithAssetURL:(NSURL*)url;

@end
