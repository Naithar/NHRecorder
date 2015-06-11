//
//  NHCameraCropCollectionView.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHCameraImageCropView.h"

@class NHCameraCropCollectionView;

@protocol NHCameraCropCollectionViewDelegate <NSObject>

@optional
- (void)cropView:(NHCameraCropCollectionView*)cropView didSelectType:(NHCropType)type;

@end
@interface NHCameraCropCollectionView : UICollectionView

@property (nonatomic, weak) id<NHCameraCropCollectionViewDelegate> nhDelegate;

- (void)setSelected:(NSInteger)index;

@end
