//
//  WMHeader.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/4/5.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#ifndef WMHeader_h
#define WMHeader_h

@import AVFoundation;
@import UIKit;
@import MediaPlayer;

//****************************枚举*******************************
// 播放器的几种状态
typedef NS_ENUM(NSInteger, WMPlayerState) {
    WMPlayerStateFailed,        // 播放失败
    WMPlayerStateBuffering,     // 缓冲中
    WMPlayerStatePlaying,       // 播放中
    WMPlayerStateStopped,        //暂停播放
    WMPlayerStateFinished,        //完成播放
    WMPlayerStatePause,       // 打断播放
};
// playerLayer的填充模式（默认：等比例填充，直到一个维度到达区域边界）
typedef NS_ENUM(NSInteger, WMPlayerLayerGravity) {
    WMPlayerLayerGravityResize,           // 非均匀模式。两个维度完全填充至整个视图区域
    WMPlayerLayerGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
    WMPlayerLayerGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
};
// 枚举值，包含播放器左上角的返回按钮的类型
typedef NS_ENUM(NSInteger, BackBtnStyle){
    BackBtnStyleClose,//关闭（X）
    BackBtnStylePop //pop箭头<-
};

//手势操作的类型
typedef NS_ENUM(NSUInteger,WMControlType) {
    progressControl,//视频进度调节操作
    voiceControl,//声音调节操作
    lightControl,//屏幕亮度调节操作
    noneControl//无任何操作
} ;
//****************************宏*********************************
#define KeyWindow [UIApplication sharedApplication].keyWindow
#define iOS8 [UIDevice currentDevice].systemVersion.floatValue >= 8.0
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define WMPlayerSrcName(file) [@"WMPlayer.bundle" stringByAppendingPathComponent:file]
#define WMPlayerFrameworkSrcName(file) [@"Frameworks/WMPlayer.framework/WMPlayer.bundle" stringByAppendingPathComponent:file]
#define WMPlayerImage(file)      [UIImage imageNamed:WMPlayerSrcName(file)] ? :[UIImage imageNamed:WMPlayerFrameworkSrcName(file)]

#define kHalfWidth (kScreenWidth) * 0.5
#define kHalfHeight (kScreenHeight) * 0.5

//****************************头文件******************************
#import "FastForwardView.h"
#import "WMLightView.h"
#import "Masonry.h"
#endif /* WMHeader_h */
