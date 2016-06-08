//
//  TestViewController.m
//  WMPlayer
//
//  Created by 郑文明 on 16/6/8.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "TestViewController.h"

#define TheUserDefaults [NSUserDefaults standardUserDefaults]

#define kHistoryTime @"HistoryTime"

@interface TestViewController ()
@property(nonatomic,strong)WMPlayer *wmPlayer;
@end

@implementation TestViewController
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect  playerFrame = CGRectMake(0, 0, kScreenWidth, (kScreenWidth)*3/4);
    self.wmPlayer = [[WMPlayer alloc]initWithFrame:playerFrame];
//    [self.wmPlayer setURLString:@"http://admin.weixin.ihk.cn/ihkwx_upload/test.mp4"];
    [self.wmPlayer setURLString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];

    
    self.wmPlayer.closeBtn.hidden = NO;
    [self.view addSubview:self.wmPlayer];
    if ([TheUserDefaults doubleForKey:kHistoryTime]) {//如果有存上次播放的时间点记录，直接跳到上次纪录时间点播放
        double time = [TheUserDefaults doubleForKey:kHistoryTime];
        [self.wmPlayer seekToTimeToPlay:time];
    }else{
        [self.wmPlayer play];
    }
}
- (void)releaseWMPlayer
{
    [self.wmPlayer.player.currentItem cancelPendingSeeks];
    [self.wmPlayer.player.currentItem.asset cancelLoading];
    
    [self.wmPlayer.player pause];
    [self.wmPlayer removeFromSuperview];
    [self.wmPlayer.playerLayer removeFromSuperlayer];
    [self.wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    self.wmPlayer = nil;
    self.wmPlayer.player = nil;
    self.wmPlayer.currentItem = nil;
    
    self.wmPlayer.playOrPauseBtn = nil;
    self.wmPlayer.playerLayer = nil;
}

- (void)dealloc
{
    //
    [TheUserDefaults setDouble:[self.wmPlayer currentTime] forKey:kHistoryTime];
    [self releaseWMPlayer];
    NSLog(@"TestViewController dealloc");
}

@end
