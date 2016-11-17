//
//  AppDelegate.h
//  WMPlayer
//
//  Created by 郑文明 on 16/2/1.
//  Copyright © 2016年 郑文明. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootTabBarController.h"

#if kUseScreenShotGesture
#import "ScreenShotView.h"
#endif


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootTabBarController *tabbar;

@property (copy, nonatomic) NSArray *sidArray;
@property (copy, nonatomic) NSArray *videoArray;

#if kUseScreenShotGesture
@property (nonatomic, strong) ScreenShotView *screenshotView;
#endif
+(AppDelegate *)shareAppDelegate;

@end


