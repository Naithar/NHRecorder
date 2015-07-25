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
@class NHFilterCollectionView;

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

@property (nonatomic, readonly, strong) UIView *selectorView;
@property (nonatomic, readonly, strong) UIView *selectorSeparatorView;
@property (nonatomic, readonly, strong) UIView *selectionContainerView;
@property (nonatomic, readonly, strong) UIView *videoSeparatorView;

@property (nonatomic, readonly, strong) UIButton *filterButton;
@property (nonatomic, readonly, strong) NHFilterCollectionView *filterCollectionView;

- (instancetype)initWithAssetURL:(NSURL*)url;

@end
