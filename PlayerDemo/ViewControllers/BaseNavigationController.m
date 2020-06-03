/*!
 @header BaseNavigationController.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
            作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/19
 
 @version 1.00 16/1/19 Creation(版本信息)
 
   Copyright © 2016年 郑文明. All rights reserved.
 */

#import "BaseNavigationController.h"
#import "AppDelegate.h"

// 打开边界多少距离才触发pop
#define DISTANCE_TO_POP 80

@interface BaseNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.barTintColor = [UIColor redColor];
    //返回按钮颜色
    UIImage *backButtonImage = [[UIImage imageNamed:@"navigator_btn_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:17.0],NSFontAttributeName ,nil];
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count == 0){
        return [super pushViewController:viewController animated:animated];
    }else if (self.viewControllers.count>=1) {
        viewController.hidesBottomBarWhenPushed = YES;//隐藏二级页面的tabbar
    }
    
    [super pushViewController:viewController animated:animated];
    
    // 修正push控制器tabbar上移问题
    if (@available(iOS 11.0, *)){
        // 修改tabBra的frame
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
        self.tabBarController.tabBar.frame = frame;
    }
}




/**
 *  导航控制器 统一管理状态栏颜色
 *  @return 状态栏颜色
 */
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden{
    if(self.topViewController.prefersStatusBarHidden){
        return self.topViewController.prefersStatusBarHidden;
    }
    return NO;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    if(self.topViewController.preferredStatusBarUpdateAnimation){
           return self.topViewController.preferredStatusBarUpdateAnimation;
       }
    return UIStatusBarAnimationNone;
}
-(BOOL)shouldAutorotate{
    if(self.topViewController.shouldAutorotate){
        return self.topViewController.shouldAutorotate;
    }
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if(self.topViewController.supportedInterfaceOrientations){
        return self.topViewController.supportedInterfaceOrientations;
    }
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if(self.topViewController.preferredInterfaceOrientationForPresentation){
        return self.topViewController.preferredInterfaceOrientationForPresentation;
    }
    return UIInterfaceOrientationPortrait;
}
@end
