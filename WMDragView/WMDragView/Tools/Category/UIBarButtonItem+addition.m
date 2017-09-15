//
//  UIBarButtonItem+addition.m
//  TongXueBao
//
//  Created by 郑文明 on 16/10/19.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "UIBarButtonItem+addition.h"

@implementation UIBarButtonItem (addition)
+ (UIBarButtonItem *)itemWithIcon:(NSString *)icon highIcon:(NSString *)highIcon target:(id)target action:(SEL)action {
    UIButton *btn = [[UIButton alloc] init];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setBackgroundImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    if (highIcon) {
        [btn setBackgroundImage:[UIImage imageNamed:highIcon] forState:UIControlStateHighlighted];
    }
    btn.frame = (CGRect){CGPointZero,btn.currentBackgroundImage.size};
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return  [[UIBarButtonItem alloc] initWithCustomView:btn];
}

+ (UIBarButtonItem *)itemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [btn setTitleColor:kTintColor forState:UIControlStateNormal];
    [btn setTitleColor:kTintColor forState:UIControlStateHighlighted];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15);
    btn.frame = CGRectMake(0, 0, title.length * 18, 30);
    return  [[UIBarButtonItem alloc] initWithCustomView:btn];
}

@end
