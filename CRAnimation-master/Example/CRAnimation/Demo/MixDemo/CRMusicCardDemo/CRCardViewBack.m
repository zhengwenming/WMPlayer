//
//  CRCardViewBack.m
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/12.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import "CRCardViewBack.h"

@implementation CRCardViewBack

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
        label.text = @"123";
        label.backgroundColor = [UIColor orangeColor];
        [self addSubview:label];
        
    }
    
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
