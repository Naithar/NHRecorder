//
//  NHCameraFilterView.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

@class NHFilterCollectionView;

@protocol NHFilterCollectionViewDelegate <NSObject>

@optional
- (void)filterView:(NHFilterCollectionView*)filteView didSelectFilter:(GPUImageFilter*)filter;

@end

@interface NHFilterCollectionView : UICollectionView

@property (nonatomic, weak) id<NHFilterCollectionViewDelegate> nhDelegate;

- (instancetype)initWithImage:(UIImage*)image;

- (void)setSelected:(NSInteger)index;
@end
