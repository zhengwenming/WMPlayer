//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WNPlayerManager.h"

typedef enum : NSUInteger {
    WNPlayerStatusNone,
    WNPlayerStatusOpening,
    WNPlayerStatusOpened,
    WNPlayerStatusPlaying,
    WNPlayerStatusBuffering,
    WNPlayerStatusPaused,
    WNPlayerStatusEOF,
    WNPlayerStatusClosing,
    WNPlayerStatusClosed,
} WNPlayerStatus;



NS_ASSUME_NONNULL_BEGIN

@interface WNPlayer : UIView
@property (nonatomic, copy) NSString *url;
@property (nonatomic) BOOL autoplay;
@property (nonatomic) BOOL repeat;
@property (nonatomic) BOOL preventFromScreenLock;
@property (nonatomic) BOOL restorePlayAfterAppEnterForeground;
@property (nonatomic, readonly) WNPlayerStatus status;

- (void)open;
- (void)close;
- (void)play;
- (void)pause;
@end

NS_ASSUME_NONNULL_END
