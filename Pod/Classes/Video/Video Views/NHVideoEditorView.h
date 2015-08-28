//
//  NHVideoEditorView.h
//  Pods
//
//  Created by Sergey Minakov on 28.08.15.
//
//

#import "NHCustomView.h"
#import "NHVideoEditorViewController.h"
#import "NHVideoView.h"

@interface NHVideoEditorView : NHCustomView

@property (nonatomic, readonly, weak) NHVideoEditorViewController *viewController;
@property (nonatomic, readonly, strong) NSURL *assetURL;
@property (nonatomic, readonly, strong) NHVideoView *videoEditorView;

- (instancetype)initWithEditorViewController:(NHVideoEditorViewController*)editorController andAssetURL:(NSURL*)assetURL;
- (UIImage *)generateThumbImage:(NSURL *)url;
- (BOOL)canProcessVideo;

@end
