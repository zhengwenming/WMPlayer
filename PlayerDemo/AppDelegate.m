//
//  AppDelegate.m
//  WMPlayer
//
//  Created by 郑文明 on 16/2/1.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "AppDelegate.h"

@import AVFoundation;

@interface AppDelegate ()
@property(nonatomic,strong)NSDateFormatter *dateFormatter;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[DataManager shareManager] getSIDArrayWithURLString:@"http://c.m.163.com/nc/video/home/0-10.html"
                                                 success:^(NSArray *sidArray, NSArray *videoArray) {
                                                     self.sidArray =[NSArray arrayWithArray:sidArray];
                                                     self.videoArray = [NSArray arrayWithArray:videoArray];
                                                 }
                                                  failed:^(NSError *error) {
                                                      
                                                  }];
    //截图返回，地址为https://github.com/zhengwenming/ScreenShotBack
    self.screenshotView = [[ScreenShotView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [self.window insertSubview:self.screenshotView atIndex:0];
    self.screenshotView.hidden = YES;

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
   
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
