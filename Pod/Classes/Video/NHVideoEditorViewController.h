//
//  NHVideoEditorViewController.h
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@class NHVideoEditorViewController;
@class NHVideoEditorView;

@protocol NHVideoEditorViewControllerDelegate <NSObject>

@optional

- (void)nhVideoEditorDidStartExporting:(NHVideoEditorViewController*)videoEdit;
- (void)nhVideoEditor:(NHVideoEditorViewController*)videoEdit didFailWithError:(NSError*)error;
- (void)nhVideoEditor:(NHVideoEditorViewController*)videoEdit didFinishExportingAtURL:(NSURL*)url;
- (void)nhVideoEditor:(NHVideoEditorViewController*)videoEdit didSaveAtURL:(NSURL*)url;
- (BOOL)nhVideoEditor:(NHVideoEditorViewController*)videoEdit shouldSaveFilteredVideoAtURL:(NSURL*)url;
- (BOOL)nhVideoEditorShouldContinueAfterSaveFail:(NHVideoEditorViewController*)videoEdit;
@end

@interface NHVideoEditorViewController : UIViewController

@property (nonatomic, weak) id<NHVideoEditorViewControllerDelegate> nhDelegate;
@property (nonatomic, strong) NHVideoEditorView *editorView;

- (instancetype)initWithAssetURL:(NSURL*)url;

+ (Class)nhVideoEditorViewClass;

- (void)processVideo;

@end
