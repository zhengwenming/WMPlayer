/*!
 @header WMPlayer.h
 
 @abstract  作者Github地址：https://github.com/zhengwenming
            作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/24
 
 @version 1.00 16/1/24 Creation(版本信息)
 
   Copyright © 2016年 郑文明. All rights reserved.
 */

#import "Masonry.h"
@import MediaPlayer;
@import AVFoundation;
@import UIKit;
// 播放器的几种状态
typedef NS_ENUM(NSInteger, WMPlayerState) {
    WMPlayerStateFailed,        // 播放失败
    WMPlayerStateBuffering,     // 缓冲中
    WMPlayerStatusReadyToPlay,  //将要播放
    WMPlayerStatePlaying,       // 播放中
    WMPlayerStateStopped,        //暂停播放
    WMPlayerStateFinished       //播放完毕
};
// 枚举值，包含播放器左上角的关闭按钮的类型
typedef NS_ENUM(NSInteger, CloseBtnStyle){
    CloseBtnStylePop, //pop箭头<-
    CloseBtnStyleClose  //关闭（X）
};


@class WMPlayer;
@protocol WMPlayerDelegate <NSObject>
@optional
///播放器事件
//点击播放暂停按钮代理方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn;
//点击关闭按钮代理方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn;
//点击全屏按钮代理方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn;
//单击WMPlayer的代理方法
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap;
//双击WMPlayer的代理方法
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap;

///播放状态
//播放失败的代理方法
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state;
//准备播放的代理方法
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state;
//播放完毕的代理方法
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer;


@end




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

/** 播放器的代理 */
@property (nonatomic, weak)id <WMPlayerDelegate> delegate;
/**
 *  底部操作工具栏
 */
@property (nonatomic,retain ) UIView         *bottomView;
/**
 *  顶部操作工具栏
 */
@property (nonatomic,retain ) UIView         *topView;

/**
 *  显示播放视频的title
 */
@property (nonatomic,strong) UILabel        *titleLabel;
/**
 ＊  播放器状态
 */
@property (nonatomic, assign) WMPlayerState   state;
/**
 ＊  播放器左上角按钮的类型
 */
@property (nonatomic, assign) CloseBtnStyle   closeBtnStyle;
/**
 *  定时器
 */
@property (nonatomic, retain) NSTimer        *autoDismissTimer;
/**
 *  BOOL值判断当前的状态
 */
@property (nonatomic,assign ) BOOL            isFullscreen;
/**
 *  控制全屏的按钮
 */
@property (nonatomic,retain ) UIButton       *fullScreenBtn;
/**
 *  播放暂停按钮
 */
@property (nonatomic,retain ) UIButton       *playOrPauseBtn;
/**
 *  左上角关闭按钮
 */
@property (nonatomic,retain ) UIButton       *closeBtn;
/**
 *  显示加载失败的UILabel
 */
@property (nonatomic,strong) UILabel        *loadFailedLabel;
/**
 *  当前播放的item
 */
@property (nonatomic, retain) AVPlayerItem   *currentItem;
/**
 *  菊花（加载框）
 */
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
/**
 *  BOOL值判断当前的播放状态
 */
@property (nonatomic,assign ) BOOL            isPlaying;
/**
 *  设置播放视频的USRLString，可以是本地的路径也可以是http的网络路径
 */
@property (nonatomic,copy) NSString       *URLString;
/**
 *  跳到time处播放
 *  @param seekTime这个时刻，这个时间点
 */

@property (nonatomic, assign) double  seekTime;
/**
 *  播放
 */
- (void)play;

/**
 * 暂停
 */
- (void)pause;

/**
 *  获取正在播放的时间点
 *
 *  @return double的一个时间点
 */
- (double)currentTime;

/**
 * 重置播放器
 */
- (void )resetWMPlayer;
/**
 * 版本号
 */
- (NSString *)version;
@end

