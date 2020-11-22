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
#import "LandscapeRightViewController.h"
#import "LandscapeLeftViewController.h"
#import "EnterFullScreenTransition.h"
#import "ExitFullScreenTransition.h"

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
    if (self.wmPlayer.viewState==PlayerViewStateSmall) {
         [self enterFullScreen];
    }
}
-(void)enterFullScreen{
    if (self.wmPlayer.viewState!=PlayerViewStateSmall) {
        return;
    }
    LandscapeRightViewController *rightVC = [[LandscapeRightViewController alloc] init];
    [self presentToVC:rightVC];
}
-(void)exitFullScreen{
    if (self.wmPlayer.viewState!=PlayerViewStateFullScreen) {
              return;
          }
    self.wmPlayer.isFullscreen = NO;
    self.wmPlayer.viewState = PlayerViewStateAnimating;
    [self dismissViewControllerAnimated:YES completion:^{
       self.wmPlayer.viewState  = PlayerViewStateSmall;
    }];
}
-(void)presentToVC:(FullScreenHelperViewController *)aHelperVC{
     self.wmPlayer.viewState = PlayerViewStateAnimating;
       self.wmPlayer.beforeBounds = self.wmPlayer.bounds;
       self.wmPlayer.beforeCenter = self.wmPlayer.center;
       self.wmPlayer.parentView = self.wmPlayer.superview;
       self.wmPlayer.isFullscreen = YES;

       aHelperVC.wmPlayer = self.wmPlayer;
        aHelperVC.modalPresentationStyle = UIModalPresentationFullScreen;
       aHelperVC.transitioningDelegate = self;
       [self presentViewController:aHelperVC animated:YES completion:^{
           self.wmPlayer.viewState = PlayerViewStateFullScreen;
       }];
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
            [self presentToVC:[LandscapeLeftViewController new]];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            [self presentToVC:[LandscapeRightViewController new]];
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
