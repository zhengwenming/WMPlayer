//
//  WMPlayerUtils.h
//  WMPlayer
//
//  播放器通用工具：时间格式化、设备判断、方向转换、版本号。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMPlayerUtils : NSObject

/**
 将秒数格式化为 mm:ss 或 hh:mm:ss（GMT 时区，与播放器展示一致）。
 */
+ (NSString *)timeStringFromSeconds:(CGFloat)seconds;

/**
 将整数秒格式化为 00:00 / 00:00:00（兼容播放器内旧的 C 函数语义）。
 */
+ (NSString *)stringFromTimeValue:(long long)timeSecond;

/**
 是否为 iPhone X 系列刘海屏。
 */
+ (BOOL)isiPhoneXSeries;

/**
 根据当前状态栏方向计算旋转 transform。
 */
+ (CGAffineTransform)currentDeviceOrientationTransform;

/**
 播放器版本号。
 */
+ (NSString *)playerVersion;

@end

NS_ASSUME_NONNULL_END
