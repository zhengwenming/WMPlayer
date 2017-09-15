//
//  AppDelegate.h
//  WMPlayer
//
//  Created by 郑文明 on 16/2/1.
//  Copyright © 2016年 郑文明. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "RootTabBarController.h"
#import "DataManager.h"

#import "ScreenShotView.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (copy, nonatomic) NSArray *sidArray;
@property (copy, nonatomic) NSArray *videoArray;

@property (nonatomic, strong) ScreenShotView *screenshotView;
+(AppDelegate *)shareAppDelegate;

@end


