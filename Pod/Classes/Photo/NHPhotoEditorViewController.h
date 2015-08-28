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




@class NHPhotoEditorViewController;
@class NHPhotoEditorView;

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

@property (nonatomic, readonly, strong) NHPhotoEditorView *editorView;

- (instancetype)initWithUIImage:(UIImage*)image;
- (void)processPhoto;

+ (Class)nhPhotoEditorViewClass;

@end
