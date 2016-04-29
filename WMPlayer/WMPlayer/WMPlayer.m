


/*!
 @header WMPlayer.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
 作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/24
 
 @version 1.00 16/1/24 Creation(版本信息)
 
 Copyright © 2016年 郑文明. All rights reserved.
 */

#import "WMPlayer.h"
#define WMVideoSrcName(file) [@"WMPlayer.bundle" stringByAppendingPathComponent:file]
#define WMVideoFrameworkSrcName(file) [@"Frameworks/WMPlayer.framework/WMPlayer.bundle" stringByAppendingPathComponent:file]
#define kHalfWidth self.frame.size.width * 0.5
#define kHalfHeight self.frame.size.height * 0.5


static void *PlayViewCMTimeValue = &PlayViewCMTimeValue;

static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface WMPlayer () <UIGestureRecognizerDelegate>
@property (nonatomic,assign)CGPoint firstPoint;
@property (nonatomic,assign)CGPoint secondPoint;
@property (nonatomic, retain)NSDateFormatter *dateFormatter;
//视频进度条的单击事件
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) CGPoint originalPoint;
@end


@implementation WMPlayer{
    UISlider *systemSlider;
    
}

-(AVPlayerItem *)getPlayItemWithURLString:(NSString *)urlString{
    if ([urlString rangeOfString:@"http"].location!=NSNotFound) {
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        return playerItem;
    }else{
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:urlString] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        return playerItem;
    }
    
}
- (instancetype)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor blackColor];
        self.currentItem = [self getPlayItemWithURLString:videoURLStr];
        //AVPlayer
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
        //AVPlayerLayer
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.layer.bounds;
        //        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.layer addSublayer:_playerLayer];
        
        //bottomView
        self.bottomView = [[UIView alloc]init];
        [self addSubview:self.bottomView];
        //autoLayout bottomView
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(0);
            make.right.equalTo(self).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self).with.offset(0);
            
        }];
        [self setAutoresizesSubviews:NO];
        //_playOrPauseBtn
        self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
        [self.playOrPauseBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
        [self.playOrPauseBtn setImage:[UIImage imageNamed:WMVideoSrcName(@"pause")] ?: [UIImage imageNamed:WMVideoFrameworkSrcName(@"pause")] forState:UIControlStateNormal];
        [self.playOrPauseBtn setImage:[UIImage imageNamed:WMVideoSrcName(@"play")] ?: [UIImage imageNamed:WMVideoFrameworkSrcName(@"play")] forState:UIControlStateSelected];
        [self.bottomView addSubview:self.playOrPauseBtn];
        //autoLayout _playOrPauseBtn
        [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.bottomView).with.offset(0);
            make.width.mas_equalTo(40);
            
        }];
        
        //创建亮度的进度条
        self.lightSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        self.lightSlider.hidden = YES;
        self.lightSlider.minimumValue = 0;
        self.lightSlider.maximumValue = 1;
        //        进度条的值等于当前系统亮度的值,范围都是0~1
        self.lightSlider.value = [UIScreen mainScreen].brightness;
        [self.lightSlider addTarget:self action:@selector(updateLightValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.lightSlider];
        
        
        
        MPVolumeView *volumeView = [[MPVolumeView alloc]init];
        [self addSubview:volumeView];
        volumeView.frame = CGRectMake(-1000, -100, 100, 100);
        [volumeView sizeToFit];
        
        
        systemSlider = [[UISlider alloc]init];
        systemSlider.backgroundColor = [UIColor clearColor];
        for (UIControl *view in volumeView.subviews) {
            if ([view.superclass isSubclassOfClass:[UISlider class]]) {
                NSLog(@"1");
                systemSlider = (UISlider *)view;
            }
        }
        systemSlider.autoresizesSubviews = NO;
        systemSlider.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:systemSlider];
        //        systemSlider.hidden = YES;
        
        
        
        self.volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        self.volumeSlider.tag = 1000;
        self.volumeSlider.hidden = YES;
        self.volumeSlider.minimumValue = systemSlider.minimumValue;
        self.volumeSlider.maximumValue = systemSlider.maximumValue;
        self.volumeSlider.value = systemSlider.value;
        [self.volumeSlider addTarget:self action:@selector(updateSystemVolumeValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.volumeSlider];
        
        
        //slider
        self.progressSlider = [[UISlider alloc]init];
        self.progressSlider.minimumValue = 0.0;
        [self.progressSlider setThumbImage:[UIImage imageNamed:WMVideoSrcName(@"dot")] ?: [UIImage imageNamed:WMVideoFrameworkSrcName(@"dot")]  forState:UIControlStateNormal];
        self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
        self.progressSlider.value = 0.0;//指定初始值
        [self.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside];
        
        //给进度条添加单击手势
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
        self.tap.delegate = self;
        [self.progressSlider addGestureRecognizer:self.tap];
        [self.bottomView addSubview:self.progressSlider];
        
        [self.bottomView addSubview:self.progressSlider];
        
        //autoLayout slider
        [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView).with.offset(45);
            make.right.equalTo(self.bottomView).with.offset(-45);
            make.height.mas_equalTo(40);
            make.top.equalTo(self.bottomView).with.offset(0);
        }];
        
        //_fullScreenBtn
        self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fullScreenBtn.showsTouchWhenHighlighted = YES;
        [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.fullScreenBtn setImage:[UIImage imageNamed:WMVideoSrcName(@"fullscreen")] ?: [UIImage imageNamed:WMVideoFrameworkSrcName(@"fullscreen")] forState:UIControlStateNormal];
        [self.fullScreenBtn setImage:[UIImage imageNamed:WMVideoSrcName(@"nonfullscreen")] ?: [UIImage imageNamed:WMVideoFrameworkSrcName(@"nonfullscreen")] forState:UIControlStateSelected];
        [self.bottomView addSubview:self.fullScreenBtn];
        //autoLayout fullScreenBtn
        [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bottomView).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.bottomView).with.offset(0);
            make.width.mas_equalTo(40);
            
        }];
        
        
        //timeLabel
        self.timeLabel = [[UILabel alloc]init];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:11];
        [self.bottomView addSubview:self.timeLabel];
        //autoLayout timeLabel
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomView).with.offset(45);
            make.right.equalTo(self.bottomView).with.offset(-45);
            make.height.mas_equalTo(20);
            make.bottom.equalTo(self.bottomView).with.offset(0);
        }];
        
        [self bringSubviewToFront:self.bottomView];
        
        
        
        
        
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.showsTouchWhenHighlighted = YES;
        [_closeBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setImage:[UIImage imageNamed:WMVideoSrcName(@"close")] ?: [UIImage imageNamed:WMVideoFrameworkSrcName(@"close")] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:WMVideoSrcName(@"close")] ?: [UIImage imageNamed:WMVideoFrameworkSrcName(@"close")] forState:UIControlStateSelected];
        _closeBtn.layer.cornerRadius = 30/2;
        [self addSubview:_closeBtn];
        
        
        
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            
            
            make.left.equalTo(self.bottomView).with.offset(5);
            make.height.mas_equalTo(30);
            make.top.equalTo(self).with.offset(5);
            make.width.mas_equalTo(30);
            
            
        }];
        
        
        
        
        // 单击的 Recognizer
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
        singleTap.numberOfTapsRequired = 1; // 单击
        [self addGestureRecognizer:singleTap];
        
        // 双击的 Recognizer
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
        doubleTap.numberOfTapsRequired = 2; // 双击
        [self addGestureRecognizer:doubleTap];
        
        
        [self.currentItem addObserver:self
                           forKeyPath:@"status"
                              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                              context:PlayViewStatusObservationContext];
        
        
        
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        
        [self initTimer];
        
        
    }
    return self;
}


- (void)appDidEnterBackground:(NSNotification*)note
{
//    [self PlayOrPause:self.playOrPauseBtn];

    NSLog(@"appDidEnterBackground");
}

- (void)appWillEnterForeground:(NSNotification*)note
{
//    [self PlayOrPause:self.playOrPauseBtn];

    NSLog(@"appWillEnterForeground");
}
- (void)appwillResignActive:(NSNotification *)note
{
    //    [self PlayOrPause:self.playOrPauseBtn];
    NSLog(@"appwillResignActive");
}
- (void)appBecomeActive:(NSNotification *)note
{
    [self.player pause];
    self.playOrPauseBtn.selected = YES;
}
//视频进度条的点击事件
- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:self.progressSlider];
    CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (touchPoint.x / self.progressSlider.frame.size.width );
    [self.progressSlider setValue:value animated:YES];
    [self.player seekToTime:CMTimeMakeWithSeconds(self.progressSlider.value, 1)];
}

- (void)updateSystemVolumeValue:(UISlider *)slider{
    systemSlider.value = slider.value;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}
#pragma mark
#pragma mark - fullScreenAction
-(void)fullScreenAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    //用通知的形式把点击全屏的时间发送到app的任何地方，方便处理其他逻辑
    [[NSNotificationCenter defaultCenter] postNotificationName:WMPlayerFullScreenButtonClickedNotification object:sender];
}
-(void)colseTheVideo:(UIButton *)sender{
    [self.player pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:WMPlayerClosedNotification object:sender];
}
- (double)duration{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return CMTimeGetSeconds([[playerItem asset] duration]);
    }
    else{
        return 0.f;
    }
}

- (double)currentTime{
    return CMTimeGetSeconds([[self player] currentTime]);
}

- (void)setCurrentTime:(double)time{
    [[self player] seekToTime:CMTimeMakeWithSeconds(time, 1)];
}
#pragma mark
#pragma mark - PlayOrPause
- (void)PlayOrPause:(UIButton *)sender{
    if (self.durationTimer==nil) {
        self.durationTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(finishedPlay:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
    }
    
    if (self.player.rate != 1.f) {
        if ([self currentTime] == [self duration])
            [self setCurrentTime:0.f];
        sender.selected = NO;
        [self.player play];
    } else {
        sender.selected = YES;
        [self.player pause];
    }
    
    //    CMTime time = [self.player currentTime];
}
-(void)play{
    [self PlayOrPause:self.playOrPauseBtn];
}
-(void)pause{
    [self PlayOrPause:self.playOrPauseBtn];
}
#pragma mark
#pragma mark - 单击手势方法
- (void)handleSingleTap{
    [[NSNotificationCenter defaultCenter] postNotificationName:WMPlayerSingleTapNotification object:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self.bottomView.alpha == 0.0) {
            self.bottomView.alpha = 1.0;
            self.closeBtn.alpha = 1.0;
            
        }else{
            self.bottomView.alpha = 0.0;
            self.closeBtn.alpha = 0.0;
            
        }
    } completion:^(BOOL finish){
        
    }];
}
#pragma mark
#pragma mark - 双击手势方法
- (void)handleDoubleTap{
    [[NSNotificationCenter defaultCenter] postNotificationName:WMPlayerDoubleTapNotification object:nil];
    if (self.player.rate != 1.f) {
        if ([self currentTime] == self.duration)
            [self setCurrentTime:0.f];
        [self.player play];
        self.playOrPauseBtn.selected = NO;
    } else {
        [self.player pause];
        self.playOrPauseBtn.selected = YES;
    }
}

/**
 *  重写videoURLStr的setter方法，处理自己的逻辑，
 */
#pragma mark
#pragma mark - 设置播放的视频
- (void)setVideoURLStr:(NSString *)videoURLStr
{
    _videoURLStr = videoURLStr;
    
    if (self.currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        [self.currentItem removeObserver:self forKeyPath:@"status"];
        
        //        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    self.currentItem = [self getPlayItemWithURLString:videoURLStr];
    
    
    
    
    [self.currentItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:PlayViewStatusObservationContext];
    
    [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];

    
}
- (void)moviePlayDidEnd:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [weakSelf.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.progressSlider setValue:0.0 animated:YES];
        weakSelf.playOrPauseBtn.selected = NO;
    }];
}
#pragma mark - 播放进度
- (void)updateProgress:(UISlider *)slider{
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, 1)];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    /* AVPlayerItem "status" property value observer. */
    if (context == PlayViewStatusObservationContext)
    {
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                if (CMTimeGetSeconds(self.player.currentItem.duration)) {
                    self.progressSlider.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
                }
                
                [self initTimer];
                if (self.durationTimer==nil) {
                    self.durationTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(finishedPlay:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
                }
                
                //5s dismiss bottomView
                if (self.autoDismissTimer==nil) {
                    self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
                }
                
                
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                
            }
                break;
        }
    }
    
}
#pragma mark
#pragma mark finishedPlay
- (void)finishedPlay:(NSTimer *)timer{
    if (self.currentTime == self.duration&&self.player.rate==.0f) {
        self.playOrPauseBtn.selected = YES;
        //播放完成后的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:WMPlayerFinishedPlayNotification object:self.durationTimer];
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
}
#pragma mark
#pragma mark autoDismissBottomView
-(void)autoDismissBottomView:(NSTimer *)timer{
    
    if (self.player.rate==.0f&&self.currentTime != self.duration) {//暂停状态
        //        if (self.bottomView.alpha == 0.0) {
        //
        //        }else{
        //            self.bottomView.alpha = 1.0;
        //        }
    }else if(self.player.rate==1.0f){
        if (self.bottomView.alpha==1.0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.bottomView.alpha = 0.0;
                self.closeBtn.alpha = 0.0;
                
            } completion:^(BOOL finish){
                
            }];
        }
    }
}
#pragma  maik - 定时器
-(void)initTimer{
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([self.progressSlider bounds]);
        interval = 0.5f * duration / width;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)  queue:NULL /* If you pass NULL, the main queue is used. */ usingBlock:^(CMTime time){
        [weakSelf syncScrubber];
    }];
    
}
- (void)syncScrubber{
    __weak typeof(self) weakSelf = self;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)){
        weakSelf.progressSlider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)){
        float minValue = [weakSelf.progressSlider minimumValue];
        float maxValue = [weakSelf.progressSlider maximumValue];
        double time = CMTimeGetSeconds([weakSelf.player currentTime]);
        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[weakSelf convertTime:time],[weakSelf convertTime:duration]];
        
        //        NSLog(@"时间 :: %f",(maxValue - minValue) * time / duration + minValue);
        [weakSelf.progressSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = [self.player currentItem];
    //    NSLog(@"%ld",playerItem.status);
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    NSString *newTime = [[self dateFormatter] stringFromDate:d];
    return newTime;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch *touch in event.allTouches) {
        self.firstPoint = [touch locationInView:self];
        
    }
    self.volumeSlider.value = systemSlider.value;
    //记录下第一个点的位置,用于moved方法判断用户是调节音量还是调节视频
    self.originalPoint = self.firstPoint;
    
    
    //    UISlider *volumeSlider = (UISlider *)[self viewWithTag:1000];
    //    volumeSlider.value = systemSlider.value;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch *touch in event.allTouches) {
        self.secondPoint = [touch locationInView:self];
    }
    
    //判断是左右滑动还是上下滑动
    CGFloat verValue =fabs(self.originalPoint.y - self.secondPoint.y);
    CGFloat horValue = fabs(self.originalPoint.x - self.secondPoint.x);
    
    //如果竖直方向的偏移量大于水平方向的偏移量,那么是调节音量或者亮度
    if (verValue > horValue) {//上下滑动
        
        //判断是全屏模式还是正常模式
        if (self.isFullscreen) {//全屏下
            
            //判断刚开始的点是左边还是右边,左边控制音量
            if (self.originalPoint.x <= kHalfHeight) {//全屏下:point在view的左边(控制音量)
                
                /* 手指上下移动的计算方式,根据y值,刚开始进度条在0位置,当手指向上移动600个点后,当手指向上移动N个点的距离后,
                 当前的进度条的值就是N/600,600随开发者任意调整,数值越大,那么进度条到大1这个峰值需要移动的距离也变大,反之越小 */
                systemSlider.value += (self.firstPoint.y - self.secondPoint.y)/600.0;
                self.volumeSlider.value = systemSlider.value;
            }else{//全屏下:point在view的右边(控制亮度)
                //右边调节屏幕亮度
                self.lightSlider.value += (self.firstPoint.y - self.secondPoint.y)/600.0;
                [[UIScreen mainScreen] setBrightness:self.lightSlider.value];
                
            }
        }else{//非全屏
            
            //判断刚开始的点是左边还是右边,左边控制音量
            if (self.originalPoint.x <= kHalfWidth) {//非全屏下:point在view的左边(控制音量)
                
                /* 手指上下移动的计算方式,根据y值,刚开始进度条在0位置,当手指向上移动600个点后,当手指向上移动N个点的距离后,
                 当前的进度条的值就是N/600,600随开发者任意调整,数值越大,那么进度条到大1这个峰值需要移动的距离也变大,反之越小 */
                systemSlider.value += (self.firstPoint.y - self.secondPoint.y)/600.0;
                self.volumeSlider.value = systemSlider.value;
            }else{//非全屏下:point在view的右边(控制亮度)
                //右边调节屏幕亮度
                self.lightSlider.value += (self.firstPoint.y - self.secondPoint.y)/600.0;
                [[UIScreen mainScreen] setBrightness:self.lightSlider.value];
                
            }
        }
    }else{//左右滑动,调节视频的播放进度
        //视频进度不需要除以600是因为self.progressSlider没设置最大值,它的最大值随着视频大小而变化
        //要注意的是,视频的一秒时长相当于progressSlider.value的1,视频有多少秒,progressSlider的最大值就是多少
        self.progressSlider.value -= (self.firstPoint.x - self.secondPoint.x);
        
        [self.player seekToTime:CMTimeMakeWithSeconds(self.progressSlider.value, 1)];
        
        //滑动太快可能会停止播放,所以这里自动继续播放
        [self.player play];
        self.playOrPauseBtn.selected = NO;
    }
    
    self.firstPoint = self.secondPoint;
    
    
    
    //    systemSlider.value += (self.firstPoint.y - self.secondPoint.y)/500.0;
    //    UISlider *volumeSlider = (UISlider *)[self viewWithTag:1000];
    //    volumeSlider.value = systemSlider.value;
    //    self.firstPoint = self.secondPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.firstPoint = self.secondPoint = CGPointZero;
}
-(void)dealloc{
    NSLog(@"WMPlayer dealloc");
    [self.player pause];
    self.autoDismissTimer = nil;
    self.durationTimer = nil;
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.currentItem removeObserver:self forKeyPath:@"status"];
}
@end
