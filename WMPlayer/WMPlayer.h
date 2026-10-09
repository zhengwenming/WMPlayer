/*!
 @header WMPlayer.h
 
 @abstract  作者Github地址：https://github.com/zhengwenming
            作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/24
 
 @version 1.00 16/1/24 Creation(版本信息)
 
   Copyright © 2016年 郑文明. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "WMPlayerModel.h"
#import "FastForwardView.h"
#import "WMLightView.h"

//****************************枚举*******************************
// 播放器的几种状态
typedef NS_ENUM(NSInteger, WMPlayerState) {
    WMPlayerStateFailed,        // 播放失败
    WMPlayerStateBuffering,     // 缓冲中
    WMPlayerStatePlaying,       // 播放中
    WMPlayerStateStopped,       //暂停播放
    WMPlayerStateFinished,      //完成播放
    WMPlayerStatePause,         // 打断播放
};
// playerLayer的填充模式（默认：等比例填充，直到一个维度到达区域边界）
typedef NS_ENUM(NSInteger, WMPlayerLayerGravity) {
    WMPlayerLayerGravityResize,           // 非均匀模式。两个维度完全填充至整个视图区域
    WMPlayerLayerGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
    WMPlayerLayerGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
};
// 枚举值，包含播放器左上角的返回按钮的类型
typedef NS_ENUM(NSInteger, BackBtnStyle){
    BackBtnStyleNone, //什么都没有
    BackBtnStyleClose,//关闭（X）
    BackBtnStylePop //pop箭头<-
};

//手势操作的类型
typedef NS_ENUM(NSUInteger,WMControlType) {
    WMControlTypeDefault,//无任何操作
    WMControlTypeProgress,//视频进度调节操作
    WMControlTypeVoice,//声音调节操作
    WMControlTypeLight//屏幕亮度调节操作
} ;



@class WMPlayer;
@protocol WMPlayerDelegate <NSObject>

@required
//点击关闭按钮代理方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)backBtn;
//点击全屏按钮代理方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn;

@optional
//点击播放暂停按钮代理方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn;
//点击锁定🔒按钮的方法
-(void)wmplayer:(WMPlayer *)wmplayer clickedLockButton:(UIButton *)lockBtn;
//单击WMPlayer的代理方法
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap;
//双击WMPlayer的代理方法
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap;
//WMPlayer的的操作栏隐藏和显示
-(void)wmplayer:(WMPlayer *)wmplayer isHiddenTopAndBottomView:(BOOL )isHidden;
//播放失败的代理方法
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state;
//准备播放的代理方法
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state;
//播放器已经拿到视频的尺寸大小
-(void)wmplayerGotVideoSize:(WMPlayer *)wmplayer videoSize:(CGSize )presentationSize;
//播放完毕的代理方法
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer;
@end


@interface WMPlayer : UIView
/**
 播放器对应的model
 */
@property (nonatomic,strong) WMPlayerModel   *playerModel;
/**
 返回按钮的样式
 */
@property (nonatomic, assign) BackBtnStyle backBtnStyle;
/**
 当前是否处于全屏（由播放器在进入/退出全屏时自动维护）
 */
@property (nonatomic,assign) BOOL    isFullscreen;
/**
 播放速率(倍速播放，支持0.5、1.0、1.25、1.5、2.0)
 */
@property (nonatomic,assign) CGFloat rate;
/**
 播放器着色
 */
@property (nonatomic,strong) UIColor *tintColor;

@property (nonatomic,assign,readonly) BOOL    prefersStatusBarHidden;
/**
 播放器的代理
 */
@property (nonatomic, weak)id <WMPlayerDelegate> delegate;
/**
 是否开启音量手势
 */
@property (nonatomic,assign) BOOL  enableVolumeGesture;
/**
 是否开启后台播放模式，default NO，关闭
 */
@property (nonatomic,assign) BOOL  enableBackgroundMode;
/**
 是否开启AirPlay投屏功能，default NO，关闭
 */
@property (nonatomic,assign) BOOL  enableAirPlay;
/**
 是否开启快进手势
 */
@property (nonatomic,assign) BOOL  enableFastForwardGesture;
/**
 是否开启双指捏合缩放视频画面的手势，default YES（仅全屏时生效）
 */
@property (nonatomic,assign) BOOL  enablePinchZoom;
/**
 视频画面缩放的最大倍数，default 3.0
 */
@property (nonatomic,assign) CGFloat  maxScale;
/**
 视频画面缩放的最小倍数，default 0.5（小于1.0即缩小画面）
 */
@property (nonatomic,assign) CGFloat  minScale;
/**
 是否静音
 */
@property (nonatomic,assign) BOOL  muted;
/**
 是否循环播放（不循环则意味着需要手动触发第二次播放），default NO
 */
@property (nonatomic,assign) BOOL  loopPlay;

/**
 设置playerLayer的填充模式
 */
@property (nonatomic, assign) WMPlayerLayerGravity    playerLayerGravity;
//是否是锁定屏幕旋转状态
@property (nonatomic,assign,readonly) BOOL isLockScreen;

/**
 自定义实例化方法初始化方式（-方法）

 @param playerModel 播放model
 @return 播放器实例
 */
-(instancetype)initPlayerModel:(WMPlayerModel *)playerModel;

/**
 自定义类方法+初始化方式（+方法）

 @param playerModel 播放model
 @return 播放器实例
 */
+(instancetype)playerWithModel:(WMPlayerModel *)playerModel;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 获取正在播放的时间点

 @return double的一个时间点
 */
- (double)currentTime;
/**
 获取视频长度
 
 @return double的一个时间点
 */
- (double)duration;
/**
 playOrPauseBtn点击事件
 */
- (void)playOrPause:(UIButton *)sender;
/**
 重置播放器,然后切换下一个播放资源
 */
- (void )resetWMPlayer;

/**
 版本号

 @return 当前版本号
 */
+(NSString *)version;
//获取当前的旋转状态
+(CGAffineTransform)getCurrentDeviceOrientation;
//判断是否为iPhone X系列
+(BOOL)IsiPhoneX;
@end

