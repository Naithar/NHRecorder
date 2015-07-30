//
//  NHVideoEditorViewController.h
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>
#import "NHCameraCropView.h"

@class NHRecorderButton;
@class NHVideoEditorViewController;
@class NHFilterCollectionView;
@class NHVideoView;
@class NHCropCollectionView;

@protocol NHVideoEditorViewControllerDelegate <NSObject>

@optional

- (void)nhVideoEditorDidStartExporting:(NHVideoEditorViewController*)controller;
- (void)nhVideoEditor:(NHVideoEditorViewController*)controller didFailWithError:(NSError*)error;
- (void)nhVideoEditor:(NHVideoEditorViewController*)controller didSaveAtURL:(NSURL*)url;
- (void)nhVideoEditor:(NHVideoEditorViewController*)controller didFinishExportingAtURL:(NSURL*)url;
- (BOOL)nhVideoEditor:(NHVideoEditorViewController*)controller shouldSaveFilteredVideoAtURL:(NSURL*)url;
- (BOOL)nhVideoEditorShouldContinueAfterSaveFail:(NHVideoEditorViewController*)controller;
@end

@interface NHVideoEditorViewController : UIViewController

@property (nonatomic, weak) id<NHVideoEditorViewControllerDelegate> nhDelegate;

@property (nonatomic, assign) NHPhotoCropType forcedCropType;

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;

@property (nonatomic, readonly, strong) NHRecorderButton *backButton;

@property (nonatomic, readonly, strong) NHVideoView *videoView;

@property (nonatomic, readonly, strong) UIView *selectorView;
@property (nonatomic, readonly, strong) UIView *selectorSeparatorView;
@property (nonatomic, readonly, strong) UIView *selectionContainerView;
@property (nonatomic, readonly, strong) UIView *videoSeparatorView;

@property (nonatomic, readonly, strong) UIButton *filterButton;
@property (nonatomic, readonly, strong) UIButton *cropButton;
@property (nonatomic, readonly, strong) NHFilterCollectionView *filterCollectionView;
@property (nonatomic, readonly, strong) NHCropCollectionView *cropCollectionView;

- (instancetype)initWithAssetURL:(NSURL*)url;

@end
