//
//  DetailViewController.m
//  WMVideoPlayer
//
//  Created by 郑文明 on 16/2/1.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "DetailViewController.h"
#import "Masonry.h"
#import "LandscapeRightViewController.h"
#import "LandscapeLeftViewController.h"
#import "EnterFullScreenTransition.h"
#import "ExitFullScreenTransition.h"
#import "WMPlayer+Private.h"

@interface DetailViewController ()<WMPlayerDelegate,UIViewControllerTransitioningDelegate>
@property(nonatomic,strong)    UIButton *nextBtn;
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
-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}
//视图控制器实现的方法
- (BOOL)shouldAutorotate{
     return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
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
    [self enterFullScreen];
}
-(void)enterFullScreen{
    [self.wmPlayer enterFullScreenFromViewController:self helperViewController:[[LandscapeRightViewController alloc] init]];
}
-(void)exitFullScreen{
    [self.wmPlayer exitFullScreenFromViewController:self];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer.viewState!=PlayerViewStateSmall) {
        return;
    }
    if (self.wmPlayer.isLockScreen){
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
        }
            break;
        case UIInterfaceOrientationPortrait:{

        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            [self.wmPlayer enterFullScreenFromViewController:self helperViewController:[LandscapeLeftViewController new]];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            [self.wmPlayer enterFullScreenFromViewController:self helperViewController:[LandscapeRightViewController new]];
        }
            break;
        default:
            break;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.frame = UIScreen.mainScreen.bounds;
     self.wmPlayer.delegate = self;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
#pragma mark
#pragma mark viewDidLoad
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];

    self.wmPlayer = [[WMPlayer alloc] initWithFrame:CGRectMake(0, [WMPlayer IsiPhoneX]?34:0, self.view.frame.size.width, self.view.frame.size.width*(9.0/16))];
    self.wmPlayer.delegate = self;
    self.wmPlayer.playerModel = self.playerModel;
    [self.view addSubview:self.wmPlayer];
    [self.wmPlayer play];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextBtn.frame = CGRectMake(20, 500, 100, 40);
    [self.nextBtn addTarget:self action:@selector(nextVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextBtn setTitle:@"切换视频" forState:UIControlStateNormal];
    self.nextBtn.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.nextBtn];
    
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}
-(void)nextVideo:(UIButton *)sender{
    [self.wmPlayer resetWMPlayer];
    WMPlayerModel *newModel = [WMPlayerModel new];
    newModel.title = @"这个切换后的新视频标题";
    newModel.videoURL = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    self.wmPlayer.playerModel = newModel;
    [self.wmPlayer play];
}
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[EnterFullScreenTransition alloc] initWithPlayer:self.wmPlayer];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [[ExitFullScreenTransition alloc] initWithPlayer:self.wmPlayer];
}
- (void)dealloc{
    [self.wmPlayer pause];
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"DetailViewController dealloc");
}
@end
