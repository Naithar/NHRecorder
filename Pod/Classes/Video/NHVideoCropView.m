//
//  NHVideoCropView.m
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import "NHVideoCropView.h"

@interface NHVideoCropView ()

@property (nonatomic, assign) CGRect cropRect;

@end

@implementation NHVideoCropView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    [self resetCrop];
}

- (void)resetCrop {
    CGPoint cropCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    CGFloat value = MAX(MIN(self.bounds.size.width, self.bounds.size.height), 0);
    self.cropRect = CGRectMake(cropCenter.x - value / 2, cropCenter.y - value / 2, value, value);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    @autoreleasepool {
        if (!CGSizeEqualToSize(rect.size, CGSizeZero)
            && self.cropRect.size.width > 0
            && self.cropRect.size.height > 0) {
            
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            if (context) {
                
                CGContextAddPath(context, [UIBezierPath bezierPathWithRect:rect].CGPath);
                
                CGPathRef cropPath = NULL;
                UIBezierPath *cropStrokePath;
//                
//                switch (self.cropType) {
//                    case NHPhotoCropTypeCircle:
//                        cropPath = [UIBezierPath bezierPathWithRoundedRect:self.cropRect cornerRadius:self.cropRect.size.width / 2].CGPath;
//                        cropStrokePath = [UIBezierPath bezierPathWithRoundedRect:self.cropRect cornerRadius:self.cropRect.size.width / 2];
//                        break;
//                    default:
                        cropPath = [UIBezierPath bezierPathWithRect:self.cropRect].CGPath;
                        cropStrokePath = [UIBezierPath bezierPathWithRect:self.cropRect];
//                        break;
//                }
                
                if (cropPath) {
                    CGContextAddPath(context, cropPath);
                }
                
                [self.cropBackgroundColor ?: [[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
                CGContextEOFillPath(context);
                
                if (cropStrokePath) {
//                    [[UIColor whiteColor] setStroke];
//                    CGContextSetLineWidth(context, kNHRecorderCornerWidth);
//                    
//                    CGFloat minX = CGRectGetMinX(self.cropRect);
//                    CGFloat minY = CGRectGetMinY(self.cropRect);
//                    CGFloat maxX = CGRectGetMaxX(self.cropRect);
//                    CGFloat maxY = CGRectGetMaxY(self.cropRect);
                    
//                    if (self.cropType != NHPhotoCropTypeCircle) {
//                        CGContextMoveToPoint(context,
//                                             minX - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2,
//                                             minY + kNHRecorderCornerOffset);
//                        CGContextAddLineToPoint(context,
//                                                minX - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2,
//                                                minY - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2);
//                        CGContextAddLineToPoint(context,
//                                                minX + kNHRecorderCornerOffset,
//                                                minY - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2);
//                        
//                        CGContextMoveToPoint(context,
//                                             minX - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2,
//                                             maxY - kNHRecorderCornerOffset);
//                        CGContextAddLineToPoint(context,
//                                                minX - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2,
//                                                maxY + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2);
//                        CGContextAddLineToPoint(context,
//                                                minX + kNHRecorderCornerOffset,
//                                                maxY + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2);
//                        
//                        CGContextMoveToPoint(context,
//                                             maxX + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2,
//                                             minY + kNHRecorderCornerOffset);
//                        CGContextAddLineToPoint(context,
//                                                maxX + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2,
//                                                minY - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2);
//                        CGContextAddLineToPoint(context,
//                                                maxX - kNHRecorderCornerOffset,
//                                                minY - kNHRecorderCornerWidth / 2 + kNHRecorderBorderWidth / 2);
//                        
//                        
//                        CGContextMoveToPoint(context,
//                                             maxX + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2,
//                                             maxY - kNHRecorderCornerOffset);
//                        CGContextAddLineToPoint(context,
//                                                maxX + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2,
//                                                maxY + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2);
//                        CGContextAddLineToPoint(context,
//                                                maxX - kNHRecorderCornerOffset,
//                                                maxY + kNHRecorderCornerWidth / 2 - kNHRecorderBorderWidth / 2);
//                        
//                        
//                        CGContextDrawPath(context, kCGPathStroke);
//                    }
//                    
//                    [[UIColor whiteColor] setStroke];
//                    CGContextAddPath(context, cropStrokePath.CGPath);
//                    CGContextEOClip(context);
//                    
//                    CGContextSetLineWidth(context, kNHRecorderBorderWidth);
//                    CGContextAddPath(context, cropStrokePath.CGPath);
//                    CGContextDrawPath(context, kCGPathStroke);
//                    
//                    CGContextSetLineWidth(context, kNHRecorderLineWidth);
//                    CGFloat width = round(self.cropRect.size.width / 3);
//                    CGFloat height = round(self.cropRect.size.height / 3);
//                    
//                    
//                    [[UIColor whiteColor] setStroke];
//                    CGContextMoveToPoint(context, minX + width, minY);
//                    CGContextAddLineToPoint(context, minX + width, maxY);
//                    
//                    CGContextMoveToPoint(context, maxX - width, minY);
//                    CGContextAddLineToPoint(context, maxX - width, maxY);
//                    
//                    CGContextMoveToPoint(context, minX, minY + height);
//                    CGContextAddLineToPoint(context, maxX, minY + height);
//                    
//                    CGContextMoveToPoint(context, minX, maxY - height);
//                    CGContextAddLineToPoint(context, maxX, maxY - height);
//                    
//                    CGContextDrawPath(context, kCGPathStroke);
                }
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self resetCrop];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    [self resetCrop];
}

@end
