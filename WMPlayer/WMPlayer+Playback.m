//
//  WMPlayer+Playback.m
//  WMPlayer
//
//  重构拆分：由 WMPlayer.m 中拆出的“Playback”相关实现。
//

#import "WMPlayer+Private.h"

@implementation WMPlayer (Playback)

- (void)appDidEnterBackground:(NSNotification*)note{
        if (self.state==WMPlayerStateFinished) {
            return;
        }else if (self.state==WMPlayerStateStopped) {//如果已经人为的暂停了
            self.isPauseBySystem = NO;
        }else if(self.state==WMPlayerStatePlaying){
            if (self.enableBackgroundMode) {
                self.playerLayer.player = nil;
                [self.playerLayer removeFromSuperlayer];
                if(![self.rateBtn.currentTitle isEqualToString:@"倍速"]){
                    self.rate = [self.rateBtn.currentTitle floatValue];
                }
            }else{
                self.isPauseBySystem = YES;
                [self pause];
                self.state = WMPlayerStatePause;
            }
        }
}

- (void)appWillEnterForeground:(NSNotification*)note{
        if (self.state==WMPlayerStateFinished) {
            if (self.enableBackgroundMode) {
                self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
                self.playerLayer.frame = self.contentView.bounds;
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                [self.contentView.layer insertSublayer:self.playerLayer atIndex:0];
            }else{
                return;
            }
        }else if(self.state==WMPlayerStateStopped){
            return;
        }else if(self.state==WMPlayerStatePause){
            if (self.isPauseBySystem) {
                self.isPauseBySystem = NO;
                [self play];
            }
        }else if(self.state==WMPlayerStatePlaying){
            if (self.enableBackgroundMode) {
                self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
                self.playerLayer.frame = self.contentView.bounds;
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                [self.contentView.layer insertSublayer:self.playerLayer atIndex:0];
                [self.player play];
                if(![self.rateBtn.currentTitle isEqualToString:@"倍速"]){
                    self.rate = [self.rateBtn.currentTitle floatValue];
                }
            }else{
                return;
            }
        }
}
//视频进度条的点击事件

- (double)duration{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return CMTimeGetSeconds([[playerItem asset] duration]);
    }else{
        return 0.f;
    }
}
//获取视频当前播放的时间

- (double)currentTime{
    if (self.player) {
        return CMTimeGetSeconds([self.player currentTime]);
    }else{
        return 0.0;
    }
}
#pragma mark
#pragma mark - PlayOrPause

-(void)play{
    if (self.isInitPlayer == NO) {
        [self creatWMPlayerAndReadyToPlay];
        self.playOrPauseBtn.selected = NO;
    }else{
        if (self.state==WMPlayerStateStopped||self.state ==WMPlayerStatePause) {
            self.state = WMPlayerStatePlaying;
            self.playOrPauseBtn.selected = NO;
            [self.player play];
        }
    }
}
//暂停

-(void)pause{
    if (self.state==WMPlayerStatePlaying) {
        self.state = WMPlayerStateStopped;
    }
    [self.player pause];
    self.playOrPauseBtn.selected = YES;
}

-(void)setupSuport {
    if([AVPictureInPictureController isPictureInPictureSupported]) {
        self.AVPictureInPictureController =  [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
        self.AVPictureInPictureController.delegate = self;
    } else {
        // not supported PIP start button desable here
    }
}
-(void)creatWMPlayerAndReadyToPlay{
    self.isInitPlayer = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    //设置player的参数
    if(self.currentItem){
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    }else{
        self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
        self.currentItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
    }
    if(self.loopPlay){
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    }else{
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    }
    //ios10新添加的属性，如果播放不了，可以试试打开这个代码
    if ([self.player respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
        self.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
    //AVPlayerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    //WMPlayer视频的默认填充模式，AVLayerVideoGravityResizeAspect
    self.playerLayer.frame = self.contentView.layer.bounds;
    self.playerLayer.videoGravity = self.videoGravity;
    [self.contentView.layer insertSublayer:self.playerLayer atIndex:0];
    self.state = WMPlayerStateBuffering;
    //监听播放状态
    [self initTimer];
    [self.player play];
    //添加画中画相关代码
    [self setupSuport];
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayerFinishedPlay:)]) {
        [self.delegate wmplayerFinishedPlay:self];
    }
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            if (self.isLockScreen) {
                [self lockAction:self.lockBtn];
            }else{
                [self showControlView];
            }
            if(!self.loopPlay){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.state = WMPlayerStateFinished;
                    self.bottomProgress.progress = 0;
                    self.playOrPauseBtn.selected = YES;
                });
            }
        }
    }];
}
//显示操作栏view

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    /* AVPlayerItem "status" property value observer. */
    if (context == WMPlayerStatusObservationContext){
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status){
                case AVPlayerItemStatusUnknown:{
                    [self.loadingProgress setProgress:0.0 animated:NO];
                    self.state = WMPlayerStateBuffering;
                    [self.loadingView startAnimating];
                }
                    break;
                case AVPlayerItemStatusReadyToPlay:{
                      /* Once the AVPlayerItem becomes ready to play, i.e.
                     [playerItem status] == AVPlayerItemStatusReadyToPlay,
                     its duration can be fetched from the item. */
                    if (![self isPausedByUser]) {
                        //5s dismiss controlView
                        [self dismissControlView];
                        self.state=WMPlayerStatePlaying;
                    }
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayerReadyToPlay:WMPlayerStatus:)]) {
                        [self.delegate wmplayerReadyToPlay:self WMPlayerStatus:WMPlayerStatePlaying];
                    }
                    [self.loadingView stopAnimating];
                    if (self.seekTime) {
                        [self seekToTimeToPlay:self.seekTime];
                    }
                    if (self.muted) {
                        self.player.muted = self.muted;
                    }
                    if (![self isPausedByUser]) {
                        if(![self.rateBtn.currentTitle isEqualToString:@"倍速"]){
                            self.rate = [self.rateBtn.currentTitle floatValue];
                        }
                    }
                }
                    break;
                    
                case AVPlayerItemStatusFailed:{
                    self.state = WMPlayerStateFailed;
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayerFailedPlay:WMPlayerStatus:)]) {
                        [self.delegate wmplayerFailedPlay:self WMPlayerStatus:WMPlayerStateFailed];
                    }
                    NSError *error = [self.player.currentItem error];
                    if (error) {
                        self.loadFailedLabel.hidden = NO;
                        [self bringSubviewToFront:self.loadFailedLabel];
                        [self.loadingView stopAnimating];
                        NSLog(@"视频加载失败===%@", error.localizedDescription);
                    }
                }
                    break;
            }
        }else if ([keyPath isEqualToString:@"duration"]) {
            if ((CGFloat)CMTimeGetSeconds(self.currentItem.duration) != self.totalTime) {
                self.totalTime = (CGFloat) CMTimeGetSeconds(self.currentItem.asset.duration);
                
                if (isnan(self.totalTime)) {
                    //时长为非法值时跳过本次更新，避免污染进度条
                    return;
                }
                self.progressSlider.maximumValue = self.totalTime;
                if (![self isPausedByUser]) {
                    self.state = WMPlayerStatePlaying;
                }
            }
        }else if ([keyPath isEqualToString:@"presentationSize"]) {
            self.playerModel.presentationSize = self.currentItem.presentationSize;
            if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayerGotVideoSize:videoSize:)]) {
                [self.delegate wmplayerGotVideoSize:self videoSize:self.playerModel.presentationSize];
            }
        }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.currentItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            //缓冲颜色
            self.loadingProgress.progressTintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
            [self.loadingProgress setProgress:timeInterval / totalDuration animated:NO];
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            [self.loadingView startAnimating];
            // 当缓冲是空的时候
            if (self.currentItem.playbackBufferEmpty) {
                [self loadedTimeRanges];
            }
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            //here
            [self.loadingView stopAnimating];
            // 当缓冲好的时候
            if (self.currentItem.playbackLikelyToKeepUp && self.state == WMPlayerStateBuffering){
                if (![self isPausedByUser]) {
                    self.state = WMPlayerStatePlaying;
                }
            }
        }
    }
}
//缓冲为空时的兜底重试：5秒后若仍未进入播放/结束状态，则尝试重新播放

- (void)loadedTimeRanges{
    if (self.state != WMPlayerStatePause) {
        self.state = WMPlayerStateBuffering;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.state != WMPlayerStatePlaying && self.state != WMPlayerStateFinished) {
            [self play];
        }
        [self.loadingView stopAnimating];
    });
}

#pragma mark
#pragma mark autoDismissControlView

-(void)initTimer{
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver =  [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC)  queue:dispatch_get_main_queue() /* If you pass NULL, the main queue is used. */
        usingBlock:^(CMTime time){
        [weakSelf syncScrubber];
    }];
}

- (void)syncScrubber{
    CMTime playerDuration = [self playerItemDuration];
    CGFloat totalTime = (CGFloat)CMTimeGetSeconds(playerDuration);
    long long nowTime = self.currentItem.currentTime.value/self.currentItem.currentTime.timescale;
    
    if (self.isFullscreen) {
        self.leftTimeLabel.text = [NSString stringWithFormat:@"%@/%@",[self convertTime:nowTime],[self convertTime:self.totalTime]];
        self.rightTimeLabel.text = @"";
    }else{
        self.leftTimeLabel.text  = [self convertTime:nowTime];
        self.rightTimeLabel.text = ([self convertTime:self.totalTime]);
    }
    
    //视频时长尚未就绪时直接返回，避免除零产生 NaN/inf
    if (self.totalTime <= 0 || isnan(self.totalTime) || isnan(totalTime)) {
        self.rightTimeLabel.text = @"";
        return;
    }
    if (self.dragingSliderStatus==1) {//拖拽slider中，不更新slider的值

    }else if(self.dragingSliderStatus==2){
            nowTime = self.progressSlider.value;
            CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * nowTime / self.totalTime + self.progressSlider.minimumValue;
            self.progressSlider.value = value;
            [self.bottomProgress setProgress:nowTime/(self.totalTime) animated:NO];
            self.dragingSliderStatus = 0;
        }else if(self.dragingSliderStatus==0){
            CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * nowTime / self.totalTime + self.progressSlider.minimumValue;
            self.progressSlider.value = value;
            [self.bottomProgress setProgress:nowTime/(self.totalTime) animated:YES];
        }
}
//seekTime跳到time处播放

- (void)seekToTimeToPlay:(double)seekTime{
    if (self.player&&self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (seekTime>=self.totalTime) {
            seekTime = 0.0;
        }
        if (seekTime<0) {
            seekTime=0.0;
        }
//        int32_t timeScale = self.player.currentItem.asset.duration.timescale;
        //currentItem.asset.duration.timescale计算的时候严重堵塞主线程，慎用
        /* A timescale of 1 means you can only specify whole seconds to seek to. The timescale is the number of parts per second. Use 600 for video, as Apple recommends, since it is a product of the common video frame rates like 50, 60, 25 and 24 frames per second*/
        [self.player seekToTime:CMTimeMakeWithSeconds(seekTime, self.currentItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            self.seekTime = 0;
        }];
    }
}

- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = self.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
}

- (NSString *)convertTime:(float)second{
    return [WMPlayerUtils timeStringFromSeconds:second];
}
//计算缓冲进度

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [self.currentItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
#pragma mark
#pragma mark - touches

@end
