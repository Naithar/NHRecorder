//
//  NHImagePickerViewController.m
//  Pods
//
//  Created by Sergey Minakov on 12.06.15.
//
//

#import "NHMediaPickerViewController.h"
#import "NHMediaPickerCollectionViewCell.h"
#import "NHPhotoCaptureViewController.h"
#import "NHPhotoEditorViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Resize.h"

const CGFloat kNHRecorderCollectionViewSpace = 1;

@interface NHMediaPickerViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *photoCollectionViewLayout;
@property (nonatomic, strong) NSArray *mediaItems;
@property (nonatomic, strong) ALAssetsLibrary *mediaLibrary;
@property (nonatomic, strong) UIBarButtonItem *closeButton;
@end

@implementation NHMediaPickerViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
    self.mediaItems = @[];
    
    self.mediaLibrary = [[ALAssetsLibrary alloc] init];
    
    self.linksToCamera = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.closeButton = [[UIBarButtonItem alloc]
                        initWithImage:[UIImage imageNamed:@"NHRecorder.back.png"]
                        style:UIBarButtonItemStylePlain target:self
                        action:@selector(closeButtonTouch:)];
    
    self.navigationItem.leftBarButtonItem = self.closeButton;
    
    self.photoCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.photoCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.photoCollectionViewLayout];
    self.photoCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoCollectionView.backgroundColor = [UIColor whiteColor];
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [self.photoCollectionView registerClass:[NHMediaPickerCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.photoCollectionView.scrollsToTop = YES;
    self.photoCollectionView.bounces = YES;
    self.photoCollectionView.alwaysBounceVertical = YES;
    
    [self.view addSubview:self.photoCollectionView];
    
    [self setupCollectionViewConstraints];
    
    [self loadImagesFromLibrary];
}

//MARK: setup

- (void)setupCollectionViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCollectionView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCollectionView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCollectionView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoCollectionView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
}

- (void)loadImagesFromLibrary {
    
    __weak __typeof(self) weakSelf = self;
    [self.mediaLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               if (group
                                   && group.numberOfAssets > 0) {
                                   __strong __typeof(weakSelf) strongSelf = weakSelf;
                                   
                                   NSLog(@"group %@", group);
                                   
                                   NSString *newTitle = [group valueForProperty:ALAssetsGroupPropertyName];
                                   NSMutableArray *newArray = [[NSMutableArray alloc] init];
                                   
                                   [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                       NSString *type = [result valueForProperty:ALAssetPropertyType];
                                       if ([type isEqualToString:ALAssetTypeVideo]) {
                                       }
                                       else if ([type isEqualToString:ALAssetTypePhoto]) {
                                           [newArray insertObject:result atIndex:0];
                                       }
                                   }];
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       strongSelf.navigationItem.title = newTitle;
                                       strongSelf.mediaItems = newArray;
                                       [strongSelf.photoCollectionView reloadData];
                                   });
                                   
                                   *stop = YES;
                               }
                           } failureBlock:^(NSError *error) {
                               NSLog(@"library error = %@", error);
                           }];
}

//MARK: buttons

- (void)closeButtonTouch:(id)sender {
    if (self.firstController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//MARK: collection view

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat cellWidth = width / 4 - kNHRecorderCollectionViewSpace;
    return CGSizeMake(cellWidth, cellWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kNHRecorderCollectionViewSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kNHRecorderCollectionViewSpace;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mediaItems.count + (self.linksToCamera ? 1 : 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NHMediaPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSInteger itemNumber = indexPath.row;
    
    if (self.linksToCamera) {
        itemNumber--;
    }
    
    if (itemNumber < 0) {
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.imageView.image = [UIImage imageNamed:@"NHRecorder.photo.png"];
    }
    else {
        if (itemNumber < self.mediaItems.count) {
            ALAsset *asset = self.mediaItems[itemNumber];
            cell.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
        }
        
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemNumber = indexPath.row;
    
    if (self.linksToCamera) {
        itemNumber--;
    }
    
    if (itemNumber < 0) {
        NHPhotoCaptureViewController *viewController = [[NHPhotoCaptureViewController alloc] init];
        viewController.firstController = NO;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        if (itemNumber < self.mediaItems.count) {
            ALAsset *asset = self.mediaItems[itemNumber];
            
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            CGFloat scale = [representation scale];
            UIImageOrientation orientation = UIImageOrientationUp;
            NSNumber* orientationValue = [asset valueForProperty:ALAssetPropertyOrientation];
            if (orientationValue != nil) {
                orientation = [orientationValue intValue];
            }
            
            UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:scale orientation:orientation];
            
            if (image) {
                UIImage *resultImage;
                CGSize imageSizeToFit = CGSizeZero;
                
                __weak __typeof(self) weakSelf = self;
                if ([weakSelf.nhDelegate respondsToSelector:@selector(imageSizeToFitForMediaPicker:)]) {
                    imageSizeToFit = [weakSelf.nhDelegate imageSizeToFitForMediaPicker:weakSelf];
                }
                
                if (CGSizeEqualToSize(imageSizeToFit, CGSizeZero)) {
                    resultImage = image;
                }
                else {
                    resultImage = [image resizedImageToFitInSize:imageSizeToFit scaleIfSmaller:YES];
                }
                
                if (resultImage) {
                    BOOL shouldEdit = YES;
                    
                    __weak __typeof(self) weakSelf = self;
                    if ([weakSelf.nhDelegate respondsToSelector:@selector(mediaPicker:shouldEditImage:)]) {
                        shouldEdit = [weakSelf.nhDelegate mediaPicker:weakSelf shouldEditImage:resultImage];
                    }
                    NHPhotoEditorViewController *viewController = [[NHPhotoEditorViewController alloc] initWithUIImage:image];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
            }
        }
    }
    
}

//MARK: setters

- (void)setLinksToCamera:(BOOL)linksToCamera {
    [self willChangeValueForKey:@"linksToCamera"];
    _linksToCamera = linksToCamera;
    [self.photoCollectionView reloadData];
    [self didChangeValueForKey:@"linksToCamera"];
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barTintColor = barTintColor;
    self.navigationController.navigationBar.barTintColor = barTintColor ?: [UIColor whiteColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setBarButtonTintColor:(UIColor *)barButtonTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barButtonTintColor = barButtonTintColor;
    self.navigationController.navigationBar.tintColor = barButtonTintColor ?: [UIColor blackColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setFirstController:(BOOL)firstController {
    [self willChangeValueForKey:@"firstController"];
    _firstController = firstController;
    
    self.closeButton.image = firstController ? [UIImage imageNamed:@"NHRecorder.close.png"] : [UIImage imageNamed:@"NHRecorder.back.png"];
    [self didChangeValueForKey:@"firstController"];
}

//MARK: view overrides

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor blackColor];
    [self.photoCollectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
