//
//  RootTabbarController.m
//  CopySource
//
//  Created by zhengwenming on 2017/4/9.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "RootTabbarController.h"

@interface RootTabbarController ()

@end

@implementation RootTabbarController

-(void)createTabBar
{
    NSURL *plistUrl = [[NSBundle mainBundle] URLForResource:@"MainUI" withExtension:@"plist"];
    NSArray *sourceArray = [NSArray arrayWithContentsOfURL:plistUrl];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSDictionary *dic in sourceArray) {
        BaseViewController  *aVC = (BaseViewController *) [[NSClassFromString(dic[@"vcName"]) alloc]init];
        BaseNavigationController *nav=[[BaseNavigationController alloc]initWithRootViewController:aVC];
        UITabBarItem *tabItem=[[UITabBarItem alloc]initWithTitle:dic[@"title"] image:[[UIImage imageNamed:dic[@"icon"] ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:dic[@"selectIcon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        aVC.title = dic[@"title"];
        nav.tabBarItem = tabItem;
        [viewControllers addObject:nav];
    }
    self.viewControllers = viewControllers;
    self.tabBar.tintColor = kTintColor;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTabBar];
}

- (BOOL)shouldAutorotate
{
    BaseNavigationController *nav = (BaseNavigationController *)self.selectedViewController;
    if ([nav.visibleViewController isKindOfClass:[NSClassFromString(@"MessageViewController") class]])
    {
        return YES;
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    BaseNavigationController *nav = (BaseNavigationController *)self.selectedViewController;
    //    topViewController = nav.lastObj
    if ([nav.visibleViewController isKindOfClass:[NSClassFromString(@"MessageViewController") class]])
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    BaseNavigationController *nav = (BaseNavigationController *)self.selectedViewController;
    if ([nav.visibleViewController isKindOfClass:[NSClassFromString(@"MessageViewController") class]])
    {
        return UIInterfaceOrientationLandscapeLeft;
    }
    return UIInterfaceOrientationPortrait;
}


@end
