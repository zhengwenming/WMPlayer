//
//  WNPlayerVideoFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayerFrame.h"
#import <OpenGLES/ES2/gl.h>

typedef enum : NSUInteger {
    kWNPlayerVideoFrameTypeNone,
    kWNPlayerVideoFrameTypeRGB,
    kWNPlayerVideoFrameTypeYUV
} WNPlayerVideoFrameType;

NS_ASSUME_NONNULL_BEGIN

@interface WNPlayerVideoFrame : WNPlayerFrame
@property (nonatomic) WNPlayerVideoFrameType videoType;
@property (nonatomic) int width;
@property (nonatomic) int height;

- (BOOL)prepareRender:(GLuint)program;
@end

NS_ASSUME_NONNULL_END
