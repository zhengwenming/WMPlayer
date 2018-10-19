//
//  WNPlayerVideoYUVFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayerVideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNPlayerVideoYUVFrame : WNPlayerVideoFrame
@property (nonatomic, strong) NSData *Y;    // Luma
@property (nonatomic, strong) NSData *Cb;   // Chroma Blue
@property (nonatomic, strong) NSData *Cr;   // Chroma Red

@end

NS_ASSUME_NONNULL_END
