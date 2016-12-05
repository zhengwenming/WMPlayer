//
//  WMLightView.h
//  WMPlayer
//
//  Created by 郑文明 on 16/10/26.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMLightView : UIView
@property (strong, nonatomic)  UIView *lightBackView;
@property (strong, nonatomic)  UIImageView *centerLightIV;

@property (nonatomic, strong) NSMutableArray * lightViewArr;

+ (instancetype)sharedLightView;
@end
