//
//  FullScreenHelperViewController.m
//  PlayerDemo
//
//  Created by apple on 2020/5/18.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "FullScreenHelperViewController.h"
#import "WMPlayer+Private.h"

@interface FullScreenHelperViewController ()<WMPlayerDelegate>

@end

@implementation FullScreenHelperViewController

-(BOOL)shouldAutorotate{
    return YES;
}

//全屏容器显式隐藏状态栏，保证全屏期间状态栏确定性隐藏（不依赖刘海屏横屏的系统行为）
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.wmPlayer.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(onDeviceOrientationChange:)
        name:UIDeviceOrientationDidChangeNotification
      object:nil];
}
///播放器CloseButton
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    NSLog(@"[WMPlayer-FullScreen] close tapped, isFullscreen=%d, viewState=%lu", wmplayer.isFullscreen, (unsigned long)wmplayer.viewState);
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
///全屏按钮
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    
}
-(void)exitFullScreen{
    // 传 self（被 present 的全屏 VC）触发 dismiss，由系统转发给 presenting VC，
    // 避免旋转进入全屏时 presentingViewController 可能为 nil 导致 dismiss 失效。
    [self.wmPlayer exitFullScreenFromViewController:self];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer.isLockScreen){
        return;
    }
    if (self.wmPlayer.viewState!=PlayerViewStateFullScreen) {
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
            self.wmPlayer.viewState = PlayerViewStateAnimating;
            [self exitFullScreen];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
        }
            break;
        default:
            break;
    }
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

