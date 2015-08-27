//
//  NHPhotoEditorView.m
//  Pods
//
//  Created by Sergey Minakov on 27.08.15.
//
//

#import "NHPhotoEditorView.h"

@implementation NHPhotoEditorView

- (instancetype)initWithEditorViewController:(NHPhotoEditorViewController*)photoEditor {
    self = [super init];
    
    if (self) {
        _viewController = photoEditor;
    }
    
    return self;
}

@end
