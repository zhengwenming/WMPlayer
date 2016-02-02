
//
//  ThirdViewController.m
//  WMVideoPlayer
//
//  Created by 郑文明 on 15/12/14.
//  Copyright © 2015年 郑文明. All rights reserved.
//

#import "ThirdViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
@interface ThirdViewController ()
{
    MPMoviePlayerViewController *moviePlayer;
}
@end

@implementation ThirdViewController
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
-(void)initBtns{
    UIButton *playBtnOne = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtnOne.frame = CGRectMake(self.view.frame.size.width/2-300/2, 100, 300, 50);
    playBtnOne.backgroundColor = [UIColor blackColor];
    [playBtnOne setTitle:@"MPMoviePlayerViewController" forState:UIControlStateNormal];
    [playBtnOne addTarget:self action:@selector(playOne:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtnOne];
}
#pragma mark 
#pragma mark viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initBtns];
}

-(void)playOne:(UIButton *)sender{
        moviePlayer =[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"]];
//    moviePlayer =[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"http://v.youku.com/player/getM3U8/vid/(ID)/type/mp4/v.m3u8"]];
    
    
//    moviePlayer =[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:@"http://player.56.com/v_NjUwNDUwODI.swf"]];

        [moviePlayer.moviePlayer prepareToPlay];
        [self presentMoviePlayerViewControllerAnimated:moviePlayer]; // 这里是presentMoviePlayerViewControllerAnimated
        [moviePlayer.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
        [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
        [moviePlayer.moviePlayer setFullscreen:YES animated:YES];
        [moviePlayer.view setFrame:self.view.bounds];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(movieFinishedCallback:)
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer.moviePlayer];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = [window.subviews objectAtIndex:0];
    [view removeFromSuperview];
    [window addSubview:view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(moviePlayerWillEnterFullscreenNotification:)
     
                 name:MPMoviePlayerWillEnterFullscreenNotification
     
               object:moviePlayer];
       
    [[NSNotificationCenter defaultCenter] addObserver:self     selector:@selector(moviePlayerWillExitFullscreenNotification:)
     
                 name:MPMoviePlayerWillExitFullscreenNotification object:moviePlayer];
}

- (void)moviePlayerWillEnterFullscreenNotification:(NSNotification*)notify
{
    NSLog(@"moviePlayerWillEnterFullscreenNotification");
}

- (void)moviePlayerWillExitFullscreenNotification:(NSNotification*)notify{
    
    
//    [moviePlayer.moviePlayer play];
    NSLog(@"moviePlayerWillExitFullscreenNotification");
}


-(void)movieStateChangeCallback:(NSNotification*)notify  {
    NSLog(@"movieStateChangeCallback = %@",notify.object);
    //点击播放器中的播放/ 暂停按钮响应的通知
}
-(void)movieFinishedCallback:(NSNotification*)notify{
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    MPMoviePlayerController* theMovie = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
    [self dismissMoviePlayerViewControllerAnimated];
    
    
    [theMovie.view removeFromSuperview];
    

}
#pragma mark 
#pragma mark dealloc
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
