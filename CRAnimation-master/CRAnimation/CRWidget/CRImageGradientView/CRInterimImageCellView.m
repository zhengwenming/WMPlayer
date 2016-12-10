//
//  CRInterimImageCellView.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/10/2.
//  Copyright © 2016年 Bear. All rights reserved.
//

typedef enum {
    kAnimaiton_Hidding,
    kAnimation_Showing,
    kAnimation_Finished,
}AnimationStatus;

static NSString *__kAnimationKeyOpacity     = @"__kAnimationKeyOpacity";

#import "CRInterimImageCellView.h"

@interface CRInterimImageCellView () <CAAnimationDelegate>

@property (strong, nonatomic) CABasicAnimation  *opacityAnimation;
@property (assign, nonatomic) AnimationStatus   animationStatus;

@end

@implementation CRInterimImageCellView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        __weak typeof(self) weakSelf = self;
        
        _animationDuration_EX   = 0.3;
        self.animationFinished  = YES;
        self.animationStatus    = kAnimation_Finished;
        self.contentMode        = UIViewContentModeScaleAspectFill;
        
        _opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        _opacityAnimation.fillMode = kCAFillModeForwards;
        _opacityAnimation.removedOnCompletion = NO;
        _opacityAnimation.delegate = weakSelf;
        
    }
    
    return self;
}

- (void)opacityAnimationShowWithImage:(UIImage *)image animation:(BOOL)aniamtion
{
    if (image) {
        self.image = image;
    }
    
    [self opacityAnimationShow:aniamtion];
}

- (void)opacityAnimationHideWithImage:(UIImage *)image animation:(BOOL)aniamtion
{
    if (image) {
        self.image = image;
    }
    
    [self opacityAnimationHide:aniamtion];
}


- (void)opacityAnimationShow:(BOOL)aniamtion
{
    if (aniamtion) {
        _opacityAnimation.fromValue     = [NSNumber numberWithFloat:0];
        _opacityAnimation.toValue       = [NSNumber numberWithFloat:1];
        _opacityAnimation.duration      = _animationDuration_EX;
        [self.layer addAnimation:_opacityAnimation forKey:__kAnimationKeyOpacity];
        self.animationStatus = kAnimation_Showing;
    }
}

- (void)opacityAnimationHide:(BOOL)aniamtion
{
    if (aniamtion) {
        
        //  显示动画仍在进行，中途改变动画
        if (self.animationStatus == kAnimation_Showing) {
            CALayer *presentLayer = [self.layer presentationLayer];
            _opacityAnimation.fromValue     = [NSNumber numberWithFloat:presentLayer.opacity];
            if (self.opacityShowFinish_Block) {
                self.opacityShowFinish_Block();
            }
        }
        else{
            _opacityAnimation.fromValue     = [NSNumber numberWithFloat:1];
        }
        
        _opacityAnimation.toValue       = [NSNumber numberWithFloat:0];
        _opacityAnimation.duration      = _animationDuration_EX;
        [self.layer addAnimation:_opacityAnimation forKey:__kAnimationKeyOpacity];
        self.animationStatus = kAnimaiton_Hidding;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([self.layer animationForKey:__kAnimationKeyOpacity] == anim) {
        
        switch (_animationStatus) {
                
            case kAnimation_Showing:
            {
                self.animationStatus = kAnimation_Finished;
                if (self.opacityShowFinish_Block) {
                    self.opacityShowFinish_Block();
                }
            }
                break;
                
            case kAnimaiton_Hidding:
            {
                self.animationStatus = kAnimation_Finished;
                if (self.opacityHideFinish_Block) {
                    self.opacityHideFinish_Block();
                }
            }
                break;
                
            default:
                break;
        }
        
    }
}

@end
