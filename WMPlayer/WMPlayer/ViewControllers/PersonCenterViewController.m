
//
//  PersonCenterViewController.m
//  WMPlayer
//
//  Created by 郑文明 on 16/6/8.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "PersonCenterViewController.h"
#import "TestViewController.h"
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
    
    [palyBtn addTarget:self action:@selector(testSeekToPlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:palyBtn];
    [palyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];
}
-(void)testSeekToPlay:(UIButton *)sender{
    [self.navigationController pushViewController:[[TestViewController alloc] init] animated:YES];
}
@end
