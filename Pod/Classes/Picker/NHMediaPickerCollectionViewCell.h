//
//  NHMediaPickerCollectionViewCell.h
//  Pods
//
//  Created by Sergey Minakov on 30.07.15.
//
//

#import <UIKit/UIKit.h>
@import AssetsLibrary;

@interface NHMediaPickerCollectionViewCell : UICollectionViewCell

- (void)reloadWithAsset:(ALAsset*)asset;

+ (NSString *)formatTime:(long)totalSeconds;

@end
