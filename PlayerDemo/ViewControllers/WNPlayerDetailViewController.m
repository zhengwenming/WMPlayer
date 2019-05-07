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
@property(nonatomic,strong)UIImageView *snapShotImageView;


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
    
    self.wnPlayer.urlString = @"http://hkwb.cskin.net/TestPlayUrl.aspx?id=4";
//    self.wnPlayer.urlString = @"http://updatedown.heikeyun.net/WMV%E6%96%87%E4%BB%B6%E8%A7%86%E9%A2%91%E6%B5%8B%E8%AF%95.wmv";


//    self.wnPlayer.urlString = self.playerModel.videoURL.absoluteString;
//
//    self.wnPlayer.urlString = @"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov";
//    self.wnPlayer.urlString = @"http://185.134.22.15:8080/2493496367/xrhJ1Dgy9U/50032";
//      self.wnPlayer.urlString = @"http://reezee.com.cn/b75d943a767b4c7c962c1c24a8f0ff2d/c7cf6212a55e4b56b66bb1be5d09ba95-435c9cccf64dda7c34248e884413eb3f-ld.mp4";

    
    
//    NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp4"]];
//    self.wnPlayer.urlString = [URL absoluteString];
    
    
    [self.view addSubview:self.wnPlayer];
    
    [self.wnPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.wnPlayer.superview);
        make.top.equalTo(self.blackView.mas_bottom);
        make.height.mas_equalTo(self.wnPlayer.mas_width).multipliedBy(9.0/16);
    }];
    

    [self.wnPlayer openWithTCP:YES optionDic:@{@"headers":@"Cookie:FTN5K=f44da28b"}];
    [self.wnPlayer play];
    
//    self.wnPlayer.playerManager.position = 3;
    
    [self.view addSubview:self.snapShotImageView];
}
-(UIImageView *)snapShotImageView{
    if (_snapShotImageView==nil) {
        _snapShotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        self.snapShotImageView.backgroundColor = [UIColor magentaColor];
        _snapShotImageView.center = self.view.center;
    }
    return _snapShotImageView;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UIImage *image = [self.wnPlayer snapshot:self.wnPlayer.frame.size];
    NSLog(@"%@",image);
    self.snapShotImageView.image = image;
}
- (void)dealloc
{
    [self.wnPlayer close];
    NSLog(@"%s",__FUNCTION__);
}
@end
