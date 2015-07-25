//
//  NHVideoEditViewController.m
//  Pods
//
//  Created by Sergey Minakov on 24.07.15.
//
//

#import "NHVideoEditViewController.h"
#import "NHRecorderButton.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHVideoEditViewController class]]\
pathForResource:name ofType:@"png"]]

#define localization(name, table) \
NSLocalizedStringFromTableInBundle(name, \
table, \
[NSBundle bundleForClass:[NHVideoEditViewController class]], nil)

@interface NHVideoEditViewController ()

@property (nonatomic, strong) NSURL *assetURL;

@property (nonatomic, strong) id orientationChange;

@property (nonatomic, strong) NHRecorderButton *backButton;

@property (nonatomic, strong) GPUImageMovie *videoFile;
@property (nonatomic, strong) GPUImageMovieWriter *videoMovieWriter;
@property (nonatomic, strong) GPUImageView *videoEditView;
@property (nonatomic, strong) GPUImageFilter *videoFilter;

@property (nonatomic, strong) GPUImageMovie *videoFileForSaving;
@property (nonatomic, strong) GPUImageFilter *videoFilterForSaving;
@property (nonatomic, strong) NSURL *fileURL;

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

- (void)commonInit {
    self.view.backgroundColor = [UIColor redColor];
    
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
    
    self.videoFilter = [[GPUImageGrayscaleFilter alloc] init];
    [self.videoFile addTarget:self.videoFilter];
    
    
    self.videoFileForSaving = [[GPUImageMovie alloc] initWithURL:self.assetURL];
    self.videoFileForSaving.playAtActualSpeed = YES;
    
    self.videoFilterForSaving = [[GPUImageGrayscaleFilter alloc] init];
    [self.videoFileForSaving addTarget:self.videoFilterForSaving];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    self.fileURL = [NSURL fileURLWithPath:pathToMovie];
    self.videoMovieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.fileURL size:CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height)];
    
    [self.videoFilterForSaving addTarget:self.videoMovieWriter];
    
    self.videoEditView = [[GPUImageView alloc] init];
    self.videoEditView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoEditView.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:self.videoEditView];
    [self setupVideoEditViewConstraints];
    
    [self.videoFilter addTarget:self.videoEditView];
    [self.videoFile startProcessing];
    
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
    [self.videoFileForSaving startProcessing];
    [self.videoMovieWriter startRecording];
    
    __weak __typeof(self) weakSelf = self;
    [self.videoMovieWriter setCompletionBlock:^{
        [weakSelf.videoMovieWriter finishRecordingWithCompletionHandler:^{
                    UISaveVideoAtPathToSavedPhotosAlbum([NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"], weakSelf, @selector(savedFilteredVideo:error:context:), nil);
        }];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
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
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
}

- (void)savedFilteredVideo:(NSString*)path error:(NSError*)error context:(void*)contextInfo {
    NSLog(@"%@", error);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChange];
}

@end
