
//
//  PersonCenterViewController.m
//  WMPlayer
//
//  Created by 郑文明 on 16/6/8.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "PersonCenterViewController.h"
#import "TestViewController.h"
#import <UIKit/UIKit.h>

@implementation PersonCenterViewController
- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor  whiteColor];

    UIButton *palyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    palyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    palyBtn.backgroundColor = [UIColor redColor];
    [palyBtn setTitle:@"记忆播放" forState:UIControlStateNormal];
    [palyBtn setTitle:@"记忆播放" forState:UIControlStateSelected];
    [palyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    palyBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [palyBtn setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateNormal];
    [palyBtn setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateSelected];
    palyBtn.frame = CGRectMake(0, 0, 200, 50);
    [palyBtn addTarget:self action:@selector(testSeekToPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:palyBtn];
    palyBtn.center = self.view.center;
}
-(void)testSeekToPlay:(UIButton *)sender{
    [self.navigationController pushViewController:[[TestViewController alloc] init] animated:YES];
}
@end
