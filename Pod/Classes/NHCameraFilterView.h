//
//  NHCameraFilterView.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

@class NHCameraFilterView;

@protocol NHCameraFilterViewDelegate <NSObject>

@optional
- (void)filterView:(NHCameraFilterView*)filteView didSelectFilter:(GPUImageFilter*)filter;

@end

@interface NHCameraFilterView : UICollectionView

@property (nonatomic, weak) id<NHCameraFilterViewDelegate> nhDelegate;

- (instancetype)initWithImage:(UIImage*)image;

- (void)setSelected:(NSInteger)index;
@end
