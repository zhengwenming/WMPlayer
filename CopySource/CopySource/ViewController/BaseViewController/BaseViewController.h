//
//  BaseViewController.h
//  TongXueBao
//
//  Created by 郑文明 on 16/9/22.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"





@interface BaseViewController : UIViewController

@property (nonatomic, assign) BOOL isHideBackItem;
@property (nonatomic,strong) MBProgressHUD* hud;
/**
 在VC的view上加HUD，

 @param msg 显示的文本，nil为不显示任何文本
 */
- (void)showHUDToViewMessage:(NSString *)msg;

- (void)showHUDToWindowMessage:(NSString *)msg;

- (void)removeHUD;
///右滑返回功能，默认开启（YES）
- (BOOL)gestureRecognizerShouldBegin;

-(NSString *)backItemImageName;
@end
