//
//  DetailViewController.h
//  WMVideoPlayer
//
//  Created by 郑文明 on 16/2/1.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WMPlayer.h"

@interface DetailViewController : BaseViewController
@property (nonatomic, retain)WMPlayerModel *playerModel;
@property (nonatomic, strong)WMPlayer  *wmPlayer;
@end
