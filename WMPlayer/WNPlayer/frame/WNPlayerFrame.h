//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    kWNPlayerFrameTypeNone,
    kWNPlayerFrameTypeVideo,
    kWNPlayerFrameTypeAudio
} WNPlayerFrameType;

NS_ASSUME_NONNULL_BEGIN

@interface WNPlayerFrame : NSObject
@property (nonatomic) WNPlayerFrameType type;
@property (nonatomic) NSData *data;
@property (nonatomic) double position;
@property (nonatomic) double duration;
@end

NS_ASSUME_NONNULL_END
