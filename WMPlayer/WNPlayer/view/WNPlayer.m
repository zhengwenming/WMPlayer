//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayer.h"
#import "WNPlayerUtils.h"
#import "Masonry.h"
#define WNPlayerSrcName(file) [@"WNPlayer.bundle" stringByAppendingPathComponent:file]
#define WNPlayerFrameworkSrcName(file) [@"Frameworks/WNPlayer.framework/WNPlayer.bundle" stringByAppendingPathComponent:file]
#define WNPlayerImage(file)      [UIImage imageNamed:WNPlayerSrcName(file)] ? :[UIImage imageNamed:WNPlayerFrameworkSrcName(file)]
typedef enum : NSUInteger {
    WNPlayerOperationNone,
    WNPlayerOperationOpen,
    WNPlayerOperationPlay,
    WNPlayerOperationPause,
    WNPlayerOperationClose,
} WNPlayerOperation;

@interface WNPlayer (){
    BOOL restorePlay;
    BOOL animatingHUD;
    NSTimeInterval showHUDTime;
}
//格式化时间（懒加载防止多次重复初始化）
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIImageView *topView,*bottomView;
//显示播放时间的UILabel+加载失败的UILabel+播放视频的title
@property (nonatomic,strong) UILabel   *leftTimeLabel,*rightTimeLabel,*titleLabel,*loadFailedLabel;
@property (nonatomic, strong) UISlider *progressSlider;
//控制全屏和播放暂停按钮
@property (nonatomic,strong) UIButton  *fullScreenBtn,*playOrPauseBtn,*lockBtn,*backBtn,*rateBtn;
@property (nonatomic) UITapGestureRecognizer *singleTap;
@property (nonatomic) dispatch_source_t timer;
@property (nonatomic) BOOL updateHUD;
@property (nonatomic) NSTimer *timerForHUD;

@property (nonatomic, readwrite) WNPlayerStatus status;
@property (nonatomic) WNPlayerOperation nextOperation;

@end

@implementation WNPlayer
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    return _dateFormatter;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.playerManager = [[WNPlayerManager alloc] init];
        self.contentView = self.playerManager.displayView;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        self.topView = [[UIImageView alloc]initWithImage:WNPlayerImage(@"top_shadow")];
        self.topView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.equalTo(self.contentView);
            make.height.mas_equalTo([WNPlayer IsiPhoneX]?50:90);
        }];
        
        
        //backBtn
        self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backBtn.showsTouchWhenHighlighted = YES;
        [self.backBtn setImage:WNPlayerImage(@"player_icon_nav_back.png") forState:UIControlStateNormal];
        [self.backBtn setImage:WNPlayerImage(@"player_icon_nav_back.png") forState:UIControlStateSelected];
        [self.backBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:self.backBtn];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.topView).offset(8);
            make.size.mas_equalTo(CGSizeMake(self.backBtn.currentImage.size.width+6, self.backBtn.currentImage.size.height+4));
            make.centerY.equalTo(self.topView);
        }];
        
        // Title Label
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.topView addSubview:self.titleLabel];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.backBtn.mas_trailing).offset(50);
            make.trailing.equalTo(self.topView).offset(-50);
            make.center.equalTo(self.topView);
            make.top.equalTo(self.topView);
        }];
        
        
        //bottomView
        self.bottomView = [[UIImageView alloc]initWithImage:WNPlayerImage(@"bottom_shadow")];
        self.bottomView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(50);
        }];
        
        // Play/Pause Button
        self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
        [self.playOrPauseBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        [self.playOrPauseBtn setImage:WNPlayerImage(@"player_ctrl_icon_pause") forState:UIControlStateNormal];
        [self.playOrPauseBtn setImage:WNPlayerImage(@"player_ctrl_icon_play") forState:UIControlStateSelected];
        [self.bottomView addSubview:self.playOrPauseBtn];
        self.playOrPauseBtn.selected = YES;//默认状态，即默认是不自动播放
        [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomView);
            make.leading.equalTo(self.bottomView).offset(10);
        }];
        
        
        
        // leftTimeLabel
        self.leftTimeLabel = [[UILabel alloc] init];
        self.leftTimeLabel.backgroundColor = [UIColor clearColor];
        self.leftTimeLabel.text = @"00:00:00";
        self.leftTimeLabel.font = [UIFont systemFontOfSize:11];
        self.leftTimeLabel.textColor = [UIColor whiteColor];
        self.leftTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:self.leftTimeLabel];
        [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.bottomView).offset(50);
            make.top.equalTo(self.bottomView.mas_centerY).with.offset(8);
        }];

        // rightTimeLabel
        self.rightTimeLabel = [[UILabel alloc] init];
        self.rightTimeLabel.backgroundColor = [UIColor clearColor];
        self.rightTimeLabel.text = @"00:00:00";
        self.rightTimeLabel.font = [UIFont systemFontOfSize:11];
        self.rightTimeLabel.textColor = [UIColor whiteColor];
        self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:self.rightTimeLabel];
        [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.bottomView).offset(-50);
            make.top.equalTo(self.bottomView.mas_centerY).with.offset(8);
        }];
        
        
        
        //fullScreenBtn
        self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fullScreenBtn.showsTouchWhenHighlighted = YES;
        [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.fullScreenBtn setImage:WNPlayerImage(@"player_icon_fullscreen") forState:UIControlStateNormal];
        [self.fullScreenBtn setImage:WNPlayerImage(@"player_icon_fullscreen") forState:UIControlStateSelected];
        [self.bottomView addSubview:self.fullScreenBtn];
        [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomView);
            make.trailing.equalTo(self.bottomView).offset(-10);
        }];
        
        
        //slider
        self.progressSlider = [UISlider new];
        self.progressSlider.minimumValue = 0.0;
        self.progressSlider.maximumValue = 1.0;
        self.progressSlider.continuous = YES;
        [self.progressSlider setThumbImage:WNPlayerImage(@"dot")  forState:UIControlStateNormal];
        self.progressSlider.minimumTrackTintColor = self.tintColor?self.tintColor:[UIColor greenColor];
        self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        self.progressSlider.backgroundColor = [UIColor clearColor];
        self.progressSlider.value = 0.0;//指定初始值
        [self.progressSlider addTarget:self action:@selector(onSliderStartSlide:) forControlEvents:UIControlEventTouchDown];
        //进度条的拖拽事件
        [self.progressSlider addTarget:self action:@selector(onSliderValueChanged:)  forControlEvents:UIControlEventValueChanged];
        //进度条的点击事件
        [self.progressSlider addTarget:self action:@selector(onSliderEndSlide:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        //给进度条添加单击手势
        //        self.progressTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
        //        self.progressTap.delegate = self;
        //        [self.progressSlider addGestureRecognizer:self.progressTap];
        [self.bottomView addSubview:self.progressSlider];
        [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.leftTimeLabel.mas_leading).offset(4);
            make.trailing.equalTo(self.rightTimeLabel.mas_trailing).offset(-4);
            make.centerY.equalTo(self.bottomView).offset(-1);
            make.height.mas_equalTo(30);
        }];


        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.contentView addSubview:self.loadingView];
        self.loadingView.hidesWhenStopped = YES;
        [self.loadingView startAnimating];
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
        
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesutreRecognizer:)];
        self.singleTap.numberOfTapsRequired = 1;
        self.singleTap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:self.singleTap];
        
        self.status = WNPlayerStatusNone;
        self.nextOperation = WNPlayerOperationNone;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(notifyAppDidEnterBackground:)
                   name:UIApplicationDidEnterBackgroundNotification object:nil];
        [nc addObserver:self selector:@selector(notifyAppWillEnterForeground:)
                   name:UIApplicationWillEnterForegroundNotification object:nil];
        [nc addObserver:self selector:@selector(notifyPlayerOpened:) name:WNPlayerNotificationOpened object:self.playerManager];
        [nc addObserver:self selector:@selector(notifyPlayerClosed:) name:WNPlayerNotificationClosed object:self.playerManager];
        [nc addObserver:self selector:@selector(notifyPlayerEOF:) name:WNPlayerNotificationEOF object:self.playerManager];
        [nc addObserver:self selector:@selector(notifyPlayerBufferStateChanged:) name:WNPlayerNotificationBufferStateChanged object:self.playerManager];
        [nc addObserver:self selector:@selector(notifyPlayerError:) name:WNPlayerNotificationError object:self.playerManager];
    }
    return self;
}
//close btn action
-(void)colseTheVideo:(UIButton *)sender{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wnplayer:clickedCloseButton:)]) {
        [self.delegate wnplayer:self clickedCloseButton:sender];
    }
}
//fullScreen btn action
-(void)fullScreenAction:(UIButton *)sender{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wnplayer:clickedFullScreenButton:)]) {
        [self.delegate wnplayer:self clickedFullScreenButton:sender];
    }
}
//playOrPauseBtn action
- (void)playOrPause:(UIButton *)sender {
    if (self.playerManager.playing) {
        [self pause];
    } else {
        [self play];
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wnplayer:clickedPlayOrPauseButton:)]) {
        [self.delegate wnplayer:self clickedPlayOrPauseButton:sender];
    }
}
-(void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    self.progressSlider.minimumTrackTintColor = self.tintColor;
}
- (void)onSliderStartSlide:(UISlider *)sender {
    self.updateHUD = NO;
    self.singleTap.enabled = NO;
}

- (void)onSliderValueChanged:(UISlider *)slider {
    int seconds = slider.value;
    self.leftTimeLabel.text = [self convertTime:seconds];
}

- (void)onSliderEndSlide:(UISlider *)slider {
    float position = slider.value;
    self.playerManager.position = position;
    self.updateHUD = YES;
    self.singleTap.enabled = YES;
}

- (void)syncHUD {
    [self syncHUD:NO];
}

- (void)syncHUD:(BOOL)force {
    if (!force) {
        if (self.topView.hidden) return;
        if (!self.playerManager.playing) return;
        if (!self.updateHUD) return;
    }
    
    // position
    double position = self.playerManager.position;
    int seconds = ceil(position);
    self.leftTimeLabel.text = [self convertTime:seconds];
    self.progressSlider.value = seconds;
}
- (NSString *)convertTime:(float)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    return [[self dateFormatter] stringFromDate:d];
}
- (void)open {
    if (self.status == WNPlayerStatusClosing) {
        self.nextOperation = WNPlayerOperationOpen;
        return;
    }
    if (self.status != WNPlayerStatusNone &&
        self.status != WNPlayerStatusClosed) {
        return;
    }
    self.status = WNPlayerStatusOpening;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    [self.playerManager open:self.url];
}

- (void)close {
    if (self.status == WNPlayerStatusOpening) {
        self.nextOperation = WNPlayerOperationClose;
        return;
    }
    self.status = WNPlayerStatusClosing;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.playerManager close];
    self.playOrPauseBtn.selected = YES;
}

- (void)play {
    if (self.status == WNPlayerStatusNone ||
        self.status == WNPlayerStatusClosed) {
        [self open];
        self.nextOperation = WNPlayerOperationPlay;
    }
    if (self.status != WNPlayerStatusOpened &&
        self.status != WNPlayerStatusPaused &&
        self.status != WNPlayerStatusEOF) {
        return;
    }
    self.status = WNPlayerStatusPlaying;
    [UIApplication sharedApplication].idleTimerDisabled = self.preventFromScreenLock;
    [self.playerManager play];
    self.playOrPauseBtn.selected = NO;
}

- (void)replay {
    self.playerManager.position = 0;
    [self play];
}

- (void)pause {
    if (self.status != WNPlayerStatusOpened &&
        self.status != WNPlayerStatusPlaying &&
        self.status != WNPlayerStatusEOF) {
        return;
    }
    self.status = WNPlayerStatusPaused;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.playerManager pause];
    self.playOrPauseBtn.selected = YES;
}

- (BOOL)doNextOperation {
    if (self.nextOperation == WNPlayerOperationNone) return NO;
    switch (self.nextOperation) {
        case WNPlayerOperationOpen:
            [self open];
            break;
        case WNPlayerOperationPlay:
            [self play];
            break;
        case WNPlayerOperationPause:
            [self pause];
            break;
        case WNPlayerOperationClose:
            [self close];
            break;
        default:
            break;
    }
    self.nextOperation = WNPlayerOperationNone;
    return YES;
}

#pragma mark - Notifications
- (void)notifyAppDidEnterBackground:(NSNotification *)notif {
    if (self.playerManager.playing) {
        [self pause];
        if (self.restorePlayAfterAppEnterForeground) restorePlay = YES;
    }
}

- (void)notifyAppWillEnterForeground:(NSNotification *)notif {
    if (restorePlay) {
        restorePlay = NO;
        [self play];
    }
}
//是否全屏
-(void)setIsFullscreen:(BOOL)isFullscreen{
    _isFullscreen = isFullscreen;
    self.fullScreenBtn.selected= isFullscreen;
    if ([WNPlayer IsiPhoneX]) {
        if (self.isFullscreen) {
            [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (self.playerManager.displayView.contentSize.width/self.playerManager.displayView.contentSize.height<1) {
                    make.edges.mas_equalTo(UIEdgeInsetsMake(20, 0, 20, 0));
                }else{
                    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 70, 0, 70));
                }
            }];
            [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.equalTo(self.contentView);
                make.height.mas_equalTo(90);
            }];
        }else{
            [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.equalTo(self.contentView);
                make.height.mas_equalTo(50);
            }];
        }
    }
}
- (void)notifyPlayerEOF:(NSNotification *)notif {
    self.status = WNPlayerStatusEOF;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wnplayerFinishedPlay:)]) {
        [self.delegate wnplayerFinishedPlay:self];
    }
    if (self.repeat) [self replay];
    else [self close];
}

- (void)notifyPlayerClosed:(NSNotification *)notif {
    self.status = WNPlayerStatusClosed;
    [self.loadingView stopAnimating];
    [self destroyTimer];
    [self doNextOperation];
}

- (void)notifyPlayerOpened:(NSNotification *)notif {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.loadingView stopAnimating];
    });
    
    self.status = WNPlayerStatusOpened;
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *title = nil;
//        if (self.playerManager.metadata != nil) {
//            NSString *t = self.playerManager.metadata[@"title"];
//            NSString *a = self.playerManager.metadata[@"artist"];
//            if (t != nil) title = t;
//            if (a != nil) title = [title stringByAppendingFormat:@" - %@", a];
//        }
//        if (title == nil) title = [self.url lastPathComponent];
//
//        self.titleLabel.text = title;
        self.titleLabel.text = self.title;
        double duration = self.playerManager.duration;
        CGSize videoSize = self.playerManager.displayView.contentSize;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(wnplayerGotVideoSize:videoSize:)]) {
            [self.delegate wnplayerGotVideoSize:self videoSize:videoSize];
        }
        int seconds = ceil(duration);
        self.rightTimeLabel.text = [self convertTime:seconds];
        self.progressSlider.enabled = seconds > 0;
        self.progressSlider.maximumValue = seconds;
        self.progressSlider.minimumValue = 0;
        self.progressSlider.value = 0;
        self.updateHUD = YES;
        [self createTimer];
        [self showHUD];
    });
    
    if (![self doNextOperation]) {
        if (self.autoplay) [self play];
    }
}

- (void)notifyPlayerBufferStateChanged:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    BOOL state = [userInfo[WNPlayerNotificationBufferStateKey] boolValue];
    if (state) {
        self.status = WNPlayerStatusBuffering;
        [self.loadingView startAnimating];
    } else {
        self.status = WNPlayerStatusPlaying;
        [self.loadingView stopAnimating];
    }
}

- (void)notifyPlayerError:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    NSError *error = userInfo[WNPlayerNotificationErrorKey];
    if ([error.domain isEqualToString:WNPlayerErrorDomainDecoder]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopAnimating];
            self.status = WNPlayerStatusNone;
            self.nextOperation = WNPlayerOperationNone;
        });
        NSLog(@"Player decoder error: %@", error);
    } else if ([error.domain isEqualToString:WNPlayerErrorDomainAudioManager]) {
        NSLog(@"Player audio error: %@", error);
        // I am not sure what will cause the audio error,
        // if it happens, please issue to me
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationError object:self userInfo:notif.userInfo];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wnplayerFailedPlay:WNPlayerStatus:)]) {
        [self.delegate wnplayerFailedPlay:self WNPlayerStatus:self.status];
    }
    
}
#pragma mark - Show/Hide HUD
- (void)showHUD {
    if (animatingHUD) return;
    [self syncHUD:YES];
    animatingHUD = YES;
    self.topView.hidden = NO;
    self.bottomView.hidden = NO;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.topView.alpha = 1.0f;
                         self.bottomView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         animatingHUD = NO;
                     }];
    [self startTimerForHideHUD];
}

- (void)hideHUD {
    if (animatingHUD) return;
    animatingHUD = YES;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.topView.alpha = 0.0f;
                         self.bottomView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         self.topView.hidden = YES;
                         self.bottomView.hidden = YES;
                         animatingHUD = NO;
                     }];
    [self stopTimerForHideHUD];
}

#pragma mark - Timer
- (void)startTimerForHideHUD {
    [self updateTimerForHideHUD];
    if (self.timerForHUD != nil) return;
    self.timerForHUD = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerForHideHUD:) userInfo:nil repeats:YES];
}

- (void)stopTimerForHideHUD {
    if (self.timerForHUD == nil) return;
    [self.timerForHUD invalidate];
    self.timerForHUD = nil;
}

- (void)updateTimerForHideHUD {
    showHUDTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)timerForHideHUD:(NSTimer *)timer {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now - showHUDTime > 5) {
        [self hideHUD];
        [self stopTimerForHideHUD];
    }
}

#pragma mark - Gesture
- (void)onTapGesutreRecognizer:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.topView.hidden) [self showHUD];
        else [self hideHUD];
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wnplayer:singleTaped:)]) {
        [self.delegate wnplayer:self singleTaped:recognizer];
    }
}

- (void)createTimer {
    if (self.timer != nil) return;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self syncHUD];
    });
    dispatch_resume(timer);
    self.timer = timer;
}
- (void)destroyTimer {
    if (self.timer == nil) return;
    dispatch_cancel(self.timer);
    self.timer = nil;
}
+(BOOL)IsiPhoneX{
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    if (@available(iOS 11.0, *)) {//x系列的系统从iOS11开始
        if(UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__FUNCTION__);
}

@end
