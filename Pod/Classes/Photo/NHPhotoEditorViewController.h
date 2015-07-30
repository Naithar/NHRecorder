//
//  NHCameraImageEditorController.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHCameraCropView.h"
#import "NHPhotoView.h"
#import "NHCropCollectionView.h"
#import "NHFilterCollectionView.h"
#import "NHRecorderButton.h"

extern const CGFloat kNHRecorderSelectorViewHeight;
extern const CGFloat kNHRecorderSelectionContainerViewHeight;

@class NHPhotoEditorViewController;

@protocol NHPhotoEditorViewControllerDelegate <NSObject>

@optional
- (void)nhPhotoEditorDidStartExporting:(NHPhotoEditorViewController*)photoEditor;
- (void)nhPhotoEditorDidFinishExporting:(NHPhotoEditorViewController*)photoEditor;


- (CGSize)imageSizeToFitForNHPhotoEditor:(NHPhotoEditorViewController*)photoEditor;
- (BOOL)nhPhotoEditor:(NHPhotoEditorViewController*)photoEditor
    shouldSaveImage:(UIImage*)image;

- (void)nhPhotoEditor:(NHPhotoEditorViewController*)photoEditor
         savedImage:(UIImage*)image;
- (void)nhPhotoEditor:(NHPhotoEditorViewController*)photoEditor
         receivedErrorOnSave:(NSError*)error;

- (BOOL)nhPhotoEditorShouldContinueAfterSaveFail:(NHPhotoEditorViewController*)photoEditor;
@end

@interface NHPhotoEditorViewController : UIViewController

@property (nonatomic, weak) id<NHPhotoEditorViewControllerDelegate> nhDelegate;

@property (nonatomic, assign) NHPhotoCropType forcedCropType;

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

- (instancetype)initWithUIImage:(UIImage*)image;

@end
