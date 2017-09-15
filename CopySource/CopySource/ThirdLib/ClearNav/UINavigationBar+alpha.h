//
//  UINavigationBar+alpha.h
//  IHK
//
//  Created by 郑文明 on 15/7/23.
//  Copyright (c) 2015年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (alpha)
- (void)wm_setBackgroundColor:(UIColor *)backgroundColor isHiddenBottomBlackLine:(BOOL)isHiddenBottomBlackLine;
///获取UINavigationBar的颜色
- (UIColor *)wm_getBackgroundColor;

- (void)wm_setContentAlpha:(CGFloat)alpha;
- (void)wm_setTranslationY:(CGFloat)translationY;
- (void)wm_reset;
@end
