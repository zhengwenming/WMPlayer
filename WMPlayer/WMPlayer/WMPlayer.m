


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


static void *PlayViewCMTimeValue = &PlayViewCMTimeValue;

static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface WMPlayer ()
@property (nonatomic,assign)CGPoint firstPoint;
@property (nonatomic,assign)CGPoint secondPoint;
@property (nonatomic, retain) NSTimer *durationTimer;
@property (nonatomic, retain) NSTimer *autoDismissTimer;
@property (nonatomic, retain)NSDateFormatter *dateFormatter;

@end


@implementation WMPlayer{
    UISlider *systemSlider;
    
}

-(AVPlayerItem *)getPlayItemWithURLString:(NSString *)urlString{
    if ([urlString containsString:@"http"]) {
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
        
        
        
        MPVolumeView *volumeView = [[MPVolumeView alloc]init];
        [self addSubview:volumeView];
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
        systemSlider.hidden = YES;
        
        
        
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
        [self initTimer];
        
        
    }
    return self;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fullScreenBtnClickNotice" object:sender];
}
-(void)colseTheVideo:(UIButton *)sender{
    [self.player pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeTheVideo" object:sender];
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
    sender.selected = !sender.selected;
    if (self.player.rate != 1.f) {
        if ([self currentTime] == [self duration])
            [self setCurrentTime:0.f];
        [self.player play];
    } else {
        [self.player pause];
    }
    
    //    CMTime time = [self.player currentTime];
}
#pragma mark
#pragma mark - 单击手势方法
- (void)handleSingleTap{
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
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.selected;
    if (self.player.rate != 1.f) {
        if ([self currentTime] == self.duration)
            [self setCurrentTime:0.f];
        [self.player play];
    } else {
        [self.player pause];
    }
}
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
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedPlay" object:self.durationTimer];
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
    NSLog(@"interva === %f",interval);
    
    __weak typeof(self) weakSelf = self;
    
    [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)  queue:NULL /* If you pass NULL, the main queue is used. */ usingBlock:^(CMTime time){
        [self syncScrubber];
    }];
    
}
- (void)syncScrubber{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)){
        self.progressSlider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)){
        float minValue = [self.progressSlider minimumValue];
        float maxValue = [self.progressSlider maximumValue];
        double time = CMTimeGetSeconds([self.player currentTime]);
        _timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self convertTime:time],[self convertTime:duration]];
        
//        NSLog(@"时间 :: %f",(maxValue - minValue) * time / duration + minValue);
        [self.progressSlider setValue:(maxValue - minValue) * time / duration + minValue];
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
    UISlider *volumeSlider = (UISlider *)[self viewWithTag:1000];
    volumeSlider.value = systemSlider.value;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch *touch in event.allTouches) {
        self.secondPoint = [touch locationInView:self];
    }
    systemSlider.value += (self.firstPoint.y - self.secondPoint.y)/500.0;
    UISlider *volumeSlider = (UISlider *)[self viewWithTag:1000];
    volumeSlider.value = systemSlider.value;
    self.firstPoint = self.secondPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.firstPoint = self.secondPoint = CGPointZero;
}
-(void)dealloc{
    [self.player pause];
    self.autoDismissTimer = nil;
    self.durationTimer = nil;
    self.player = nil;
    [self.currentItem removeObserver:self forKeyPath:@"status"];
}
@end
