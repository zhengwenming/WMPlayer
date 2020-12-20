/*!
 @header WMPlayer.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
 作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/24
 
 @version 2.0.0 16/1/24 Creation(版本信息)
 
 Copyright © 2016年 郑文明. All rights reserved.
 */


#import "WMPlayer.h"
//****************************宏*********************************
#define WMPlayerSrcName(file) [@"WMPlayer.bundle" stringByAppendingPathComponent:file]
#define WMPlayerFrameworkSrcName(file) [@"Frameworks/WMPlayer.framework/WMPlayer.bundle" stringByAppendingPathComponent:file]
#define WMPlayerImage(file)      [UIImage imageNamed:WMPlayerSrcName(file)] ? :[UIImage imageNamed:WMPlayerFrameworkSrcName(file)]



//整个屏幕代表的时间
#define TotalScreenTime 90
#define LeastDistance 15

static void *PlayViewCMTimeValue = &PlayViewCMTimeValue;
static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;

@interface WMPlayer () <UIGestureRecognizerDelegate,AVRoutePickerViewDelegate,AVPictureInPictureControllerDelegate>
@property(nonatomic, strong)AVPictureInPictureController *AVPictureInPictureController;
//顶部&底部操作工具栏
@property (nonatomic,retain) UIImageView *topView,*bottomView;
//是否初始化了播放器
@property (nonatomic,assign) BOOL  isInitPlayer;
//用来判断手势是否移动过
@property (nonatomic,assign) BOOL  hasMoved;
//总时间
@property (nonatomic,assign)CGFloat totalTime;
//记录触摸开始时的视频播放的时间
@property (nonatomic,assign)CGFloat touchBeginValue;
//记录触摸开始亮度
@property (nonatomic,assign)CGFloat touchBeginLightValue;
//记录触摸开始的音量
@property (nonatomic,assign) CGFloat touchBeginVoiceValue;
//记录touch开始的点
@property (nonatomic,assign) CGPoint touchBeginPoint;
//手势控制的类型,用来判断当前手势是在控制进度?声音?亮度?
@property (nonatomic,assign) WMControlType controlType;
//格式化时间（懒加载防止多次重复初始化）
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
//监听播放起状态的监听者
@property (nonatomic,strong) id playbackTimeObserver;
//视频进度条的单击手势&播放器的单击手势
@property (nonatomic,strong) UITapGestureRecognizer *progressTap,*singleTap;
//是否正在拖曳进度条
@property (nonatomic,assign) BOOL isDragingSlider;
//BOOL值判断操作栏是否隐藏
@property (nonatomic,assign) BOOL isHiddenTopAndBottomView;
//BOOL值判断操作栏是否隐藏
@property (nonatomic,assign) BOOL hiddenStatusBar;
//是否被系统暂停
@property (nonatomic,assign) BOOL isPauseBySystem;
//播放器状态
@property (nonatomic,assign) WMPlayerState   state;
//wmPlayer内部一个UIView，所有的控件统一管理在此view中
@property (nonatomic,strong) UIView     *contentView;
//亮度调节的view
@property (nonatomic,strong) WMLightView * lightView;
//这个用来显示滑动屏幕时的时间
@property (nonatomic,strong) FastForwardView * FF_View;
//显示播放时间的UILabel+加载失败的UILabel+播放视频的title
@property (nonatomic,strong) UILabel   *leftTimeLabel,*rightTimeLabel,*titleLabel,*loadFailedLabel;
//控制全屏和播放暂停按钮
@property (nonatomic,strong) UIButton  *fullScreenBtn,*playOrPauseBtn,*lockBtn,*pipBtn,*backBtn,*rateBtn;
//进度滑块&声音滑块
@property (nonatomic,strong) UISlider   *progressSlider,*volumeSlider;
//显示缓冲进度和底部的播放进度
@property (nonatomic,strong) UIProgressView *loadingProgress,*bottomProgress;
//菊花（加载框）
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
//当前播放的item
@property (nonatomic,retain) AVPlayerItem   *currentItem;
//playerLayer,可以修改frame
@property (nonatomic,retain) AVPlayerLayer  *playerLayer;
//播放器player
@property (nonatomic,retain) AVPlayer   *player;
//播放资源路径URL
@property (nonatomic,strong) NSURL         *videoURL;
//播放资源
@property (nonatomic,strong) AVURLAsset    *urlAsset;
//跳到time处播放
@property (nonatomic,assign) double    seekTime;
//视频填充模式
@property (nonatomic, copy) NSString   *videoGravity;
@property (nonatomic,strong) UIView *airPlayView;


@end


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
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    return _dateFormatter;
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
-(void)initWMPlayer{
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryErr];
    [[AVAudioSession sharedInstance]setActive: YES error: &activationErr];
    //wmplayer内部的一个view，用来管理子视图
    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.contentView];
    self.backgroundColor = [UIColor blackColor];

    //创建fastForwardView，快进⏩和快退的view
    self.FF_View = [[FastForwardView alloc] init];
    self.FF_View.hidden = YES;
    [self.contentView addSubview:self.FF_View];
    self.lightView =[[WMLightView alloc] init];
    [self.contentView addSubview:self.lightView];
    //设置默认值
    self.enableVolumeGesture = YES;
    self.enableFastForwardGesture = YES;
    
    //小菊花
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.contentView addSubview:self.loadingView];
    [self.loadingView startAnimating];
    
    //topView
    self.topView = [[UIImageView alloc]initWithImage:WMPlayerImage(@"top_shadow")];
    self.topView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.topView];
    
    //bottomView
    self.bottomView = [[UIImageView alloc]initWithImage:WMPlayerImage(@"bottom_shadow")];
    self.bottomView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.bottomView];
    
    //playOrPauseBtn
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
    [self.playOrPauseBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn setImage:WMPlayerImage(@"player_ctrl_icon_pause") forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:WMPlayerImage(@"player_ctrl_icon_play") forState:UIControlStateSelected];
    [self.bottomView addSubview:self.playOrPauseBtn];
    self.playOrPauseBtn.selected = YES;//默认状态，即默认是不自动播放
    
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    for (UIControl *view in volumeView.subviews) {
        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
            self.volumeSlider = (UISlider *)view;
        }
    }
    self.loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.loadingProgress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.loadingProgress.trackTintColor    = [UIColor clearColor];
    [self.bottomView addSubview:self.loadingProgress];
    [self.loadingProgress setProgress:0.0 animated:NO];
    [self.bottomView sendSubviewToBack:self.loadingProgress];
    
    //slider
    self.progressSlider = [UISlider new];
    self.progressSlider.minimumValue = 0.0;
    self.progressSlider.maximumValue = 1.0;
    [self.progressSlider setThumbImage:WMPlayerImage(@"dot")  forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = self.tintColor?self.tintColor:[UIColor greenColor];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    self.progressSlider.backgroundColor = [UIColor clearColor];
    self.progressSlider.value = 0.0;//指定初始值
    //进度条的拖拽事件
    [self.progressSlider addTarget:self action:@selector(stratDragSlide:)  forControlEvents:UIControlEventValueChanged];
    //进度条的点击事件
    [self.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    //给进度条添加单击手势
    self.progressTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    self.progressTap.delegate = self;
    [self.progressSlider addGestureRecognizer:self.progressTap];
    [self.bottomView addSubview:self.progressSlider];
    
    self.bottomProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.bottomProgress.trackTintColor    = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.bottomProgress.progressTintColor = self.tintColor?self.tintColor:[UIColor greenColor];
    self.bottomProgress.alpha = 0;
    [self.contentView addSubview:self.bottomProgress];
    
    //fullScreenBtn
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setImage:WMPlayerImage(@"player_icon_fullscreen") forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:WMPlayerImage(@"player_icon_fullscreen") forState:UIControlStateSelected];
    [self.bottomView addSubview:self.fullScreenBtn];
    
    //lockBtn
    self.lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lockBtn.showsTouchWhenHighlighted = YES;
    [self.lockBtn addTarget:self action:@selector(lockAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.lockBtn setImage:WMPlayerImage(@"player_icon_unlock") forState:UIControlStateNormal];
    [self.lockBtn setImage:WMPlayerImage(@"player_icon_lock") forState:UIControlStateSelected];
    self.lockBtn.hidden = YES;
    [self.contentView addSubview:self.lockBtn];
    
    //PictureInPicture简称PIP，pipBtn为开启画中画的功能按钮
    self.pipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pipBtn.showsTouchWhenHighlighted = YES;
    [self.pipBtn addTarget:self action:@selector(pipAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.pipBtn setImage:WMPlayerImage(@"pip.jpg") forState:UIControlStateNormal];
    [self.pipBtn setImage:WMPlayerImage(@"pip.jpg") forState:UIControlStateSelected];
    self.pipBtn.hidden = NO;
    [self.contentView addSubview:self.pipBtn];
    
    //leftTimeLabel显示左边的时间进度
    self.leftTimeLabel = [UILabel new];
    self.leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    self.leftTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.leftTimeLabel];
    self.leftTimeLabel.text = [self convertTime:0.0];//设置默认值
    
    //rightTimeLabel显示右边的总时间
    self.rightTimeLabel = [UILabel new];
    self.rightTimeLabel.textAlignment = NSTextAlignmentRight;
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    self.rightTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.rightTimeLabel];
    self.rightTimeLabel.text = [self convertTime:0.0];//设置默认值

    //backBtn
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn.showsTouchWhenHighlighted = YES;
    [self.backBtn setImage:WMPlayerImage(@"player_icon_nav_back.png") forState:UIControlStateNormal];
    [self.backBtn setImage:WMPlayerImage(@"player_icon_nav_back.png") forState:UIControlStateSelected];
    [self.backBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.backBtn];
    
    //rateBtn
    self.rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rateBtn addTarget:self action:@selector(switchRate:) forControlEvents:UIControlEventTouchUpInside];
    [self.rateBtn setTitle:@"倍速" forState:UIControlStateNormal];
    [self.rateBtn setTitle:@"倍速" forState:UIControlStateSelected];
    self.rateBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    self.rateBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.bottomView addSubview:self.rateBtn];
    self.rateBtn.hidden = YES;
    self.rate = 1.0;//默认值
      if (@available(iOS 11.0, *)) {
        AVRoutePickerView  *airPlayView = [[AVRoutePickerView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
          //活跃状态颜色
          airPlayView.activeTintColor = [UIColor whiteColor];
          //设置代理
          airPlayView.delegate = self;
          [self.topView addSubview:airPlayView];
          self.airPlayView = airPlayView;
      } else {
         MPVolumeView  *airplay = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
             airplay.showsVolumeSlider = NO;
             airplay.backgroundColor = [UIColor whiteColor];
             [self.topView addSubview:airplay];
          self.airPlayView = airplay;
      }
    
    self.enableAirPlay = NO;
    
    
    //titleLabel
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.topView addSubview:self.titleLabel];
    
    //加载失败的提示
    self.loadFailedLabel = [UILabel new];
    self.loadFailedLabel.textColor = [UIColor lightGrayColor];
    self.loadFailedLabel.textAlignment = NSTextAlignmentCenter;
    self.loadFailedLabel.text = @"视频加载失败";
    self.loadFailedLabel.hidden = YES;
    [self.contentView addSubview:self.loadFailedLabel];
    [self.loadFailedLabel sizeToFit];
    
    // 单击的 Recognizer
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTap.numberOfTapsRequired = 1; // 单击
    self.singleTap.numberOfTouchesRequired = 1;
    self.singleTap.delegate = self;
    [self.contentView addGestureRecognizer:self.singleTap];

    // 双击的 Recognizer
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTouchesRequired = 1; //手指数
    doubleTap.numberOfTapsRequired = 2; // 双击
    doubleTap.delegate = self;
    // 解决点击当前view时候响应其他控件事件
    [self.singleTap setDelaysTouchesBegan:YES];
    [doubleTap setDelaysTouchesBegan:YES];
    [self.singleTap requireGestureRecognizerToFail:doubleTap];//如果双击成立，则取消单击手势（双击的时候不会走单击事件）
    [self.contentView addGestureRecognizer:doubleTap];
}
#pragma mark - Gesture Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
        if ([touch.view isKindOfClass:[UIControl class]]) {
            return NO;
        }
    return YES;
}
-(void)setRate:(CGFloat)rate{
    _rate = rate;
    self.player.rate = rate;
    self.state = WMPlayerStatePlaying;
    self.playOrPauseBtn.selected = NO;
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
-(void)switchRate:(UIButton *)rateBtn{
    CGFloat rate = 1.0f;
    if (![rateBtn.currentTitle isEqualToString:@"倍速"]) {
        rate = [rateBtn.currentTitle floatValue];
    }
    if(rate==0.5){
        rate+=0.5;
    }else if(rate==1.0){
        rate+=0.25;
    }else if(rate==1.25){
        rate+=0.25;
    }else if(rate==1.5){
        rate+=0.5;
    }else if(rate==2){
        rate=0.5;
    }
    self.rate = rate;
}
#pragma mark
#pragma mark - layoutSubviews
-(void)layoutSubviews{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    self.playerLayer.frame = self.contentView.bounds;
    CGFloat iphoneX_margin  = [WMPlayer IsiPhoneX]?60:20;
    self.FF_View.frame = CGRectMake(0, 0, 120, 70);
    self.FF_View.center = self.contentView.center;
    self.loadingView.center = self.contentView.center;
    self.topView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 70);
    self.backBtn.frame = CGRectMake(self.isFullscreen?([WMPlayer IsiPhoneX]?60:30):10, self.topView.frame.size.height/2-(self.backBtn.currentImage.size.height+4)/2, self.backBtn.currentImage.size.width+6, self.backBtn.currentImage.size.height+4);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.backBtn.frame)+5, 0, self.topView.frame.size.width-CGRectGetMaxX(self.backBtn.frame)-20-50, self.topView.frame.size.height);
    
    if (self.isFullscreen) {
        self.bottomView.frame = CGRectMake(self.topView.frame.origin.x, self.contentView.frame.size.height-105, self.topView.frame.size.width, 105);
        self.leftTimeLabel.frame = CGRectMake(iphoneX_margin, 0, 100, 20);
        self.rightTimeLabel.frame = CGRectMake(self.bottomView.frame.size.width-iphoneX_margin-self.leftTimeLabel.frame.size.width, self.leftTimeLabel.frame.origin.y, self.leftTimeLabel.frame.size.width, self.leftTimeLabel.frame.size.height);
        self.loadingProgress.frame = CGRectMake(self.leftTimeLabel.frame.origin.x, self.bottomView.frame.size.height/2-25, self.bottomView.frame.size.width-(self.leftTimeLabel.frame.origin.x)*2, 1);
        self.progressSlider.frame = CGRectMake(self.loadingProgress.frame.origin.x-3, self.loadingProgress.frame.origin.y+2, self.bottomView.frame.size.width-(self.loadingProgress.frame.origin.x)*2+6, 1);
        self.playOrPauseBtn.frame = CGRectMake(iphoneX_margin, self.progressSlider.frame.origin.y+15, self.playOrPauseBtn.currentImage.size.width, self.playOrPauseBtn.currentImage.size.height);
        self.rateBtn.frame = CGRectMake(self.bottomView.frame.size.width-iphoneX_margin-45, self.playOrPauseBtn.frame.origin.y, 45, 30);
    }else{
        self.bottomView.frame = CGRectMake(self.topView.frame.origin.x, self.contentView.frame.size.height-70, self.topView.frame.size.width, 70);
        self.playOrPauseBtn.frame = CGRectMake(10, self.bottomView.frame.size.height/2-self.playOrPauseBtn.currentImage.size.height/2, self.playOrPauseBtn.currentImage.size.width, self.playOrPauseBtn.currentImage.size.height);
        self.leftTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.playOrPauseBtn.frame)+5, self.bottomView.frame.size.height/2+8, 100, 20);
        self.rightTimeLabel.frame = CGRectMake(self.bottomView.frame.size.width-self.leftTimeLabel.frame.origin.x-self.leftTimeLabel.frame.size.width, self.bottomView.frame.size.height/2+8, self.leftTimeLabel.frame.size.width, self.leftTimeLabel.frame.size.height);
        self.loadingProgress.frame = CGRectMake(self.leftTimeLabel.frame.origin.x, self.bottomView.frame.size.height/2-2, self.bottomView.frame.size.width-(self.leftTimeLabel.frame.origin.x)*2, 1);
        self.progressSlider.frame = CGRectMake(self.leftTimeLabel.frame.origin.x-3, self.bottomView.frame.size.height/2, self.bottomView.frame.size.width-(self.leftTimeLabel.frame.origin.x)*2+6, 1);
        self.rateBtn.frame = CGRectMake(self.bottomView.frame.size.width-self.playOrPauseBtn.frame.origin.x, self.playOrPauseBtn.frame.origin.y, 45, 30);
    }
    self.lockBtn.frame = CGRectMake(iphoneX_margin, self.contentView.frame.size.height/2-self.lockBtn.frame.size.height/2, self.lockBtn.currentImage.size.width, self.lockBtn.currentImage.size.height);
    self.pipBtn.frame = CGRectMake(self.contentView.frame.size.width-40, self.contentView.frame.size.height/2-self.lockBtn.frame.size.height/2, self.lockBtn.currentImage.size.width, self.lockBtn.currentImage.size.height);
    self.fullScreenBtn.frame = CGRectMake(self.bottomView.frame.size.width-10-self.fullScreenBtn.currentImage.size.width, self.playOrPauseBtn.frame.origin.y, self.fullScreenBtn.currentImage.size.width, self.fullScreenBtn.currentImage.size.height);
    
    
    self.bottomProgress.frame = CGRectMake(iphoneX_margin, self.contentView.frame.size.height-2, self.bottomView.frame.size.width-iphoneX_margin*2, 1);
    self.loadFailedLabel.center = self.contentView.center;
}
#pragma mark
#pragma mark 进入后台
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
-(void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    self.progressSlider.minimumTrackTintColor = self.tintColor;
    self.bottomProgress.progressTintColor = self.tintColor;
}
#pragma mark
#pragma mark 进入前台
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
- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchLocation = [sender locationInView:self.progressSlider];
    CGFloat value = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (touchLocation.x/self.progressSlider.frame.size.width);
    [self.progressSlider setValue:value animated:YES];
    self.bottomProgress.progress = self.progressSlider.value;

    [self.player seekToTime:CMTimeMakeWithSeconds(self.progressSlider.value, self.currentItem.currentTime.timescale)];
    if (self.player.rate != 1.f) {
        self.playOrPauseBtn.selected = NO;
        [self.player play];
    }
}
//AirPlay界面弹出时回调
- (void)routePickerViewWillBeginPresentingRoutes:(AVRoutePickerView *)routePickerView API_AVAILABLE(ios(11.0)){
    NSLog(@"AirPlay界面弹出时回调 %@",[routePickerView valueForKey:@"airPlayActive"]);
}
//AirPlay界面结束时回调
- (void)routePickerViewDidEndPresentingRoutes:(AVRoutePickerView *)routePickerView API_AVAILABLE(ios(11.0)){
    NSLog(@"AirPlay界面结束时回调  %@",[routePickerView valueForKey:@"airPlayActive"]);
    
}
-(void)pipAction:(UIButton *)sender{
    if (_AVPictureInPictureController.pictureInPictureActive) {
        [_AVPictureInPictureController stopPictureInPicture];
    } else {
        [_AVPictureInPictureController startPictureInPicture];
    }
}
#pragma mark
#pragma mark - 点击锁定🔒屏幕旋转
-(void)lockAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.isLockScreen = sender.selected;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:clickedLockButton:)]) {
        [self.delegate wmplayer:self clickedLockButton:sender];
    }
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
//获取视频长度
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
- (void)playOrPause:(UIButton *)sender{
    if (self.state==WMPlayerStateStopped||self.state==WMPlayerStateFailed) {
        [self play];
        if(![self.rateBtn.currentTitle isEqualToString:@"倍速"]){
            self.rate = [self.rateBtn.currentTitle floatValue];
        }else{
            self.rate = 1.0f;
        }
    } else if(self.state==WMPlayerStatePlaying){
        [self pause];
    }else if(self.state ==WMPlayerStateFinished){
        if(![self.rateBtn.currentTitle isEqualToString:@"倍速"]){
            self.rate = [self.rateBtn.currentTitle floatValue];
        }else{
            self.rate = 1.0f;
        }

    }else if(self.state==WMPlayerStatePause){
        if(![self.rateBtn.currentTitle isEqualToString:@"倍速"]){
            self.rate = [self.rateBtn.currentTitle floatValue];
        }else{
            self.rate = 1.0f;
        }
    }
    if ([self.delegate respondsToSelector:@selector(wmplayer:clickedPlayOrPauseButton:)]) {
        [self.delegate wmplayer:self clickedPlayOrPauseButton:sender];
    }
}
//播放
-(void)play{
    if (self.isInitPlayer == NO) {
        [self creatWMPlayerAndReadyToPlay];
        self.playOrPauseBtn.selected = NO;
    }else{
        if (self.state==WMPlayerStateStopped||self.state ==WMPlayerStatePause) {
            self.state = WMPlayerStatePlaying;
            self.playOrPauseBtn.selected = NO;
            [self.player play];
        }else if(self.state ==WMPlayerStateFinished){
            NSLog(@"fffff");
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
-(void)setEnableAirPlay:(BOOL)enableAirPlay{
    _enableAirPlay = enableAirPlay;
    self.airPlayView.hidden= !enableAirPlay;
}
-(void)setPrefersStatusBarHidden:(BOOL)prefersStatusBarHidden{
    _prefersStatusBarHidden = prefersStatusBarHidden;
}
#pragma mark
#pragma mark - 单击手势方法
- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    if (self.isLockScreen) {
        if (self.lockBtn.alpha) {
            self.lockBtn.alpha = 0.0;
            self.prefersStatusBarHidden = self.hiddenStatusBar = YES;
        }else{
            self.lockBtn.alpha = 1.0;
            self.prefersStatusBarHidden = self.hiddenStatusBar = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenLockBtn) object:nil];
            [self performSelector:@selector(hiddenLockBtn) withObject:nil afterDelay:5.0];
        }
    }else{
        
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:singleTaped:)]) {
        [self.delegate wmplayer:self singleTaped:sender];
    }
    if (self.isLockScreen) {
        return;
    }
    [self dismissControlView];
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
                              context:PlayViewStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        // 缓冲区空了，需要等待数据
        [_currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options: NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        // 缓冲区有足够数据可以播放了
        [_currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options: NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        
        [_currentItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:PlayViewStatusObservationContext];
        
        [self.player replaceCurrentItemWithPlayerItem:_currentItem];
        // 添加视频播放结束通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    }
   
}
-(void)setupSuport {
    if([AVPictureInPictureController isPictureInPictureSupported]) {
        _AVPictureInPictureController =  [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
        _AVPictureInPictureController.delegate = self;
    } else {
        // not supported PIP start button desable here
    }
}
//设置静音
- (void)setMuted:(BOOL)muted{
    _muted = muted;
    self.player.muted = muted;
}
//设置playerLayer的填充模式
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
//重写playerModel的setter方法，处理自己的逻辑
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
//是否全屏
-(void)setIsFullscreen:(BOOL)isFullscreen{
    _isFullscreen = isFullscreen;
   self.rateBtn.hidden = self.lockBtn.hidden = !isFullscreen;
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
#pragma mark
#pragma mark--播放完成
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
-(void)showControlView{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 1.0;
        self.topView.alpha = 1.0;
        self.lockBtn.alpha = 1.0;
        self.bottomProgress.alpha = 0.f;
        self.isHiddenTopAndBottomView = NO;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:isHiddenTopAndBottomView:)]) {
            [self.delegate wmplayer:self isHiddenTopAndBottomView:self.isHiddenTopAndBottomView];
        }
    } completion:^(BOOL finish){

    }];
}

-(void)hiddenLockBtn{
     self.lockBtn.alpha = 0.0;
    self.prefersStatusBarHidden = self.hiddenStatusBar = YES;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:singleTaped:)]) {
        [self.delegate wmplayer:self singleTaped:self.singleTap];
    }
}
//隐藏操作栏view
-(void)hiddenControlView{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 0.0;
        self.topView.alpha = 0.0;
      
        if (self.isLockScreen) {
            self.bottomProgress.alpha = 1.0;
            //5s hiddenLockBtn
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenLockBtn) object:nil];
            [self performSelector:@selector(hiddenLockBtn) withObject:nil afterDelay:5.0];
        }else{
            self.lockBtn.alpha = 0.0;
            self.bottomProgress.alpha = 0.f;
        }
        self.isHiddenTopAndBottomView = YES;
        if (self.delegate&&[self.delegate respondsToSelector:@selector(wmplayer:isHiddenTopAndBottomView:)]) {
            [self.delegate wmplayer:self isHiddenTopAndBottomView:self.isHiddenTopAndBottomView];
        }
    } completion:^(BOOL finish){
        
    }];
}
-(void)addSubview:(UIView *)view{
    [super addSubview:view];
    self.parentView = view;
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
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, self.currentItem.currentTime.timescale)];
}
-(void)dismissControlView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissControlView) object:nil];
    [self performSelector:@selector(autoDismissControlView) withObject:nil afterDelay:5.0];
}
#pragma mark
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    /* AVPlayerItem "status" property value observer. */
    if (context == PlayViewStatusObservationContext){
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
                    if (self.state==WMPlayerStateStopped||self.state==WMPlayerStatePause) {
                      
                    }else{
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
                    if (self.state==WMPlayerStateStopped||self.state==WMPlayerStatePause) {
                        
                    }else{
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
                        //here
                        [self.loadingView stopAnimating];
                    }
                    NSLog(@"视频加载失败===%@",error.description);
                }
                    break;
            }
        }else if ([keyPath isEqualToString:@"duration"]) {
            if ((CGFloat)CMTimeGetSeconds(self.currentItem.duration) != self.totalTime) {
                self.totalTime = (CGFloat) CMTimeGetSeconds(self.currentItem.asset.duration);
                
                if (!isnan(self.totalTime)) {
                    self.progressSlider.maximumValue = self.totalTime;
                }else{
                    self.totalTime = MAXFLOAT;
                }
                if (self.state==WMPlayerStateStopped||self.state==WMPlayerStatePause) {
                   
                }else{
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
                NSLog(@"%s WMPlayerStateBuffering",__FUNCTION__);
                [self loadedTimeRanges];
            }
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            //here
            [self.loadingView stopAnimating];
            // 当缓冲好的时候
            if (self.currentItem.playbackLikelyToKeepUp && self.state == WMPlayerStateBuffering){
                NSLog(@"55555%s WMPlayerStatePlaying",__FUNCTION__);
                if (self.state==WMPlayerStateStopped||self.state==WMPlayerStatePause) {
                    
                }else{
                    self.state = WMPlayerStatePlaying;
                }
            }
        }
    }
}
//缓冲回调
- (void)loadedTimeRanges{
    if (self.state==WMPlayerStatePause) {
        
    }else{
        self.state = WMPlayerStateBuffering;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.state==WMPlayerStatePlaying||self.state==WMPlayerStateFinished) {
            
        }else{
            [self play];
        }
        [self.loadingView stopAnimating];
    });
}

#pragma mark
#pragma mark autoDismissControlView
-(void)autoDismissControlView{
    [self hiddenControlView];//隐藏操作栏
}
#pragma  mark - 定时器
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
    self.leftTimeLabel.text = [self convertTime:nowTime];
    self.rightTimeLabel.text = [self convertTime:self.totalTime];
    
    if (isnan(totalTime)) {
        self.rightTimeLabel.text = @"";
        NSLog(@"NaN");
    }
        if (self.isDragingSlider==YES) {//拖拽slider中，不更新slider的值
            
        }else if(self.isDragingSlider==NO){
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
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    return [[self dateFormatter] stringFromDate:d];
}
//计算缓冲进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [_currentItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
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
    self.hasMoved = NO;
    self.touchBeginValue = self.progressSlider.value;
    //位置
    self.touchBeginPoint = [touches.anyObject locationInView:self];
    //亮度
    self.touchBeginLightValue = [UIScreen mainScreen].brightness;
    //声音
    self.touchBeginVoiceValue = self.volumeSlider.value;
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
    if (fabs(tempPoint.x - self.touchBeginPoint.x) < LeastDistance && fabs(tempPoint.y - self.touchBeginPoint.y) < LeastDistance) {
        return;
    }
    self.hasMoved = YES;
    //如果还没有判断出使什么控制手势, 就进行判断
        //滑动角度的tan值
        float tan = fabs(tempPoint.y - _touchBeginPoint.y)/fabs(tempPoint.x - self.touchBeginPoint.x);
        if (tan < 1/sqrt(3)) {    //当滑动角度小于30度的时候, 进度手势
            self.controlType = WMControlTypeProgress;
        }else if(tan > sqrt(3)){  //当滑动角度大于60度的时候, 声音和亮度
            //判断是在屏幕的左半边还是右半边滑动, 左侧控制为亮度, 右侧控制音量
            if (self.touchBeginPoint.x < self.bounds.size.width/2) {
                self.controlType = WMControlTypeLight;
            }else{
                self.controlType = WMControlTypeVoice;
            }
        }else{     //如果是其他角度则不是任何控制
            self.controlType = WMControlTypeDefault;
            return;
        }
    if (self.controlType == WMControlTypeProgress) {     //如果是进度手势
        if (self.enableFastForwardGesture) {
            float value = [self moveProgressControllWithTempPoint:tempPoint];
            [self timeValueChangingWithValue:value];
        }
        }else if(self.controlType == WMControlTypeVoice){    //如果是音量手势
        if (self.isFullscreen) {//全屏的时候才开启音量的手势调节
            if (self.enableVolumeGesture) {
                //根据触摸开始时的音量和触摸开始时的点去计算出现在滑动到的音量
                float voiceValue = self.touchBeginVoiceValue - ((tempPoint.y - self.touchBeginPoint.y)/self.bounds.size.height);
                //判断控制一下, 不能超出 0~1
                if (voiceValue < 0) {
                    self.volumeSlider.value = 0;
                }else if(voiceValue > 1){
                    self.volumeSlider.value = 1;
                }else{
                    self.volumeSlider.value = voiceValue;
                }
            }
        }else{
            return;
        }
    }else if(self.controlType == WMControlTypeLight){   //如果是亮度手势
        if (self.isFullscreen) {
            //根据触摸开始时的亮度, 和触摸开始时的点来计算出现在的亮度
            float tempLightValue = self.touchBeginLightValue - ((tempPoint.y - _touchBeginPoint.y)/self.bounds.size.height);
            if (tempLightValue < 0) {
                tempLightValue = 0;
            }else if(tempLightValue > 1){
                tempLightValue = 1;
            }
            //        控制亮度的方法
            [UIScreen mainScreen].brightness = tempLightValue;
            //        实时改变现实亮度进度的view
            NSLog(@"亮度调节 = %f",tempLightValue);
            [self.contentView bringSubviewToFront:self.lightView];
        }else{
            
        }
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    //判断是否移动过,
    if (self.hasMoved) {
        if (_controlType == WMControlTypeProgress) { //进度控制就跳到响应的进度
            CGPoint tempPoint = [touches.anyObject locationInView:self];
            //            if ([self.delegate respondsToSelector:@selector(seekToTheTimeValue:)]) {
            if (self.enableFastForwardGesture) {
                float value = [self moveProgressControllWithTempPoint:tempPoint];
                //                [self.delegate seekToTheTimeValue:value];
                [self seekToTimeToPlay:value];
            }
            //            }
                        self.FF_View.hidden = YES;
        }else if (_controlType == WMControlTypeLight){//如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
        }
    }else{
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.FF_View.hidden = YES;
    [super touchesEnded:touches withEvent:event];
    //判断是否移动过,
    if (self.hasMoved) {
        if (self.controlType == WMControlTypeProgress) { //进度控制就跳到响应的进度
            //            if ([self.delegate respondsToSelector:@selector(seekToTheTimeValue:)]) {
            if (self.enableFastForwardGesture) {
                CGPoint tempPoint = [touches.anyObject locationInView:self];
                float value = [self moveProgressControllWithTempPoint:tempPoint];
                [self seekToTimeToPlay:value];
                self.FF_View.hidden = YES;
            }
        }else if (_controlType == WMControlTypeLight){//如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
        }
    }else{

    }
}
#pragma mark - 用来控制移动过程中计算手指划过的时间
-(float)moveProgressControllWithTempPoint:(CGPoint)tempPoint{
    //90代表整个屏幕代表的时间
    float tempValue = self.touchBeginValue + TotalScreenTime * ((tempPoint.x - self.touchBeginPoint.x)/([UIScreen mainScreen].bounds.size.width));
    if (tempValue > [self duration]) {
        tempValue = [self duration];
    }else if (tempValue < 0){
        tempValue = 0.0f;
    }
    return tempValue;
}

#pragma mark - 用来显示时间的view在时间发生变化时所作的操作
-(void)timeValueChangingWithValue:(float)value{
    if (value > self.touchBeginValue) {
        self.FF_View.stateImageView.image = WMPlayerImage(@"progress_icon_r");
    }else if(value < self.touchBeginValue){
        self.FF_View.stateImageView.image = WMPlayerImage(@"progress_icon_l");
    }
    self.FF_View.hidden = NO;
    self.FF_View.timeLabel.text = [NSString stringWithFormat:@"%@/%@", [self convertTime:value], [self convertTime:self.totalTime]];
    self.leftTimeLabel.text = [self convertTime:value];
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
//重置播放器
-(void )resetWMPlayer{
    self.currentItem = nil;
    self.isInitPlayer = NO;
    self.bottomProgress.progress = 0;
    _playerModel = nil;
    self.seekTime = 0;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 暂停
    [self pause];
    self.progressSlider.value = 0;
    self.bottomProgress.progress = 0;
    self.loadingProgress.progress = 0;
    self.leftTimeLabel.text = self.rightTimeLabel.text = [self convertTime:0.0];//设置默认值
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
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
//版本号
+(NSString *)version{
    return @"5.1.0";
}
@end
