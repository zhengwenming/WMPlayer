//
//  FullScreenHelperViewController.m
//  PlayerDemo
//
//  Created by apple on 2020/5/18.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "FullScreenHelperViewController.h"

@interface FullScreenHelperViewController ()<WMPlayerDelegate>

@end

@implementation FullScreenHelperViewController

-(BOOL)shouldAutorotate{
    return YES;
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
    self.wmPlayer.viewState = PlayerViewStateAnimating;
    //isFullscreen 延后到转场动画完成后再置 NO，避免动画开始前 player.frame 被提前改成小屏导致画面跳变
    [self dismissViewControllerAnimated:YES completion:^{
        //兜底：用进入全屏前记录的小屏 bounds/center 重建 originFrame，确保首次退出也能还原原始尺寸与位置
        self.wmPlayer.originFrame = CGRectMake(self.wmPlayer.beforeCenter.x - self.wmPlayer.beforeBounds.size.width/2,
                                               self.wmPlayer.beforeCenter.y - self.wmPlayer.beforeBounds.size.height/2,
                                               self.wmPlayer.beforeBounds.size.width,
                                               self.wmPlayer.beforeBounds.size.height);
        self.wmPlayer.isFullscreen = NO;
        self.wmPlayer.viewState = PlayerViewStateSmall;
    }];
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

