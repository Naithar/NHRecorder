//
//  NHCameraImageEditorController.m
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import "NHPhotoEditorViewController.h"
//#import <SCFilterSelectorViewInternal.h>



const CGFloat kNHRecorderSelectorViewHeight = 40;
const CGFloat kNHRecorderSelectionContainerViewHeight = 80;

@interface NHPhotoEditorViewController ()<NHFilterCollectionViewDelegate, NHCropCollectionViewDelegate>

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NHPhotoView *photoView;

@property (nonatomic, strong) UIView *selectorView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *selectionContainerView;

@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *cropButton;

@property (nonatomic, strong) NHCropCollectionView *cropCollectionView;
@property (nonatomic, strong) NHFilterCollectionView *filterCollectionView;

@end

@implementation NHPhotoEditorViewController

- (instancetype)initWithUIImage:(UIImage*)image {
    self = [super init];
    
    if (self) {
        _image = image;
        [self commonInit];
    }
    
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.photoView sizeContent];
}

- (void)commonInit {
    
    _forcedCropType = NHPhotoCropTypeNone;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[UIImage imageNamed:@"NHRecorder.back.png"]
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(backButtonTouch:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Next"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(nextButtonTouch:)];
    
    self.photoView = [[NHPhotoView alloc] initWithImage:self.image];
    self.photoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.photoView];
    
    self.selectorView = [[UIView alloc] init];
    self.selectorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectorView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.selectorView];
    
    self.selectionContainerView = [[UIView alloc] init];
    self.selectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectionContainerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.selectionContainerView];
    
    [self setupSelectorViewConstraints];
    [self setupSelectionContainerViewConstraints];
    [self setupPhotoViewConstraints];
    
    self.filterButton = [[UIButton alloc] init];
    self.filterButton.backgroundColor = [UIColor clearColor];
    self.filterButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.filterButton setTitle:nil forState:UIControlStateNormal];
    [self.filterButton setImage:[[UIImage imageNamed:@"NHRecorder.filter.button.png"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateNormal];
    [self.filterButton setImage:[[UIImage imageNamed:@"NHRecorder.filter.button-active.png"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateSelected];
    [self.filterButton addTarget:self action:@selector(filterButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cropButton = [[UIButton alloc] init];
    self.cropButton.backgroundColor = [UIColor clearColor];
    self.cropButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cropButton setTitle:nil forState:UIControlStateNormal];
    [self.cropButton setImage:[[UIImage imageNamed:@"NHRecorder.crop.button.png"]
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateNormal];
    [self.cropButton setImage:[[UIImage imageNamed:@"NHRecorder.crop.button-active.png"]
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateSelected];
    [self.cropButton addTarget:self action:@selector(cropButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupSelectorButtons];
    
    self.filterCollectionView = [[NHFilterCollectionView alloc] initWithImage:self.image];
    self.filterCollectionView.backgroundColor = [UIColor blackColor];
    self.filterCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterCollectionView.nhDelegate = self;
    [self.selectionContainerView addSubview:self.filterCollectionView];
    [self setupFilterCollectionViewConstraints];

    
    self.cropCollectionView = [[NHCropCollectionView alloc] init];
    self.cropCollectionView.backgroundColor = [UIColor blackColor];
    self.cropCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cropCollectionView.nhDelegate = self;
    [self.selectionContainerView addSubview:self.cropCollectionView];
    [self setupCropCollectionViewConstraints];
    
    [self.filterCollectionView setSelected:0];
    [self.cropCollectionView setSelected:0];
    
    [self showFiltersCollection];
}

//MARK: setup

- (void)setupSelectorViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0 constant:kNHRecorderSelectorViewHeight]];
    
    self.separatorView = [[UIView alloc] init];
    self.separatorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectorView addSubview:self.separatorView];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0 constant:0]];
    
    [self.separatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.separatorView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:0.5]];
}

- (void)setupSelectionContainerViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.selectorView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:0 constant:kNHRecorderSelectionContainerViewHeight]];
}

- (void)setupPhotoViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

- (void)setupSelectorButtons {
    [self.filterButton removeFromSuperview];
    [self.cropButton removeFromSuperview];
    
    [self.selectorView addSubview:self.filterButton];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0 constant:0]];
    if (self.forcedCropType == NHPhotoCropTypeNone) {
        [self.selectorView addSubview:self.cropButton];
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0 constant:0]];
        
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0 constant:0]];
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.filterButton
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];
        
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropButton
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.filterButton
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0 constant:0]];
    }
    else {
        [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.selectorView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0 constant:0]];
    }
}

- (void)setupFilterCollectionViewConstraints {
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0 constant:5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0 constant:-5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0 constant:15]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterCollectionView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0 constant:-15]];
}

- (void)setupCropCollectionViewConstraints {
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainerView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0 constant:-5]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainerView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:15]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cropCollectionView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainerView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0 constant:-15]];
}

- (void)showFiltersCollection {
    self.filterButton.selected = YES;
    self.cropButton.selected = NO;
    
    self.cropCollectionView.hidden = YES;
}

- (void)showCropCollection {
    self.filterButton.selected = NO;
    self.cropButton.selected = YES;
    
    self.cropCollectionView.hidden = NO;
}

//MARK: Setters

- (void)setBarTintColor:(UIColor *)barTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barTintColor = barTintColor;
    self.navigationController.navigationBar.barTintColor = barTintColor ?: [UIColor blackColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setBarButtonTintColor:(UIColor *)barButtonTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barButtonTintColor = barButtonTintColor;
    self.navigationController.navigationBar.tintColor = barButtonTintColor ?: [UIColor whiteColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setForcedCropType:(NHPhotoCropType)forcedCropType {
    [self willChangeValueForKey:@"forcedCropType"];
    _forcedCropType = forcedCropType;
    [self didChangeValueForKey:@"forcedCropType"];
    [self.photoView setCropType:forcedCropType];
    [self setupSelectorButtons];
}

//MARK: buttons

- (void)backButtonTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonTouch:(id)sender {
    [self.photoView processImageWithBlock:^(UIImage *image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }];
}

- (void)filterButtonTouch:(id)sender {
    if (!self.filterButton.selected) {
        [self showFiltersCollection];
    }
}

- (void)cropButtonTouch:(id)sender {
    if (!self.cropButton.selected) {
        [self showCropCollection];
    }
}

//MARK: delegates

- (void)cropView:(NHCropCollectionView *)cropView didSelectType:(NHPhotoCropType)type {
    if (self.forcedCropType == NHPhotoCropTypeNone) {
        [self.photoView setCropType:type];
    }
}

- (void)filterView:(NHFilterCollectionView *)filteView didSelectFilter:(GPUImageFilter *)filter {
    [self.photoView setFilter:filter];
}

//MARK: view overrides

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor whiteColor];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
