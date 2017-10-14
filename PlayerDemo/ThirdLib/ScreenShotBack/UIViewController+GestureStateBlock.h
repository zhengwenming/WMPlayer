//
//  UIViewController+GestureStateBlock.h
//  ScreenShotBack
//
//  Created by zhengwenming on 2017/7/19.
//  Copyright © 2017年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^GestureBeganBlock)    (UIViewController *viewController);
typedef void(^GestureChangedBlock)  (UIViewController *viewController);
typedef void(^GestureEndedBlock)    (UIViewController *viewController);

@interface UIViewController (GestureStateBlock)

@property(nonatomic,copy)GestureBeganBlock      gestureBeganBlock;
@property(nonatomic,copy)GestureChangedBlock    gestureChangedBlock;
@property(nonatomic,copy)GestureEndedBlock      gestureEndedBlock;

@end
