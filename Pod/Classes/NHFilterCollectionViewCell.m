//
//  NHFilterCollectionViewCell.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHFilterCollectionViewCell.h"

@interface NHFilterCollectionViewCell ()

@property (nonatomic, strong) UIImageView *filterImageView;
@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic, strong) UILabel *filterLabel;
@end

@implementation NHFilterCollectionViewCell

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
    
    self.backgroundColor = [UIColor blackColor];
    
    self.filterImageView = [[UIImageView alloc] init];
    self.filterImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.filterImageView.backgroundColor = [UIColor blackColor];
    self.filterImageView.layer.cornerRadius = 5;
    self.filterImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.filterImageView];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0 constant:5]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0 constant:50]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0 constant:0]];
    
    self.selectionView = [[UIView alloc] init];
    self.selectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectionView.backgroundColor = [UIColor blackColor];
    self.selectionView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.selectionView.layer.cornerRadius = 7.5;
    self.selectionView.layer.borderWidth = 1;
    self.selectionView.clipsToBounds = YES;
    
    
    [self.contentView insertSubview:self.selectionView atIndex:0];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0 constant:-2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0 constant:-2]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:2]];
    
    self.filterLabel = [[UILabel alloc] init];
    self.filterLabel.textColor = [UIColor whiteColor];
    self.filterLabel.font = [UIFont systemFontOfSize:12];
    self.filterLabel.backgroundColor = [UIColor blackColor];
    self.filterLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterLabel.textAlignment = NSTextAlignmentCenter;
    self.filterLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.filterLabel.numberOfLines = 1;
    
    [self.contentView insertSubview:self.filterLabel atIndex:0];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.filterImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0 constant:5]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0 constant:1]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0 constant:-1]];
    
    
}

//- (void)reloadWithImage:(UIImage*)image
//              andFilter:(SCFilter*)filter {
//    [self reloadWithImage:image
//                andFilter:filter
//               isSelected:NO];
//}
//
//- (void)reloadWithImage:(UIImage*)image
//              andFilter:(SCFilter*)filter
//             isSelected:(BOOL)selected {
//    [self reloadWithImage:image andFilter:filter andName:nil isSelected:selected];
//}
//
//- (void)reloadWithImage:(UIImage*)image
//              andFilter:(SCFilter*)filter
//                andName:(NSString*)name
//             isSelected:(BOOL)selected {
//    self.filterImageView.image = image;
////    [self.filterImageView setImageByUIImage:image];
////    self.filterImageView.filter = filter;
//    self.selectionView.hidden = !selected;
//    self.filterLabel.text = name;
//}
@end
