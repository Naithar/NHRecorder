//
//  NHVideoEditViewController.m
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import "NHVideoEditViewController.h"
#import "NHRecorderButton.h"
#import "NHFilterCollectionView.h"
#import "NHPhotoEditorViewController.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHVideoEditViewController class]]\
pathForResource:name ofType:@"png"]]

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHVideoEditViewController class]], nil)

@interface NHVideoEditViewController ()<NHFilterCollectionViewDelegate>

@property (nonatomic, strong) NSURL *assetURL;

@property (nonatomic, strong) id orientationChange;

@property (nonatomic, strong) NHRecorderButton *backButton;

@property (nonatomic, strong) GPUImageMovie *videoFile;
@property (nonatomic, strong) GPUImageMovieWriter *videoMovieWriter;
@property (nonatomic, strong) GPUImageView *videoEditView;
@property (nonatomic, strong) GPUImageFilter *videoFilter;

@property (nonatomic, strong) GPUImageMovie *videoFileForSaving;
@property (nonatomic, strong) GPUImageFilter *videoFilterForSaving;

@property (nonatomic, strong) UIView *selectorView;
@property (nonatomic, strong) UIView *selectorSeparatorView;
@property (nonatomic, strong) UIView *selectionContainerView;
@property (nonatomic, strong) UIView *videoSeparatorView;

@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) NHFilterCollectionView *filterCollectionView;

@end

@implementation NHVideoEditViewController

- (instancetype)initWithAssetURL:(NSURL*)url {
    self = [super init];
    
    if (self) {
        _assetURL = url;
        [self commonInit];
    }
    
    return self;
}

- (NSString *)filteredVideoPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
}

- (void)commonInit {
    self.view.backgroundColor = [UIColor blackColor];
    
    self.backButton = [NHRecorderButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(0, 0, 44, 44);
    self.backButton.tintColor = [UIColor whiteColor];
    [self.backButton setImage:image(@"NHRecorder.back") forState:UIControlStateNormal];
    self.backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.backButton addTarget:self action:@selector(backButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:localization(@"NHRecorder.button.done", @"NHRecorder")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(nextButtonTouch:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@" "
                                             style:UIBarButtonItemStylePlain
                                             target:nil
                                             action:nil];
    
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.assetURL options:nil];
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    self.videoFile = [[GPUImageMovie alloc] initWithURL:self.assetURL];
    self.videoFile.playAtActualSpeed = YES;
    self.videoFile.shouldRepeat = YES;
    
    self.videoFilter = [[GPUImageFilter alloc] init];
    [self.videoFile addTarget:self.videoFilter];
    
    self.videoFileForSaving = [[GPUImageMovie alloc] initWithURL:self.assetURL];
    self.videoFileForSaving.playAtActualSpeed = YES;
    
    self.videoFilterForSaving = [[GPUImageFilter alloc] init];
    [self.videoFileForSaving addTarget:self.videoFilterForSaving];
    
    NSString *pathToMovie = [self filteredVideoPath];
    unlink([pathToMovie UTF8String]);
    NSURL *fileURL = [NSURL fileURLWithPath:pathToMovie];
    self.videoMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:fileURL size:CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height)];
    
    self.videoMovieWriter.shouldPassthroughAudio = YES;
    self.videoFileForSaving.audioEncodingTarget = self.videoMovieWriter;
    [self.videoFileForSaving enableSynchronizedEncodingUsingMovieWriter:self.videoMovieWriter];
    [self.videoFilterForSaving addTarget:self.videoMovieWriter];
    
    self.videoEditView = [[GPUImageView alloc] init];
    self.videoEditView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoEditView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoEditView];
    
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
    [self setupVideoEditViewConstraints];
    
    [self.videoFilter addTarget:self.videoEditView];
    [self.videoFile startProcessing];
    
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
    [self.selectorView addSubview:self.filterButton];
    self.filterButton.selected = YES;
//    [self.filterButton addTarget:self action:@selector(filterButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupFilterButtonConstraints];
    
    self.filterCollectionView = [[NHFilterCollectionView alloc] initWithImage:[self generateThumbImage:self.assetURL]];
    self.filterCollectionView.backgroundColor = [UIColor clearColor];
    self.filterCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.filterCollectionView.nhDelegate = self;
    [self.selectionContainerView addSubview:self.filterCollectionView];
    [self setupFilterCollectionViewConstraints];
    
    __weak __typeof(self) weakSelf = self;
    self.orientationChange = [[NSNotificationCenter defaultCenter]
                              addObserverForName:UIDeviceOrientationDidChangeNotification
                              object:nil
                              queue:nil
                              usingBlock:^(NSNotification *note) {
                                  __strong __typeof(weakSelf) strongSelf = weakSelf;
                                  if (strongSelf
                                      && strongSelf.view.window) {
                                      [strongSelf deviceOrientationChange];
                                  }
                              }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self.videoFile startProcessing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.barTintColor ?: [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = self.barButtonTintColor ?: [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [UIView performWithoutAnimation:^{
        [self deviceOrientationChange];
    }];
}

//http://stackoverflow.com/questions/1347562/getting-thumbnail-from-a-video-url-or-data-in-iphone-sdk
-(UIImage *)generateThumbImage:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 1;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

- (void)deviceOrientationChange {
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)backButtonTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonTouch:(id)sender {
    
    self.navigationController.view.userInteractionEnabled = NO;
    [self.videoMovieWriter startRecording];
    [self.videoFileForSaving startProcessing];
    
    __weak __typeof(self) weakSelf = self;
    [self.videoMovieWriter setCompletionBlock:^{
        [weakSelf.videoMovieWriter finishRecordingWithCompletionHandler:^{
            weakSelf.navigationController.view.userInteractionEnabled = YES;
                    UISaveVideoAtPathToSavedPhotosAlbum([weakSelf filteredVideoPath],
                                                        weakSelf,
                                                        @selector(savedFilteredVideo:error:context:),
                                                        nil);
        }];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.videoFilter removeAllTargets];
    [self.videoFile removeTarget:self.videoFilter];
    [self.videoFilter removeOutputFramebuffer];
    [self.videoFile addTarget:self.videoFilter];
    [self.videoFilter addTarget:self.videoEditView];
}

- (void)setupVideoEditViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoEditView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:-1]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoEditView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoEditView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoEditView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.selectionContainerView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
}

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
    
    self.videoSeparatorView = [[UIView alloc] init];
    self.videoSeparatorView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.videoSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.selectionContainerView addSubview:self.videoSeparatorView];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSeparatorView
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSeparatorView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0 constant:0]];
    
    [self.selectionContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSeparatorView
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainerView
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1.0 constant:0]];
    
    [self.videoSeparatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSeparatorView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.videoSeparatorView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:0 constant:0.5]];
}

- (void)setupFilterButtonConstraints {
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
    
    [self.selectorView addConstraint:[NSLayoutConstraint constraintWithItem:self.filterButton
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectorView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0 constant:0]];
    
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


- (void)filterView:(NHFilterCollectionView *)filterView didSelectFilterType:(NHFilterType)filterType {
    [self.videoFilter removeAllTargets];
    [self.videoFile removeTarget:self.videoFilter];
    [self.videoFilter removeOutputFramebuffer];
    self.videoFilter = [filterView filterForType:filterType];
    [self.videoFile addTarget:self.videoFilter];
    [self.videoFilter addTarget:self.videoEditView];
    
    [self.videoFilterForSaving removeAllTargets];
    [self.videoFileForSaving removeTarget:self.videoFilterForSaving];
    self.videoFilterForSaving = [filterView filterForType:filterType];
    [self.videoFileForSaving addTarget:self.videoFilterForSaving];
    [self.videoFilterForSaving addTarget:self.videoMovieWriter];
}
- (void)savedFilteredVideo:(NSString*)path error:(NSError*)error context:(void*)contextInfo {
    NSLog(@"%@", error);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [self.videoMovieWriter finishRecording];
    [self.videoFilterForSaving removeAllTargets];
    [self.videoFileForSaving removeAllTargets];
    
    [self.videoFile endProcessing];
    [self.videoFilter removeAllTargets];
    [self.videoFile removeAllTargets];
    self.videoFilter = nil;
    self.videoFile = nil;
    self.videoFilterForSaving = nil;
    self.videoFilterForSaving = nil;
    self.videoMovieWriter = nil;
    
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
