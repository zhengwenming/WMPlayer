//
//  WNPlayerUtils.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WNPlayerUtils : NSObject
+ (BOOL)createError:(NSError **)error withDomain:(NSString *)domain andCode:(NSInteger)code andMessage:(NSString *)message;
+ (BOOL)createError:(NSError **)error withDomain:(NSString *)domain andCode:(NSInteger)code andMessage:(NSString *)message andRawError:(NSError *)rawError;
+ (NSString *)localizedString:(NSString *)name;
+ (NSString *)durationStringFromSeconds:(int)seconds;

@end

NS_ASSUME_NONNULL_END
