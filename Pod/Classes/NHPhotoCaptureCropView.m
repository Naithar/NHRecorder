//
//  NHCameraImageCropView.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHPhotoCaptureCropView.h"
//#import <SCFilterSelectorViewInternal.h>
#import <GPUImage.h>

@interface NHPhotoCaptureCropView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) GPUImageView *contentView;
@property (nonatomic, strong) GPUImagePicture *picture;
@property (nonatomic, strong) GPUImageFilter *collectionFilter;
@property (nonatomic, strong) GPUImageCropFilter *cropFilter;
@property (nonatomic, strong) GPUImageFilter *rotationFilter;
@property (nonatomic, assign) NHCropType cropType;

@property (nonatomic, strong) UIView *cropView;

@end

@implementation NHPhotoCaptureCropView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage*)image {
    return [self initWithFrame:CGRectZero image:image];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame image:nil];
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage*)image {
    self = [super initWithFrame:frame];
    
    if (self) {
        _image = image;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.cropType = NHCropTypeNone;
    
    self.delegate = self;
    self.bounces = YES;
    self.alwaysBounceVertical = NO;
    self.alwaysBounceHorizontal = NO;
    self.minimumZoomScale = 1;
    self.maximumZoomScale = 5;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView = [[GPUImageView alloc] init];

    [self addSubview:self.contentView];
    
//    [self.contentView setImageByUIImage:self.image];
    self.contentView.backgroundColor = [UIColor greenColor];
    
//    @autoreleasepool {
    
    
    
//    self.contentView.image = [picture imageFromCurrentFramebuffer];
    
//    [filter addTarget:self.contentView];
    
//    [self.filter useNextFrameForImageCapture];
    
    
//    self.contentView.image = [filter imageFromCurrentFramebuffer];
    
    
    
    
    
    self.cropView = [[UIView alloc] init];
    self.cropView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.cropView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cropView.layer.borderWidth = 1;
    self.cropView.clipsToBounds = YES;
    [self addSubview:self.cropView];
    
    [self sizeContent];
    
    self.picture = [[GPUImagePicture alloc] initWithImage:self.image smoothlyScaleOutput:NO];
    self.cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];
    self.rotationFilter = [[GPUImageFilter alloc] init];
    
    GPUImageRotationMode newRotation = kGPUImageNoRotation;
    
    switch (self.image.imageOrientation) {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            newRotation = kGPUImageRotateLeft;
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            newRotation = kGPUImageRotateRight;
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            newRotation = kGPUImageRotate180;
            break;
        default:
            break;
    }
    [self.rotationFilter setInputRotation:newRotation atIndex:0];
    
//    [self.transformFilter setAffineTransform:CGAffineTransformMakeRotation(M_PI_2)];
    
    self.collectionFilter = [[GPUImageFilter alloc] init];
    
//    self.picture = nil;
    [self.picture addTarget:self.rotationFilter];
    
    
    [self.rotationFilter addTarget:self.collectionFilter];
    [self.collectionFilter addTarget:self.cropFilter];
    [self.collectionFilter addTarget:self.contentView];
    
    if (self.window) {
        [self.picture processImage];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = self.image;
    [self addSubview:imageView];
    
//    self.contentView.image = [self.filter imageFromCurrentFramebuffer];
//    [self.filter addTarget:self.contentView];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//[self.picture processImage];
//    });
//    [self.picture processImage];
//    [self.picture processImage];
//    [self.picture processImage];
//    [self.picture processImage];
    
//    }
}




- (void)layoutSubviews {
    [super layoutSubviews];
    
//    [self.filter addTarget:self.contentView];
//    [self.filter useNextFrameForImageCapture];
//    [self.picture processImage];
//    [self.picture processImage];
//    [self.picture processImage];
//    [self.picture processImage];
    
}

- (void)setCropType:(NHCropType)type {
////    _cropType = type;
//    
    _cropType = NHCropTypeNone;
    [self resetCropAnimated:YES];
    
    _cropType = type;
    [self resetCropAnimated:YES];
}
- (void)setFilter:(GPUImageFilter*)filter {
    
    [self.rotationFilter removeTarget:self.collectionFilter];
    
    self.collectionFilter = filter;
    
    [self.rotationFilter addTarget:self.collectionFilter];
    [self.collectionFilter addTarget:self.cropFilter];
    [self.collectionFilter addTarget:self.contentView];
    
    if (self.window) {
        [self.picture processImage];
    }
//    self.contentView.filters = @[filter];
//    self.contentView.selectedFilter = filter;
    
//    [self.contentView setNeedsDisplay];
}

- (void)sizeContent {
    CGRect bounds = self.image ? (CGRect) { .size = self.image.size } : self.contentView.frame;
    
    if (bounds.size.height) {
        CGFloat ratio = bounds.size.width / bounds.size.height;
        
        if (ratio) {
            
            if (ratio > 1) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.height = bounds.size.width / ratio;
                    
                }
                else {
                    bounds.size.width = MAX(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.height = bounds.size.width / ratio;
                    
                }
            }
            else if (ratio < 1) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.height = MAX(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.width = bounds.size.height * ratio;
                }
                else {
                    bounds.size.height = MIN(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.width = bounds.size.height * ratio;
                }
            }
            else {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.height = MAX(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.width = bounds.size.height * ratio;
                }
                else {
                    bounds.size.width = MAX(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.height = bounds.size.width / ratio;
                }
            }
        }
    }
    
    if (!CGRectEqualToRect(self.contentView.bounds, bounds)) {
        
        [self.collectionFilter removeTarget:self.contentView];
        
        self.contentView.frame = bounds;
        
        [self.collectionFilter addTarget:self.contentView];
        
        
        self.contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        self.contentSize = CGSizeZero;
        
        [self resetCropAnimated:NO];
        
        [self scrollViewDidZoom:self];
    }
    
    if (self.window) {
        [self.picture processImage];
    }
}

- (void)resetCropAnimated:(BOOL)animated {
//    
    CGRect cropRect = CGRectZero;
    
    CGFloat width = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat height = MIN(self.bounds.size.width, self.bounds.size.height);
    
    switch (self.cropType) {
        case NHCropTypeNone:
            self.cropView.hidden = YES;
            self.minimumZoomScale = 1;
            [self setZoomScale:1 animated:animated];
            [self scrollViewDidZoom:self];
            return;
        case NHCropTypeSquare: {
            self.cropView.hidden = NO;
            self.cropView.layer.cornerRadius = 0;
            cropRect.size.width = width;
            cropRect.size.height = width;
            
        } break;
        case NHCropTypeCircle: {
            self.cropView.hidden = NO;
            self.cropView.layer.cornerRadius = width / 2;
            cropRect.size.width = width;
            cropRect.size.height = width;
        } break;
        case NHCropType4x3:
            self.cropView.hidden = NO;
            self.cropView.layer.cornerRadius = 0;
            cropRect.size.width = width;
            cropRect.size.height = round(width / 4 * 3);
            break;
        case NHCropType16x9:
            self.cropView.hidden = NO;
            self.cropView.layer.cornerRadius = 0;
            cropRect.size.width = width;
            cropRect.size.height = round(width / 16 * 9);
            break;
        case NHCropType3x4:
            self.cropView.hidden = NO;
            self.cropView.layer.cornerRadius = 0;
            cropRect.size.width = round(height / 4 * 3);
            cropRect.size.height = height;
            break;
        case NHCropType9x16:
            self.cropView.hidden = NO;
            self.cropView.layer.cornerRadius = 0;
            cropRect.size.width = round(height / 16 * 9);
            cropRect.size.height = height;
            break;
        default:
            break;
    }
    

    self.cropView.frame = cropRect;
    self.cropView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    CGFloat newValue = 1;

    if (self.cropView.bounds.size.width > self.cropView.bounds.size.height) {
        newValue = self.cropView.bounds.size.width / self.contentView.bounds.size.width;
    }
    else if (self.cropView.bounds.size.width < self.cropView.bounds.size.height) {
        newValue = self.cropView.bounds.size.height / self.contentView.bounds.size.height;
    }
    else {
        newValue = self.contentView.bounds.size.width <= self.contentView.bounds.size.height
        ? self.cropView.bounds.size.width / self.contentView.bounds.size.width
        : self.cropView.bounds.size.height / self.contentView.bounds.size.height;
    }
    
    self.minimumZoomScale = newValue;
    [self setZoomScale:newValue animated:animated];
    [self scrollViewDidZoom:self];
}

- (BOOL)saveImageWithCallbackObject:(id)obj andSelector:(SEL)selector {

    switch (self.cropType) {
            case NHCropTypeNone:
                break;
            case NHCropTypeSquare:
            case NHCropType4x3:
            case NHCropType16x9:
            case NHCropType9x16:
            case NHCropType3x4:
            case NHCropTypeCircle: {
                
                CGRect newRect = [self convertRect:self.cropView.frame toView:self.contentView];
                
//                CGFloat ratio = self.image.size.height / self.contentView.bounds.size.height;
                CGFloat resultWidth = newRect.size.width;
                CGFloat resultHeight = newRect.size.height;
                CGFloat resultXOffset = newRect.origin.x;
                CGFloat resultYOffset = newRect.origin.y;
                
                
//                UIImageOrientation newOrientation = self.image.imageOrientation;
//                
//                switch (self.image.imageOrientation) {
//                    case UIImageOrientationLeftMirrored:
//                        newOrientation = UIImageOrientationRightMirrored;
//                        break;
//                    case UIImageOrientationRightMirrored:
//                        newOrientation = UIImageOrientationLeftMirrored;
//                        break;
//                    default:
//                        break;
//                }
//                
//                switch (self.image.imageOrientation) {
//                    case UIImageOrientationDown:
//                    case UIImageOrientationDownMirrored:
//                        resultXOffset = self.contentView.bounds.size.width - resultWidth - resultXOffset;
//                        resultYOffset = self.contentView.bounds.size.height - resultHeight - resultYOffset;
//                        break;
//                    case UIImageOrientationRight: {
//                        CGFloat oldWidth = resultWidth;
//                        CGFloat oldHeight = resultHeight;
//                        CGFloat oldX = resultXOffset;
//                        CGFloat oldY = resultYOffset;
//                        
//                        resultXOffset = oldY;
//                        resultYOffset = self.contentView.bounds.size.width - oldWidth - oldX;
//                        
//                        resultHeight = oldWidth;
//                        resultWidth = oldHeight;
//                    } break;
//                    case UIImageOrientationLeftMirrored: {
//                        CGFloat oldWidth = resultWidth;
//                        CGFloat oldHeight = resultHeight;
//                        CGFloat oldX = resultXOffset;
//                        CGFloat oldY = resultYOffset;
//                        
//                        resultXOffset = oldY;
//                        resultYOffset = oldX;
//                        
//                        resultHeight = oldWidth;
//                        resultWidth = oldHeight;
//
//                    } break;
//                    case UIImageOrientationLeft: {
//                        CGFloat oldWidth = resultWidth;
//                        CGFloat oldHeight = resultHeight;
//                        CGFloat oldX = resultXOffset;
//                        CGFloat oldY = resultYOffset;
//                        
//                        resultXOffset = self.contentView.bounds.size.height - oldHeight - oldY;
//                        resultYOffset = oldX;
//                        
//                        resultHeight = oldWidth;
//                        resultWidth = oldHeight;
//                    } break;
//                    case UIImageOrientationRightMirrored: {
//                        CGFloat oldWidth = resultWidth;
//                        CGFloat oldHeight = resultHeight;
//                        CGFloat oldX = resultXOffset;
//                        CGFloat oldY = resultYOffset;
//                        
//                        resultXOffset = self.contentView.bounds.size.height - oldHeight - oldY;
//                        resultYOffset = self.contentView.bounds.size.width - oldWidth - oldX;
//                        
//                        resultHeight = oldWidth;
//                        resultWidth = oldHeight;
//                    } break;
//                    default:
//                        break;
//                }
//                
                CGRect resultRect = CGRectMake(
                                               resultXOffset / self.contentView.bounds.size.width,
                                               resultYOffset / self.contentView.bounds.size.height,
                                               resultWidth / self.contentView.bounds.size.width,
                                               resultHeight / self.contentView.bounds.size.height);

                
                if (resultRect.size.width != 0
                    && resultRect.size.height != 0) {
                    
                    [self.cropFilter setCropRegion:resultRect];
//                    [self.cropFilter useNextFrameForImageCapture];
//                    resultImage = [self.cropFilter imageFromCurrentFramebuffer];
                    
                }
            } break;
            default:
                break;
        }
    
    [self.picture processImageUpToFilter:self.cropFilter withCompletionHandler:^(UIImage *processedImage) {
        UIImageWriteToSavedPhotosAlbum(processedImage, obj, selector, nil);

    }];
    
//        if (resultImage) {
//            return YES;
//        }

    return NO;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    
    CGSize zoomedSize = self.contentView.bounds.size;
    zoomedSize.width *= self.zoomScale;
    zoomedSize.height *= self.zoomScale;
    
    CGFloat verticalOffset = 0;
    CGFloat horizontalOffset = 0;
    
    if (zoomedSize.height < self.bounds.size.height) {
        verticalOffset = (self.bounds.size.height - zoomedSize.height) / 2.0;
    }
    
    if (zoomedSize.width < self.bounds.size.width) {
        horizontalOffset = (self.bounds.size.width - zoomedSize.width) / 2.0;
    }
    
    CGFloat cropVerticalOffset = 0;
    CGFloat cropHorizontalOffset = 0;
    
    if (self.cropType != NHCropTypeNone) {
        cropVerticalOffset = (self.bounds.size.height - self.cropView.bounds.size.height) / 2 - verticalOffset;
        cropHorizontalOffset = (self.bounds.size.width - self.cropView.bounds.size.width) / 2 - horizontalOffset;
    }
    else if (self.zoomScale == 1) {
        self.contentSize = CGSizeZero;
        self.contentInset = UIEdgeInsetsZero;
        self.cropView.center = CGPointMake(
                                           self.bounds.size.width / 2,
                                           self.bounds.size.height / 2);
        return;
    }
    
    self.contentInset = UIEdgeInsetsMake(verticalOffset - self.contentView.frame.origin.y + cropVerticalOffset,
                                         horizontalOffset - self.contentView.frame.origin.x + cropHorizontalOffset,
                                         verticalOffset + self.contentView.frame.origin.y + cropVerticalOffset,
                                         horizontalOffset + self.contentView.frame.origin.x + cropHorizontalOffset);
    
    self.cropView.center = CGPointMake(scrollView.contentOffset.x + scrollView.bounds.size.width / 2,
                                       scrollView.contentOffset.y + scrollView.bounds.size.height / 2);
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.cropView.center = CGPointMake(
                                       scrollView.contentOffset.x + scrollView.bounds.size.width / 2,
                                       scrollView.contentOffset.y + scrollView.bounds.size.height / 2);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)dealloc {
}


@end

