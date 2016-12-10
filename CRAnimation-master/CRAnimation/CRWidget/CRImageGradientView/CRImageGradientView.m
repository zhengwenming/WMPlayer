//
//  CRImageGradientView.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/6/3.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import "CRImageGradientView.h"
#import "CRInterimImageCellView.h"

@interface CRImageGradientView ()

@property (strong, nonatomic) NSString          *nowImageName;
@property (strong, nonatomic) UIView            *interimImageBgView;
@property (strong, nonatomic) NSMutableArray    *imageViewsArray;   //复用队列数组
@property (assign, nonatomic) NSInteger         imageViewsIndexNow; //复用队列中计数器，从0开始计数
@property (assign, nonatomic) NSInteger         imageViewsMaxNum;   //复用队列数量上限


@end

@implementation CRImageGradientView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _animationDuration_EX = 0.3;
        
        _imageViewsArray = [NSMutableArray new];
        _imageViewsIndexNow = -1;
        _imageViewsMaxNum = 5;
        
        _interimImageBgView = [[UIView alloc] initWithFrame:self.bounds];
        _interimImageBgView.clipsToBounds = YES;
        [self addSubview:_interimImageBgView];
    }
    
    return self;
}

@synthesize nextImageName = _nextImageName;
- (void)setNextImageName:(NSString *)nextImageName
{
    _nextImageName = nextImageName;
    
    [self insertImage:nextImageName];
    [self hideFormerImage];
}

- (void)insertImage:(NSString *)imgName
{
    __weak typeof(self) weakSelf = self;
    
    void (^insertNewBlock)(BOOL aniamtion) = ^(BOOL aniamtion){
        
        CRInterimImageCellView *interimImageCellView = [[CRInterimImageCellView alloc] initWithFrame:self.bounds];
        interimImageCellView.animationDuration_EX = _animationDuration_EX;
        
        //  放置图层最上方
        [weakSelf.interimImageBgView insertSubview:interimImageCellView atIndex:[[weakSelf.interimImageBgView subviews] count]];
        
        [interimImageCellView opacityAnimationShowWithImage:[UIImage imageNamed:imgName] animation:aniamtion];
        [_imageViewsArray addObject:interimImageCellView];
        
        _imageViewsIndexNow ++;
    };
    
    void (^reuseBlock)(BOOL aniamtion) = ^(BOOL aniamtion){
    
        CRInterimImageCellView *tailImageCellView = [weakSelf getQueueTailImageCellView];
        
        //  放置图层最上方
        [weakSelf.interimImageBgView insertSubview:tailImageCellView atIndex:[[weakSelf.interimImageBgView subviews] count]];
        
        [tailImageCellView opacityAnimationShowWithImage:[UIImage imageNamed:imgName] animation:aniamtion];
        
        _imageViewsIndexNow = [weakSelf getImageCellViewIndex:tailImageCellView];
    };
    
    
    //  第一次切换图片
    if ([_imageViewsArray count] == 0) {
        
        if (insertNewBlock) {
            insertNewBlock(NO);
        }
    }
    //  非第一次切换图片
    else{
        
        //  新增InterimImageCellView
        if ([_imageViewsArray count] < _imageViewsMaxNum) {
            
            if (insertNewBlock) {
                insertNewBlock(YES);
            }
        }
        
        //  复用队列中尾部ImageCellView
        else{
            
            if (reuseBlock) {
                reuseBlock(YES);
            }
        }
    }
}

- (void)hideFormerImage
{
    __weak CRInterimImageCellView *formerImageCellView = [self getFormerImageCellView];
    
    if (formerImageCellView) {
        [formerImageCellView opacityAnimationHideWithImage:nil animation:YES];
        formerImageCellView.opacityHideFinish_Block = ^(){
            [formerImageCellView removeFromSuperview];
        };
    }
}

- (CRInterimImageCellView *)getFormerImageCellView
{
    if ([_imageViewsArray count] <= 1) {
        return nil;
    }
    
    NSInteger imageViewsIndexFormer = _imageViewsIndexNow - 1;
    if (imageViewsIndexFormer < 0) {
        imageViewsIndexFormer = [_imageViewsArray count] - 1;
    }
    
    CRInterimImageCellView *formerImageCellView = _imageViewsArray[imageViewsIndexFormer];
    return formerImageCellView;
}

- (CRInterimImageCellView *)getQueueTailImageCellView
{
    if ([_imageViewsArray count] <= 1) {
        return nil;
    }
    
    //  数量未满
    if ([_imageViewsArray count] < _imageViewsMaxNum){
        return nil;
    }
    
    NSInteger imageViewsIndexTail = _imageViewsIndexNow + 1;
    if (imageViewsIndexTail > [_imageViewsArray count] - 1) {
        imageViewsIndexTail = 0;
    }
    
    CRInterimImageCellView *formerImageCellView = _imageViewsArray[imageViewsIndexTail];
    return formerImageCellView;
}

- (NSInteger)getImageCellViewIndex:(CRInterimImageCellView *)imageCellView
{
    NSInteger index = [_imageViewsArray indexOfObject:imageCellView];
    
    return index;
}

@end
