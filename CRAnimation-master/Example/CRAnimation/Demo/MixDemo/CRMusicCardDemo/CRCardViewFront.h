//
//  CRCardViewFront.h
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/31.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRCardViewFront : UIView

@property (strong, nonatomic) UIView        *unitIndicatorPoint;
@property (strong, nonatomic) UILabel       *unitLabel;

@property (strong, nonatomic) UIImageView   *headImgV;
@property (strong, nonatomic) UIView        *holeView_big;
@property (strong, nonatomic) UIView        *holeView_small;

@property (strong, nonatomic) UIView        *middleView;
@property (strong, nonatomic) UILabel       *mainLabel;
@property (strong, nonatomic) UILabel       *assignLabel_1;
@property (strong, nonatomic) UILabel       *assignLabel_2;

@property (strong, nonatomic) UIView        *bottomMenuView;
@property (strong, nonatomic) UIButton      *collectBtn;
@property (strong, nonatomic) UIButton      *playBtn;
@property (strong, nonatomic) UIButton      *shareBtn;

@end
