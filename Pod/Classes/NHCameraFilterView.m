//
//  NHCameraFilterView.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHCameraFilterView.h"
#import "NHFilterCollectionViewCell.h"

@interface NHCameraFilterView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) UIImage *image;
@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, strong) NSArray *filterNames;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation NHCameraFilterView

- (instancetype)initWithImage:(UIImage*)image {
    self = [super init];
    
    if (self) {
        _image = image;
    }
    
    return self;
}

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
//    self.filters = @[
//                     [SCFilter emptyFilter],
//                     [SCFilter filterWithCIFilterName:@"CIPhotoEffectMono"],
//                     [SCFilter filterWithCIFilterName:@"CIPhotoEffectNoir"],
//                     [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"],
//                     [SCFilter filterWithCIFilterName:@"CIColorClamp"],
//                     [SCFilter filterWithCIFilterName:@"CIColorMonochrome"],
//                     [SCFilter filterWithCIFilterName:@"CIPhotoEffectChrome"],
//                     [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"],
//                     [SCFilter filterWithCIFilterName:@"CIPhotoEffectTransfer"],
//                     [SCFilter filterWithCIFilterName:@"CISepiaTone"],
//                     ];
    
    self.filterNames = @[
                         @"original",
                         @"mono",
                         @"noir",
                         @"fade",
                         @"clamp",
                         @"monochrome",
                         @"chrome",
                         @"instant",
                         @"transfer",
                         @"sepiatone"
                         ];
    
    self.delegate = self;
    self.dataSource = self;
    self.scrollsToTop = NO;
    self.bounces = YES;
    self.alwaysBounceVertical = NO;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    [self registerClass:[NHFilterCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(65, self.bounds.size.height);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NHFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    
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
    
    if (indexPath.row >= self.filters.count) {
        return;
    }
    
    self.selectedIndex = indexPath.row;
//    
//    SCFilter *filter = self.filters[indexPath.row];
//    
//    
//    __weak __typeof(self) weakSelf = self;
//    if ([weakSelf.nhDelegate respondsToSelector:@selector(filterView:didSelectFilter:)]) {
//        [weakSelf.nhDelegate filterView:weakSelf didSelectFilter:filter];
//    }
    
    [self reloadData];
}

- (void)setSelected:(NSInteger)index {
    self.selectedIndex = index;
    
    [self reloadData];
    
    if (index >= self.filters.count) {
        return;
    }
//
//    SCFilter *filter = self.filters[index];
//    
//    __weak __typeof(self) weakSelf = self;
//    if ([weakSelf.nhDelegate respondsToSelector:@selector(filterView:didSelectFilter:)]) {
//        [weakSelf.nhDelegate filterView:weakSelf didSelectFilter:filter];
//    }
}


- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
}

@end
