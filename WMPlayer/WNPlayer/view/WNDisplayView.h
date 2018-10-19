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
@property (nonatomic,assign) CGSize contentSize;
@property (nonatomic,assign) CGFloat rotation;
@property (nonatomic,assign) BOOL isYUV;
@property (nonatomic,assign) BOOL keepLastFrame;

- (void)render:(WNPlayerVideoFrame *)frame;
- (void)clear;
@end

