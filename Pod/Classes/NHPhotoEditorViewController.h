//
//  NHCameraImageEditorController.h
//  Pods
//
//  Created by Sergey Minakov on 11.06.15.
//
//

#import <UIKit/UIKit.h>
#import "NHPhotoView.h"

@interface NHPhotoEditorViewController : UIViewController

@property (nonatomic, readonly, strong) NHPhotoView *photoView;

@property (nonatomic, readonly, strong) UIView *selectorView;
@property (nonatomic, readonly, strong) UIView *separatorView;
@property (nonatomic, readonly, strong) UIView *selectionContainerView;

- (instancetype)initWithUIImage:(UIImage*)image;

@end
