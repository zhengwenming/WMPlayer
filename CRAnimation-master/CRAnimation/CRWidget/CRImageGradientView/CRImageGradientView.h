//
//  CRImageGradientView.h
//  MusicWidgetAnimation
//
//  Created by Bear on 16/6/3.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRImageGradientView : UIView

@property (assign, nonatomic) CGFloat   animationDuration_EX;   //切换动效所需时间
@property (strong, nonatomic) NSString  *nextImageName;         //下一张图片名称

@end
