/*!
 @header WMPlayer.h
 
 @abstract  作者Github地址：https://github.com/zhengwenming
            作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/24
 
 @version 1.00 16/1/24 Creation(版本信息)
 
   Copyright © 2016年 郑文明. All rights reserved.
 */

/**
 *  全屏按钮被点击的通知
 */
#define WMPlayerFullScreenButtonClickedNotification @"WMPlayerFullScreenButtonClickedNotification"
/**
 *  关闭播放器的通知
 */
#define WMPlayerClosedNotification @"WMPlayerClosedNotification"
/**
 *  播放完成的通知
 */
#define WMPlayerFinishedPlayNotification @"WMPlayerFinishedPlayNotification"
/**
 *  单击播放器view的通知
 */
#define WMPlayerSingleTapNotification @"WMPlayerSingleTapNotification"
/**
 *  双击播放器view的通知
 */
#define WMPlayerDoubleTapNotification @"WMPlayerDoubleTapNotification"

#import <UIKit/UIKit.h>
#import "Masonry.h"


// 播放器的几种状态
typedef NS_ENUM(NSInteger, WMPlayerState) {
    WMPlayerStateFailed,     // 播放失败
    WMPlayerStateBuffering,  // 缓冲中
    WMPlayerStatePlaying,    // 播放中
    WMPlayerStateStopped,    // 停止播放
    WMPlayerStatePause       // 暂停播放
};

@import MediaPlayer;
@import AVFoundation;

/**
 *  注意⚠：本人把属性都公开到.h文件里面了，为了适配广大开发者，不同的需求可以修改属性东西，也可以直接修改源代码。
 */
@interface WMPlayer : UIView
/**
 *  播放器player
 */
@property (nonatomic,retain ) AVPlayer       *player;
/**
 *playerLayer,可以修改frame
 */
@property (nonatomic,retain ) AVPlayerLayer  *playerLayer;

/** 播放器的几种状态 */
@property (nonatomic, assign) WMPlayerState   state;

/**
 *  底部操作工具栏
 */
@property (nonatomic,retain ) UIView         *bottomView;
@property (nonatomic,retain ) UISlider       *progressSlider;
@property (nonatomic,retain ) UISlider       *volumeSlider;
@property (nonatomic,copy   ) NSString       *videoURLStr;
/** 亮度的进度条 */
@property (nonatomic, retain) UISlider       *lightSlider;


/**
 *  定时器
 */
@property (nonatomic, retain) NSTimer        *durationTimer;
@property (nonatomic, retain) NSTimer        *autoDismissTimer;
/**
 *  BOOL值判断当前的状态
 */
@property (nonatomic,assign ) BOOL            isFullscreen;
/**
 *  显示播放时间的UILabel
 */
@property (nonatomic,retain ) UILabel        *timeLabel;
/**
 *  控制全屏的按钮
 */
@property (nonatomic,retain ) UIButton       *fullScreenBtn;
/**
 *  播放暂停按钮
 */
@property (nonatomic,retain ) UIButton       *playOrPauseBtn;
/**
 *  关闭按钮
 */
@property (nonatomic,retain ) UIButton       *closeBtn;

/**
 *  当前播放的item
 */
@property (nonatomic, retain) AVPlayerItem   *currentItem;

/**
 *  BOOL值判断当前的播放状态
 */
@property (nonatomic,assign ) BOOL            isPlaying;
/**
 *  初始化WMPlayer的方法
 *
 *  @param frame       frame
 *  @param videoURLStr URL字符串，包括网络的和本地的URL
 *
 *  @return id类型，实际上就是WMPlayer的一个对象
 */
- (id)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr;
- (void)play;
- (void)pause;

@end

