//
//  MBProgressHUD+Show.m
//  weibo
//
//  Created by apple on 13-9-1.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+Show.h"

@implementation MBProgressHUD (Show)
+ (void)showText:(NSString *)text name:(NSString *)name
{
    // 显示加载失败
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    // 显示一张图片(mode必须写在customView设置之前)
    hud.mode = MBProgressHUDModeCustomView;
    // 设置一张图片
    name = [NSString stringWithFormat:@"MBProgressHUD.bundle/%@", name];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    
    hud.labelText = text;
    
    // 隐藏的时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒后自动隐藏
    [hud hide:YES afterDelay:1];
}

+ (void)showErrorWithText:(NSString *)text
{
    [self showText:text name:@"error.png"];
}

+ (void)showSuccessWithText:(NSString *)text
{
    [self showText:text name:@"success.png"];
}



@end
