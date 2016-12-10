//
//  CRMusicCardDemoVC.m
//  CRAnimation
//
//  Created by Bear on 16/10/9.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "CRMusicCardDemoVC.h"
#import "CRCardAnimationView.h"
#import "CRMyCardView.h"
#import "CRImageGradientView.h"
#import "CRBottomPageView.h"

@interface CRMusicCardDemoVC () <CardAnimationViewDelegate, MyCardViewDelegate>
{
    NSArray             *_imageArray;
    NSArray             *_nameArray;
    NSArray             *_artistNameArray;
    NSArray             *_timeArray;
    NSArray             *_unitArray;
    
    CRImageGradientView   *_bgImageView;
    CRBottomPageView      *_bottomPageView;
    CRCardAnimationView   *_cardAnimationView;
}

@end

@implementation CRMusicCardDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    [self addTopBar];
}

- (void)createUI
{
    _imageArray = @[@"TestImage_1",
                    @"TestImage_2",
                    @"TestImage_3",
                    @"TestImage_4",
                    @"TestImage_5",
                    @"TestImage_6",
                    @"TestImage_7",
                    @"TestImage_8",
                    @"TestImage_9",
                    @"TestImage_10",
                    @"TestImage_11",
                    @"TestImage_12",
                    @"TestImage_13",
                    @"TestImage_14",
                    @"TestImage_15",
                    @"TestImage_16",
                    @"TestImage_17",
                    @"TestImage_18"];
    
    _nameArray = @[@"人型电脑天使心",
                   @"Bleach",
                   @"境界的彼方",
                   @"火影忍者疾风传",
                   @"火影忍者疾风传",
                   @"Bleach",
                   @"最终幻想",
                   @"境界的彼方",
                   @"人型电脑天使心",
                   @"境界的彼方",
                   @"最终幻想",
                   @"Bleach",
                   @"火影忍者疾风传",
                   @"火影忍者疾风传",
                   @"火影忍者疾风传",
                   @"火影忍者疾风传",
                   @"火影忍者疾风传",
                   @"火影忍者疾风传"];
    
    _artistNameArray = @[@"本须秀树",
                         @"黑崎一护",
                         @"神原秋人－栗山未来",
                         @"鸣人－佐助",
                         @"鼬",
                         @"黑崎一护",
                         @"克劳德·斯特莱夫",
                         @"栗山未来",
                         @"本须和秀树",
                         @"神原秋人－栗山未来",
                         @"克劳德·斯特莱夫",
                         @"乌尔奇奥拉·西法",
                         @"鸣人",
                         @"鸣人－佐助",
                         @"佐助",
                         @"鸣人",
                         @"鸣人",
                         @"鼬"];
    
    _timeArray = @[@"时长： 40:20",
                   @"时长： 34:10",
                   @"时长： 44:24",
                   @"时长： 10:34",
                   @"时长： 41:52",
                   @"时长： 14:42",
                   @"时长： 38:31",
                   @"时长： 36:14",
                   @"时长： 51:42",
                   @"时长： 26:15",
                   @"时长： 21:51",
                   @"时长： 14:43",
                   @"时长： 17:57",
                   @"时长： 43:14",
                   @"时长： 15:22",
                   @"时长： 41:50",
                   @"时长： 12:20",
                   @"时长： 30:14"];
    
    _unitArray = @[@"BiliBala",
                   @"动漫小分队",
                   @"动漫Action",
                   @"漫漫来",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action",
                   @"动漫Action"];
    
    
    
    _cardAnimationView = [[CRCardAnimationView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    _cardAnimationView.delegate = self;
    _cardAnimationView.backgroundColor = [UIColor clearColor];
    _cardAnimationView.cardShowInView_Count = 3;
    //    cardAnimationView.animationDuration_Normal = 0.7;
    //    cardAnimationView.animationDuration_Flip = 1.0;
    //    cardAnimationView.cardRotateWhenPan = NO;
    //    cardAnimationView.cardRotateMaxAngle = 45;
    //    cardAnimationView.cardAlphaGapValue = 0.1;
    _cardAnimationView.cardOffSetPoint = CGPointMake(0, 30);
    _cardAnimationView.cardScaleRatio  = 0.09;
    //    cardAnimationView.cardFlyMaxDistance = 80;
    _cardAnimationView.cardCycleShow = YES;
    //    cardAnimationView.cardPanEnable = NO;
    [self.view addSubview:_cardAnimationView];
    
    //  虚化背景
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.alpha = 0.8;
    visualEffectView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    visualEffectView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view insertSubview:visualEffectView belowSubview:_cardAnimationView];
    
    //  图片切换view
    _bgImageView = [[CRImageGradientView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    _bgImageView.animationDuration_EX = 1.3;
    [self.view insertSubview:_bgImageView belowSubview:visualEffectView];
    
    _bottomPageView = [[CRBottomPageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    _bottomPageView.pageAll = [_imageArray count];
    _bottomPageView.pageNow = 0;
    [self.view insertSubview:_bottomPageView belowSubview:_cardAnimationView];
    [_bottomPageView setMaxY:HEIGHT - 30];
}


#pragma mark - CardAnimationView delegate
- (CRCardViewCell *)cardViewInCardAnimationView:(CRCardAnimationView *)cardAnimationView Index:(int)index
{
    CGFloat cardView_width = (1.0 * 540 / 640) * WIDTH;
    CGFloat cardView_height = (1.0 * 811 / 1134) * HEIGHT;
    NSString *cardViewID_Str = @"cardViewID_Str";
    
    CRMyCardView *cardView = (CRMyCardView *)[cardAnimationView dequeueReusableCardViewCellWithIdentifier:cardViewID_Str];
    if (!cardView) {
        cardView = [[CRMyCardView alloc] initWithFrame:CGRectMake(0, 0, cardView_width, cardView_height) reuseIdentifier:cardViewID_Str];
    }
    
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.cardViewFront.headImgV.image = [UIImage imageNamed:_imageArray[index]];
    cardView.cardViewFront.mainLabel.text = _nameArray[index];
    cardView.cardViewFront.assignLabel_1.text = _artistNameArray[index];
    cardView.cardViewFront.assignLabel_2.text = _timeArray[index];
    cardView.cardViewFront.unitLabel.text = _unitArray[index];
    cardView.delegate = self;
    
    return cardView;
}

- (NSInteger)numberOfCardsInCardAnimationView:(CRCardAnimationView *)cardAnimationView
{
    return [_imageArray count];
}

- (void)cardViewWillShowInTopWithCardViewCell:(CRCardViewCell *)cardViewCell Index:(NSInteger)index
{
    NSLog(@"will show index:%ld", (long)index);
    _bgImageView.nextImageName = _imageArray[index];
    _bottomPageView.pageNow = index + 1;
    //    _bgImageView.image = [UIImage imageNamed:_imageArray[index]];
    
    CRMyCardView *cardView = (CRMyCardView *)cardViewCell;
    cardView.tapEnable = YES;
}

- (void)cardViewWillDisappearWithCardViewCell:(CRCardViewCell *)cardViewCell Index:(NSInteger)index
{
    NSLog(@"will disappear index:%ld", (long)index);
    CRMyCardView *cardView = (CRMyCardView *)cardViewCell;
    cardView.tapEnable = NO;
}

#pragma mark - MyCardView delegate

- (void)myCardViewFlipAnimationDoing:(CRMyCardView *)cardView
{
    _cardAnimationView.cardPanEnable = NO;
}

- (void)myCardViewFlipAnimationFinished:(CRMyCardView *)cardView
{
    if (cardView.cardStatus == kCardStatus_Front) {
        _cardAnimationView.cardPanEnable = YES;
    }else{
        _cardAnimationView.cardPanEnable = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
