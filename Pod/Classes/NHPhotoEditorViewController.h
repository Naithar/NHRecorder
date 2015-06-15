//
//  NHCameraImageEditorController.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHPhotoCropView.h"
#import "NHPhotoView.h"
#import "NHCropCollectionView.h"
#import "NHFilterCollectionView.h"

@interface NHPhotoEditorViewController : UIViewController

@property (nonatomic, assign) NHPhotoCropType forcedCropType;

@property (nonatomic, strong) UIColor *barTintColor;
@property (nonatomic, strong) UIColor *barButtonTintColor;

@property (nonatomic, readonly, strong) NHPhotoView *photoView;

@property (nonatomic, readonly, strong) UIView *selectorView;
@property (nonatomic, readonly, strong) UIView *separatorView;
@property (nonatomic, readonly, strong) UIView *selectionContainerView;

@property (nonatomic, readonly, strong) UIButton *filterButton;
@property (nonatomic, readonly, strong) UIButton *cropButton;

@property (nonatomic, readonly, strong) NHCropCollectionView *cropCollectionView;
@property (nonatomic, readonly, strong) NHFilterCollectionView *filterCollectionView;

- (instancetype)initWithUIImage:(UIImage*)image;

@end
