//
//  SceneOneViewController.m
//  WMDragView
//
//  Created by zhengwenming on 2017/8/19.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "SceneOneViewController.h"

@interface SceneOneViewController ()

@end

@implementation SceneOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"又回到最初的起点";
    
    CGRect originalFrame = (CGRect){CGPointMake(self.view.center.x-80/2, self.view.center.y-80/2),CGSizeMake(80, 80)};
    
    WMDragView *orangeView = [[WMDragView alloc] initWithFrame:originalFrame];
    orangeView.imageView.image = [UIImage imageNamed:@"logo1024"];
    orangeView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:orangeView];
    
    orangeView.clickDragViewBlock = ^(WMDragView *dragView){

        
    };
    
    
    orangeView.endDragBlock = ^(WMDragView *dragView) {
            [UIView animateWithDuration:0.5 animations:^{
                dragView.frame = originalFrame;
            }];
        };

}



@end
