//
//  VCRotateViewController.m
//  PlayerDemo
//
//  Created by apple on 2020/6/3.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "VCRotateViewController.h"

@interface VCRotateViewController ()<WMPlayerDelegate>
@property (nonatomic, strong)WMPlayer  *wmPlayer;
@end

@implementation VCRotateViewController
- (BOOL)shouldAutorotate{
    if (self.wmPlayer.playerModel.verticalVideo||self.wmPlayer.isLockScreen) {
           return NO;
       }
        return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    return UIInterfaceOrientationLandscapeRight;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(onDeviceOrientationChange:)
                                                name:UIDeviceOrientationDidChangeNotification
                                              object:nil
    ];
    WMPlayerModel *playerModel = [WMPlayerModel new];
    playerModel.title = @"这是视频标题";
    playerModel.videoURL = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];


    self.wmPlayer = [[WMPlayer alloc] initWithFrame:CGRectMake(0, [WMPlayer IsiPhoneX]?34:0, self.view.frame.size.width, self.view.frame.size.width*(9.0/16))];
    self.wmPlayer.delegate = self;
    self.wmPlayer.playerModel =playerModel;
    [self.view addSubview:self.wmPlayer];
    [self.wmPlayer play];
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    if (wmplayer.isFullscreen) {
         [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
         [UIViewController attemptRotationToDeviceOrientation];
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
    if (self.wmPlayer.isFullscreen) {//全屏-->非全屏
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }else{//非全屏-->全屏
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    [UIViewController attemptRotationToDeviceOrientation];
}
//旋转屏幕通知方法
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer.isLockScreen){
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
            [self.wmPlayer setIsFullscreen:NO];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            [self.wmPlayer setIsFullscreen:YES];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            [self.wmPlayer setIsFullscreen:YES];
        }
            break;
        default:
            break;
    }
}
- (void)dealloc{
    [self.wmPlayer pause];
       [self.wmPlayer removeFromSuperview];
       self.wmPlayer = nil;    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"DetailViewController dealloc");
}
@end
