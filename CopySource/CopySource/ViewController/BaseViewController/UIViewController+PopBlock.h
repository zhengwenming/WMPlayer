//
//  UIViewController+PopBlock.h
//  CopySource
//
//  Created by zhengwenming on 2017/8/19.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^PopBlock)(UIBarButtonItem *backItem);

@interface UIViewController (PopBlock)
@property(nonatomic,copy)PopBlock popBlock;

@end
