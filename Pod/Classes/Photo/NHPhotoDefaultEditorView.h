//
//  NHPhotoDefaultEditorView.h
//  Pods
//
//  Created by Sergey Minakov on 27.08.15.
//
//

#import "NHPhotoEditorView.h"

@interface NHPhotoDefaultEditorView : NHPhotoEditorView

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;

@property (nonatomic, readonly, strong) NHPhotoView *photoView;

@property (nonatomic, readonly, strong) UIView *selectorView;
@property (nonatomic, readonly, strong) UIView *selectorSeparatorView;
@property (nonatomic, readonly, strong) UIView *selectionContainerView;
@property (nonatomic, readonly, strong) UIView *photoSeparatorView;

@property (nonatomic, readonly, strong) UIButton *filterButton;
@property (nonatomic, readonly, strong) UIButton *cropButton;

@property (nonatomic, readonly, strong) NHRecorderButton *backButton;

@property (nonatomic, readonly, strong) NHCropCollectionView *cropCollectionView;
@property (nonatomic, readonly, strong) NHFilterCollectionView *filterCollectionView;

- (void)setForcedCrop:(NHPhotoCropType)cropType;

@end
