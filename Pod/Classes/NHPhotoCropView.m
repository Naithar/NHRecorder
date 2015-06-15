//
//  NHPhotoCropView.m
//  Pods
//
//  Created by Sergey Minakov on 15.06.15.
//
//

#import "NHPhotoCropView.h"

@interface NHPhotoCropView ()

@property (nonatomic, strong) UIImageView *maskImageView;

@end

@implementation NHPhotoCropView

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
    self.cropType = NHPhotoCropTypeCircle;
    self.maxCropSize = CGSizeMake(200, 200);
    
    self.maskImageView = [[UIImageView alloc] init];
//    self.layer.mask = self.maskImageView.layer;
    
//    [self addSubview:self.maskImageView];
    
    [self resetCrop];
}

- (void)resetCrop {
    CGPoint cropCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    switch (self.cropType) {
        case NHPhotoCropTypeNone:
            self.hidden = YES;
            self.cropRect = CGRectZero;
            return;
        case NHPhotoCropTypeSquare: {
            self.hidden = NO;
            CGFloat value = MIN(self.maxCropSize.width, self.maxCropSize.height);
            self.cropRect = CGRectMake(cropCenter.x - value / 2, cropCenter.y - value / 2, value, value);
        } break;
        case NHPhotoCropTypeCircle: {
            self.hidden = NO;
            CGFloat value = MIN(self.maxCropSize.width, self.maxCropSize.height);
            self.cropRect = CGRectMake(cropCenter.x - value / 2, cropCenter.y - value / 2, value, value);
        } break;
        default:
            break;
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (context) {
            
            CGContextAddPath(context, [UIBezierPath bezierPathWithRect:self.bounds].CGPath);
            
            CGPathRef cropPath = NULL;
            CGPathRef cropStrokePath = NULL;
            
            switch (self.cropType) {
                case NHPhotoCropTypeSquare:
                    cropPath = [UIBezierPath bezierPathWithRect:self.cropRect].CGPath;
                    cropStrokePath = [UIBezierPath bezierPathWithRect:self.cropRect].CGPath;
                    break;
                case NHPhotoCropTypeCircle:
                    cropPath = [UIBezierPath bezierPathWithRoundedRect:self.cropRect cornerRadius:self.cropRect.size.width / 2].CGPath;
                    cropStrokePath = [UIBezierPath bezierPathWithRoundedRect:self.cropRect cornerRadius:self.cropRect.size.width / 2].CGPath;
                    break;
                default:
                    break;
            }
            
            if (cropPath) {
                CGContextAddPath(context, cropPath);
            }
            
            [self.cropBackgroundColor ?: [[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
            CGContextEOFillPath(context);
            
            [[[UIColor whiteColor] colorWithAlphaComponent:0.5] setStroke];
            CGContextSetLineWidth(context, 2);
            CGContextAddPath(context, cropStrokePath);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
}

- (void)setCropType:(NHPhotoCropType)cropType {
    [self willChangeValueForKey:@"cropType"];
    _cropType = cropType;
    [self didChangeValueForKey:@"cropType"];
}
@end
