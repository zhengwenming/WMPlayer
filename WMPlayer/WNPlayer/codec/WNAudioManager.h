//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^WNPlayerAudioManagerFrameReaderBlock)(float *data, UInt32 num, UInt32 channels);

NS_ASSUME_NONNULL_BEGIN

@interface WNAudioManager : NSObject
@property (nonatomic, copy) WNPlayerAudioManagerFrameReaderBlock frameReaderBlock;
@property (nonatomic) float volume;

- (BOOL)open:(NSError **)error;
- (BOOL)play;
- (BOOL)play:(NSError **)error;
- (BOOL)pause;
- (BOOL)pause:(NSError **)error;
- (BOOL)close;
- (BOOL)close:(NSArray<NSError *> **)errors;

- (double)sampleRate;
- (UInt32)channels;
@end

NS_ASSUME_NONNULL_END
