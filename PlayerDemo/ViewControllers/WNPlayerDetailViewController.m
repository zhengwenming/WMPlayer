//
//  WNPlayerDetailViewController.m
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/16.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayerDetailViewController.h"
#import "WNPlayer.h"
#import "Masonry.h"
#import "WMPlayer.h"

@interface WNPlayerDetailViewController ()<WNPlayerDelegate>
@property(nonatomic,strong)WNPlayer *wnPlayer;
@property(nonatomic,strong)UIView *blackView;


@end

@implementation WNPlayerDetailViewController
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

//视图控制器实现的方法
- (BOOL)shouldAutorotate{
    if (self.wnPlayer.playerManager.displayView.contentSize.width/self.wnPlayer.playerManager.displayView.contentSize.height<1) {
        return NO;
    }
    return YES;
}
//viewController所支持的全部旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    //对于present出来的控制器，要主动的（强制的）选择VC，让wmPlayer全屏
    //    UIInterfaceOrientationLandscapeLeft或UIInterfaceOrientationLandscapeRight
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    return UIInterfaceOrientationLandscapeRight;
}

//点击关闭按钮代理方法
-(void)wnplayer:(WNPlayer *)wnplayer clickedCloseButton:(UIButton *)backBtn{
    [self.navigationController popViewControllerAnimated:YES];
}
//点击全屏按钮代理方法
-(void)wnplayer:(WNPlayer *)wnplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (self.wnPlayer.isFullscreen) {//全屏
        //强制翻转屏幕，Home键在下边。
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }else{//非全屏
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
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
        [self.wnPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.wnPlayer.superview);
            make.top.equalTo(self.blackView.mas_bottom);
            make.height.mas_equalTo(self.wnPlayer.mas_width).multipliedBy(9.0/16);
        }];
        self.wnPlayer.isFullscreen = NO;
    }else{
        [self.wnPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            if([WMPlayer IsiPhoneX]){
                if (self.wnPlayer.playerManager.displayView.contentSize.width/self.wnPlayer.playerManager.displayView.contentSize.height<1) {
                    make.edges.mas_equalTo(UIEdgeInsetsMake(14, 0, 0, 0));
                }else{
                    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
                }
            }else{
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }
        }];
        self.wnPlayer.isFullscreen = YES;
    }
    self.enablePanGesture = !self.wnPlayer.isFullscreen;
    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}
- (void)viewDidLoad {
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
    
    self.wnPlayer = [[WNPlayer alloc] init];
    self.wnPlayer.autoplay = YES;
    self.wnPlayer.delegate = self;
    self.wnPlayer.repeat = YES;
    self.wnPlayer.title = self.playerModel.title;
    self.wnPlayer.urlString = self.playerModel.videoURL.absoluteString;
//    self.wnPlayer.urlString = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
    [self.view addSubview:self.wnPlayer];
    
    [self.wnPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.wnPlayer.superview);
        make.top.equalTo(self.blackView.mas_bottom);
 make.height.mas_equalTo(self.wnPlayer.mas_width).multipliedBy(9.0/16);
    }];
    
    
    [self.wnPlayer open];
    [self.wnPlayer play];
}
- (void)dealloc
{
    [self.wnPlayer close];

    NSLog(@"%s",__FUNCTION__);
}
@end
