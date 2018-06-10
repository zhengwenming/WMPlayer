//
//  RootTabBarController.m
//  WMVideoPlayer
//
//  Created by 郑文明 on 15/12/14.
//  Copyright © 2015年 郑文明. All rights reserved.
//

#import "RootTabBarController.h"
@interface RootTabBarController (){
}
@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = [UIColor redColor];
    self.selectedIndex = 1;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
