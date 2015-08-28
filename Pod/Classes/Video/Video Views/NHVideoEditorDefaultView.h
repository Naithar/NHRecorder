//
//  NHDefaultVideoEditorView.h
//  Pods
//
//  Created by Sergey Minakov on 28.08.15.
//
//

#import "NHVideoEditorView.h"
#import "NHCameraCropView.h"

@class NHRecorderButton;
@class NHFilterCollectionView;
@class NHVideoView;
@class NHCropCollectionView;

@interface NHVideoEditorDefaultView : NHVideoEditorView

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

- (void)setForcedCrop:(NHPhotoCropType)cropType;

@end
