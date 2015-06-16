//
//  NHCameraFilterView.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHFilterCollectionView.h"
#import "NHFilterCollectionViewCell.h"
#import "UIImage+Resize.h"

@interface NHFilterCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) UIImage *image;
@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, strong) NSArray *outFilters;
@property (nonatomic, strong) NSArray *filterNames;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation NHFilterCollectionView

- (instancetype)initWithImage:(UIImage*)image {
    self = [super init];
    
    if (self) {
        _image = [image rescaleToFill:CGSizeMake(50, 50)];
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
    
    self.filters = @[
                     [[GPUImageFilter alloc] init],
                     [[GPUImageToneCurveFilter alloc] initWithACV:@"1977"],
                     [[GPUImageToneCurveFilter alloc] initWithACV:@"amaro"],
                     [[GPUImageGrayscaleFilter alloc] init],
                     [[GPUImageToneCurveFilter alloc] initWithACV:@"hudson"],
                     [[GPUImageToneCurveFilter alloc] initWithACV:@"mayfair"],
                     [[GPUImageToneCurveFilter alloc] initWithACV:@"nashville"],
                     [[GPUImageToneCurveFilter alloc] initWithACV:@"valencia"],
                      ];
    
    self.outFilters = @[
                         [[GPUImageFilter alloc] init],
                         [[GPUImageToneCurveFilter alloc] initWithACV:@"1977"],
                         [[GPUImageToneCurveFilter alloc] initWithACV:@"amaro"],
                         [[GPUImageGrayscaleFilter alloc] init],
                         [[GPUImageToneCurveFilter alloc] initWithACV:@"hudson"],
                         [[GPUImageToneCurveFilter alloc] initWithACV:@"mayfair"],
                         [[GPUImageToneCurveFilter alloc] initWithACV:@"nashville"],
                         [[GPUImageToneCurveFilter alloc] initWithACV:@"valencia"],
                         ];
    
    self.filterNames = @[
                         NSLocalizedStringFromTable(@"NHRecorder.filter.none", @"NHRecorder", nil),
                         NSLocalizedStringFromTable(@"NHRecorder.filter.1977", @"NHRecorder", nil),
                         NSLocalizedStringFromTable(@"NHRecorder.filter.amaro", @"NHRecorder", nil),
                         NSLocalizedStringFromTable(@"NHRecorder.filter.grayscale", @"NHRecorder", nil),
                         NSLocalizedStringFromTable(@"NHRecorder.filter.hudson", @"NHRecorder", nil),
                         NSLocalizedStringFromTable(@"NHRecorder.filter.mayfair", @"NHRecorder", nil),
                         NSLocalizedStringFromTable(@"NHRecorder.filter.nashville", @"NHRecorder", nil),
                         NSLocalizedStringFromTable(@"NHRecorder.filter.valencia", @"NHRecorder", nil)
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
    return CGSizeMake(self.bounds.size.width / 4 - 5, self.bounds.size.height);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filters.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NHFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    GPUImageFilter *filter;
    
    if (indexPath.row < self.filters.count) {
        filter = self.filters[indexPath.row];
    }
    
    NSString *name;
    if (indexPath.row < self.filterNames.count) {
        name = self.filterNames[indexPath.row];
    }
    
    [cell reloadWithImage:self.image andFilter:filter andName:name isSelected:indexPath.row == self.selectedIndex];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    [self setSelected:indexPath.row];
}

- (void)setSelected:(NSInteger)index {
    self.selectedIndex = index;
    
    [self reloadData];
    
    if (index >= self.outFilters.count) {
        return;
    }

    GPUImageFilter *filter = self.outFilters[index];
    
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(filterView:didSelectFilter:)]) {
        [weakSelf.nhDelegate filterView:weakSelf didSelectFilter:filter];
    }
}


- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
}

@end
