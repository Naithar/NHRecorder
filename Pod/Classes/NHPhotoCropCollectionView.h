//
//  NHCameraCropCollectionView.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHPhotoCaptureCropView.h"

@class NHPhotoCropCollectionView;

@protocol NHPhotoCropCollectionViewDelegate <NSObject>

@optional
- (void)cropView:(NHPhotoCropCollectionView*)cropView didSelectType:(NHCropType)type;

@end
@interface NHPhotoCropCollectionView : UICollectionView

@property (nonatomic, weak) id<NHPhotoCropCollectionViewDelegate> nhDelegate;

- (void)setSelected:(NSInteger)index;

@end
