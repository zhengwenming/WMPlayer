//
//  DetailViewController.m
//  WMVideoPlayer
//
//  Created by 郑文明 on 16/2/1.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "DetailViewController.h"
#import "Masonry.h"

@interface DetailViewController ()<WMPlayerDelegate>
@property(nonatomic,strong)    UIButton *nextBtn;
@property(nonatomic,strong)    UIView *blackView;


@property(nonatomic,assign)    BOOL  forbidRotate;//手势返回的时候禁止旋转VC
@end

@implementation DetailViewController
//全屏的时候hidden底部homeIndicator
-(BOOL)prefersHomeIndicatorAutoHidden{
    return self.wmPlayer.isFullscreen;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden{
    return self.wmPlayer.prefersStatusBarHidden;
}
//视图控制器实现的方法
- (BOOL)shouldAutorotate{
    if (self.forbidRotate) {
        return NO;
    }
//    if (self.wmPlayer.playerModel.verticalVideo) {
//        return NO;
//    }
     return !self.wmPlayer.isLockScreen;
}
//viewController所支持的全部旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    //对于present出来的控制器，要主动的（强制的）旋转VC，让wmPlayer全屏
//    UIInterfaceOrientationLandscapeLeft或UIInterfaceOrientationLandscapeRight
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    return UIInterfaceOrientationLandscapeRight;
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    if (wmplayer.isFullscreen) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        //刷新
//        [UIViewController attemptRotationToDeviceOrientation];
    }else{
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
///播放暂停
-(void)wmplayer:(WMPlayer *)wmplayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    NSLog(@"clickedPlayOrPauseButton");
}
///全屏按钮
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (self.wmPlayer.isFullscreen) {//全屏
        //强制翻转屏幕，Home键在下边。
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }else{//非全屏
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}
///单击播放器
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{    
    [self setNeedsStatusBarAppearanceUpdate];
}
///双击播放器
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
    if (wmplayer.isLockScreen) {
        return;
    }
    [wmplayer playOrPause:[wmplayer valueForKey:@"playOrPauseBtn"]];
}
///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{

}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
}
-(void)wmplayerGotVideoSize:(WMPlayer *)wmplayer videoSize:(CGSize )presentationSize{
    
}
//操作栏隐藏或者显示都会调用此方法
-(void)wmplayer:(WMPlayer *)wmplayer isHiddenTopAndBottomView:(BOOL)isHidden{
    [self setNeedsStatusBarAppearanceUpdate];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer.isLockScreen){
        return;
    }
    if (self.forbidRotate) {
        return ;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            [self toOrientation:UIInterfaceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
        }
            break;
        default:
            break;
    }
}

//点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
-(void)toOrientation:(UIInterfaceOrientation)orientation{    
    if (orientation ==UIInterfaceOrientationPortrait) {
        [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.wmPlayer.superview);
            make.top.equalTo(self.blackView.mas_bottom);
        make.height.mas_equalTo(self.wmPlayer.mas_width).multipliedBy(9.0/16);
        }];
        self.wmPlayer.isFullscreen = NO;
    }else{
        [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            if([WMPlayer IsiPhoneX]){
                make.edges.mas_equalTo(UIEdgeInsetsMake(self.wmPlayer.playerModel.verticalVideo?14:0, 0, 0, 0));
            }else{
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }
        }];
        self.wmPlayer.isFullscreen = YES;
    }
    self.enablePanGesture = !self.wmPlayer.isFullscreen;
    self.nextBtn.hidden = self.wmPlayer.isFullscreen;
    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
#pragma mark
#pragma mark viewDidLoad
- (void)viewDidLoad{
    [super viewDidLoad];
    //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
    self.blackView = [UIView new];
    self.blackView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.blackView];
    [self.blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.equalTo(@([WMPlayer IsiPhoneX]?34:0));
    }];
    
    if(self.wmPlayer==nil){
        self.wmPlayer = [[WMPlayer alloc] initPlayerModel:self.playerModel];
    }
    self.wmPlayer.backBtnStyle = BackBtnStylePop;
    self.wmPlayer.loopPlay = YES;//设置是否循环播放
    self.wmPlayer.tintColor = [UIColor orangeColor];//改变播放器着色
    self.wmPlayer.enableBackgroundMode = YES;//开启后台播放模式
    self.wmPlayer.delegate = self;
    [self.view addSubview:self.wmPlayer];
    [self.wmPlayer play];
    [self.wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.wmPlayer.superview);
        make.top.equalTo(self.blackView.mas_bottom);
        make.height.mas_equalTo(self.wmPlayer.mas_width).multipliedBy(9.0/16);
    }];
    
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextBtn.backgroundColor = [UIColor lightGrayColor];
    [self.nextBtn addTarget:self action:@selector(nextVideo:) forControlEvents:UIControlEventTouchUpInside];
     [self.nextBtn setTitle:@"切换视频" forState:UIControlStateNormal];
    self.nextBtn.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    
    
    __weak __typeof(&*self) weakSelf = self;
    ///手势开始时刻回调block
    self.gestureBeganBlock = ^(UIViewController *viewController) {
        weakSelf.forbidRotate = YES;
    };
    
    ///手势作用期间回调block
    self.gestureChangedBlock = ^(UIViewController *viewController) {

    };
    
    ///手势结束时刻回调block
    self.gestureEndedBlock = ^(UIViewController *viewController) {
        weakSelf.forbidRotate = NO;
    };
//        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
}
-(void)nextVideo:(UIButton *)sender{
    [self.wmPlayer resetWMPlayer];
    WMPlayerModel *newModel = [WMPlayerModel new];
    newModel.title = @"这个是新视频的标题";
    newModel.videoURL = [NSURL URLWithString:@"http://sz-ctfs.ftn.qq.com/%E6%97%A0%E8%80%BB%E5%AE%B6%E5%BA%ADS10E07cut.mp4?ver=5199&rkey=f8f7130a5c956907f4fb5d1a8141eaf883a412a8ed6935b719fe54af077d961c66c7c2a9cb94a74991cd71f53a79c081876dc6cf2f8248ccd5db9a0fc0ed0b25"];
    self.wmPlayer.playerModel = newModel;
    [self.wmPlayer play];
}
- (void)releaseWMPlayer{
    [self.wmPlayer pause];
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;
}
- (void)dealloc{
    [self releaseWMPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"DetailViewController dealloc");
}
@end
