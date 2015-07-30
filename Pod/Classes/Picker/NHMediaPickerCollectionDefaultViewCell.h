//
//  NHMediaPickerCollectionViewCell.h
//  Pods
//
//  Created by Sergey Minakov on 15.06.15.
//
//

#import <UIKit/UIKit.h>
@import AssetsLibrary;

@interface NHMediaPickerCollectionDefaultViewCell : UICollectionViewCell

@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) UILabel *durationLabel;

- (void)reloadWithAsset:(ALAsset*)asset;

@end