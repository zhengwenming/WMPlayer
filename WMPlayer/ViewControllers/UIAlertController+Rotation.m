//
//  UIAlertController+Rotation.m
//  WMPlayer
//
//  Created by 郑文明 on 16/11/10.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "UIAlertController+Rotation.h"

@implementation UIAlertController (Rotation)
// 是否支持自动转屏
- (BOOL)shouldAutorotate
{
    return YES;
}

// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
