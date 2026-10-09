//
//  WMPlayer+Controls.m
//  WMPlayer
//
//  重构拆分：由 WMPlayer.m 中拆出的“Controls”相关实现。
//

#import "WMPlayer+Private.h"

@implementation WMPlayer (Controls)

-(void)initWMPlayer{
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryErr];
    [[AVAudioSession sharedInstance]setActive: YES error: &activationErr];
    //wmplayer内部的一个view，用来管理子视图
    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor blackColor];
    //裁剪溢出内容，保证放大的视频画面不超出播放器边界
    self.contentView.layer.masksToBounds = YES;
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
    self.enablePinchZoom = YES;
    self.minScale = 0.5;
    self.maxScale = 3.0;
    self.currentScale = 1.0;
    self.lastScale = 1.0;
    
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
    self.pipBtn.hidden = YES;
    [self.contentView addSubview:self.pipBtn];
    
    //缩放模式下显示的“恢复”按钮（捏合放大/缩小后隐藏其它控件，仅保留此按钮）
    self.resetPinchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resetPinchBtn addTarget:self action:@selector(resetPinchAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.resetPinchBtn setTitle:@"恢复" forState:UIControlStateNormal];
    [self.resetPinchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resetPinchBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    self.resetPinchBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.resetPinchBtn.layer.cornerRadius = 18.0;
    self.resetPinchBtn.layer.masksToBounds = YES;
    self.resetPinchBtn.hidden = YES;
    [self.contentView addSubview:self.resetPinchBtn];
    
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
    
    // 双指捏合缩放手势
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    self.pinchGesture.delegate = self;
    [self.contentView addGestureRecognizer:self.pinchGesture];
}
#pragma mark - Gesture Delegate

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
    self.resetPinchBtn.frame = CGRectMake(0, 0, 72, 36);
    self.resetPinchBtn.center = self.contentView.center;
    self.topView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 70);
    self.backBtn.frame = CGRectMake(self.isFullscreen?([WMPlayer IsiPhoneX]?60:30):10, self.topView.frame.size.height/2-(self.backBtn.currentImage.size.height+4)/2, self.backBtn.currentImage.size.width+6, self.backBtn.currentImage.size.height+4);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.backBtn.frame)+5, 0, self.topView.frame.size.width-CGRectGetMaxX(self.backBtn.frame)-20-50, self.topView.frame.size.height);
    if (self.isFullscreen) {
        self.bottomView.frame = CGRectMake(self.topView.frame.origin.x, self.contentView.frame.size.height-105, self.topView.frame.size.width, 105);
        self.progressSlider.frame = CGRectMake(iphoneX_margin, 0, self.bottomView.frame.size.width-iphoneX_margin*2, 30);
        self.loadingProgress.frame = CGRectMake(iphoneX_margin+2, CGRectGetMaxY(self.progressSlider.frame)-30/2-2, self.bottomView.frame.size.width-iphoneX_margin*2-2, 1);
        self.playOrPauseBtn.frame = CGRectMake(iphoneX_margin, CGRectGetMaxY(self.progressSlider.frame)+15, self.playOrPauseBtn.currentImage.size.width, self.playOrPauseBtn.currentImage.size.height);
        self.leftTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.playOrPauseBtn.frame)+10, CGRectGetMaxY(self.playOrPauseBtn.frame)-self.playOrPauseBtn.frame.size.height/2-20/2, 100, 20);
        self.rightTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.leftTimeLabel.frame)+1, self.leftTimeLabel.frame.origin.y, self.leftTimeLabel.frame.size.width, self.leftTimeLabel.frame.size.height);
        self.rateBtn.frame = CGRectMake(self.bottomView.frame.size.width-iphoneX_margin-45, self.playOrPauseBtn.frame.origin.y, 45, 30);
    }else{
        self.bottomView.frame = CGRectMake(self.topView.frame.origin.x, self.contentView.frame.size.height-70, self.topView.frame.size.width, 70);
        self.playOrPauseBtn.frame = CGRectMake(10, self.bottomView.frame.size.height/2-self.playOrPauseBtn.currentImage.size.height/2, self.playOrPauseBtn.currentImage.size.width, self.playOrPauseBtn.currentImage.size.height);
        self.leftTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.playOrPauseBtn.frame)+5, self.bottomView.frame.size.height/2+8, 100, 20);
        self.rightTimeLabel.frame = CGRectMake(self.bottomView.frame.size.width-self.leftTimeLabel.frame.origin.x-self.leftTimeLabel.frame.size.width, self.bottomView.frame.size.height/2+8, self.leftTimeLabel.frame.size.width, self.leftTimeLabel.frame.size.height);
        self.loadingProgress.frame = CGRectMake(self.leftTimeLabel.frame.origin.x, self.bottomView.frame.size.height/2-2, self.bottomView.frame.size.width-(self.leftTimeLabel.frame.origin.x)*2, 1);
        self.progressSlider.frame = CGRectMake(self.leftTimeLabel.frame.origin.x-3, self.bottomView.frame.size.height/2-30/2, self.bottomView.frame.size.width-(self.leftTimeLabel.frame.origin.x)*2+6, 30);
        self.rateBtn.frame = CGRectMake(self.bottomView.frame.size.width-self.playOrPauseBtn.frame.origin.x, self.playOrPauseBtn.frame.origin.y, 45, 30);
    }
    //lock/pip 图标按钮统一使用 lock 图片的逻辑尺寸（pip.jpg 为 208x168 非规范图，直接取 currentImage.size 会被放大）
    CGFloat iconSize = self.lockBtn.currentImage.size.width;
    self.lockBtn.frame = CGRectMake(iphoneX_margin, self.contentView.frame.size.height/2-iconSize/2, iconSize, iconSize);
    //画中画按钮贴边靠右：右边距用较小固定值，离屏幕更近
    self.pipBtn.frame = CGRectMake(self.contentView.frame.size.width-20-iconSize, self.contentView.frame.size.height/2-iconSize/2, iconSize, iconSize);
    self.fullScreenBtn.frame = CGRectMake(self.bottomView.frame.size.width-10-self.fullScreenBtn.currentImage.size.width, self.playOrPauseBtn.frame.origin.y, self.fullScreenBtn.currentImage.size.width, self.fullScreenBtn.currentImage.size.height);
    
    
    self.bottomProgress.frame = CGRectMake(iphoneX_margin, self.contentView.frame.size.height-2, self.bottomView.frame.size.width-iphoneX_margin*2, 1);
    self.loadFailedLabel.center = self.contentView.center;
}
- (void)routePickerViewWillBeginPresentingRoutes:(AVRoutePickerView *)routePickerView API_AVAILABLE(ios(11.0)){
}
//AirPlay界面结束时回调（预留）

- (void)routePickerViewDidEndPresentingRoutes:(AVRoutePickerView *)routePickerView API_AVAILABLE(ios(11.0)){
}

-(void)pipAction:(UIButton *)sender{
    if (self.AVPictureInPictureController.pictureInPictureActive) {
        [self.AVPictureInPictureController stopPictureInPicture];
    } else {
        [self.AVPictureInPictureController startPictureInPicture];
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

- (void)resetPinchZoom{
    self.currentScale = 1.0;
    self.lastScale = 1.0;
    self.playerLayer.transform = CATransform3DIdentity;
    self.resetPinchBtn.hidden = YES;
}
//进入缩放模式：隐藏所有操作控件，只显示“恢复”按钮

- (void)enterZoomMode{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissControlView) object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.alpha = 0.0;
        self.bottomView.alpha = 0.0;
        self.lockBtn.alpha = 0.0;
        self.pipBtn.alpha = 0.0;
        self.bottomProgress.alpha = 0.0;
    }];
    self.resetPinchBtn.hidden = NO;
    self.isHiddenTopAndBottomView = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(wmplayer:isHiddenTopAndBottomView:)]) {
        [self.delegate wmplayer:self isHiddenTopAndBottomView:self.isHiddenTopAndBottomView];
    }
}
//退出缩放模式：隐藏“恢复”按钮，恢复操作栏

- (void)exitZoomMode{
    self.resetPinchBtn.hidden = YES;
    self.pipBtn.alpha = 1.0;
    [self showControlView];
}
//点击“恢复”按钮：缩放平滑回到 1.0 并恢复操作栏

- (void)resetPinchAction:(UIButton *)sender{
    self.currentScale = 1.0;
    self.lastScale = 1.0;
    self.resetPinchBtn.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.playerLayer.transform = CATransform3DIdentity;
    }];
    [self exitZoomMode];
}

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
#pragma mark
#pragma mark--开始拖曳sidle

-(void)dismissControlView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissControlView) object:nil];
    [self performSelector:@selector(autoDismissControlView) withObject:nil afterDelay:5.0];
}
#pragma mark
#pragma mark KVO

-(void)autoDismissControlView{
    [self hiddenControlView];//隐藏操作栏
}
#pragma  mark - 定时器

@end
