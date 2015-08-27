//
//  NHPhotoEditorView.h
//  Pods
//
//  Created by Sergey Minakov on 27.08.15.
//
//

#import "NHCustomView.h"
#import "NHPhotoEditorViewController.h"

@interface NHPhotoEditorView : NHCustomView

@property (nonatomic, readonly, weak) NHPhotoEditorViewController *viewController;
@property (nonatomic, readonly, strong) NHPhotoView *photoEditorView;

- (instancetype)initWithEditorViewController:(NHPhotoEditorViewController*)photoEditor;

@end
