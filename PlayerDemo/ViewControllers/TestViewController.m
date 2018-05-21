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

    }


    self.wmPlayer.delegate = self;
//    [self.wmPlayer setURLString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    [self.view addSubview:self.wmPlayer];
    [self.wmPlayer play];
}

- (void)releaseWMPlayer{
    [self.wmPlayer pause];
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;
}

- (void)dealloc{
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

