//
//  NHCameraImageCropView.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import <SCRecorder.h>
@interface NHCameraImageCropView : UIScrollView

- (instancetype)initWithImage:(UIImage*)image;
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage*)image;

- (void)sizeContent;
- (void)setFilter:(SCFilter*)filter;
- (BOOL)saveImageWithCallbackObject:(id)obj
                        andSelector:(SEL)selector;
@end
