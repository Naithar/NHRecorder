//
//  UIImage+Resize.h
//  Pods
//
//  Created by Sergey Minakov on 14.06.15.
//
//

@import UIKit;


@interface UIImage (NHRecorderResize)

- (UIImage*)scaleImageByX:(CGFloat)x andY:(CGFloat)y;
- (UIImage*)rescaleToFit:(CGSize)size;
- (UIImage*)rescaleToFill:(CGSize)size;

@end