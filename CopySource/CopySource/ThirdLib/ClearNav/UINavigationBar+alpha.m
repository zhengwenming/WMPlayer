//
//  UINavigationBar+alpha.m
//  IHK
//
//  Created by 郑文明 on 15/7/23.
//  Copyright (c) 2015年 郑文明. All rights reserved.
//

#import "UINavigationBar+alpha.h"
#import <objc/runtime.h>

static char overlayKey;
static char emptyImageKey;
static char lineKey;

@implementation UINavigationBar (alpha)

- (UIView *)overlay
{
    UIView *overlayView = objc_getAssociatedObject(self, &overlayKey);
    return overlayView;
}

- (void)setOverlay:(UIView *)overlay
{
    objc_setAssociatedObject(self, &overlayKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)emptyImage
{
    return objc_getAssociatedObject(self, &emptyImageKey);
}

- (void)setEmptyImage:(UIImage *)image
{
    objc_setAssociatedObject(self, &emptyImageKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)line{
    return objc_getAssociatedObject(self, &lineKey);
}
- (void)setLine:(UIView *)line{
    objc_setAssociatedObject(self, &lineKey, line, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)wm_getBackgroundColor{
    if (self.overlay) {
        return self.overlay.backgroundColor;
    }
    return self.barTintColor;
}
- (void)wm_setBackgroundColor:(UIColor *)backgroundColor isHiddenBottomBlackLine:(BOOL)isHiddenBottomBlackLine
{
    if (!self.overlay) {
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.bounds) + 20)];
        NSLog(@"alloc overLay");
        self.overlay.userInteractionEnabled = NO;
        self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [[self.subviews firstObject] insertSubview:self.overlay atIndex:0];
        [[self.subviews firstObject] bringSubviewToFront:self.overlay];
    }
        if (isHiddenBottomBlackLine==NO) {
            
        }else{
            //去除底部黑线
            [self setShadowImage:[UIImage new]];
        }
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.overlay.backgroundColor = backgroundColor;
}

- (void)wm_setTranslationY:(CGFloat)translationY
{
    self.transform = CGAffineTransformMakeTranslation(0, translationY);
}

- (void)wm_setContentAlpha:(CGFloat)alpha
{
    if (!self.overlay) {
        [self wm_setBackgroundColor:self.barTintColor isHiddenBottomBlackLine:NO];
    }
    [self setAlpha:alpha forSubviewsOfView:self];
    if (alpha == 1) {
        if (!self.emptyImage) {
            self.emptyImage = [UIImage new];
        }
        self.backIndicatorImage = self.emptyImage;
    }
}

- (void)setAlpha:(CGFloat)alpha forSubviewsOfView:(UIView *)view
{
    for (UIView *subview in view.subviews) {
        if (subview == self.overlay) {
            continue;
        }
        subview.alpha = alpha;
        [self setAlpha:alpha forSubviewsOfView:subview];
    }
}

- (void)wm_reset
{
        [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:nil];
    if (self.overlay) {
        [self.overlay removeFromSuperview];
        self.overlay = nil;
        NSLog(@"release overLay");
    }
}

@end

