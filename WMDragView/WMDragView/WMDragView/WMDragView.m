//
//  WMDragView.m
//  DragButtonDemo
//
//  Created by zhengwenming on 2016/12/16.
//
//

#import "WMDragView.h"

@interface WMDragView ()
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,assign) CGPoint startFramePoint;
@property (nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation WMDragView
/**
 WMDragView内部的一个控件imageView
 默认充满父视图
 @return 懒加载这个imageView
 */
-(UIImageView *)imageView{
    if (_imageView==nil) {
        _imageView = [[UIImageView alloc]init];
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
        _imageView.frame = (CGRect){CGPointZero,self.bounds.size};
        [self.contentViewForDrag addSubview:_imageView];
    }
    return _imageView;
}
/**
 WMDragView内部的一个控件button
 默认充满父视图
 @return 懒加载这个imageView
 */
-(UIButton *)button{
    if (_button==nil) {
        _button = [[UIButton alloc]init];
        _button.clipsToBounds = YES;
        _button.enabled = NO;
        _button.frame = (CGRect){CGPointZero,self.bounds.size};
        [self.contentViewForDrag addSubview:_button];
    }
    return _button;
}

-(UIView *)contentViewForDrag{
    if (_contentViewForDrag==nil) {
        _contentViewForDrag = [[UIView alloc]init];
        _contentViewForDrag.clipsToBounds = YES;
        _contentViewForDrag.frame = (CGRect){CGPointZero,self.bounds.size};
        [self addSubview:self.contentViewForDrag];
    }
    return _contentViewForDrag;
}

///代码初始化
- (instancetype)init{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}
///从xib中加载
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setUp];
}
-(void)layoutSubviews{
    if (self.freeRect.origin.x!=0||self.freeRect.origin.y!=0||self.freeRect.size.height!=0||self.freeRect.size.width!=0) {
        //设置了freeRect--活动范围
    }else{
        //没有设置freeRect--活动范围，则设置默认的活动范围为父视图的frame
        self.freeRect = (CGRect){CGPointZero,self.superview.bounds.size};
    }
}
-(void)setUp{
    self.dragEnable = YES;//默认可以拖曳
    self.clipsToBounds = YES;
    self.isKeepBounds = NO;
    self.backgroundColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDragView)];
    [self addGestureRecognizer:singleTap];
    
    
    //添加移动手势可以拖动
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    _panGestureRecognizer.minimumNumberOfTouches = 1;
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_panGestureRecognizer];
    
}

/**
 拖动事件
 @param pan 拖动手势
 */
-(void)dragAction:(UIPanGestureRecognizer *)pan{
    //先判断可不可以拖动，如果不可以拖动，直接返回，不操作
    if (self.dragEnable==NO) {
        return;
    }
    switch (pan.state) {
            ///开始拖动
        case UIGestureRecognizerStateBegan:{
            
            if (self.BeginDragBlock) {
                self.BeginDragBlock(self);
            }
            //  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointMake(0, 0) inView:self];
            //保存触摸起始点位置
            self.startPoint = [pan translationInView:self];
            //该view置于最前
            [[self superview] bringSubviewToFront:self];
            break;
        }
            ///拖动中
        case UIGestureRecognizerStateChanged:
        {
           
            //计算位移=当前位置-起始位置
            if (self.DuringDragBlock) {
                self.DuringDragBlock(self);
            }
            CGPoint point = [pan translationInView:self];
            float dx;
            float dy;
            
            switch (self.dragDirection) {
                case WMDragDirectionAny:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
                case WMDragDirectionHorizontal:
                    dx = point.x - self.startPoint.x;
                    dy = 0;
                    break;
                case WMDragDirectionVertical:
                    dx = 0;
                    dy = point.y - self.startPoint.y;
                    break;
                default:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
            }
            
            //计算移动后的view中心点
            CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            /* 限制用户不可将视图托出给定的范围 */
//            float halfx = CGRectGetMidX(self.bounds);
        
//                        newcenter.x = MAX(halfx + self.freeRect.origin.x , newcenter.x);
//            x坐标右边界
//                        newcenter.x = MIN(self.freeRect.size.width+self.freeRect.origin.x - halfx, newcenter.x);
            
            
//            if (self.isKeepBounds) {
//                //y坐标同理
//                            float halfy = CGRectGetMidY(self.bounds);
//                //y的上面进行限制
//                            newcenter.y = MAX(halfy + self.freeRect.origin.y, newcenter.y);
//                //y的下面进行限制
//                            newcenter.y = MIN(self.freeRect.size.height+self.freeRect.origin.y - halfy, newcenter.y);
//            }
           
            
            //移动view
            self.center = newcenter;
            //  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointMake(0, 0) inView:self];
            break;
        }
            ///拖动结束
        case UIGestureRecognizerStateEnded:
        {
            [self keepBounds];
            
            if (self.EndDragBlock) {
                self.EndDragBlock(self);
            }

            break;
        }
        default:
            break;
    }
   
}
///点击事件
-(void)clickDragView{
    if (self.ClickDragViewBlock) {
        self.ClickDragViewBlock(self);
    }
}
- (void)keepBounds
{
    //中心点判断
    float centerX = self.freeRect.origin.x+(self.freeRect.size.width - self.frame.size.width)/2;

    CGRect rect = self.frame;

    if (self.isKeepBounds==NO) {//没有黏贴边界的效果
        if (self.frame.origin.x < self.freeRect.origin.x) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            [self setFrame:rect];
            [UIView commitAnimations];
        } else if(self.freeRect.origin.x+self.freeRect.size.width < self.frame.origin.x+self.frame.size.width){
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x+self.freeRect.size.width-self.frame.size.width;
            [self setFrame:rect];
            [UIView commitAnimations];
        }
    }else if(self.isKeepBounds==YES){//自动粘边
        if (self.frame.origin.x< centerX) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            [self setFrame:rect];
            [UIView commitAnimations];
        } else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x =self.freeRect.origin.x+self.freeRect.size.width - self.frame.size.width;
            [self setFrame:rect];
            [UIView commitAnimations];
        }
    }
    
    if (self.frame.origin.y < self.freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y;
        [self setFrame:rect];
        [UIView commitAnimations];
    } else if(self.freeRect.origin.y+self.freeRect.size.height< self.frame.origin.y+self.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y+self.freeRect.size.height-self.frame.size.height;
        [self setFrame:rect];
        [UIView commitAnimations];
    }
   }
@end
