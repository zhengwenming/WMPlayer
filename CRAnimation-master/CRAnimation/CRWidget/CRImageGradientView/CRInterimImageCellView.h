//
//  CRInterimImageCellView.h
//  MusicWidgetAnimation
//
//  Created by Bear on 16/10/2.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OpacityShowFinish_Block)();
typedef void(^OpacityHideFinish_Block)();

@interface CRInterimImageCellView : UIImageView

@property (assign, nonatomic) CGFloat   animationDuration_EX;
@property (assign, nonatomic) BOOL      animationFinished;

@property (copy, nonatomic) OpacityShowFinish_Block opacityShowFinish_Block;
@property (copy, nonatomic) OpacityHideFinish_Block opacityHideFinish_Block;

- (void)opacityAnimationShowWithImage:(UIImage *)image animation:(BOOL)aniamtion;
- (void)opacityAnimationHideWithImage:(UIImage *)image animation:(BOOL)aniamtion;

@end
