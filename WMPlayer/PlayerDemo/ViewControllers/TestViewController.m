//
//  TestViewController.m
//  WMPlayer
//
//  Created by zhengwenming on 16/6/10.
//  Copyright © 2016年 郑文明. All rights reserved.
//


#import "TestViewController.h"
#import "WMPlayer.h"

#define TheUserDefaults [NSUserDefaults standardUserDefaults]

#define kHistoryTime @"HistoryTime"

@interface TestViewController ()<WMPlayerDelegate>
@property (weak, nonatomic) IBOutlet WMPlayer *wmPlayer;
@property(nonatomic,assign)WMPlayerState nowStatue;
@end

@implementation TestViewController
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    
}
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    NSLog(@"didSingleTaped");
}
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
}

///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidReadyToPlay");
    
}
//播放完毕的代理方法
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerFinishedPlay");
 
}
- (void)viewDidLoad
{
    self.navigationItem.title = @"XIB加载WMPlayer";
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([TheUserDefaults doubleForKey:kHistoryTime]) {//如果有存上次播放的时间点记录，直接跳到上次纪录时间点播放
        double time = [TheUserDefaults doubleForKey:kHistoryTime];
        self.wmPlayer.seekTime = time;
    }
    [self.wmPlayer setURLString:@"http://admin.weixin.ihk.cn/ihkwx_upload/test.mp4"];


    self.wmPlayer.delegate = self;
//    [self.wmPlayer setURLString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    self.wmPlayer.closeBtn.hidden = YES;
    [self.view addSubview:self.wmPlayer];

    
    [self.wmPlayer play];


}

- (void)releaseWMPlayer
{
     //堵塞主线程
//    [self.wmPlayer.player.currentItem cancelPendingSeeks];
//    [self.wmPlayer.player.currentItem.asset cancelLoading];
    [self.wmPlayer pause];
    
    
    [self.wmPlayer removeFromSuperview];
    [self.wmPlayer.playerLayer removeFromSuperlayer];
    [self.wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    self.wmPlayer.player = nil;
    self.wmPlayer.currentItem = nil;
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [self.wmPlayer.autoDismissTimer invalidate];
    self.wmPlayer.autoDismissTimer = nil;
    
    
   self.wmPlayer.playOrPauseBtn = nil;
    self.wmPlayer.playerLayer = nil;
    self.wmPlayer = nil;
}

- (void)dealloc
{
    double time = [self.wmPlayer currentTime];
    [TheUserDefaults setDouble:time forKey:kHistoryTime];
    NSLog(@"TestViewController dealloc");
    [self releaseWMPlayer];
  
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
//    [self.wmPlayer resetWMPlayer];
//    [self.wmPlayer setURLString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
//    [self.wmPlayer play];

    
}
@end

