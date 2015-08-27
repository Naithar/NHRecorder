//
//  NHPhotoEditorView.m
//  Pods
//
//  Created by Sergey Minakov on 27.08.15.
//
//

#import "NHPhotoEditorView.h"

@implementation NHPhotoEditorView

- (instancetype)initWithEditorViewController:(NHPhotoEditorViewController*)photoEditor andImage:(UIImage *)image {
    self = [super init];
    
    if (self) {
        _viewController = photoEditor;
        _image = image;
    }
    
    return self;
}

- (BOOL)canProcessPhoto {
    return YES;
}

@end
