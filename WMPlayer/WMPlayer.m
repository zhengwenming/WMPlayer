/*!
 @header WMPlayer.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
 作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/24
 
 @version 2.0.0 16/1/24 Creation(版本信息)
 
 Copyright © 2016年 郑文明. All rights reserved.
 */


#import "WMPlayer.h"
#import "WMPlayerUtils.h"
#import "WMPlayer+Private.h"

void *WMPlayerStatusObservationContext = &WMPlayerStatusObservationContext;

@implementation WMPlayer
- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self initWMPlayer];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWMPlayer];
    }
    return self;
}

-(instancetype)initPlayerModel:(WMPlayerModel *)playerModel{
    self = [super init];
    if (self) {
        self.playerModel = playerModel;
    }
    return self;
}

+(instancetype)playerWithModel:(WMPlayerModel *)playerModel{
    WMPlayer *player = [[WMPlayer alloc] initPlayerModel:playerModel];
    return player;
}

- (NSString *)videoGravity {
    if (!_videoGravity) {
        _videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _videoGravity;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (!self.isFullscreen) {
        self.originFrame = frame;
    }
}

-(void)setRate:(CGFloat)rate{
    _rate = rate;
    self.player.rate = rate;
    if(rate==1.25){
        [self.rateBtn setTitle:[NSString stringWithFormat:@"%.2fX",rate] forState:UIControlStateNormal];
        [self.rateBtn setTitle:[NSString stringWithFormat:@"%.2fX",rate] forState:UIControlStateSelected];
    }else{
        if (rate==1.0) {
            [self.rateBtn setTitle:@"倍速" forState:UIControlStateNormal];
            [self.rateBtn setTitle:@"倍速" forState:UIControlStateSelected];
        }else{
            [self.rateBtn setTitle:[NSString stringWithFormat:@"%.1fX",rate] forState:UIControlStateNormal];
            [self.rateBtn setTitle:[NSString stringWithFormat:@"%.1fX",rate] forState:UIControlStateSelected];
        }
    }
}
//切换速度

+(BOOL)IsiPhoneX{
    return [WMPlayerUtils isiPhoneXSeries];
}
//是否全屏

-(void)setIsFullscreen:(BOOL)isFullscreen{
    _isFullscreen = isFullscreen;
   self.rateBtn.hidden = self.lockBtn.hidden = !isFullscreen;
   //画中画按钮默认隐藏，仅在横屏全屏时显示（“如果出现”时贴边靠右）
   self.pipBtn.hidden = !isFullscreen;
   self.fullScreenBtn.hidden = self.fullScreenBtn.selected= isFullscreen;
    if (isFullscreen) {
        self.backBtnStyle = BackBtnStylePop;
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(0, 0, MAX(w, h), MIN(w, h));
        self.bottomProgress.alpha = self.isLockScreen?1.0f:0.f;
    }else{
        self.bottomProgress.alpha = 0.0;
        self.frame = self.originFrame;
    }
    //切换全屏/小屏时重置缩放
    [self resetPinchZoom];
}

-(void)setBackBtnStyle:(BackBtnStyle)backBtnStyle{
    _backBtnStyle = backBtnStyle;
    if (backBtnStyle==BackBtnStylePop) {
        [self.backBtn setImage:WMPlayerImage(@"player_icon_nav_back.png") forState:UIControlStateNormal];
        [self.backBtn setImage:WMPlayerImage(@"player_icon_nav_back.png") forState:UIControlStateSelected];
    }else if(backBtnStyle==BackBtnStyleClose){
        [self.backBtn setImage:WMPlayerImage(@"close.png") forState:UIControlStateNormal];
        [self.backBtn setImage:WMPlayerImage(@"close.png") forState:UIControlStateSelected];
    }else{
        [self.backBtn setImage:nil forState:UIControlStateNormal];
        [self.backBtn setImage:nil forState:UIControlStateSelected];
    }
}

-(void)setIsHiddenTopAndBottomView:(BOOL)isHiddenTopAndBottomView{
    _isHiddenTopAndBottomView = isHiddenTopAndBottomView;
    self.prefersStatusBarHidden = isHiddenTopAndBottomView;
}

-(void)setLoopPlay:(BOOL)loopPlay{
    _loopPlay = loopPlay;
    if(self.player){
        if(loopPlay){
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        }else{
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        }
    }
}
//是否处于用户主动暂停/停止的状态

- (BOOL)isPausedByUser{
    return self.state == WMPlayerStateStopped || self.state == WMPlayerStatePause;
}
//设置播放的状态

- (void)setState:(WMPlayerState)state{
    _state = state;
    // 控制菊花显示、隐藏
    if (state == WMPlayerStateBuffering) {
        [self.loadingView startAnimating];
    }else if(state == WMPlayerStatePlaying){
        [self.loadingView stopAnimating];
    }else if(state == WMPlayerStatePause){
        [self.loadingView stopAnimating];
    }else{
        [self.loadingView stopAnimating];
    }
}

-(void)setPrefersStatusBarHidden:(BOOL)prefersStatusBarHidden{
    _prefersStatusBarHidden = prefersStatusBarHidden;
}

-(void)setIsLockScreen:(BOOL)isLockScreen{
    _isLockScreen = isLockScreen;
    self.prefersStatusBarHidden = self.hiddenStatusBar = isLockScreen;
    if (isLockScreen) {
        [self hiddenControlView];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenLockBtn) object:nil];
        [self showControlView];
        [self dismissControlView];
    }
}

-(void)setCurrentItem:(AVPlayerItem *)playerItem{
    if (_currentItem==playerItem) {
        return;
    }
    if (_currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        [_currentItem removeObserver:self forKeyPath:@"status"];
        [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [_currentItem removeObserver:self forKeyPath:@"duration"];
        [_currentItem removeObserver:self forKeyPath:@"presentationSize"];
        _currentItem = nil;
    }
    _currentItem = playerItem;
    if (_currentItem) {
        [_currentItem addObserver:self
                           forKeyPath:@"status"
                              options:NSKeyValueObservingOptionNew
                              context:WMPlayerStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:WMPlayerStatusObservationContext];
        // 缓冲区空了，需要等待数据
        [_currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options: NSKeyValueObservingOptionNew context:WMPlayerStatusObservationContext];
        // 缓冲区有足够数据可以播放了
        [_currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options: NSKeyValueObservingOptionNew context:WMPlayerStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:WMPlayerStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:WMPlayerStatusObservationContext];
        
        [self.player replaceCurrentItemWithPlayerItem:_currentItem];
        // 添加视频播放结束通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    }
   
}

- (void)setMuted:(BOOL)muted{
    _muted = muted;
    self.player.muted = muted;
}

- (void)setPlayerLayerGravity:(WMPlayerLayerGravity)playerLayerGravity {
    _playerLayerGravity = playerLayerGravity;
    switch (playerLayerGravity) {
        case WMPlayerLayerGravityResize:
            self.playerLayer.videoGravity = AVLayerVideoGravityResize;
            self.videoGravity = AVLayerVideoGravityResize;
            break;
        case WMPlayerLayerGravityResizeAspect:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            self.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case WMPlayerLayerGravityResizeAspectFill:
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
}

-(void)setPlayerModel:(WMPlayerModel *)playerModel{
    if (_playerModel==playerModel) {
        return;
    }
    _playerModel = playerModel;
    self.isPauseBySystem = NO;
    self.seekTime = playerModel.seekTime;
    self.titleLabel.text = playerModel.title;
    if(playerModel.playerItem){
        self.currentItem = playerModel.playerItem;
    }else{
        self.videoURL = playerModel.videoURL;
    }
    if (self.isInitPlayer) {
        self.state = WMPlayerStateBuffering;
    }else{
        self.state = WMPlayerStateStopped;
        [self.loadingView stopAnimating];
    }
}

-(void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    self.progressSlider.minimumTrackTintColor = self.tintColor;
    self.bottomProgress.progressTintColor = self.tintColor;
}

-(void)setEnableAirPlay:(BOOL)enableAirPlay{
    _enableAirPlay = enableAirPlay;
    self.airPlayView.hidden= !enableAirPlay;
}

#pragma mark
#pragma mark--播放完成

-(void )resetWMPlayer{
    self.currentItem = nil;
    self.isInitPlayer = NO;
    self.bottomProgress.progress = 0;
    _playerModel = nil;
    self.seekTime = 0;
    //重置缩放
    [self resetPinchZoom];
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 暂停
    [self pause];
    self.progressSlider.value = 0;
    self.bottomProgress.progress = 0;
    self.loadingProgress.progress = 0;
    
    if (self.isFullscreen) {
        self.leftTimeLabel.text = [NSString stringWithFormat:@"%@/%@",[self convertTime:0.0],[self convertTime:0.0]];
        self.rightTimeLabel.text = @"";
    }else{
        self.leftTimeLabel.text  = [self convertTime:0.0];//设置默认值
        self.rightTimeLabel.text = ([self convertTime:self.totalTime]);
    }
    
    self.leftTimeLabel.text = self.isFullscreen?([NSString stringWithFormat:@"/%@",[self convertTime:self.totalTime]]):([self convertTime:self.totalTime]);
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
    // 移除进度观察者
    if (self.playbackTimeObserver) {
        [self.player removeTimeObserver:self.playbackTimeObserver];
        self.playbackTimeObserver = nil;
    }
    // 把player置为nil
    self.player = nil;
}

-(void)dealloc{
    NSLog(@"WMPlayer dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player pause];
    [self.player removeTimeObserver:self.playbackTimeObserver];
    
    //移除观察者
    [_currentItem removeObserver:self forKeyPath:@"status"];
    [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [_currentItem removeObserver:self forKeyPath:@"duration"];
    [_currentItem removeObserver:self forKeyPath:@"presentationSize"];
    _currentItem = nil;

    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.playOrPauseBtn = nil;
    self.playerLayer = nil;
    self.lightView = nil;
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

//获取当前的旋转状态

+(CGAffineTransform)getCurrentDeviceOrientation{
    return [WMPlayerUtils currentDeviceOrientationTransform];
}
//版本号

+(NSString *)version{
    return [WMPlayerUtils playerVersion];
}

@end
