//
//  NHCameraCropCollectionView.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHCameraCropCollectionView.h"

@interface NHCameraCropCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation NHCameraCropCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    UICollectionViewFlowLayout *realLayout = [UICollectionViewFlowLayout new];
    realLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self = [super initWithFrame:frame collectionViewLayout:realLayout];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.delegate = self;
    self.dataSource = self;
    self.scrollsToTop = NO;
    self.bounces = YES;
    self.alwaysBounceVertical = NO;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(65, self.bounds.size.height);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor redColor];
//    SCFilter *filter;
//    
//    if (indexPath.row < self.filters.count) {
//        filter = self.filters[indexPath.row];
//    }
//    
//    NSString *name;
//    if (indexPath.row < self.filterNames.count) {
//        name = self.filterNames[indexPath.row];
//    }
//    
//    [cell reloadWithImage:self.image andFilter:filter andName:name isSelected:indexPath.row == self.selectedIndex];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    
    NHCropType type = NHCropTypeNone;
    
    switch (indexPath.row) {
        case 1:
            type = NHCropTypeSquare;
            break;
        case 2:
            type = NHCropType4x3;
            break;
        case 3:
            type = NHCropType16x9;
            break;
        default:
            break;
    }
    
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(cropView:didSelectType:)]) {
        [weakSelf.nhDelegate cropView:weakSelf didSelectType:type];
    }
    
    [self reloadData];
}

- (void)setSelected:(NSInteger)index {
    self.selectedIndex = index;
    
    [self reloadData];
    
    NHCropType type = NHCropTypeNone;
    
    switch (index) {
        case 1:
            type = NHCropTypeSquare;
            break;
        case 2:
            type = NHCropType4x3;
            break;
        case 3:
            type = NHCropType16x9;
            break;
        default:
            break;
    }
    
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(cropView:didSelectType:)]) {
        [weakSelf.nhDelegate cropView:weakSelf didSelectType:type];
    }
}


- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
}

@end
