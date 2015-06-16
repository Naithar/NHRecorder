//
//  NHCameraImageCropView.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>
#import "NHPhotoCropView.h"

@interface NHPhotoView : UIScrollView


@property (nonatomic, readonly, strong) GPUImageView *contentView;
@property (nonatomic, readonly, strong) NHPhotoCropView *cropView;

- (instancetype)initWithImage:(UIImage*)image;
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage*)image;

- (void)sizeContent;
- (void)processImageWithBlock:(void(^)(UIImage *image))block;
- (void)setCropType:(NHPhotoCropType)type;
- (void)setFilter:(GPUImageFilter*)filter;
@end