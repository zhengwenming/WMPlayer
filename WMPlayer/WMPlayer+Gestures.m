//
//  WMPlayer+Gestures.m
//  WMPlayer
//
//  重构拆分：由 WMPlayer.m 中拆出的“Gestures”相关实现。
//

#import "WMPlayer+Private.h"

@implementation WMPlayer (Gestures)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
        if ([touch.view isKindOfClass:[UIControl class]]) {
            return NO;
        }
    return YES;
}

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
//AirPlay界面弹出时回调（预留）

- (void)handleSingleTap:(UITapGestureRecognizer *)sender{
    //缩放模式下单击不切换操作栏（此时只保留“恢复”按钮）
    if (fabs(self.currentScale - 1.0) > 0.01) {
        return;
    }
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
#pragma mark
#pragma mark - 双指捏合缩放视频画面

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch{
    //仅在开启且全屏时生效（小屏嵌在列表里，捏合易与列表滚动冲突）
    if (!self.enablePinchZoom || !self.isFullscreen) {
        return;
    }
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan:{
            //记录捏合开始时的累计缩放，避免多次捏合间出现跳变
            self.lastScale = self.currentScale;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            CGFloat newScale = self.lastScale * pinch.scale;
            //钳制在最小/最大倍数之间（防御外部把 min/max 设反的情况）
            CGFloat minScale = MIN(self.minScale, self.maxScale);
            CGFloat maxScale = MAX(self.minScale, self.maxScale);
            newScale = MIN(MAX(newScale, minScale), maxScale);
            self.currentScale = newScale;
            self.playerLayer.transform = CATransform3DMakeScale(newScale, newScale, 1.0);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:{
            self.lastScale = self.currentScale;
            //捏合结束后，若缩放倍数偏离 1.0 则进入缩放模式（隐藏操作栏、只留“恢复”按钮），否则恢复操作栏
            if (fabs(self.currentScale - 1.0) > 0.01) {
                [self enterZoomMode];
            } else {
                [self exitZoomMode];
            }
        }
            break;
        default:
            break;
    }
}
//重置缩放状态（切换全屏/小屏、重置播放器时调用）

- (void)stratDragSlide:(UISlider *)slider{
    self.dragingSliderStatus = 1;
}
#pragma mark
#pragma mark - 播放进度

- (void)updateProgress:(UISlider *)slider{
    //放手的那一刻，立即更新播放器的实际进度为slider的进度
    [self.player seekToTime:CMTimeMakeWithSeconds(slider.value, self.currentItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        self.dragingSliderStatus = 2;
    }];
}

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
    if (fabs(tempPoint.x - self.touchBeginPoint.x) < WMPlayerLeastDistance && fabs(tempPoint.y - self.touchBeginPoint.y) < WMPlayerLeastDistance) {
        return;
    }
    self.hasMoved = YES;
    //如果还没有判断出使什么控制手势, 就进行判断
        //滑动角度的tan值
        float tan = fabs(tempPoint.y - self.touchBeginPoint.y)/fabs(tempPoint.x - self.touchBeginPoint.x);
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
            float tempLightValue = self.touchBeginLightValue - ((tempPoint.y - self.touchBeginPoint.y)/self.bounds.size.height);
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
        if (self.controlType == WMControlTypeProgress) { //进度控制就跳到响应的进度
            CGPoint tempPoint = [touches.anyObject locationInView:self];
            //            if ([self.delegate respondsToSelector:@selector(seekToTheTimeValue:)]) {
            if (self.enableFastForwardGesture) {
                float value = [self moveProgressControllWithTempPoint:tempPoint];
                //                [self.delegate seekToTheTimeValue:value];
                [self seekToTimeToPlay:value];
            }
            //            }
                        self.FF_View.hidden = YES;
        }else if (self.controlType == WMControlTypeLight){//如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
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
        }else if (self.controlType == WMControlTypeLight){//如果是亮度控制, 控制完亮度还要隐藏显示亮度的view
        }
    }else{

    }
}
#pragma mark - 用来控制移动过程中计算手指划过的时间

-(float)moveProgressControllWithTempPoint:(CGPoint)tempPoint{
    //90代表整个屏幕代表的时间
    float tempValue = self.touchBeginValue + WMPlayerTotalScreenTime * ((tempPoint.x - self.touchBeginPoint.x)/([UIScreen mainScreen].bounds.size.width));
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

//重置播放器

@end
