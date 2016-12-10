//
//  CRBottomPageView.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/6/6.
//  Copyright © 2016年 Bear. All rights reserved.
//

#define color_d5d6d7    UIColorFromHEX(0xd5d6d7)


#import "CRBottomPageView.h"

@implementation CRBottomPageView
{
    UIView          *_lineV_left;
    UIView          *_lineV_right;
    UILabel         *_pageLabel;
    NSMutableArray  *_subViewArray;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        _pageAll = 0;
        _pageNow = 0;
        
        _lineV_left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 1)];
        _lineV_left.backgroundColor = color_d5d6d7;
        [self addSubview:_lineV_left];
        
        _lineV_right = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 1)];
        _lineV_right.backgroundColor = color_d5d6d7;
        [self addSubview:_lineV_right];
        
        _pageLabel = [UILabel new];
        _pageLabel.textColor = color_d5d6d7;
        _pageLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_pageLabel];
        
        _subViewArray = [NSMutableArray new];
        [_subViewArray addObject:_lineV_left];
        [_subViewArray addObject:_pageLabel];
        [_subViewArray addObject:_lineV_right];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_pageNow, (long)_pageAll];
    [_pageLabel sizeToFit];
    [UIView BearAutoLayViewArray:_subViewArray layoutAxis:kLAYOUT_AXIS_X center:YES gapDistance:7];
}

@synthesize pageNow = _pageNow;
- (void)setPageNow:(NSInteger)pageNow
{
    _pageNow = pageNow;
    [self setNeedsLayout];
}

@synthesize pageAll = _pageAll;
- (void)setPageAll:(NSInteger)pageAll
{
    _pageAll = pageAll;
    [self setNeedsLayout];
}

@end
