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
    [containerView insertSubview:toView belowSubview:fromView];
    
    CGFloat width = containerView.frame.size.width;
    CGFloat height = width * (9 / 16.0f);
    
    if ([self.player.parentView isKindOfClass:[UIImageView class]]) {
        [self.player.parentView addSubview:self.player];
        [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.player.superview);
        }];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            fromView.transform = CGAffineTransformIdentity;
            fromView.center = [containerView convertPoint:self.player.beforeCenter fromView:nil];
            fromView.bounds = self.player.beforeBounds;
        } completion:^(BOOL finished) {
            [fromView removeFromSuperview];
             [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
                               make.edges.mas_equalTo(self.player.superview);
                           }];
              [transitionContext completeTransition:YES];
        }];
    }else{
        [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.player.superview);
            make.height.equalTo(@(height));
            make.center.equalTo(self.player.superview).centerOffset(CGPointMake(-(containerView.frame.size.height - height) / 2.0+([WMPlayer IsiPhoneX]?34:0), 0));
        }];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            fromView.transform = CGAffineTransformIdentity;
            fromView.center = [containerView convertPoint:self.player.beforeCenter fromView:nil];
            fromView.bounds = self.player.beforeBounds;
        } completion:^(BOOL finished) {
            [self.player.parentView addSubview:self.player];
            [fromView removeFromSuperview];
             [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(self.player.superview);
                    make.top.equalTo(@([WMPlayer IsiPhoneX]?34:0));
                    make.height.mas_equalTo(@(containerView.frame.size.width * (9 / 16.0f)));
            }];
              [transitionContext completeTransition:YES];
        }];
    }
}

@end


