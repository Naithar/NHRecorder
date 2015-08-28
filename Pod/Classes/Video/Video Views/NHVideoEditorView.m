//
//  NHVideoEditorView.m
//  Pods
//
//  Created by Sergey Minakov on 28.08.15.
//
//

#import "NHVideoEditorView.h"

@implementation NHVideoEditorView


- (instancetype)initWithEditorViewController:(NHVideoEditorViewController*)editorController {
    self = [super init];
    
    if (self) {
        _viewController = editorController;
    }
    
    return self;
}

- (BOOL)canProcessVideo {
    return YES;
}
@end
