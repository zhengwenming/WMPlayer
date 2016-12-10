//
//  CRMyCardView.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/31.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import "CRMyCardView.h"
#import "CRCardViewBack.h"
#import "CRCardViewFront.h"


@implementation CRMyCardView
{
    UITapGestureRecognizer  *_tapGesture;
    CGFloat                 cardView_width;
    CGFloat                 cardView_height;
}

- (instancetype)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture_Event:)];
        _tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_tapGesture];
        
        cardView_width          = self.width;
        cardView_height         = self.height;
        _animationDuration_Flip = 0.8;
        self.tapEnable          = NO;
        
        [self createUI];
    }
    
    return self;
}

- (void)createUI
{
    self.cardStatus = kCardStatus_Front;
    
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    
    _cardViewBack = [[CRCardViewBack alloc] initWithFrame:self.frame];
    [self addSubview:_cardViewBack];
    
    _cardViewFront = [[CRCardViewFront alloc] initWithFrame:self.frame];
    [self addSubview:_cardViewFront];
}

#pragma mark - Gesture

- (void)tapGesture_Event:(UITapGestureRecognizer *)tapGesture
{
    CRMyCardView *cardView = (CRMyCardView *)tapGesture.view;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:_animationDuration_Flip];
    
    NSUInteger index_back = [cardView.subviews indexOfObject:cardView.cardViewBack];
    NSUInteger index_front = [cardView.subviews indexOfObject:cardView.cardViewFront];
    
    
    //  翻转后，back模式
    if (index_back < index_front) {
        
        cardView.cardStatus = kCardStatus_Back;
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:cardView cache:YES];
        
        [self setBigSize:cardView];
        [self setBigSize:(UIView *)cardView.cardViewBack];
    }
    //  翻转后，front模式
    else{
        
        cardView.cardStatus = kCardStatus_Front;
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cardView cache:YES];
        
        [self setSmallSize:cardView];
        [self setSmallSize:(UIView *)cardView.cardViewBack];
    }
    
    [cardView exchangeSubviewAtIndex:index_back withSubviewAtIndex:index_front];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationWillStartSelector:@selector(flipAnimationWillStart_Event)];
    [UIView setAnimationDidStopSelector:@selector(flipAnimationDidStop_Event)];
    [UIView commitAnimations];
}

- (void)flipAnimationWillStart_Event
{
    if ([_delegate respondsToSelector:@selector(myCardViewFlipAnimationDoing:)]) {
        [_delegate myCardViewFlipAnimationDoing:self];
    }
}

- (void)flipAnimationDidStop_Event
{
    if ([_delegate respondsToSelector:@selector(myCardViewFlipAnimationFinished:)]) {
        [_delegate myCardViewFlipAnimationFinished:self];
    }
}

- (void)setBigSize:(UIView *)view
{
    [view setWidth_DonotMoveCenter:WIDTH];
    [view setHeight_DonotMoveCenter:HEIGHT];
}

- (void)setSmallSize:(UIView *)view
{
    [view setWidth_DonotMoveCenter:cardView_width];
    [view setHeight_DonotMoveCenter:cardView_height];
}


#pragma mark - rewrite

- (void)setTapEnable:(BOOL)tapEnable
{
    _tapEnable = tapEnable;
    
    _tapGesture.enabled = tapEnable;
}

@end
