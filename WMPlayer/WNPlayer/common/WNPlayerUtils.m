//
//  WNPlayerUtils.m
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayerUtils.h"
#import "WNPlayerDef.h"

@implementation WNPlayerUtils
+ (BOOL)createError:(NSError **)error withDomain:(NSString *)domain andCode:(NSInteger)code andMessage:(NSString *)message {
    if (error == nil) return NO;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (message != nil) userInfo[NSLocalizedDescriptionKey] = message;
        *error = [NSError errorWithDomain:domain
                                     code:code
                                 userInfo:userInfo];
    return YES;
}

+ (BOOL)createError:(NSError **)error withDomain:(NSString *)domain andCode:(NSInteger)code andMessage:(NSString *)message andRawError:(NSError *)rawError {
    if (error == nil) return NO;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (message != nil) userInfo[NSLocalizedDescriptionKey] = message;
    if (rawError != nil) userInfo[NSLocalizedFailureReasonErrorKey] = rawError;
    *error = [NSError errorWithDomain:domain
                                 code:code
                             userInfo:userInfo];
    return YES;
}
+ (NSString *)localizedString:(NSString *)name {
    return NSLocalizedStringFromTable(name, WNPlayerLocalizedStringTable, nil);
}
@end

