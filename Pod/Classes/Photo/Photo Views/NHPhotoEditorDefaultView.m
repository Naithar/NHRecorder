//
//  NHPhotoDefaultEditorView.m
//  Pods
//
//  Created by Sergey Minakov on 27.08.15.
//
//

#import "NHPhotoEditorDefaultView.h"

const CGFloat kNHRecorderSelectorViewHeight = 40;
const CGFloat kNHRecorderSelectionContainerViewHeight = 80;

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHPhotoEditorDefaultView class]]\
pathForResource:name ofType:@"png"]]

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHPhotoEditorDefaultView class]], nil)

@interface NHPhotoEditorDefaultView ()<NHFilterCollectionViewDelegate, NHCropCollectionViewDelegate>

@property (nonatomic, strong) NHPhotoView *photoView;

@property (nonatomic, strong) UIView *selectorView;
@property (nonatomic, strong) UIView *selectorSeparatorView;
@property (nonatomic, strong) UIView *selectionContainerView;
@property (nonatomic, strong) UIView *photoSeparatorView;

@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *cropButton;

@property (nonatomic, strong) NHCropCollectionView *cropCollectionView;
@property (nonatomic, strong) NHFilterCollectionView *filterCollectionView;

@property (nonatomic, strong) NHRecorderButton *backButton;

@property (nonatomic, assign) NHPhotoCropType forcedCropType;

@end

@implementation NHPhotoEditorDefaultView

+ (Class)nhFilterCollectionViewClass {
    return [NHFilterCollectionView class];
}

+ (Class)nhCropCollectionViewClass {
    return [NHCropCollectionView class];
}

- (void)setupView {
    self.viewController.view.backgroundColor = [UIColor blackColor];
    
    _forcedCropType = NHPhotoCropTypeNone;
    
    self.backButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(0, 0, 44, 44);
    self.backButton.tintColor = [UIColor whiteColor];
    [self.backButton setImage:image(@"NHRecorder.back") forState:UIControlStateNormal];
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.backButton addTarget:self action:@selector(backButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    
    self.viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                             initWithTitle:localization(@"NHRecorder.button.done", @"NHRecorder")
                                                             style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(nextButtonTouch:)];
    
    self.viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                            initWithTitle:@" "
                                                            style:UIBarButtonItemStylePlain
                                                            target:nil
                                                            action:nil];
    
    self.photoView = [[NHPhotoView alloc] initWithImage:self.image];
    self.photoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoView.backgroundColor = [UIColor blackColor];
    [self.viewController.view addSubview:self.photoView];
    
    self.selectorView = [[UIView alloc] init];
    self.selectorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectorView.backgroundColor = [UIColor blackColor];
    [self.viewController.view addSubview:self.selectorView];
    
    self.selectionContainerView = [[UIView alloc] init];
    self.selectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectionContainerView.backgroundColor = [UIColor blackColor];
    [self.viewController.view addSubview:self.selectionContainerView];
    
    [self setupSelectorViewConstraints];
    [self setupSelectionContainerViewConstraints];
    [self setupPhotoViewConstraints];
    
    self.filterButton = [[UIButton alloc] init];
    self.filterButton.backgroundColor = [UIColor clearColor];
    self.filterButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.filterButton setTitle:nil forState:UIControlStateNormal];
    [self.filterButton setImage:[image(@"NHRecorder.filter.button")
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateNormal];
    [self.filterButton setImage:[image(@"NHRecorder.filter.button-active")
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                       forState:UIControlStateSelected];
    [self.filterButton addTarget:self action:@selector(filterButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cropButton = [[UIButton alloc] init];
    self.cropButton.backgroundColor = [UIColor clearColor];
    self.cropButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cropButton setTitle:nil forState:UIControlStateNormal];
    [self.cropButton setImage:[image(@"NHRecorder.crop.button")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateNormal];
    [self.cropButton setImage:[image(@"NHRecorder.crop.button-active")
                               imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                     forState:UIControlStateSelected];
    [self.cropButton addTarget:self action:@selector(cropButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupSelectorButtons];
    
    
    Class filterCollectionViewClass = [[self class] nhFilterCollectionViewClass];
    if (![filterCollectionViewClass isSubclassOfClass:[NHFilterCollectionView class]]) {
        filterCollectionViewClass = [NHFilterCollectionView class];
    }
    
    self.filterCollectionView = [[filterCollectionViewClass alloc] initWithImage:self.image];
    self.filterCollectionView.backgroundColor = [UIColor clearColor];
    self.filterCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterCollectionView.nhDelegate = self;
    [self.selectionContainerView addSubview:self.filterCollectionView];
    [self setupFilterCollectionViewConstraints];
    
    Class cropCollectionViewClass = [[self class] nhCropCollectionViewClass];
    if (![cropCollectionViewClass isSubclassOfClass:[NHCropCollectionView class]]) {
        cropCollectionViewClass = [NHCropCollectionView class];
    }
    
    self.cropCollectionView = [[cropCollectionViewClass alloc] init];
    self.cropCollectionView.backgroundColor = [UIColor clearColor];
    self.cropCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cropCollectionView.nhDelegate = self;
    [self.selectionContainerView addSubview:self.cropCollectionView];
    [self setupCropCollectionViewConstraints];
    
    [self.filterCollectionView setSelected:0];
    [self.cropCollectionView setSelected:0];
    
    [self showFiltersCollection];
    
    
    [self.photoView.panGestureRecognizer addTarget:self action:@selector(photoGestureAction:)];
    [self.photoView.pinchGestureRecognizer addTarget:self action:@selector(photoGestureAction:)];
}

- (void)photoGestureAction:(UIGestureRecognizer*)recognizer {
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            self.viewController.navigationItem.rightBarButtonItem.enabled = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNextEnabled) object:nil];
            break;
        default: {
            [self performSelector:@selector(checkNextEnabled) withObject:nil afterDelay:0.5];
        } break;
    }
}

- (void)checkNextEnabled {
    self.viewController.navigationItem.rightBarButtonItem.enabled =
    ((self.photoView.panGestureRecognizer.state == UIGestureRecognizerStateFailed
      || self.photoView.panGestureRecognizer.state == UIGestureRecognizerStatePossible)
     && (self.photoView.pinchGestureRecognizer.state == UIGestureRecognizerStateFailed
         || self.photoView.pinchGestureRecognizer.state == UIGestureRecognizerStatePossible));
}

- (void)setupSelectorViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0 constant:kNHRecorderSelectorViewHeight]];
    
    self.selectorSeparatorView = [[UIView alloc] init];
    self.selectorSeparatorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.selectorSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectorView addSubview:self.selectorSeparatorView];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0 constant:0]];
    
    [self.selectorSeparatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectorSeparatorView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.selectorSeparatorView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:0 constant:0.5]];
}

- (void)setupSelectionContainerViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.selectorView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:0 constant:kNHRecorderSelectionContainerViewHeight]];
    
    self.photoSeparatorView = [[UIView alloc] init];
    self.photoSeparatorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.photoSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectionContainerView addSubview:self.photoSeparatorView];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoSeparatorView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoSeparatorView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoSeparatorView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0 constant:0]];
    
    [self.photoSeparatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.photoSeparatorView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.photoSeparatorView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0 constant:0.5]];
}

- (void)setupPhotoViewConstraints {
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                                         attribute:NSLayoutAttributeLeft
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeLeft
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.viewController.view
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0 constant:0]];
    
    [self.viewController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.photoView
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
    
    self.filterCollectionView.hidden = NO;
    self.cropCollectionView.hidden = YES;
}

- (void)showCropCollection {
    self.filterButton.selected = NO;
    self.cropButton.selected = YES;
    
    self.filterCollectionView.hidden = YES;
    self.cropCollectionView.hidden = NO;
}

- (void)setForcedCropType:(NHPhotoCropType)forcedCropType {
    [self willChangeValueForKey:@"forcedCropType"];
    _forcedCropType = forcedCropType;
    [self didChangeValueForKey:@"forcedCropType"];
    [self.photoView setCropType:forcedCropType];
    [self setupSelectorButtons];
}

- (void)backButtonTouch:(id)sender {
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonTouch:(id)sender {
    [self.viewController processPhoto];
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

- (void)cropView:(NHCropCollectionView *)cropView didSelectType:(NHPhotoCropType)type {
    if (self.forcedCropType == NHPhotoCropTypeNone) {
        [self.photoView setCropType:type];
    }
}

- (void)filterView:(NHFilterCollectionView *)filteView didSelectFilter:(GPUImageFilter *)filter {
    [self.photoView setFilter:filter];
}

- (void)showView {
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barTintColor = barTintColor;
    self.viewController.navigationController.navigationBar.barTintColor = barTintColor ?: [UIColor blackColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)setBarButtonTintColor:(UIColor *)barButtonTintColor {
    [self willChangeValueForKey:@"barTintColor"];
    _barButtonTintColor = barButtonTintColor;
    self.viewController.navigationController.navigationBar.tintColor = barButtonTintColor ?: [UIColor whiteColor];
    [self didChangeValueForKey:@"barTintColor"];
}

- (void)willShowView {
    self.viewController.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor blackColor];
    self.viewController.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor whiteColor];
    
    [self.viewController.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.viewController.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)changeOrientationTo:(UIDeviceOrientation)orientation {
    CGFloat angle = 0;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        default:
            return;
    }
    
    self.cropButton.imageView.transform = CGAffineTransformMakeRotation(angle);
    self.filterButton.imageView.transform = CGAffineTransformMakeRotation(angle);
}

- (void)setForcedCrop:(NHPhotoCropType)cropType {
    self.forcedCropType = cropType;
}

- (NHPhotoView *)photoEditorView {
    return self.photoView;
}

- (BOOL)canProcessPhoto {
    return self.photoView.panGestureRecognizer.state == UIGestureRecognizerStatePossible
    && self.photoView.pinchGestureRecognizer.state == UIGestureRecognizerStatePossible;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)statusBarHidden {
    return YES;
}

- (void)dealloc {
}

@end

