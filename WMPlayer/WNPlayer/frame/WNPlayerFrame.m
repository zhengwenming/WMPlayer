//
//  WNPlayerFrame.m
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayerFrame.h"

@implementation WNPlayerFrame

- (instancetype)init{
    self = [super init];
    if (self) {
        _type = kWNPlayerFrameTypeNone;
        _data = nil;
    }
    return self;
}
@end
