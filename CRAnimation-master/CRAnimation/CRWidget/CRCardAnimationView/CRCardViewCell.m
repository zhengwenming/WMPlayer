//
//  CRCardViewCell.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/28.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import "CRCardViewCell.h"

@implementation CRCardViewCell

- (instancetype)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        
        //  缩放动画
        _scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        _scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        _scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
        _scaleAnimation.fillMode = kCAFillModeForwards;
        _scaleAnimation.removedOnCompletion = NO;
        _scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        //  旋转动画
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
        _rotationAnimation.toValue = [NSNumber numberWithFloat:0];
        _rotationAnimation.fillMode = kCAFillModeForwards;
        _rotationAnimation.removedOnCompletion = NO;
        _rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        //  翻转动画
        _flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        _flipAnimation.fromValue = [NSNumber numberWithFloat:0];
        _flipAnimation.toValue = [NSNumber numberWithFloat:M_PI];
        _flipAnimation.fillMode = kCAFillModeForwards;
        _flipAnimation.removedOnCompletion = NO;
        _flipAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    
    return self;
}

@end
