//
//  NHCropCollectionViewCell.m
//  Pods
//
//  Created by Sergey Minakov on 15.06.15.
//
//

#import "NHCropCollectionViewCell.h"

@interface NHCropCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation NHCropCollectionViewCell


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
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.layer.cornerRadius = 5;
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.textLabel];
    
    [self setupImageViewConstraints];
    
    [self setupTextLabelConstraints];
}

- (void)setupImageViewConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0 constant:0]];
    
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.imageView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:0 constant:50]];
    
    
    [self.imageView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.imageView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0 constant:0]];
}

- (void)setupTextLabelConstraints {
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.imageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:2]];
    
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0 constant:2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:-2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:0]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.textLabel.text = nil;
}

- (void)reloadWithType:(NHPhotoCropType)type {
    [self reloadWithType:type andSelected:NO];
}

- (void)reloadWithType:(NHPhotoCropType)type andSelected:(BOOL)selected {
    NSString *text;
    UIImage *image;
    
    switch (type) {
        case NHPhotoCropTypeNone:
            text = @"original";
            image = (selected
            ? [UIImage imageNamed:@"NHRecorder.crop.none-active.png"]
            : [UIImage imageNamed:@"NHRecorder.crop.none.png"]);
            break;
        case NHPhotoCropTypeSquare:
            text = @"square";
            image = (selected
            ? [UIImage imageNamed:@"NHRecorder.crop.square-active.png"]
            : [UIImage imageNamed:@"NHRecorder.crop.square.png"]);
            break;
        case NHPhotoCropType4x3:
            text = @"4:3";
            image = selected
            ? [UIImage imageNamed:@"NHRecorder.crop.4x3-active.png"]
            : [UIImage imageNamed:@"NHRecorder.crop.4x3.png"];
            break;
        case NHPhotoCropType16x9:
            text = @"16:9";
            image = selected
            ? [UIImage imageNamed:@"NHRecorder.crop.16x9-active.png"]
            : [UIImage imageNamed:@"NHRecorder.crop.16x9.png"];
            break;
        case NHPhotoCropType3x4:
            text = @"3:4";
            image = selected
            ? [UIImage imageNamed:@"NHRecorder.crop.3x4-active.png"]
            : [UIImage imageNamed:@"NHRecorder.crop.3x4.png"];
            break;
        default:
            break;
    }
    
    self.imageView.image = image;
    self.textLabel.text = text;
}
@end
