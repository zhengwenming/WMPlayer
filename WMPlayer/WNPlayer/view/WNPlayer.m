//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayer.h"
#import "WNPlayerUtils.h"

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
@property (nonatomic, strong) WNPlayerManager *playerManager;
@property (nonatomic, strong) UIActivityIndicatorView *aivBuffering;

@property (nonatomic, weak) UIView *vTopBar;
@property (nonatomic, weak) UILabel *lblTitle;
@property (nonatomic, weak) UIView *vBottomBar;
@property (nonatomic, weak) UIButton *btnPlay;
@property (nonatomic, weak) UILabel *lblPosition;
@property (nonatomic, weak) UILabel *lblDuration;
@property (nonatomic, weak) UISlider *sldPosition;

@property (nonatomic) UITapGestureRecognizer *grTap;

@property (nonatomic) dispatch_source_t timer;
@property (nonatomic) BOOL updateHUD;
@property (nonatomic) NSTimer *timerForHUD;

@property (nonatomic, readwrite) WNPlayerStatus status;
@property (nonatomic) WNPlayerOperation nextOperation;

@end

@implementation WNPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.playerManager = [[WNPlayerManager alloc] init];
        UIView *v = self.playerManager.displayView;
        v.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:v];
        
        // Add constraints
        NSDictionary *views = NSDictionaryOfVariableBindings(v);
        NSArray<NSLayoutConstraint *> *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views];
        [self addConstraints:ch];
        NSArray<NSLayoutConstraint *> *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views];
        [self addConstraints:cv];
        
        [self initTopBar];
        [self initBottomBar];
        [self initBuffering];
        
        self.grTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesutreRecognizer:)];
        self.grTap.numberOfTapsRequired = 1;
        self.grTap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:self.grTap];
        
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
- (void)onPlayButtonTapped:(UIButton *)sender {
    if (self.playerManager.playing) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)onSliderStartSlide:(UISlider *)sender {
    self.updateHUD = NO;
    self.grTap.enabled = NO;
}

- (void)onSliderValueChanged:(UISlider *)slider {
    int seconds = slider.value;
    self.lblPosition.text = [WNPlayerUtils durationStringFromSeconds:seconds];
}

- (void)onSliderEndSlide:(UISlider *)slider {
    float position = slider.value;
    self.playerManager.position = position;
    self.updateHUD = YES;
    self.grTap.enabled = YES;
}

- (void)syncHUD {
    [self syncHUD:NO];
}

- (void)syncHUD:(BOOL)force {
    if (!force) {
        if (self.vTopBar.hidden) return;
        if (!self.playerManager.playing) return;
        if (!self.updateHUD) return;
    }
    
    // position
    double position = self.playerManager.position;
    int seconds = ceil(position);
    self.lblPosition.text = [WNPlayerUtils durationStringFromSeconds:seconds];
    self.sldPosition.value = seconds;
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
    self.aivBuffering.hidden = NO;
    [self.aivBuffering startAnimating];
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
    [self.btnPlay setTitle:@"|>" forState:UIControlStateNormal];
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
    [self.btnPlay setTitle:@"||" forState:UIControlStateNormal];
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
    [self.btnPlay setTitle:@"|>" forState:UIControlStateNormal];
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

- (void)notifyPlayerEOF:(NSNotification *)notif {
    self.status = WNPlayerStatusEOF;
    if (self.repeat) [self replay];
    else [self close];
}

- (void)notifyPlayerClosed:(NSNotification *)notif {
    self.status = WNPlayerStatusClosed;
    [self.aivBuffering stopAnimating];
    [self destroyTimer];
    [self doNextOperation];
}

- (void)notifyPlayerOpened:(NSNotification *)notif {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.aivBuffering stopAnimating];
    });
    
    self.status = WNPlayerStatusOpened;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        NSString *title = nil;
        if (strongSelf.playerManager.metadata != nil) {
            NSString *t = strongSelf.playerManager.metadata[@"title"];
            NSString *a = strongSelf.playerManager.metadata[@"artist"];
            if (t != nil) title = t;
            if (a != nil) title = [title stringByAppendingFormat:@" - %@", a];
        }
        if (title == nil) title = [strongSelf.url lastPathComponent];
        
        strongSelf.lblTitle.text = title;
        double duration = strongSelf.playerManager.duration;
        int seconds = ceil(duration);
        strongSelf.lblDuration.text = [WNPlayerUtils durationStringFromSeconds:seconds];
        strongSelf.sldPosition.enabled = seconds > 0;
        strongSelf.sldPosition.maximumValue = seconds;
        strongSelf.sldPosition.minimumValue = 0;
        strongSelf.sldPosition.value = 0;
        strongSelf.updateHUD = YES;
        [strongSelf createTimer];
        [strongSelf showHUD];
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
        [self.aivBuffering startAnimating];
    } else {
        self.status = WNPlayerStatusPlaying;
        [self.aivBuffering stopAnimating];
    }
}

- (void)notifyPlayerError:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    NSError *error = userInfo[WNPlayerNotificationErrorKey];
    
    if ([error.domain isEqualToString:WNPlayerErrorDomainDecoder]) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            [strongSelf.aivBuffering stopAnimating];
            strongSelf.status = WNPlayerStatusNone;
            strongSelf.nextOperation = WNPlayerOperationNone;
        });
        
        NSLog(@"Player decoder error: %@", error);
    } else if ([error.domain isEqualToString:WNPlayerErrorDomainAudioManager]) {
        NSLog(@"Player audio error: %@", error);
        // I am not sure what will cause the audio error,
        // if it happens, please issue to me
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationError object:self userInfo:notif.userInfo];
}
- (void)initBuffering {
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.translatesAutoresizingMaskIntoConstraints = NO;
    aiv.hidesWhenStopped = YES;
    [self addSubview:aiv];
    
    UIView *topbar = self.vTopBar;
    
    // Add constraints
    NSLayoutConstraint *cx = [NSLayoutConstraint constraintWithItem:aiv
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:topbar
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:-8];
    NSLayoutConstraint *cy = [NSLayoutConstraint constraintWithItem:aiv
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:topbar
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0];
    [self addConstraints:@[cx, cy]];
    self.aivBuffering = aiv;
}

- (void)initTopBar {
    CGRect frame = self.bounds;
    frame.size.height = 44;
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self addSubview:v];
    NSDictionary *views = NSDictionaryOfVariableBindings(v);
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v(==44)]"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:ch];
    [self addConstraints:cv];
    
    // Title Label
    UILabel *lbltitle = [[UILabel alloc] init];
    lbltitle.translatesAutoresizingMaskIntoConstraints = NO;
    lbltitle.backgroundColor = [UIColor clearColor];
    lbltitle.text = @"WNPlayer";
    lbltitle.font = [UIFont systemFontOfSize:15];
    lbltitle.textColor = [UIColor whiteColor];
    lbltitle.textAlignment = NSTextAlignmentCenter;
    [v addSubview:lbltitle];
    views = NSDictionaryOfVariableBindings(lbltitle);
    ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[lbltitle]-|" options:0 metrics:nil views:views];
    [v addConstraints:ch];
    cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lbltitle]|" options:0 metrics:nil views:views];
    [v addConstraints:cv];
    v.backgroundColor = [UIColor magentaColor];
    self.vTopBar = v;
    self.lblTitle = lbltitle;
}

- (void)initBottomBar {
    CGRect frame = self.bounds;
    frame.size.height = 44;
    UIView *v = [[UIView alloc] initWithFrame:frame];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    v.backgroundColor = [UIColor redColor];
    
    [self addSubview:v];
    NSDictionary *views = NSDictionaryOfVariableBindings(v);
    NSArray *ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    NSArray *cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v(==44)]|"
                                                          options:0
                                                          metrics:nil
                                                            views:views];
    [self addConstraints:ch];
    [self addConstraints:cv];
    
    // Play/Pause Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"|>" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onPlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:button];
    views = NSDictionaryOfVariableBindings(button);
    cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics:nil views:views];
    [v addConstraints:cv];
    
    // Position Label
    UILabel *lblpos = [[UILabel alloc] init];
    lblpos.translatesAutoresizingMaskIntoConstraints = NO;
    lblpos.backgroundColor = [UIColor clearColor];
    lblpos.text = @"--:--:--";
    lblpos.font = [UIFont systemFontOfSize:15];
    lblpos.textColor = [UIColor whiteColor];
    lblpos.textAlignment = NSTextAlignmentCenter;
    [v addSubview:lblpos];
    views = NSDictionaryOfVariableBindings(lblpos);
    cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lblpos]|" options:0 metrics:nil views:views];
    [v addConstraints:cv];
    
    UISlider *sldpos = [[UISlider alloc] init];
    sldpos.translatesAutoresizingMaskIntoConstraints = NO;
    sldpos.backgroundColor = [UIColor clearColor];
    sldpos.continuous = YES;
    [sldpos addTarget:self action:@selector(onSliderStartSlide:) forControlEvents:UIControlEventTouchDown];
    [sldpos addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [sldpos addTarget:self action:@selector(onSliderEndSlide:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [v addSubview:sldpos];
    views = NSDictionaryOfVariableBindings(sldpos);
    cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sldpos]|" options:0 metrics:nil views:views];
    [v addConstraints:cv];
    
    UILabel *lblduration = [[UILabel alloc] init];
    lblduration.translatesAutoresizingMaskIntoConstraints = NO;
    lblduration.backgroundColor = [UIColor clearColor];
    lblduration.text = @"--:--:--";
    lblduration.font = [UIFont systemFontOfSize:15];
    lblduration.textColor = [UIColor whiteColor];
    lblduration.textAlignment = NSTextAlignmentCenter;
    [v addSubview:lblduration];
    views = NSDictionaryOfVariableBindings(lblduration);
    cv = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[lblduration]|" options:0 metrics:nil views:views];
    [v addConstraints:cv];
    
    views = NSDictionaryOfVariableBindings(button, lblpos, sldpos, lblduration);
    ch = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[button(==32)]-[lblpos(==72)]-[sldpos]-[lblduration(==72)]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views];
    [v addConstraints:ch];
    
    self.vBottomBar = v;
    self.btnPlay = button;
    self.lblPosition = lblpos;
    self.sldPosition = sldpos;
    self.lblDuration = lblduration;
}


#pragma mark - Show/Hide HUD
- (void)showHUD {
    if (animatingHUD) return;
    
    [self syncHUD:YES];
    animatingHUD = YES;
    self.vTopBar.hidden = NO;
    self.vBottomBar.hidden = NO;
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         __strong typeof(weakSelf)strongSelf = weakSelf;
                         strongSelf.vTopBar.alpha = 1.0f;
                         strongSelf.vBottomBar.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         animatingHUD = NO;
                     }];
    [self startTimerForHideHUD];
}

- (void)hideHUD {
    if (animatingHUD) return;
    animatingHUD = YES;
    
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         __strong typeof(weakSelf)strongSelf = weakSelf;
                         strongSelf.vTopBar.alpha = 0.0f;
                         strongSelf.vBottomBar.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         __strong typeof(weakSelf)strongSelf = weakSelf;
                         
                         strongSelf.vTopBar.hidden = YES;
                         strongSelf.vBottomBar.hidden = YES;
                         
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
        if (self.vTopBar.hidden) [self showHUD];
        else [self hideHUD];
    }
}

- (void)createTimer {
    if (self.timer != nil) return;
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    
    __weak typeof(self)weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        [weakSelf syncHUD];
    });
    dispatch_resume(timer);
    self.timer = timer;
}
- (void)destroyTimer {
    if (self.timer == nil) return;
    dispatch_cancel(self.timer);
    self.timer = nil;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__FUNCTION__);

}

@end
