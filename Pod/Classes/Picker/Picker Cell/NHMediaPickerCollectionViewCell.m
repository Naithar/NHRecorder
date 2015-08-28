//
//  NHMediaPickerCollectionViewCell.m
//  Pods
//
//  Created by Sergey Minakov on 30.07.15.
//
//

#import "NHMediaPickerCollectionViewCell.h"

@implementation NHMediaPickerCollectionViewCell

- (void)reloadWithAsset:(ALAsset*)asset {
    
}

+ (NSString *)formatTime:(long)totalSeconds {
    NSInteger hours = (totalSeconds / 60) / 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger seconds = totalSeconds % 60;
    
    NSString *durationString = @"";
    
    if (hours > 0) {
        durationString = [durationString
                          stringByAppendingString:[NSString stringWithFormat:@"%02ld:", (long)hours]];
    }
    
    durationString = [durationString
                      stringByAppendingString:[NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds]];
    
    return durationString;
}

@end
