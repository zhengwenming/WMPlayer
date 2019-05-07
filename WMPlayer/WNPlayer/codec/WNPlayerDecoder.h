//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WNPlayerDecoder : NSObject
@property (nonatomic) BOOL isYUV;
@property (nonatomic) BOOL hasVideo;
@property (nonatomic) BOOL hasAudio;
@property (nonatomic) BOOL hasPicture;
@property (nonatomic) BOOL isEOF;
@property (nonatomic) BOOL usesTCP;

@property (nonatomic) double rotation;
@property (nonatomic) double duration;
@property (nonatomic, strong) NSDictionary *metadata;
@property (nonatomic, strong) NSDictionary *optionDic;

@property (nonatomic) UInt32 audioChannels;
@property (nonatomic) float audioSampleRate;

@property (nonatomic) double videoFPS;
@property (nonatomic) double videoTimebase;
@property (nonatomic) double audioTimebase;

- (BOOL)open:(NSString *)url error:(NSError **)error;
- (void)close;
- (void)prepareClose;
- (NSArray *)readFrames;
- (void)seek:(double)position;
- (int)videoWidth;
- (int)videoHeight;
- (BOOL)isYUV;
@end

NS_ASSUME_NONNULL_END
