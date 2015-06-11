//
//  NHCameraImageCropView.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHCameraImageCropView.h"
#import <SCFilterSelectorViewInternal.h>

@interface NHCameraImageCropView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) SCFilterSelectorView *contentView;
@property (nonatomic, assign) NHCropType cropType;

@property (nonatomic, strong) UIView *cropView;

@end

@implementation NHCameraImageCropView

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
    
    self.contentView = [[SCFilterSelectorView alloc] init];
    [self.contentView setImageByUIImage:self.image];
    self.contentView.backgroundColor = [UIColor greenColor];
    [self addSubview:self.contentView];
    
    self.cropView = [[UIView alloc] init];
    self.cropView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    self.cropView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cropView.layer.borderWidth = 1;
    self.cropView.clipsToBounds = YES;
    [self addSubview:self.cropView];
    
    [self sizeContent];
}


- (void)setCropType:(NHCropType)type {
//    _cropType = type;
    
    _cropType = NHCropTypeNone;
    [self resetCropAnimated:YES];
    
    _cropType = type;
    [self resetCropAnimated:YES];
}
- (void)setFilter:(SCFilter*)filter {
    self.contentView.filters = @[filter];
    self.contentView.selectedFilter = filter;
    
    [self.contentView refresh];
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
        self.contentView.frame = bounds;
        self.contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        self.contentSize = CGSizeZero;
        
        [self resetCropAnimated:NO];
        
        [self scrollViewDidZoom:self];
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
            cropRect.size.width = round(height / 4 * 3);
            cropRect.size.height = height;
            break;
        default:
            break;
    }
    

    self.cropView.frame = cropRect;
    self.cropView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    CGFloat newValue = 1;

    self.minimumZoomScale = newValue;
    [self setZoomScale:newValue animated:animated];
}

- (BOOL)saveImageWithCallbackObject:(id)obj andSelector:(SEL)selector {
    UIImage *image;
    if((image = [self.contentView
                 currentlyDisplayedImageWithScale:self.image.scale
                 orientation:self.image.imageOrientation])) {
        
        UIImage *resultImage;
        
        switch (self.cropType) {
            case NHCropTypeNone:
                resultImage = image;
                break;
            case NHCropTypeSquare:
            case NHCropType4x3:
            case NHCropType16x9:
            case NHCropTypeCircle: {
                
                CGRect newRect =  [self convertRect:self.cropView.frame toView:self.contentView];
                
                CGFloat ratio = self.image.size.height / self.contentView.bounds.size.height;
                CGFloat resultWidth = round(ratio * newRect.size.width);
                CGFloat resultHeight = round(ratio * newRect.size.height);
                CGFloat resultXOffset = round(ratio * newRect.origin.x);
                CGFloat resultYOffset = round(ratio * newRect.origin.y);
                
                if (resultXOffset < 0) {
                    resultWidth += resultXOffset;
                    resultXOffset = 0;
                }
                
                if (resultYOffset < 0) {
                    resultHeight += resultYOffset;
                    resultYOffset = 0;
                }
                
                CGRect resultRect = CGRectMake(
                                               (image.imageOrientation == UIImageOrientationUp
                                                || image.imageOrientation == UIImageOrientationDown)
                                               ? resultXOffset : resultYOffset,
                                               (image.imageOrientation == UIImageOrientationUp
                                                || image.imageOrientation == UIImageOrientationDown)
                                               ? resultYOffset : resultXOffset,
                                               (image.imageOrientation == UIImageOrientationUp
                                                || image.imageOrientation == UIImageOrientationDown)
                                               ? resultWidth : resultHeight,
                                               (image.imageOrientation == UIImageOrientationUp
                                                || image.imageOrientation == UIImageOrientationDown)
                                               ? resultHeight : resultWidth);
                
                if (resultRect.size.width != 0
                    && resultRect.size.height != 0) {
                    resultImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, resultRect) scale:image.scale orientation:image.imageOrientation];
                }
            } break;
            default:
                break;
        }
        
        if (resultImage) {
            UIImageWriteToSavedPhotosAlbum(resultImage, obj, selector, nil);
            return YES;
        }
    }

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
