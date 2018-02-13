//
//  UIViewController+GestureStateBlock.m
//  ScreenShotBack
//
//  Created by zhengwenming on 2017/7/19.
//  Copyright © 2017年 郑文明. All rights reserved.
//

#import "UIViewController+GestureStateBlock.h"
#import <objc/runtime.h>
static char GestureBeganBlockKey;
static char GestureChangedBlockKey;
static char GestureEndedBlockKey;

@implementation UIViewController (GestureStateBlock)

-(void)setGestureBeganBlock:(GestureBeganBlock)gestureBeganBlock{
    objc_setAssociatedObject(self, &GestureBeganBlockKey, gestureBeganBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);

}
-(GestureBeganBlock)gestureBeganBlock{
   return objc_getAssociatedObject(self, &GestureBeganBlockKey);
}

-(void)setGestureChangedBlock:(GestureChangedBlock)gestureChangedBlock{
    objc_setAssociatedObject(self, &GestureChangedBlockKey, gestureChangedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
 
}
-(GestureChangedBlock)gestureChangedBlock{
    return objc_getAssociatedObject(self, &GestureChangedBlockKey);
}

-(void)setGestureEndedBlock:(GestureEndedBlock)gestureEndedBlock{
    objc_setAssociatedObject(self, &GestureEndedBlockKey, gestureEndedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(GestureEndedBlock)gestureEndedBlock{
    return objc_getAssociatedObject(self, &GestureEndedBlockKey);

}
@end
