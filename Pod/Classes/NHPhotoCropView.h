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
};

@interface NHPhotoCropView : UIView

@property (nonatomic, strong) UIColor *cropBackgroundColor;
@property (nonatomic, assign) CGSize maxCropSize;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) NHPhotoCropType cropType;

- (void)resetCrop;
@end
