//
//  UIImage+Resize.h
//  Pods
//
//  Created by Sergey Minakov on 14.06.15.
//
//

@import UIKit;


@interface UIImage(ResizeCategory)
-(UIImage*)resizedImageToSize:(CGSize)dstSize;
-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
@end