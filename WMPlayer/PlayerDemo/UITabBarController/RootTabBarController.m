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
    tencentNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"腾讯" image:[UIImage imageNamed:@"found"] selectedImage:[UIImage imageNamed:@"found_s"]];
    tencentNav.navigationBar.barTintColor = [UIColor redColor];

    
    
    SinaNewsViewController *sinaVC = [[SinaNewsViewController alloc]init];
    sinaVC.title = @"新浪";
    BaseNavigationController *sinaNav = [[BaseNavigationController alloc]initWithRootViewController:sinaVC];
    
    sinaNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"新浪" image:[UIImage imageNamed:@"message"] selectedImage:[UIImage imageNamed:@"message_s"]];

    self.viewControllers = @[tencentNav,sinaNav];
    
    self.tabBar.tintColor = [UIColor redColor];
}
-(BOOL)shouldAutorotate{
    UINavigationController *nav = self.viewControllers[self.selectedIndex];
    return [nav.topViewController shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
     UINavigationController *nav = self.viewControllers[self.selectedIndex];
    return [nav.topViewController supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UINavigationController *nav = self.viewControllers[self.selectedIndex];
    return [nav.topViewController preferredInterfaceOrientationForPresentation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
