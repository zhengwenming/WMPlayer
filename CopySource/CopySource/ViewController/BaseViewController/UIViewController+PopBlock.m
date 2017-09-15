//
//  UIViewController+PopBlock.m
//  CopySource
//
//  Created by zhengwenming on 2017/8/19.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "UIViewController+PopBlock.h"
#import <objc/runtime.h>


@implementation UIViewController (PopBlock)
-(void)setPopBlock:(PopBlock)popBlock{
    objc_setAssociatedObject(self, @selector(popBlock), popBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(PopBlock)popBlock{
    return objc_getAssociatedObject(self, _cmd);
}
@end
