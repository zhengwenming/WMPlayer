//
//  ExitFullScreenTransition.m
//  PlayerDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "ExitFullScreenTransition.h"
#import "Masonry.h"

@interface ExitFullScreenTransition ()
@property(nonatomic,strong)WMPlayer *player;
@end


@implementation ExitFullScreenTransition
- (instancetype)initWithPlayer:(WMPlayer *)wmplayer{
    self = [super init];
    if (self) {
        self.player = wmplayer;
    }
    return self;
}
#pragma mark - UIViewControllerTransitioningDelegate
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.30;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    //转场过渡的容器view
    UIView *containerView = [transitionContext containerView];
    //ToVC
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    fromView.backgroundColor = [UIColor clearColor];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    CGPoint initialCenter = [containerView convertPoint:self.player.beforeCenter fromView:nil];

    //关键：强制 toView 填满竖屏容器。横屏期间 toView(详情页)仍可能保持横屏 frame，
    //若不纠正，动画中 fromView 缩小后会露出容器黑色背景，形成“底部黑块”。
    toView.transform = CGAffineTransformIdentity;
    toView.bounds = containerView.bounds;
    toView.center = CGPointMake(containerView.bounds.size.width / 2.0, containerView.bounds.size.height / 2.0);

    [containerView insertSubview:toView belowSubview:fromView];
   
    if ([self.player.parentView isKindOfClass:[UIImageView class]]) {
        self.player.frame = CGRectMake(self.player.oldFrameToWindow.origin.x, self.player.oldFrameToWindow.origin.y, self.player.frame.size.width, self.player.frame.size.height);
        [[UIApplication sharedApplication].keyWindow addSubview:self.player];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            fromView.transform = CGAffineTransformIdentity;
            fromView.center = initialCenter;
            fromView.bounds = self.player.beforeBounds;
        } completion:^(BOOL finished) {
            [self.player removeFromSuperview];
            self.player.frame = self.player.parentView.bounds;
            [self.player.parentView addSubview:self.player];
            [fromView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }else{
        //对称于进入动画：缩放并旋转 fromView（全屏容器），并让 player 始终填满 fromView，避免溢出与画面变形
        CGPoint finalCenter = [containerView convertPoint:self.player.beforeCenter fromView:self.player.parentView];
        CGRect finalBounds = self.player.beforeBounds;
        self.player.frame = fromView.bounds;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromView.transform = CGAffineTransformIdentity;
            fromView.center = finalCenter;
            fromView.bounds = finalBounds;
            self.player.frame = finalBounds;
        } completion:^(BOOL finished) {
            [self.player removeFromSuperview];
            //用进入全屏前记录的小屏 bounds/center 还原，避免依赖可能被污染的 originFrame
            self.player.bounds = self.player.beforeBounds;
            self.player.center = self.player.beforeCenter;
            self.player.originFrame = self.player.frame;
            [self.player.parentView addSubview:self.player];
            [fromView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

@end


