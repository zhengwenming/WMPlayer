//
//  WNPlayerDetailViewController.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/16.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMPlayerModel.h"
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNPlayerDetailViewController : BaseViewController
@property (nonatomic, retain)WMPlayerModel *playerModel;

@end

NS_ASSUME_NONNULL_END
