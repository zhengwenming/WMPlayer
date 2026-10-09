//
//  WMPlayerUtils.m
//  WMPlayer
//

#import "WMPlayerUtils.h"

@implementation WMPlayerUtils

+ (NSString *)timeStringFromSeconds:(CGFloat)seconds {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    });

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    if (seconds / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    return [formatter stringFromDate:date];
}

+ (NSString *)stringFromTimeValue:(long long)timeSecond {
    if (timeSecond < 60) {
        return [NSString stringWithFormat:@"00:%.2lld", timeSecond];
    } else if (timeSecond < 3600) {
        return [NSString stringWithFormat:@"%.2lld:%.2lld", timeSecond / 60, timeSecond % 60];
    }
    return [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", timeSecond / 3600, timeSecond % 3600 / 60, timeSecond % 60];
}

+ (BOOL)isiPhoneXSeries {
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return NO;
    }
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat ratio = ABS(MAX(screenWidth, screenHeight) / MIN(screenWidth, screenHeight));
    // 896/414 (XS Max / 11 Pro Max) 与 812/375 (X / XS / 11 Pro) 两种刘海屏比例
    return (ABS(ratio - 896 / 414.0) < 0.01) || (ABS(ratio - 812 / 375.0) < 0.01);
}

+ (CGAffineTransform)currentDeviceOrientationTransform {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

+ (NSString *)playerVersion {
    return @"5.1.0";
}

@end
