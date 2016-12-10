//
//  CRCardAnimationView.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/7.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import "CRCardAnimationView.h"

typedef void (^UpdateCardsAnimationFinish_Block)();

@interface CRCardAnimationView ()
{
    UIPanGestureRecognizer  *_panGesture;
    PanDirection            panDir;
    
    NSMutableArray          *_cardDisplayArray;
    NSMutableArray          *_reuseArray;
    NSInteger               _cards_AllCount;            //card实际显示总数（和复用数量无关）
    NSInteger               _cardNextIndex_logic;       //card实际索引,willAppear（和复用数量无关）
    NSInteger               _cardNowIndex_logic;        //card实际索引，当前显示的（和复用数量无关）
    NSInteger               _cardLastIndex_logic;       //card实际索引，即将消失的（和复用数量无关）
    
    CGFloat                 cardView_width;
    CGFloat                 cardView_height;
    
    BOOL                    _initCreate;                //暂时修复layout的bug
    
    UpdateCardsAnimationFinish_Block _updateCardsAnimationFinish_Block;
}

@property (assign, nonatomic) int       cardIndex_show; //card显示索引
@property (strong, nonatomic) CRCardViewCell  *cardView_Now;

@end

@implementation CRCardAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //  默认参数配置
        _cardShowInView_Count       = 3;
        _animationDuration_Normal   = 0.2;
        _cardRotateWhenPan          = YES;
        _cardRotateMaxAngle         = 8.0;
        _cardAlphaGapValue          = 0.25;
        _cardOffSetPoint            = CGPointMake(0, 25);
        _cardScaleRatio             = 0.08;
        _cardFlyMaxDistance         = 40;
        _cardPanEnable              = YES;
        _initCreate                 = YES;
        
        cardView_width = WIDTH * 0.8;
        cardView_height = HEIGHT * 0.7;
        
        self.cardIndex_show = 0;
        panDir = kPanDir_Null;
        _reuseArray = [NSMutableArray new];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (_initCreate == YES) {
        
        [self createUI];
        _initCreate = NO;
    }
}


- (void)createUI
{
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture_Event:)];
    _cardDisplayArray = [[NSMutableArray alloc] init];
    _cardNextIndex_logic = 0;
    _cardNowIndex_logic = 0;
    _cardLastIndex_logic = 0;
    
    for (int i = 0 ; i < _cardShowInView_Count + 2; i++) {
        
        CRCardViewCell *cardView;
        if ([_delegate respondsToSelector:@selector(cardViewInCardAnimationView:Index:)]) {
            cardView = (CRCardViewCell *)[_delegate cardViewInCardAnimationView:self Index:i];
        }
        _cardNextIndex_logic = _cardShowInView_Count;
        
        if ([_delegate respondsToSelector:@selector(numberOfCardsInCardAnimationView:)]) {
            _cards_AllCount = [_delegate numberOfCardsInCardAnimationView:self];
        }
        //  初次创建全部放入_reuseArray
        [_reuseArray addObject:cardView];
        [_cardDisplayArray addObject:cardView];
        [self addSubview:cardView];
        
        if (i > 0) {
            [self insertSubview:cardView belowSubview:_cardDisplayArray[i - 1]];
        }else{
            [self addSubview:cardView];
        }
    }
    
    [self updateCardsWithAnimation:NO];
}

- (void)updateCardsWithAnimation:(BOOL)animation
{
    if (animation) {
        
        [UIView animateWithDuration:_animationDuration_Normal delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self updateCardsDetail];
        } completion:^(BOOL finished) {
            if (_updateCardsAnimationFinish_Block) {
                _updateCardsAnimationFinish_Block();
            }
        }];
    }else{
        [self updateCardsDetail];
    }
}



- (void)updateCardsDetail
{
    int cardAll_count           = (int)[_cardDisplayArray count];
    int cardWillDisappear_index = _cardIndex_show + cardAll_count - 1;
    int cardWillAppear_index    = _cardIndex_show + cardAll_count - 2;
    
    if (cardWillDisappear_index >= cardAll_count) {
        cardWillDisappear_index -= cardAll_count;
    }
    
    if (cardWillAppear_index >= cardAll_count) {
        cardWillAppear_index -= cardAll_count;
    }
    
    
    //  即将消失的cardView
    CRCardViewCell *cardView_willDisappear = _cardDisplayArray[cardWillDisappear_index];
    if (panDir == kPanDir_Left){
        [cardView_willDisappear setMaxX:0];
    }
    else if (panDir == kPanDir_Right) {
        [cardView_willDisappear setX:self.width];
    }
    
    if ([_delegate respondsToSelector:@selector(cardViewWillDisappearWithCardViewCell:Index:)]) {
        
        _cardLastIndex_logic = _cardNowIndex_logic - 1;
        
        if (!_cardCycleShow && _cardLastIndex_logic >= 0) {
            [_delegate cardViewWillDisappearWithCardViewCell:cardView_willDisappear Index:_cardLastIndex_logic];
        }
        else if (_cardCycleShow) {
            [_delegate cardViewWillDisappearWithCardViewCell:cardView_willDisappear Index:_cardLastIndex_logic >= 0 ? _cardLastIndex_logic : _cards_AllCount - 1];
        }
        
    }
    
    //  旧的即将显示的view
    CRCardViewCell *oldWillDisplayView = _cardDisplayArray[cardWillAppear_index];
    oldWillDisplayView.alpha = 0;
    if (_cardCycleShow == YES) {
        if (_cardNowIndex_logic >= _cards_AllCount) {
            _cardNowIndex_logic = 0;
        }
    }
    
    //  即将显示的cardView
    CRCardViewCell *cardView_willAppear;
    if (_cardNextIndex_logic < _cards_AllCount) {
        
        _cardDisplayArray[cardWillAppear_index] = [self getCardViewInCardAnimationView:self Index:(int)_cardNextIndex_logic++];
        cardView_willAppear = _cardDisplayArray[cardWillAppear_index];
        
        if (_cardCycleShow == YES) {
            if (_cardNextIndex_logic >= _cards_AllCount) {
                _cardNextIndex_logic = 0;
            }
        }
    }else{
        _cardDisplayArray[cardWillAppear_index] = [CRCardViewCell new];
    }
    cardView_willAppear.alpha = 1 - _cardShowInView_Count * _cardAlphaGapValue;
    [cardView_willAppear setCenter:CGPointMake(self.width / 2.0 - _cardOffSetPoint.x * _cardShowInView_Count, self.height / 2.0 - _cardOffSetPoint.y * _cardShowInView_Count)];
    
    
    //  动画执行完之后的处理，（设置为hidden=YES后，会影响复用机制，所以动画执行完后hidden=NO）
    cardView_willAppear.hidden = YES;

    _updateCardsAnimationFinish_Block = ^{
        cardView_willDisappear.alpha = 0;
        cardView_willAppear.alpha = 0;
        cardView_willDisappear.hidden = NO;
        cardView_willAppear.hidden = NO;
    };

    //  缩放动画
    cardView_willAppear.scaleAnimation.fromValue = cardView_willAppear.scaleAnimation.toValue;
    cardView_willAppear.scaleAnimation.toValue = [NSNumber numberWithFloat:1 - _cardShowInView_Count * _cardScaleRatio];
    cardView_willAppear.scaleAnimation.duration = _animationDuration_Normal;
    [cardView_willAppear.layer addAnimation:cardView_willAppear.scaleAnimation forKey:cardView_willAppear.scaleAnimation.keyPath];
    
    //  旋转复位
    cardView_willAppear.layer.anchorPoint = CGPointMake(0.5, 0.5);
    cardView_willAppear.rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    cardView_willAppear.rotationAnimation.toValue = [NSNumber numberWithFloat:0];
    [cardView_willAppear.layer addAnimation:cardView_willAppear.rotationAnimation forKey:cardView_willAppear.rotationAnimation.keyPath];
    
    
    //  中间可见的cardView
    for (int j = 0 ; j < _cardShowInView_Count; j++) {
        
        int i = j + _cardIndex_show;
        if (i >= cardAll_count) {
            i -= cardAll_count;
        }
        
        CRCardViewCell *cardView = _cardDisplayArray[i];
        cardView.hidden = NO;
        cardView.alpha = 1 - j * _cardAlphaGapValue;
        [cardView setCenter:CGPointMake(self.width / 2.0 - _cardOffSetPoint.x * j, self.height / 2.0 - _cardOffSetPoint.y * j)];

        //  缩放动画
        cardView.scaleAnimation.fromValue = cardView.scaleAnimation.toValue;
        cardView.scaleAnimation.toValue = [NSNumber numberWithFloat:1 - j * _cardScaleRatio];
        cardView.scaleAnimation.duration = _animationDuration_Normal;
        [cardView.layer addAnimation:cardView.scaleAnimation forKey:cardView.scaleAnimation.keyPath];
        
        //  手势移交
        if (j == 0) {
            [_panGesture.view removeGestureRecognizer:_panGesture];
            [cardView addGestureRecognizer:_panGesture];
        }
        
        //  即将显示的view插入在最后一个可见cardView的下方
        if (j == _cardShowInView_Count - 1) {
            [self insertSubview:cardView_willAppear belowSubview:cardView];
            
            
        }
        
        //  即将显示的最前方的cardView
        if (j == 0) {
            if ([_delegate respondsToSelector:@selector(cardViewWillShowInTopWithCardViewCell:Index:)]) {
                [_delegate cardViewWillShowInTopWithCardViewCell:cardView Index:_cardNowIndex_logic];
            }
        }

    }
    
    _cardNowIndex_logic++;
}


/**
 *
 *  lastPositionX:              上一次的X值
 *  lastView:                   上一次处理的view
 *
 *  leftThreshold_x:            手势阈值 绝对向左手势
 *  rightThreshold_x:           手势阈值 绝对向右手势
 *  position:                   手势在self中的坐标
 *  position_translationInSelf: 手势在self中的坐标(只要手势不抬起，就一直记录)
 *  rotationThreshold_degree:   旋转阈值，旋转角度超出该阈值后不再旋转，开始平移操作
 *  gestureView:                当前手势所在view
 */
- (void)panGesture_Event:(UIPanGestureRecognizer *)panGesture
{
    static CGFloat      lastPositionX = 0;
    static UIView       *lastView;
    
    CGFloat     leftThreshold_x             = self.width * (2.0 / 4);
    CGFloat     rightThreshold_x            = self.width * (2.0 / 4);
    CGPoint     position                    = [panGesture locationInView:self];
    CGPoint     position_translationInSelf  = [panGesture translationInView:self];
    CGFloat     rotationThreshold_degree    = 1.0 * _cardRotateMaxAngle / 180 * M_PI;
    CRCardViewCell    *gestureView                = (CRCardViewCell *)panGesture.view;
    
    //  禁止拖动模式，return
    if (_cardPanEnable == NO) {
        return;
    }
    
    //  没有历史数据，每次切换页面时，只存储历史值，然后return
    if (!lastView || ![lastView isEqual:gestureView]) {
        lastView = gestureView;
        lastPositionX = position.x;
        return;
    }

    //  计算旋转角度
    CGFloat tanA = position_translationInSelf.x / (cardView_height / 3.0);
    CGFloat rotation_degree = atan(tanA);
    
    //  cardViewCell偏移位置绝对值
    CGFloat cardViewABSOffX = position.x - self.width / 2.0;
    if (cardViewABSOffX < 0) {
        cardViewABSOffX = -cardViewABSOffX;
    }
    
    //  旋转
    BOOL res_rotation1 = (rotation_degree > 0 && rotation_degree < rotationThreshold_degree);
    BOOL res_rotation2 = (rotation_degree < 0 && -rotation_degree < rotationThreshold_degree);
    if (_cardRotateWhenPan == YES && (res_rotation1 || res_rotation2))
    {
        //  手势改变
        if (panGesture.state == UIGestureRecognizerStateChanged) {
            gestureView.layer.position = CGPointMake(self.width / 2.0, self.height / 2.0 + cardView_height / 2.0);
            gestureView.layer.anchorPoint = CGPointMake(0.5, 1);
            
            gestureView.rotationAnimation.fromValue = gestureView.rotationAnimation.toValue;
            gestureView.rotationAnimation.toValue = [NSNumber numberWithFloat:rotation_degree];
            [gestureView.layer addAnimation:gestureView.rotationAnimation forKey:gestureView.rotationAnimation.keyPath];
        }
        //  手势结束
        else if (panGesture.state == UIGestureRecognizerStateEnded){
            
            //  仍然有旋转角度
            if (gestureView.rotationAnimation.toValue != [NSNumber numberWithFloat:0]) {
                gestureView.rotationAnimation.fromValue = gestureView.rotationAnimation.toValue;
                gestureView.rotationAnimation.toValue = [NSNumber numberWithFloat:0];
                [gestureView.layer addAnimation:gestureView.rotationAnimation forKey:gestureView.rotationAnimation.keyPath];
            }
        }
    }
    
    //  平移没有超出阈值的情况
    else if (_cardRotateWhenPan == NO && cardViewABSOffX < _cardFlyMaxDistance)
    {
        //  手势改变
        if (panGesture.state == UIGestureRecognizerStateChanged) {
        
            [gestureView setX:gestureView.x + (position.x - lastPositionX)];
        }
        //  手势结束
        else if (panGesture.state == UIGestureRecognizerStateEnded){
            
            [UIView animateWithDuration:_animationDuration_Normal animations: ^(){
                [gestureView setCenterX:self.width / 2.0];
            }];
        }
        
    }
    
    //
    else{
        
        if (_cardRotateWhenPan == YES) {
            //  旋转最终角度校对
            BOOL res_1 = (gestureView.rotationAnimation.toValue != [NSNumber numberWithFloat:rotationThreshold_degree]);
            BOOL res_2 = (gestureView.rotationAnimation.toValue != [NSNumber numberWithFloat:-rotationThreshold_degree]);
            BOOL res_3 = (rotation_degree > 0);
            if ((res_3 && res_1) || (!res_3 && res_2)) {
                
                NSNumber *toValue = [NSNumber numberWithFloat:rotationThreshold_degree];
                if (res_3 && res_1) {
                    
                    toValue = [NSNumber numberWithFloat:rotationThreshold_degree];
                }else if (!res_3 && res_2){
                    toValue = [NSNumber numberWithFloat:-rotationThreshold_degree];
                }
                
                gestureView.layer.position = CGPointMake(gestureView.layer.position.x, self.height / 2.0 + cardView_height / 2.0);
                gestureView.layer.anchorPoint = CGPointMake(0.5, 1);
                
                gestureView.rotationAnimation.fromValue = gestureView.rotationAnimation.toValue;
                gestureView.rotationAnimation.toValue = toValue;
                [gestureView.layer addAnimation:gestureView.rotationAnimation forKey:gestureView.rotationAnimation.keyPath];
            }
        }
        
        
        //  和历史坐标比较，判断左滑
        if (lastPositionX > position.x) {
            panDir = kPanDir_Left;
        }
        //  和历史坐标比较，判断右滑
        else if (lastPositionX < position.x){
            panDir = kPanDir_Right;
        }
        
        
        //  绝对左滑
        if (position.x < leftThreshold_x) {
            panDir = kPanDir_Left;
        }
        //  绝对右滑
        else if (position.x > rightThreshold_x){
            panDir = kPanDir_Right;
        }
        
        
        //  判断手势
        switch (panGesture.state) {
            case UIGestureRecognizerStateChanged:
            {
                [gestureView setX:gestureView.x + (position.x - lastPositionX)];
            }
                break;
                
            case UIGestureRecognizerStateEnded:
            {
                
                switch (panDir) {
                    case kPanDir_Left:
                    {
                        [self disappearToLeft:panGesture];
                    }
                        break;
                        
                    case kPanDir_Right:
                    {
                        [self disappearToRight:panGesture];
                    }
                        break;
                        
                    case kPanDir_Null:
                    {
                        nil;
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            default:
                break;
        }
    }
    

    //  存储历史X值
    lastPositionX = position.x;
}

//  从左侧消失
- (void)disappearToLeft:(UIPanGestureRecognizer *)panGesture
{
    if (self.cardIndex_show + 2 > [_cardDisplayArray count]) {
        self.cardIndex_show = 0;
    }else{
        self.cardIndex_show = self.cardIndex_show + 1;
    }
}

//  从右侧消失
- (void)disappearToRight:(UIPanGestureRecognizer *)panGesture
{
    if (self.cardIndex_show + 2 > [_cardDisplayArray count]) {
        self.cardIndex_show = 0;
    }else{
        self.cardIndex_show = self.cardIndex_show + 1;
    }
}


#pragma mark - 重写cardIndex_show

@synthesize cardIndex_show = _cardIndex_show;
- (void)setCardIndex_show:(int)cardIndex_show
{
    _cardIndex_show = cardIndex_show;
    
    _cardView_Now = _cardDisplayArray[_cardIndex_show];
    [self updateCardsWithAnimation:YES];
}

#pragma mark - reuse
- (CRCardViewCell *)getCardViewInCardAnimationView:(CRCardAnimationView *)cardAnimationView Index:(int)index
{
    CRCardViewCell *cardView;
    
    if ([_delegate respondsToSelector:@selector(cardViewInCardAnimationView:Index:)]) {
        cardView = (CRCardViewCell *)[_delegate cardViewInCardAnimationView:self Index:index];
    }
    
    BOOL needAdd = YES;
    for (int i = 0; i < [_reuseArray count]; i++) {
        CRCardViewCell *tempCell = _reuseArray[i];
        if ([tempCell.reuseIdentifier isEqualToString:cardView.reuseIdentifier]) {
            needAdd = NO;
        }
    }
    
    if (needAdd == YES) {
        [_reuseArray addObject:cardView];
    }
    
    return cardView;
}

- (CRCardViewCell *)dequeueReusableCardViewCellWithIdentifier:(NSString *)CellIdentifier
{
    for (CRCardViewCell *cardViewCell in _reuseArray) {
        if (cardViewCell != nil && ![self isDisplayedInSelf:cardViewCell]) {
            return cardViewCell;
        }
    }
    
    return nil;
}

// 判断View是否显示在屏幕上
- (BOOL)isDisplayedInSelf:(UIView *)view
{
    if (view == nil) {
        return FALSE;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    // 转换view对应window的Rect
    CGRect rect = [view convertRect:view.frame fromView:self];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return FALSE;
    }
    
    // 若view 隐藏
    if (view.hidden) {
        return FALSE;
    }
    
    // 若没有superview
    if (view.superview == nil) {
        return FALSE;
    }
    
    // 若size为CGrectZero
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return  FALSE;
    }
    
    // 获取 该view与window 交叉的 Rect
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return FALSE;
    }
    
    return TRUE;
}

@end
