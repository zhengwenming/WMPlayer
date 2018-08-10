//
//  UIView+Tools.m
//  VideoRecord
//
//  Created by guimingsu on 14-8-25.
//  Copyright (c) 2014年 guimingsu. All rights reserved.
//

#import "UIView+Tools.h"

@implementation UIView (Tools)
-(void)makeCornerRadius:(float)radius borderColor:(UIColor *)bColor borderWidth:(float)bWidth{
    self.layer.borderWidth = bWidth;
    
    if (bColor != nil) {
        self.layer.borderColor = bColor.CGColor;
    }
    
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}


@end
