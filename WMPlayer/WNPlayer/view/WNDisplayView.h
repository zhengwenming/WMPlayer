//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WNPlayerVideoFrame;



@interface WNDisplayView : UIView
@property (nonatomic) CGSize contentSize;
@property (nonatomic) CGFloat rotation;
@property (nonatomic) BOOL isYUV;
@property (nonatomic) BOOL keepLastFrame;

- (void)render:(WNPlayerVideoFrame *)frame;
- (void)clear;
@end

