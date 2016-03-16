//
//  RootTabBarController.m
//  WMVideoPlayer
//
//  Created by 郑文明 on 15/12/14.
//  Copyright © 2015年 郑文明. All rights reserved.
//

#import "RootTabBarController.h"
#import "TencentNewsViewController.h"
#import "SinaNewsViewController.h"
#import "NetEaseViewController.h"
#import "BaseNavigationController.h"

@interface RootTabBarController (){
}

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    TencentNewsViewController *tencentVC = [[TencentNewsViewController alloc]init];
    tencentVC.title = @"腾讯";

    BaseNavigationController *tencentNav = [[BaseNavigationController alloc]initWithRootViewController:tencentVC];
    tencentNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"腾讯" image:[UIImage imageNamed:@"found@2x.png"] selectedImage:[UIImage imageNamed:@"found_s@2x.png"]];
    tencentNav.navigationBar.barTintColor = [UIColor redColor];

    
    
    SinaNewsViewController *sinaVC = [[SinaNewsViewController alloc]init];
    sinaVC.title = @"新浪";
    BaseNavigationController *sinaNav = [[BaseNavigationController alloc]initWithRootViewController:sinaVC];
    
    sinaNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"新浪" image:[UIImage imageNamed:@"message@2x.png"] selectedImage:[UIImage imageNamed:@"message_s@2x.png"]];

    
    
    NetEaseViewController *netEaseVC = [[NetEaseViewController alloc]init];
    netEaseVC.title = @"网易";

    BaseNavigationController *netEaseNav = [[BaseNavigationController alloc]initWithRootViewController:netEaseVC];
    netEaseNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"网易" image:[UIImage imageNamed:@"share@2x.png"] selectedImage:[UIImage imageNamed:@"share_s@2x.png"]];
    
    self.viewControllers = @[tencentNav,sinaNav,netEaseNav];
    
    self.tabBar.tintColor = [UIColor redColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
