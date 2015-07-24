//
//  NHPhotoCropView.h
//  Pods
//
//  Created by Sergey Minakov on 15.06.15.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NHPhotoCropType) {
    NHPhotoCropTypeNone,
    NHPhotoCropTypeSquare,
    NHPhotoCropTypeCircle,
    NHPhotoCropType4x3,
    NHPhotoCropType16x9,
    NHPhotoCropType3x4
};

@interface NHPhotoCropView : UIView

@property (nonatomic, strong) UIColor *cropBackgroundColor;
@property (nonatomic, assign) CGSize maxCropSize;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, assign) NHPhotoCropType cropType;

- (void)resetCrop;
@end
