//
//  NHVideoEditorView.h
//  Pods
//
//  Created by Sergey Minakov on 28.08.15.
//
//

#import "NHCustomView.h"
#import "NHVideoEditorViewController.h"

@interface NHVideoEditorView : NHCustomView

@property (nonatomic, readonly, weak) NHVideoEditorViewController *viewController;
@property (nonatomic, readonly, strong) NHVideoView *videoEditorView;

- (instancetype)initWithEditorViewController:(NHVideoEditorViewController*)editorController;

- (BOOL)canProcessVideo;

@end
