//
//  DetailViewController.m
//  WMVideoPlayer
//
//  Created by 郑文明 on 16/2/1.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "DetailViewController.h"
#import "Masonry.h"
#import "FullScreenHelperViewController.h"
#import "LandscapeLeftViewController.h"
#import "LandscapeRightViewController.h"
#import "EnterFullScreenTransition.h"
#import "ExitFullScreenTransition.h"
#import <AVKit/AVKit.h>
@interface DetailViewController ()<WMPlayerDelegate,UIViewControllerTransitioningDelegate>
@property(nonatomic,strong)    UIButton *nextBtn;
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
     return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    if (wmplayer.isFullscreen) {
        [self exitFullScreen];
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
    if (self.wmPlayer.isFullscreen) {//全屏-->非全屏
        [self exitFullScreen];
    }else{//非全屏-->全屏
        [self enterFullScreen:[LandscapeRightViewController new]];
    }
}
-(void)enterFullScreen:(FullScreenHelperViewController *)aHelperVC{
    self.wmPlayer.isFullscreen = YES;
    self.wmPlayer.beforeBounds = self.wmPlayer.bounds;
    self.wmPlayer.beforeCenter = self.wmPlayer.center;
    self.wmPlayer.parentView = self.wmPlayer.superview;
    
    aHelperVC.transitioningDelegate = self;
    aHelperVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:aHelperVC animated:YES completion:^{

    }];
}
-(void)exitFullScreen{
    self.wmPlayer.isFullscreen = NO;
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[EnterFullScreenTransition alloc] initWithPlayer:self.wmPlayer];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [[ExitFullScreenTransition alloc] initWithPlayer:self.wmPlayer];
}
///单击播放器
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{    
    [self setNeedsStatusBarAppearanceUpdate];
}
///双击播放器
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{

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
    if (self.wmPlayer.isLockScreen||self.forbidRotate){
        return;
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
            if (self.wmPlayer.isFullscreen==NO) {
                return;
            }
            [self exitFullScreen];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            if (self.wmPlayer.isFullscreen) {
                return;
            }
            [self enterFullScreen:[LandscapeLeftViewController new]];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            if (self.wmPlayer.isFullscreen) {
                return;
            }
            [self enterFullScreen:[LandscapeRightViewController new]];
        }
            break;
        default:
            break;
    }
    self.nextBtn.hidden = self.wmPlayer.isFullscreen;
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
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    if(self.wmPlayer==nil){
        self.wmPlayer = [[WMPlayer alloc] initPlayerModel:self.playerModel];
    }
    self.wmPlayer.backBtnStyle = BackBtnStylePop;
    self.wmPlayer.delegate = self;
    [self.view addSubview:self.wmPlayer];
    [self.wmPlayer play];
    [self.wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.wmPlayer.superview);
        make.top.equalTo(@([WMPlayer IsiPhoneX]?34:0));
        make.height.mas_equalTo(self.wmPlayer.mas_width).multipliedBy(9.0/16);
    }];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextBtn.backgroundColor = [UIColor lightGrayColor];
    [self.nextBtn addTarget:self action:@selector(nextVideo:) forControlEvents:UIControlEventTouchUpInside];
     [self.nextBtn setTitle:@"切换视频" forState:UIControlStateNormal];
    self.nextBtn.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(280);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
}
-(void)nextVideo:(UIButton *)sender{
    [self.wmPlayer resetWMPlayer];
    WMPlayerModel *newModel = [WMPlayerModel new];
    newModel.title = @"这个切换后的新视频标题";
    newModel.videoURL = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    self.wmPlayer.playerModel = newModel;
    [self.wmPlayer play];
}
- (void)dealloc{
    [self.wmPlayer pause];
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"DetailViewController dealloc");
}
@end
