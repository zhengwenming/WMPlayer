//
//  CRCardViewFront.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/31.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import "CRCardViewFront.h"

#define color_blue      UIColorFromHEX(0x4cb9f3)
#define color_545556    UIColorFromHEX(0x545556)
#define color_898d90    UIColorFromHEX(0x898d90)
#define color_edeeef    UIColorFromHEX(0xedeeef)
#define color_f1f2f3    UIColorFromHEX(0xf1f2f3)
#define color_e2e3e4    UIColorFromHEX(0xe2e3e4)
#define color_313233    UIColorFromHEX(0x313233)
#define color_999a9b    UIColorFromHEX(0x999a9b)


@implementation CRCardViewFront

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = color_edeeef;
        [self createUI];
    }
    
    return self;
}

- (void)createUI
{
    //  components
    
    
    //  --> top unit
    
    _unitIndicatorPoint = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 9, 9)];
    _unitIndicatorPoint.layer.cornerRadius = _unitIndicatorPoint.width / 2.0;
    _unitIndicatorPoint.layer.masksToBounds = YES;
    _unitIndicatorPoint.backgroundColor = color_blue;
    [self addSubview:_unitIndicatorPoint];
    
    _unitLabel = [[UILabel alloc] init];
    _unitLabel.font = [UIFont systemFontOfSize:13];
    _unitLabel.textColor = color_545556;
    [self addSubview:_unitLabel];
    
    
    
    //  --> _headImage
    
    _headImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
    _headImgV.layer.cornerRadius = _headImgV.height / 2.0;
    _headImgV.layer.masksToBounds = YES;
    _headImgV.contentMode = UIViewContentModeScaleAspectFill;
    _headImgV.backgroundColor = [UIColor blueColor];
    [self addSubview:_headImgV];
    
    _holeView_big = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _holeView_big.layer.cornerRadius = _holeView_big.width / 2.0;
    _holeView_big.layer.masksToBounds = YES;
    _holeView_big.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [_headImgV addSubview:_holeView_big];
    [_holeView_big BearSetCenterToParentViewWithAxis:kAXIS_X_Y];
    
    _holeView_small = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 9, 9)];
    _holeView_small.layer.cornerRadius = _holeView_small.width / 2.0;
    _holeView_small.layer.masksToBounds = YES;
    _holeView_small.backgroundColor = color_898d90;
    [_holeView_big addSubview:_holeView_small];
    [_holeView_small BearSetCenterToParentViewWithAxis:kAXIS_X_Y];
    
    
    _middleView = [[UIView alloc] init];
    [self addSubview:_middleView];
    
    _mainLabel = [[UILabel alloc] init];
    _mainLabel.font = [UIFont systemFontOfSize:16];
    _mainLabel.textColor = color_313233;
    [_middleView addSubview:_mainLabel];
    
    _assignLabel_1 = [[UILabel alloc] init];
    _assignLabel_1.font = [UIFont systemFontOfSize:16];
    _assignLabel_1.textColor = color_313233;
    [_middleView addSubview:_assignLabel_1];
    
    _assignLabel_2 = [[UILabel alloc] init];
    _assignLabel_2.font = [UIFont systemFontOfSize:14];
    _assignLabel_2.textColor = color_999a9b;
    [_middleView addSubview:_assignLabel_2];
    
    
    
    //  --> bottomMenuView
    
    CGFloat btn_width   = 40;
    CGFloat btn_height  = 40;
    CGFloat gap_width   = (1.0 * 100 / 540) * self.width;
    
    _bottomMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 50, self.width, 50)];
    _bottomMenuView.backgroundColor = color_f1f2f3;
    [self addSubview:_bottomMenuView];
    
    UIView *sepLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomMenuView.width, 1)];
    sepLineView.backgroundColor = color_e2e3e4;
    [_bottomMenuView addSubview:sepLineView];
    
    NSMutableArray *subViewArray = [NSMutableArray new];
    
    _collectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btn_width, btn_height)];
    [_collectBtn setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
    [_collectBtn setImage:[UIImage imageNamed:@"icon_like_hover"] forState:UIControlStateSelected];
    [_bottomMenuView addSubview:_collectBtn];
    [subViewArray addObject:_collectBtn];
    
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btn_width, btn_height)];
    [_playBtn setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateSelected];
    [_bottomMenuView addSubview:_playBtn];
    [subViewArray addObject:_playBtn];
    
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btn_width, btn_height)];
    [_shareBtn setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [_bottomMenuView addSubview:_shareBtn];
    [subViewArray addObject:_shareBtn];
    
    [UIView BearAutoLayViewArray:subViewArray layoutAxis:kLAYOUT_AXIS_X center:YES gapDistance:gap_width];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_unitLabel sizeToFit];
    [_unitLabel BearSetRelativeLayoutWithDirection:kDIR_RIGHT destinationView:_unitIndicatorPoint parentRelation:NO distance:4 center:YES];
    
    [_headImgV BearSetRelativeLayoutWithDirection:kDIR_UP destinationView:nil parentRelation:YES distance:50 center:YES];
    
    _middleView.frame = CGRectMake(0, _headImgV.maxY, self.width, self.height - 50 - _headImgV.maxY);
    [_mainLabel sizeToFit];
    [_assignLabel_1 sizeToFit];
    [_assignLabel_2 sizeToFit];
    [UIView BearAutoLayViewArray:(NSMutableArray *)_middleView.subviews layoutAxis:kLAYOUT_AXIS_Y center:YES gapDistance:15];
}

@end
