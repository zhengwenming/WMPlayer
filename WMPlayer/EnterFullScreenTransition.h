//
//  EnterFullScreenTransition.h
//  PlayerDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WMPlayer.h"
NS_ASSUME_NONNULL_BEGIN

@interface EnterFullScreenTransition : NSObject<UIViewControllerAnimatedTransitioning>
- (instancetype)initWithPlayer:(WMPlayer *)wmplayer;
@end

NS_ASSUME_NONNULL_END
