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
    self.tabBar.tintColor = [UIColor redColor];
}
-(BOOL)shouldAutorotate{
    BaseNavigationController *nav = (BaseNavigationController *)self.selectedViewController;
    if ([nav.topViewController isKindOfClass:[NSClassFromString(@"DetailViewController") class]]) {
        return YES;
    }
    return NO;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    BaseNavigationController *nav = (BaseNavigationController *)self.selectedViewController;
    if ([nav.topViewController isKindOfClass:[NSClassFromString(@"DetailViewController") class]]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    BaseNavigationController *nav = (BaseNavigationController *)self.selectedViewController;
    if ([nav.topViewController isKindOfClass:[NSClassFromString(@"DetailViewController") class]]) {
        return UIInterfaceOrientationPortrait|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
    }
    return UIInterfaceOrientationPortrait;
    
}- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
