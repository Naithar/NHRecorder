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
    
    [self sizeContent];
}

- (void)zoomToPoint:(CGPoint)point andScale:(CGFloat)scale {
//    CGRect zoomRect = CGRectZero;
//    
//    zoomRect.size.width = self.bounds.size.width / scale;
//    zoomRect.size.height = self.bounds.size.height / scale;
//    
//    zoomRect.origin.x = point.x - (zoomRect.size.width / 2);
//    zoomRect.origin.y = point.y - (zoomRect.size.height / 2);
//    
//    [self zoomToRect:zoomRect animated:YES];
//    
//    [self setZoomScale:scale animated:YES];
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
            
            if (ratio > 1.5) {
                if (self.frame.size.height > self.frame.size.width) {
                    bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.height = bounds.size.width / ratio;
                    
                }
                else {
                    bounds.size.width = MAX(self.bounds.size.width, self.bounds.size.height);
                    bounds.size.height = bounds.size.width / ratio;
                    
                }
            }
            else if (ratio < 0.5) {
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
    
    self.contentView.frame = bounds;
    self.contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.contentSize = CGSizeZero;
    
    [self scrollViewDidZoom:self];
}

- (BOOL)saveImageWithCallbackObject:(id)obj andSelector:(SEL)selector {
   UIImage *image = [self.contentView currentlyDisplayedImageWithScale:self.image.scale orientation:self.image.imageOrientation];
    
    UIImageWriteToSavedPhotosAlbum(image, obj, selector, nil);

    return NO;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    scrollView.alwaysBounceVertical = scrollView.zoomScale > 1;
    scrollView.alwaysBounceHorizontal = scrollView.zoomScale > 1;
    
    if (scrollView.zoomScale == self.minimumZoomScale) {
        self.contentSize = CGSizeZero;
        self.contentInset = UIEdgeInsetsZero;
        return;
    }
    
    CGSize zoomedSize = self.contentView.bounds.size;
    zoomedSize.width *= self.zoomScale;
    zoomedSize.height *= self.zoomScale;
    
    CGFloat verticalOffset = 0;
    CGFloat horizontalOffset = 0;
    
    if (zoomedSize.width < self.bounds.size.width) {
        horizontalOffset = (self.bounds.size.width - zoomedSize.width) / 2.0;
    }
    
    if (zoomedSize.height < self.bounds.size.height) {
        verticalOffset = (self.bounds.size.height - zoomedSize.height) / 2.0;
    }
    
    self.contentInset = UIEdgeInsetsMake(verticalOffset - self.contentView.frame.origin.y,
                                         horizontalOffset - self.contentView.frame.origin.x,
                                         verticalOffset + self.contentView.frame.origin.y,
                                         horizontalOffset + self.contentView.frame.origin.x);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}

- (void)dealloc {
}


@end

