//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WNPlayerManager.h"

typedef enum : NSUInteger {
    WNPlayerStatusNone,
    WNPlayerStatusOpening,
    WNPlayerStatusOpened,
    WNPlayerStatusPlaying,
    WNPlayerStatusBuffering,
    WNPlayerStatusPaused,
    WNPlayerStatusEOF,
    WNPlayerStatusClosing,
    WNPlayerStatusClosed,
} WNPlayerStatus;




@class WNPlayer;
@protocol WNPlayerDelegate <NSObject>
@optional
//点击播放暂停按钮代理方法
-(void)wnplayer:(WNPlayer *)wnplayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn;
//点击关闭按钮代理方法
-(void)wnplayer:(WNPlayer *)wnplayer clickedCloseButton:(UIButton *)backBtn;
//点击全屏按钮代理方法
-(void)wnplayer:(WNPlayer *)wnplayer clickedFullScreenButton:(UIButton *)fullScreenBtn;
//单击WMPlayer的代理方法
-(void)wnplayer:(WNPlayer *)wnplayer singleTaped:(UITapGestureRecognizer *)singleTap;

//播放失败的代理方法
-(void)wnplayerFailedPlay:(WNPlayer *)wnplayer WNPlayerStatus:(WNPlayerStatus)state;
//播放器已经拿到视频的尺寸大小
-(void)wnplayerGotVideoSize:(WNPlayer *)wnplayer videoSize:(CGSize )presentationSize;
//播放完毕的代理方法
-(void)wnplayerFinishedPlay:(WNPlayer *)wnplayer;
@end



NS_ASSUME_NONNULL_BEGIN

@interface WNPlayer : UIView
@property (nonatomic, strong) WNPlayerManager *playerManager;
@property (nonatomic,copy) NSString *urlString;
@property (nonatomic,copy) NSString *title;
@property (nonatomic, weak)id <WNPlayerDelegate> delegate;
// 播放器着色
@property (nonatomic,strong) UIColor *tintColor;
@property (nonatomic,assign) BOOL autoplay;
@property (nonatomic,assign) BOOL isFullscreen;
@property (nonatomic,assign) BOOL repeat;
@property (nonatomic,assign) BOOL preventFromScreenLock;
@property (nonatomic,assign) BOOL restorePlayAfterAppEnterForeground;
@property (nonatomic,readonly) WNPlayerStatus status;
//获取当前视频播放帧的截图UIImage
- (UIImage*)snapshot:(CGSize)viewSize;
///默认是UDP，如有需要用TCP，请传YES
- (void)openWithTCP:(BOOL)usesTCP;
- (void)close;
- (void)play;
- (void)pause;
//判断是否为iPhone X系列
+(BOOL)IsiPhoneX;
@end

NS_ASSUME_NONNULL_END
