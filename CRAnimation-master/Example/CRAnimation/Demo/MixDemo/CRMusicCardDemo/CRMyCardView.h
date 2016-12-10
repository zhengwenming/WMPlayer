//
//  CRMyCardView.h
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/31.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import "CRCardViewCell.h"
#import "CRCardViewBack.h"
#import "CRCardViewFront.h"
@class CRMyCardView;

typedef enum {
    kCardStatus_Front,
    kCardStatus_Back,
}CardStatus;

@protocol MyCardViewDelegate <NSObject>

- (void)myCardViewFlipAnimationDoing:(CRMyCardView *)cardView;
- (void)myCardViewFlipAnimationFinished:(CRMyCardView *)cardView;

@end

@interface CRMyCardView : CRCardViewCell

@property (assign, nonatomic) CGFloat   animationDuration_Flip;     //翻转动画时间

@property (strong, nonatomic)   CRCardViewBack  *cardViewBack;
@property (strong, nonatomic)   CRCardViewFront *cardViewFront;
@property (assign, nonatomic)   CardStatus      cardStatus;
@property (weak, nonatomic)     id<MyCardViewDelegate> delegate;
@property (assign, nonatomic)   BOOL            tapEnable;

@end
