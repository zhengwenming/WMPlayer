//
//  WNPlayerVideoRGBFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayerVideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNPlayerVideoRGBFrame : WNPlayerVideoFrame
@property (nonatomic) NSUInteger linesize;
@property (nonatomic) BOOL hasAlpha;
@end

NS_ASSUME_NONNULL_END
