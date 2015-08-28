//
//  NHVideoEditorView.m
//  Pods
//
//  Created by Sergey Minakov on 28.08.15.
//
//

#import "NHVideoEditorView.h"

@implementation NHVideoEditorView


- (instancetype)initWithEditorViewController:(NHVideoEditorViewController*)editorController andAssetURL:(NSURL*)assetURL{
    self = [super init];
    
    if (self) {
        _viewController = editorController;
        _assetURL = assetURL;
    }
    
    return self;
}

- (BOOL)canProcessVideo {
    return YES;
}


//http://stackoverflow.com/questions/1347562/getting-thumbnail-from-a-video-url-or-data-in-iphone-sdk
-(UIImage *)generateThumbImage:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 1;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}
@end
