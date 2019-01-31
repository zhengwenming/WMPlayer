//
//  AppDelegate.m
//  WMPlayer
//
//  Created by 郑文明 on 16/2/1.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()
@property(nonatomic,strong)NSDateFormatter *dateFormatter;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.tabbar = [[RootTabBarController alloc]init];
    self.screenshotView = [[ScreenShotView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [self.window insertSubview:self.screenshotView atIndex:0];
    self.screenshotView.hidden = YES;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    
//    < !DOCTYPE html>
//    <html>
//    <head>
//    <meta charset="UTF-8">
//    <title></title>
//    </head>
//
//    <body>
//    <p class="title top-space" style="font-size: 50; text-align: center; top:200 ;"> MXFootBall</p >
//    <p class=" download_ content top-space" style-"text-align: center;">
//    <a class="download_ btn" style="font-size: 45; text-align: center; color: blue; text-decoration :none;" href= " itms - services ://?actiondownload-manifest&url=https://1gitee. com/DevYoung/MXFootBall/raw/master /manifest . plist">下载安装 </a >
//    </p >
//    </body>
//    </html>
//
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
 
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}
+(AppDelegate *)shareAppDelegate{
    return (AppDelegate *) [UIApplication sharedApplication].delegate;
}
@end
