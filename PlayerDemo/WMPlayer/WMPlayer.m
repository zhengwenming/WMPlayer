/*!
 @header WMPlayer.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
 作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/24
 
 @version 2.0.0 16/1/24 Creation(版本信息)
 
 Copyright © 2016年 郑文明. All rights reserved.
 */
#import <Masonry/Masonry.h>
#import "WMPlayer.h"
#import "WMLightView.h"
#define Window [UIApplication sharedApplication].keyWindow
#define iOS8 [UIDevice currentDevice].systemVersion.floatValue >= 8.0

#define WMPlayerSrcName(file) [@"WMPlayer.bundle" stringByAppendingPathComponent:file]
#define WMPlayerFrameworkSrcName(file) [@"Frameworks/WMPlayer.framework/WMPlayer.bundle" stringByAppendingPathComponent:file]
#define WMPlayerImage(file)      [UIImage imageNamed:WMPlayerSrcName(file)] ? :[UIImage imageNamed:WMPlayerFrameworkSrcName(file)]

#define kHalfWidth self.frame.size.width * 0.5
#define kHalfHeight self.frame.size.height * 0.5
//整个屏幕代表的时间
#define TotalScreenTime 90
#define LeastDistance 15

static void *PlayViewCMTimeValue = &PlayViewCMTimeValue;

static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface WMPlayer () <UIGestureRecognizerDelegate>{
    //用来判断手势是否移动过
    BOOL _hasMoved;
    //记录触摸开始时的视频播放的时间
    float _touchBeginValue;
    //记录触摸开始亮度
    float _touchBeginLightValue;
    //记录触摸开始的音量
    float _touchBeginVoiceValue;
   
    //总时间
    CGFloat totalTime;
}

/** 是否初始化了播放器 */
@property (nonatomic, assign) BOOL                   isInitPlayer;

///记录touch开始的点
@property (nonatomic,assign)CGPoint touchBeginPoint;

///手势控制的类型
///判断当前手势是在控制进度?声音?亮度?
@property (nonatomic, assign) WMControlType controlType;


@property (nonatomic, strong)NSDateFormatter *dateFormatter;
//监听播放起状态的监听者
@property (nonatomic ,strong) id playbackTimeObserver;

//视频进度条的单击事件
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) BOOL isDragingSlider;//是否点击了按钮的响应事件
/**
 *  显示播放时间的UILabel
 */
@property (nonatomic,strong) UILabel        *leftTimeLabel;
@property (nonatomic,strong) UILabel        *rightTimeLabel;
///进度滑块
@property (nonatomic,strong) UISlider       *progressSlider;
///声音滑块
@property (nonatomic,strong) UISlider       *volumeSlider;
//显示缓冲进度
@property (nonatomic,strong) UIProgressView *loadingProgress;


@end


@implementation WMPlayer{
    UITapGestureRecognizer* singleTap;
}
/**
 *  storyboard、xib的初始化方法
 */
- (void)awakeFromNib
{
    [self initWMPlayer];
    [super awakeFromNib];
}
/**
 *  initWithFrame的初始化方法
 */
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWMPlayer];
    }
    return self;
}
//快进⏩和快退的view
-(void)creatFF_View{
   self.FF_View = [[NSBundle mainBundle] loadNibNamed:@"FastForwardView" owner:self options:nil].lastObject;
    self.FF_View.hidden = YES;
    self.FF_View.layer.cornerRadius = 10.0;
    [self.contentView addSubview:self.FF_View];
    
    [self.FF_View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.width.equalTo(@(120));
        make.height.equalTo(@60);
    }];

}

/**
 *  初始化WMPlayer的控件，添加手势，添加通知，添加kvo等
 */
-(void)initWMPlayer{
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayback
     error: &setCategoryErr];
    [[AVAudioSession sharedInstance]
     setActive: YES
     error: &activationErr];
    //wmplayer内部的一个view，用来管理子视图
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.contentView];
    //autoLayout contentView
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    //创建fastForwardView
    [self creatFF_View];
    [[UIApplication sharedApplication].keyWindow addSubview:[WMLightView sharedLightView]];
    //设置默认值
    self.seekTime = 0.00;
    self.enableVolumeGesture = YES;
    self.enableFastForwardGesture = YES;
    
    //小菊花
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    UIActivityIndicatorViewStyleWhiteLarge 的尺寸是（37，37）
//    UIActivityIndicatorViewStyleWhite 的尺寸是（22，22）
    [self.contentView addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
    [self.loadingView startAnimating];

    
    //topView
    self.topView = [[UIImageView alloc]init];
    self.topView.image = WMPlayerImage(@"top_shadow");
    self.topView.userInteractionEnabled = YES;
//    self.topView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self.contentView addSubview:self.topView];
    //autoLayout topView
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView).with.offset(0);
        make.height.mas_equalTo(70);
        make.top.equalTo(self.contentView).with.offset(0);
    }];
    
    
    //bottomView
    self.bottomView = [[UIImageView alloc]init];
    self.bottomView.image = WMPlayerImage(@"bottom_shadow");
    self.bottomView.userInteractionEnabled = YES;
//    self.bottomView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self.contentView addSubview:self.bottomView];
    
    
    //autoLayout bottomView
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(0);
        make.right.equalTo(self.contentView).with.offset(0);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.contentView).with.offset(0);
    }];
    
    [self setAutoresizesSubviews:NO];
    
    //_playOrPauseBtn
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
    [self.playOrPauseBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn setImage:WMPlayerImage(@"pause") forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:WMPlayerImage(@"play") forState:UIControlStateSelected];

    [self.bottomView addSubview:self.playOrPauseBtn];
    //autoLayout _playOrPauseBtn
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(0);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(50);
        
    }];
    self.playOrPauseBtn.selected = YES;//默认状态，即默认是不自动播放
    
    
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    for (UIControl *view in volumeView.subviews) {
        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
            self.volumeSlider = (UISlider *)view;
        }
    }
    
    
    //slider
    self.progressSlider = [[UISlider alloc]init];
    self.progressSlider.minimumValue = 0.0;
    self.progressSlider.maximumValue = 1.0;

    [self.progressSlider setThumbImage:WMPlayerImage(@"dot")  forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];

    self.progressSlider.value = 0.0;//指定初始值
    //进度条的拖拽事件
    [self.progressSlider addTarget:self action:@selector(stratDragSlide:)  forControlEvents:UIControlEventValueChanged];
    //进度条的点击事件
    [self.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside];
    
    //给进度条添加单击手势
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    self.tap.delegate = self;
    [self.progressSlider addGestureRecognizer:self.tap];
    [self.bottomView addSubview:self.progressSlider];
    self.progressSlider.backgroundColor = [UIColor clearColor];
    //autoLayout slider
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.centerY.equalTo(self.bottomView.mas_centerY).offset(-1);
        make.height.mas_equalTo(30);
    }];
    

    self.loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.loadingProgress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.loadingProgress.trackTintColor    = [UIColor clearColor];
    [self.bottomView addSubview:self.loadingProgress];
    [self.loadingProgress setProgress:0.0 animated:NO];

    
    [self.loadingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.centerY.equalTo(self.bottomView.mas_centerY);
    }];
    
    
    [self.bottomView sendSubviewToBack:self.loadingProgress];
    
    
    //_fullScreenBtn
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setImage:WMPlayerImage(@"fullscreen") forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:WMPlayerImage(@"nonfullscreen") forState:UIControlStateSelected];
    [self.bottomView addSubview:self.fullScreenBtn];
    //autoLayout fullScreenBtn
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).with.offset(0);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(50);
        
    }];

    
    //leftTimeLabel显示左边的时间进度
    self.leftTimeLabel = [[UILabel alloc]init];
    self.leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    self.leftTimeLabel.backgroundColor = [UIColor clearColor];
    self.leftTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.leftTimeLabel];
    //autoLayout timeLabel
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];
    self.leftTimeLabel.text = [self convertTime:0.0];//设置默认值
    
    //rightTimeLabel显示右边的总时间
    self.rightTimeLabel = [[UILabel alloc]init];
    self.rightTimeLabel.textAlignment = NSTextAlignmentRight;
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    self.rightTimeLabel.backgroundColor = [UIColor clearColor];
    self.rightTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.rightTimeLabel];
    //autoLayout timeLabel
    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];
    self.rightTimeLabel.text = [self convertTime:0.0];//设置默认值

    
    //_closeBtn
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.showsTouchWhenHighlighted = YES;
//    _closeBtn.backgroundColor = [UIColor redColor];
    [_closeBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
       [self.topView addSubview:_closeBtn];
    //autoLayout _closeBtn
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(5);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
        make.top.equalTo(self.topView).with.offset(20);
        
    }];
    
    //titleLabel
    self.titleLabel = [[UILabel alloc]init];
//    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.topView addSubview:self.titleLabel];
    //autoLayout titleLabel
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(45);
        make.right.equalTo(self.topView).with.offset(-45);
        make.center.equalTo(self.topView);
        make.top.equalTo(self.topView).with.offset(0);

    }];
    
    // 单击的 Recognizer
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1; // 单击
    singleTap.numberOfTouchesRequired = 1;
    [self.contentView addGestureRecognizer:singleTap];
    
    // 双击的 Recognizer
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTouchesRequired = 1; //手指数
    doubleTap.numberOfTapsRequired = 2; // 双击
    // 解决点击当前view时候响应其他控件事件
    [singleTap setDelaysTouchesBegan:YES];
    [doubleTap setDelaysTouchesBegan:YES];
    [singleTap requireGestureRecognizerToFail:doubleTap];//如果双击成立，则取消单击手势（双击的时候不回走单击事件）
    [self.contentView addGestureRecognizer:doubleTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];    
}
#pragma mark
#pragma mark lazy 加载失败的label
-(UILabel *)loadFailedLabel{
    if (_loadFailedLabel==nil) {
        _loadFailedLabel = [[UILabel alloc]init];
        _loadFailedLabel.backgroundColor = [UIColor clearColor];
        _loadFailedLabel.textColor = [UIColor whiteColor];
        _loadFailedLabel.textAlignment = NSTextAlignmentCenter;
        _loadFailedLabel.text = @"视频加载失败";
        _loadFailedLabel.hidden = YES;
        [self.contentView addSubview:_loadFailedLabel];

        [_loadFailedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.width.equalTo(self.contentView);
            make.height.equalTo(@30);
        }];
    }
    return _loadFailedLabel;
}
#pragma mark
#pragma mark 进入后台
- (void)appDidEnterBackground:(NSNotification*)note
{
    if (self.playOrPauseBtn.isSelected==NO) {//如果是播放中，则继续播放
        NSArray *tracks = [self.currentItem tracks];
        for (AVPlayerItemTrack *playerItemTrack in tracks) {
            if ([playerItemTrack.assetTrack hasMediaCharacteristic:AVMediaCharacteristicVisual]) {
                playerItemTrack.enabled = YES;
            }
        }
        self.playerLayer.player = nil;
        [self.player play];
        NSLog(@"22222 %s WMPlayerStatePlaying",__FUNCTION__);

        self.state = WMPlayerStatePlaying;
    }else{
        NSLog(@"%s WMPlayerStateStopped",__FUNCTION__);
        self.state = WMPlayerStateStopped;
    }
}
#pragma mark 
#pragma mark 进入前台
- (void)appWillEnterForeground:(NSNotification*)note
{
    if (self.playOrPauseBtn.isSelected==NO) {//如果是播放中，则继续播放
        NSArray *tracks = [self.currentItem tracks];
        for (AVPlayerItemTrack *playerItemTrack in tracks) {
            if ([playerItemTrack.assetTrack hasMediaCharacteristic:AVMediaCharacteristicVisual]) {
                playerItemTrack.enabled = YES;
            }
        }
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.frame = self.contentView.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.contentView.layer insertSublayer:_playerLayer atIndex:0];
        [self.player play];
        self.state = WMPlayerStatePlaying;
        NSLog(@"3333333%s WMPlayerStatePlaying",__FUNCTION__);

    }else{
        NSLog(@"%s WMPlayerStateStopped",__FUNCTION__);

        self.state = WMPlayerStateStopped;
    }
}
#pragma mark
#pragma mark appwillResignActive
- (void)appwillResignActive:(NSNotification *)note
{
    NSLog(@"appwillResignActive");
}
- (void)appBecomeActive:(NSNotification *)note
{
    NSLog(@"appBecomeActive");
}
//视频进度条的点击事件
- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchLocation = [sender locationInView:self.progressSlider];
    CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (touchLocation.x/self.progressSlider.frame.size.width);
    [self.progressSlider setValue:value animated:YES];

    [self.player seekToTime:CMTimeMakeWithSeconds(self.progressSlider.value, self.currentItem.currentTime.timescale)];
    if (self.player.rate != 1.f) {
        if ([self currentTime] == [self duration])
            [self setCurrentTime:0.f];
        self.playOrPauseBtn.selected = NO;
        [self.player play];
    }
}


#pragma mark
#pragma mark - layoutSubviews
-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}
#pragma mark
#pragma mark - 全屏按钮点击func
-(void)fullScreenAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:clickedFullScreenButton:)]) {
        [self.delegate wmplayer:self clickedFullScreenButton:sender];
    }
}
#pragma mark
#pragma mark - 关闭按钮点击func
-(void)colseTheVideo:(UIButton *)sender{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:clickedCloseButton:)]) {
        [self.delegate wmplayer:self clickedCloseButton:sender];
    }
}
///获取视频长度
- (double)duration{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return CMTimeGetSeconds([[playerItem asset] duration]);
    }
    else{
        return 0.f;
    }
}
///获取视频当前播放的时间
- (double)currentTime{
    if (self.player) {
        return CMTimeGetSeconds([self.player currentTime]);
    }else{
        return 0.0;
    }
}

- (void)setCurrentTime:(double)time{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player seekToTime:CMTimeMakeWithSeconds(time, self.currentItem.currentTime.timescale)];

    });
}
#pragma mark
#pragma mark - PlayOrPause
- (void)PlayOrPause:(UIButton *)sender{
    if (self.state ==WMPlayerStateStopped||self.state==WMPlayerStateFailed) {
        [self play];
    } else if(self.state ==WMPlayerStatePlaying){
        [self pause];
    }else if(self.state ==WMPlayerStateFinished){
        NSLog(@"ggggg");
        self.state = WMPlayerStatePlaying;
        [self.player play];
        self.playOrPauseBtn.selected = NO;
    }
    if ([self.delegate respondsToSelector:@selector(wmplayer:clickedPlayOrPauseButton:)]) {
        [self.delegate wmplayer:self clickedPlayOrPauseButton:sender];
    }
}
///播放
-(void)play{
    if (self.isInitPlayer == NO) {
        self.isInitPlayer = YES;
        [self creatWMPlayerAndReadyToPlay];
        [self.player play];
        self.playOrPauseBtn.selected = NO;
    }else{
        if (self.state==WMPlayerStateStopped||self.state ==WMPlayerStatePause) {
            self.state = WMPlayerStatePlaying;
            [self.player play];
            self.playOrPauseBtn.selected = NO;
        }else if(self.state ==WMPlayerStateFinished){
            NSLog(@"fffff");
        }
    }
}
///暂停
-(void)pause{
    if (self.state==WMPlayerStatePlaying) {
        self.state = WMPlayerStateStopped;
    }
    [self.player pause];
    self.playOrPauseBtn.selected = YES;
}

#pragma mark
#pragma mark - 单击手势方法
- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissBottomView:) object:nil];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:singleTaped:)]) {
        [self.delegate wmplayer:self singleTaped:sender];
    }
    
    
   
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
    [UIView animateWithDuration:0.5 animations:^{
        if (self.bottomView.alpha == 0.0) {
            [self showControlView];
        }else{
            [self hiddenControlView];
        }
    } completion:^(BOOL finish){
        
    }];
}
#pragma mark
#pragma mark - 双击手势方法
- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:doubleTaped:)]) {
        [self.delegate wmplayer:self doubleTaped:doubleTap];
    }
    [self PlayOrPause:self.playOrPauseBtn];

    [self showControlView];
}
/**
 *  重写playerItem的setter方法，处理自己的逻辑
 */
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

        _currentItem = nil;
    }
    _currentItem = playerItem;
    if (_currentItem) {
        [_currentItem addObserver:self
                           forKeyPath:@"status"
                              options:NSKeyValueObservingOptionNew
                              context:PlayViewStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        // 缓冲区空了，需要等待数据
        [_currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options: NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        // 缓冲区有足够数据可以播放了
        [_currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options: NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];

        
        [self.player replaceCurrentItemWithPlayerItem:_currentItem];
        // 添加视频播放结束通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    }
}
/**
 *  重写placeholderImage的setter方法，处理自己的逻辑
 */
- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    _placeholderImage = placeholderImage;
    if (placeholderImage) {
        self.contentView.layer.contents = (id) self.placeholderImage.CGImage;
    } else {
        UIImage *image = WMPlayerImage(@"");
        self.contentView.layer.contents = (id) image.CGImage;
    }
}

-(void)creatWMPlayerAndReadyToPlay{
    //设置player的参数
    self.currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.URLString]];
    
    self.player = [AVPlayer playerWithPlayerItem:_currentItem];
    if ([self.player respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
        self.player.automaticallyWaitsToMinimizeStalling = YES;
    }
    self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
    //AVPlayerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.contentView.layer.bounds;
    //WMPlayer视频的默认填充模式，AVLayerVideoGravityResizeAspect
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.contentView.layer insertSublayer:_playerLayer atIndex:0];
    self.state = WMPlayerStateBuffering;
}
/**
 *  重写URLString的setter方法，处理自己的逻辑，
 */
- (void)setURLString:(NSString *)URLString{
    if (_URLString==URLString) {
        return;
    }
    _URLString = URLString;

    if (self.isInitPlayer) {
        self.state = WMPlayerStateBuffering;
    }else{
        self.state = WMPlayerStateStopped;
        //here
        [self.loadingView stopAnimating];
    }
    
    if (!self.placeholderImage) {//开发者可以在此处设置背景图片
        UIImage *image = WMPlayerImage(@"");
        self.contentView.layer.contents = (id) image.CGImage;
    }
    //左上角的返回按钮的样式
    if (self.closeBtnStyle==CloseBtnStylePop) {
        [_closeBtn setImage:WMPlayerImage(@"play_back.png") forState:UIControlStateNormal];
        [_closeBtn setImage:WMPlayerImage(@"play_back.png") forState:UIControlStateSelected];
        
    }else{
        [_closeBtn setImage:WMPlayerImage(@"close") forState:UIControlStateNormal];
        [_closeBtn setImage:WMPlayerImage(@"close") forState:UIControlStateSelected];
    }
}

-(void)setCloseBtnStyle:(CloseBtnStyle)closeBtnStyle{
    _closeBtnStyle = closeBtnStyle;
    if (closeBtnStyle==CloseBtnStylePop) {
        [_closeBtn setImage:WMPlayerImage(@"play_back.png") forState:UIControlStateNormal];
        [_closeBtn setImage:WMPlayerImage(@"play_back.png") forState:UIControlStateSelected];
        
    }else{
        [_closeBtn setImage:WMPlayerImage(@"close") forState:UIControlStateNormal];
        [_closeBtn setImage:WMPlayerImage(@"close") forState:UIControlStateSelected];
    }
}
/**
 *  设置播放的状态
 *  @param state WMPlayerState
 */
- (void)setState:(WMPlayerState)state
{
    _state = state;
    // 控制菊花显示、隐藏
    if (state == WMPlayerStateBuffering) {
        [self.loadingView startAnimating];
    }else if(state == WMPlayerStatePlaying){
        //here
        [self.loadingView stopAnimating];//
    }else if(state == WMPlayerStatePause){
        //here
        [self.loadingView stopAnimating];//
    }
    else{
        //here
        [self.loadingView stopAnimating];//
    }
}

/**
 *  通过颜色来生成一个纯色图片
 */
- (UIImage *)buttonImageFromColor:(UIColor *)color{
    
    CGRect rect = self.bounds;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); return img;
}

#pragma mark
#pragma mark--播放完成
- (void)moviePlayDidEnd:(NSNotification *)notification {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayerFinishedPlay:)]) {
        [self.delegate wmplayerFinishedPlay:self];
    }
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self showControlView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.state = WMPlayerStateFinished;
                self.playOrPauseBtn.selected = YES;
            });
        }
    }];
}
///显示操作栏view
-(void)showControlView{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 1.0;
        self.topView.alpha = 1.0;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:isHiddenTopAndBottomView:)]) {
            [self.delegate wmplayer:self isHiddenTopAndBottomView:NO];
        }
    } completion:^(BOOL finish){

    }];
}
///隐藏操作栏view
-(void)hiddenControlView{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 0.0;
        self.topView.alpha = 0.0;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:isHiddenTopAndBottomView:)]) {
            [self.delegate wmplayer:self isHiddenTopAndBottomView:YES];
        }
    } completion:^(BOOL finish){
        
    }];
}
#pragma mark
#pragma mark--开始拖曳sidle
- (void)stratDragSlide:(UISlider *)slider{
    self.isDragingSlider = YES;
}
#pragma mark
#pragma mark - 播放进度
- (void)updateProgress:(UISlider *)slider{
    self.isDragingSlider = NO;
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, _currentItem.currentTime.timescale)];
}
#pragma mark
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    /* AVPlayerItem "status" property value observer. */

    if (context == PlayViewStatusObservationContext)
    {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status)
            {
                    /* Indicates that the status of the player is not yet known because
                     it has not tried to load new media resources for playback */
                case AVPlayerStatusUnknown:
                {
                    [self.loadingProgress setProgress:0.0 animated:NO];
                    NSLog(@"%s WMPlayerStateBuffering",__FUNCTION__);

                    self.state = WMPlayerStateBuffering;
                    [self.loadingView startAnimating];
                }
                    break;
                    
                case AVPlayerStatusReadyToPlay:
                {
                    self.state = WMPlayerStatePlaying;

                      /* Once the AVPlayerItem becomes ready to play, i.e.
                     [playerItem status] == AVPlayerItemStatusReadyToPlay,
                     its duration can be fetched from the item. */
//                    if (CMTimeGetSeconds(_currentItem.duration)) {
//                        
//                        totalTime = CMTimeGetSeconds(_currentItem.duration);
//                        if (!isnan(totalTime)) {
//                            self.progressSlider.maximumValue = totalTime;
//                            NSLog(@"totalTime = %f",totalTime);
//
//                        }
//                    }
                    //监听播放状态
                    [self initTimer];
                    
                    
                    //5s dismiss bottomView
                    if (self.autoDismissTimer==nil) {
                        self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
                        [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
                    }
                    
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayerReadyToPlay:WMPlayerStatus:)]) {
                        [self.delegate wmplayerReadyToPlay:self WMPlayerStatus:WMPlayerStatePlaying];
                    }
                    //here

                    [self.loadingView stopAnimating];
                    // 跳到xx秒播放视频
                    if (self.seekTime) {
                        [self seekToTimeToPlay:self.seekTime];
                    }
                    
                }
                    break;
                    
                case AVPlayerStatusFailed:
                {
                    self.state = WMPlayerStateFailed;
                    NSLog(@"%s WMPlayerStateFailed",__FUNCTION__);

                    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayerFailedPlay:WMPlayerStatus:)]) {
                        [self.delegate wmplayerFailedPlay:self WMPlayerStatus:WMPlayerStateFailed];
                    }
                    NSError *error = [self.player.currentItem error];
                    if (error) {
                        self.loadFailedLabel.hidden = NO;
                        [self bringSubviewToFront:self.loadFailedLabel];
                        //here
                        [self.loadingView stopAnimating];
                    }
                    NSLog(@"视频加载失败===%@",error.description);
                }
                    break;
            }

        }else if ([keyPath isEqualToString:@"duration"]) {
            if ((CGFloat)CMTimeGetSeconds(_currentItem.duration) != totalTime) {
                totalTime = (CGFloat)CMTimeGetSeconds(_currentItem.duration);
                self.progressSlider.maximumValue = totalTime;
                self.state = WMPlayerStatePlaying;
            }
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
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
                self.state = WMPlayerStateBuffering;
                NSLog(@"%s WMPlayerStateBuffering",__FUNCTION__);

                [self loadedTimeRanges];
            }
            
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            //here
            [self.loadingView stopAnimating];
            // 当缓冲好的时候
            if (self.currentItem.playbackLikelyToKeepUp && self.state == WMPlayerStateBuffering){
                NSLog(@"55555%s WMPlayerStatePlaying",__FUNCTION__);

                self.state = WMPlayerStatePlaying;
            }
            
        }
    }

}
/**
 *  缓冲回调
 */
- (void)loadedTimeRanges
{
    self.state = WMPlayerStateBuffering;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self play];
        //here
        [self.loadingView stopAnimating];
    });
}

#pragma mark
#pragma mark autoDismissBottomView
-(void)autoDismissBottomView:(NSTimer *)timer{
    if (self.state==WMPlayerStatePlaying) {
        if (self.bottomView.alpha==1.0) {
            [self hiddenControlView];//隐藏操作栏
        }
    }
}
#pragma  mark - 定时器
-(void)initTimer{
    double interval = .1f;
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    long long nowTime = _currentItem.currentTime.value/_currentItem.currentTime.timescale;
        CGFloat width = CGRectGetWidth([self.progressSlider bounds]);
        interval = 0.5f * nowTime / width;
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver =  [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC)  queue:dispatch_get_main_queue() /* If you pass NULL, the main queue is used. */
        usingBlock:^(CMTime time){
        [weakSelf syncScrubber];
    }];
    
}
- (void)syncScrubber{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)){
        self.progressSlider.minimumValue = 0.0;
        return;
    }
        float minValue = [self.progressSlider minimumValue];
        float maxValue = [self.progressSlider maximumValue];
        long long nowTime = _currentItem.currentTime.value/_currentItem.currentTime.timescale;
        self.leftTimeLabel.text = [self convertTime:nowTime];
        self.rightTimeLabel.text = [self convertTime:totalTime];
        if (self.isDragingSlider==YES) {//拖拽slider中，不更新slider的值
            
        }else if(self.isDragingSlider==NO){
            [self.progressSlider setValue:(maxValue - minValue) * nowTime / totalTime + minValue];
        }
}
/**
 *  跳到time处播放
 *  @param seekTime这个时刻，这个时间点
 */
- (void)seekToTimeToPlay:(double)time{
    if (self.player&&self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (time>=totalTime) {
            time = 0.0;
        }
        if (time<0) {
            time=0.0;
        }
//        int32_t timeScale = self.player.currentItem.asset.duration.timescale;
        //currentItem.asset.duration.timescale计算的时候严重堵塞主线程，慎用
        /* A timescale of 1 means you can only specify whole seconds to seek to. The timescale is the number of parts per second. Use 600 for video, as Apple recommends, since it is a product of the common video frame rates like 50, 60, 25 and 24 frames per second*/

        [self.player seekToTime:CMTimeMakeWithSeconds(time, _currentItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            
        }];
        
        
    }
}
- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = _currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
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
/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [_currentItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    return _dateFormatter;
}
#pragma mark 
#pragma mark - touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //这个是用来判断, 如果有多个手指点击则不做出响应
    UITouch * touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        return;
    }
//    这个是用来判断, 手指点击的是不是本视图, 如果不是则不做出响应
    if (![[(UITouch *)touches.anyObject view] isEqual:self.contentView] &&  ![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesBegan:touches withEvent:event];

    //触摸开始, 初始化一些值
    _hasMoved = NO;
    _touchBeginValue = self.progressSlider.value;
    //位置
    _touchBeginPoint = [touches.anyObject locationInView:self];
    //亮度
    _touchBeginLightValue = [UIScreen mainScreen].brightness;
    //声音
    _touchBeginVoiceValue = _volumeSlider.value;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch * touch = (UITouch *)touches.anyObject;
    if (touches.count > 1 || [touch tapCount] > 1  || event.allTouches.count > 1) {
        return;
    }
    if (![[(UITouch *)touches.anyObject view] isEqual:self.contentView] && ![[(UITouch *)touches.anyObject view] isEqual:self]) {
        return;
    }
    [super touchesMoved:touches withEvent:event];
    
    
    //如果移动的距离过于小, 就判断为没有移动
    CGPoint tempPoint = [touches.anyObject locationInView:self];
    if (fabs(tempPoint.x - _touchBeginPoint.x) < LeastDistance && fabs(tempPoint.y - _touchBeginPoint.y) < LeastDistance) {
        return;
    }
    _hasMoved = YES;
    //如果还没有判断出使什么控制手势, 就进行判断
        //滑动角度的tan值
        float tan = fabs(tempPoint.y - _touchBeginPoint.y)/fabs(tempPoint.x - _touchBeginPoint.x);
        if (tan < 1/sqrt(3)) {    //当滑动角度小于30度的时候, 进度手势
            _controlType = progressControl;
//            _controlJudge = YES;
        }else if(tan > sqrt(3)){  //当滑动角度大于60度的时候, 声音和亮度
            //判断是在屏幕的左半边还是右半边滑动, 左侧控制为亮度, 右侧控制音量
            if (_touchBeginPoint.x < self.bounds.size.width/2) {
                _controlType = lightControl;
            }else{
                _controlType = voiceControl;
            }
//            _controlJudge = YES;
        }else{     //如果是其他角度则不是任何控制
            _controlType = noneControl;
            return;
        }
    
    
    if (_controlType == progressControl) {     //如果是进度手势
        if (self.enableFastForwardGesture) {
            float value = [self moveProgressControllWithTempPoint:tempPoint];
            [self timeValueChangingWithValue:value];

        }
        }else if(_controlType == voiceControl){    //如果是音量手势
        if (self.isFullscreen) {//全屏的时候才开启音量的手势调节
            
            if (self.enableVolumeGesture) {
                //根据触摸开始时的音量和触摸开始时的点去计算出现在滑动到的音量
                float voiceValue = _touchBeginVoiceValue - ((tempPoint.y - _touchBeginPoint.y)/self.bounds.size.height);
                //判断控制一下, 不能超出 0~1
                if (voiceValue < 0) {
                    _volumeSlider.value = 0;
                }else if(voiceValue > 1){
                    _volumeSlider.value = 1;
                }else{
                    _volumeSlider.value = voiceValue;
                }
            }
        }else{
            return;
        }
    }else if(_controlType == lightControl){   //如果是亮度手势
        //显示音量控制的view
        [self hideTheLightViewWithHidden:NO];
        if (self.isFullscreen) {
            //根据触摸开始时的亮度, 和触摸开始时的点来计算出现在的亮度
            float tempLightValue = _touchBeginLightValue - ((tempPoint.y - _touchBeginPoint.y)/self.bounds.size.height);
            if (tempLightValue < 0) {
                tempLightValue = 0;
            }else if(tempLightValue > 1){
                tempLightValue = 1;
            }
            //        控制亮度的方法
            [UIScreen mainScreen].brightness = tempLightValue;
            //        实时改变现实亮度进度的view
            NSLog(@"亮度调节 = %f",tempLightValue);
        }else{
            
        }
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
//    if (iOS8) {
//        self.effectView.alpha = 0.0;
//    }
    //判断是否移动过,
    if (_hasMoved) {
        if (_controlType == progressControl) { //进度控制就跳到响应的进度
            CGPoint tempPoint = [touches.anyObject locationInView:self];
            //            if ([self.delegate respondsToSelector:@selector(seekToTheTimeValue:)]) {
            if (self.enableFastForwardGesture) {
                float value = [self moveProgressControllWithTempPoint:tempPoint];
                //                [self.delegate seekToTheTimeValue:value];
                [self seekToTimeToPlay:value];
            }
            //            }
                        self.FF_View.hidden = YES;
        }else if (_controlType == lightControl){//如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
            [self hideTheLightViewWithHidden:YES];
        }
    }else{
        //        if (self.topView.hidden) {
        //            [self controlViewOutHidden];
        //        }else{
        //            [self controlViewHidden];
        //        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    self.FF_View.hidden = YES;
    [self hideTheLightViewWithHidden:YES];
    [super touchesEnded:touches withEvent:event];
    //判断是否移动过,
    if (_hasMoved) {
        if (_controlType == progressControl) { //进度控制就跳到响应的进度
            //            if ([self.delegate respondsToSelector:@selector(seekToTheTimeValue:)]) {
            if (self.enableFastForwardGesture) {
                CGPoint tempPoint = [touches.anyObject locationInView:self];
                float value = [self moveProgressControllWithTempPoint:tempPoint];
                //                [self.delegate seekToTheTimeValue:value];
                [self seekToTimeToPlay:value];
                //            }
                self.FF_View.hidden = YES;
            }
          
        }else if (_controlType == lightControl){//如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
            [self hideTheLightViewWithHidden:YES];
        }
    }else{
        //        if (self.topView.hidden) {
        //            [self controlViewOutHidden];
        //        }else{
        //            [self controlViewHidden];
        //        }
    }


}
#pragma mark - 用来控制移动过程中计算手指划过的时间
-(float)moveProgressControllWithTempPoint:(CGPoint)tempPoint{
    //90代表整个屏幕代表的时间
    float tempValue = _touchBeginValue + TotalScreenTime * ((tempPoint.x - _touchBeginPoint.x)/([UIScreen mainScreen].bounds.size.width));
    if (tempValue > [self duration]) {
        tempValue = [self duration];
    }else if (tempValue < 0){
        tempValue = 0.0f;
    }
    return tempValue;
}

#pragma mark - 用来显示时间的view在时间发生变化时所作的操作
-(void)timeValueChangingWithValue:(float)value{
    if (value > _touchBeginValue) {
        self.FF_View.sheetStateImageView.image = WMPlayerImage(@"progress_icon_r");
    }else if(value < _touchBeginValue){
        self.FF_View.sheetStateImageView.image =WMPlayerImage(@"progress_icon_l");
    }
    self.FF_View.hidden = NO;
    self.FF_View.sheetTimeLabel.text = [NSString stringWithFormat:@"%@/%@", [self convertTime:value], [self convertTime:totalTime]];
    self.leftTimeLabel.text = [self convertTime:value];
    [self showControlView];
    [self.progressSlider setValue:value animated:YES];
}

NSString * calculateTimeWithTimeFormatter(long long timeSecond){
    NSString * theLastTime = nil;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%.2lld", timeSecond];
    }else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld", timeSecond/60, timeSecond%60];
    }else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", timeSecond/3600, timeSecond%3600/60, timeSecond%60];
    }
    return theLastTime;
}


#pragma mark -
#pragma mark - 用来控制显示亮度的view, 以及毛玻璃效果的view
-(void)hideTheLightViewWithHidden:(BOOL)hidden{
    if (self.isFullscreen) {//全屏才出亮度调节的view
        if (hidden) {
            [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                if (iOS8) {
                    self.effectView.alpha = 0.0;
                }
            } completion:nil];
            
        }else{
            if (iOS8) {
                self.effectView.alpha = 1.0;
            }
        }
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            self.effectView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.height)/2-155/2, ([UIScreen mainScreen].bounds.size.width)/2-155/2, 155, 155);
        }
    }else{
        return;
    }
    
}

//重置播放器
-(void )resetWMPlayer{
    
  
    
    self.currentItem = nil;
    self.seekTime = 0;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 关闭定时器
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    // 暂停
    [self.player pause];
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
    // 把player置为nil
    self.player = nil;
}
-(void)dealloc{
    for (UIView *aLightView in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([aLightView isKindOfClass:[WMLightView class]]) {
            [aLightView removeFromSuperview];
        }
    }
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

    _currentItem = nil;

    [self.effectView removeFromSuperview];
    self.effectView = nil;
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.playOrPauseBtn = nil;
    self.playerLayer = nil;
    self.autoDismissTimer = nil;
}

//获取当前的旋转状态
+(CGAffineTransform)getCurrentDeviceOrientation{
    //状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //根据要进行旋转的方向来计算旋转的角度
    if (orientation ==UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation ==UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if(orientation ==UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}
///版本号
- (NSString *)version{
    return @"4.2.0";
}
@end
