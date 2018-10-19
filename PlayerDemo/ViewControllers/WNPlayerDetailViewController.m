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

@interface WNPlayerDetailViewController ()
@property(nonatomic,strong)WNPlayer *wnPlayer;
@end

@implementation WNPlayerDetailViewController
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
    self.wnPlayer = [[WNPlayer alloc] init];
    self.wnPlayer.autoplay = YES;
    self.wnPlayer.repeat = YES;
    self.wnPlayer.url = self.playerModel.videoURL.absoluteString;
    [self.view addSubview:self.wnPlayer];
    
    [self.wnPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.wnPlayer.superview);
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
