//
//  WNPlayerModel.h
//  PlayerDemo
//
//  Created by apple on 2018/11/10.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface WNPlayerModel : NSObject
//视频标题
@property (nonatomic, copy) NSString   *title;
//视频的URL，本地路径or网络路径http
@property (nonatomic, strong) NSURL    *videoURL;
//视频尺寸
@property (nonatomic,assign) CGSize presentationSize;
//是否是适合竖屏播放的资源，w：h<1的资源，一般是手机竖屏（人像模式）拍摄的视频资源
@property (nonatomic,assign) BOOL verticalVideo;
@end

NS_ASSUME_NONNULL_END
