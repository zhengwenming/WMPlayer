//
//  BaseViewController.h
//  WMPlayer
//
//  Created by 郑文明 on 16/3/15.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
@property (nonatomic,retain) MBProgressHUD* hud;
- (void)addHud;
- (void)addHudWithMessage:(NSString*)message;
- (void)removeHud;
@end
