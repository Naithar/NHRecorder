//
//  NHCameraImageCropView.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

typedef NS_ENUM(NSUInteger, NHCropType) {
    NHCropTypeNone,
    NHCropTypeSquare,
    NHCropTypeCircle,
    NHCropType4x3,
    NHCropType16x9,
    NHCropType3x4,
    NHCropType9x16,
};

@interface NHPhotoCaptureCropView : UIScrollView

@property (nonatomic, weak) UIView *overlay;

- (instancetype)initWithImage:(UIImage*)image;
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage*)image;

- (void)sizeContent;
- (void)setFilter:(GPUImageFilter*)filter;
- (BOOL)saveImageWithCallbackObject:(id)obj
                        andSelector:(SEL)selector;
- (void)setCropType:(NHCropType)type;
@end
