//
//  ViewController.m
//  WMDragView
//
//  Created by zhengwenming on 2016/12/16.
//  Copyright © 2016年 zhengwenming. All rights reserved.
//

#import "ViewController.h"
#import "WMDragView.h"
#import "TestViewController.h"


@implementation ViewController

- (void)viewDidLoad
{
    self.title = @"可拖曳的View";
    [super viewDidLoad];
    
    
    WMDragView *redView = [[WMDragView alloc]initWithFrame:CGRectMake(20, 64+20, 200, 200)];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, redView.frame.size.width, 60)];
    label.text = @"橙色view被限制在红色view中，出不来了!";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [redView addSubview:label];
    
   WMDragView *orangeView = [[WMDragView alloc] initWithFrame:CGRectMake(0, 0 , 70, 70)];
    orangeView.button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [orangeView.button setTitle:@"可拖曳" forState:UIControlStateNormal];
    orangeView.backgroundColor = [UIColor orangeColor];
    [redView addSubview:orangeView];
    orangeView.clickDragViewBlock = ^(WMDragView *dragView){
        NSLog(@"橙色view被点击了");
        dragView.dragEnable = !dragView.dragEnable;
        if (dragView.dragEnable) {
            [dragView.button setTitle:@"可拖曳" forState:UIControlStateNormal];
        }else{
            [dragView.button setTitle:@"不可拖曳" forState:UIControlStateNormal];
        }

    };
//    orangeView.EndDragBlock = ^(WMDragView *dragView) {
//        [UIView animateWithDuration:0.5 animations:^{
//            dragView.frame = CGRectMake(0, 0 , 70, 70);
//        }];
//    };
    
    
    
    ///初始化可以拖曳的view
   WMDragView *logoView = [[WMDragView alloc] initWithFrame:CGRectMake(0, 0 , 70, 70)];
    logoView.layer.cornerRadius = 14;
    logoView.isKeepBounds = YES;
    //设置显示图片方式一：
    logoView.imageView.image = [UIImage imageNamed:@"logo1024"];
    //设置显示图片方式二：
//    [logoView.button setBackgroundImage:[UIImage imageNamed:@"logo1024"] forState:UIControlStateNormal];

    
    [logoView setBackgroundColor:[UIColor redColor]];
    [[UIApplication sharedApplication].keyWindow addSubview:logoView];
    //限定logoView的活动范围
    logoView.center = self.view.center;
    logoView.clickDragViewBlock = ^(WMDragView *dragView){
        
        [self.navigationController pushViewController:[TestViewController new] animated:YES];
    };

    
}

@end
