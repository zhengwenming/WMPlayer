//
//  AppDelegate.h
//  CopySource
//
//  Created by zhengwenming on 2017/4/9.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootTabbarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootTabbarController *rootTabbar;

+ (AppDelegate* )shareAppDelegate;

@end

