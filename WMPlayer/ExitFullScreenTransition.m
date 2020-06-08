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

    [containerView insertSubview:toView belowSubview:fromView];
    
    
    if ([self.player.parentView isKindOfClass:[UIImageView class]]) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            fromView.transform = CGAffineTransformIdentity;
            fromView.center = initialCenter;
            fromView.bounds = self.player.beforeBounds;
        } completion:^(BOOL finished) {
            [self.player.parentView addSubview:self.player];
            [fromView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }else{
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            fromView.transform = CGAffineTransformIdentity;
            fromView.center = initialCenter;
            fromView.bounds = self.player.beforeBounds;
        } completion:^(BOOL finished) {
            [self.player.parentView addSubview:self.player];
            [fromView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

@end


