//
//  AppDelegate.m
//  WMPlayer
//
//  Created by 郑文明 on 16/2/1.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate
//此方法解决横屏启动APP的时候UI错乱的bug（前提是在设置里面Device orientation仅仅勾选☑️一个竖屏即可，其他的都不勾选）
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return  UIInterfaceOrientationMaskAllButUpsideDown;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.tabbar = [[RootTabBarController alloc]init];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
