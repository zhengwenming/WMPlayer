//
//  BaseViewController.h
//  TongXueBao
//
//  Created by 郑文明 on 16/9/22.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface BaseViewController : UIViewController

@property (nonatomic, assign) BOOL isHideBackItem;

///右滑返回功能，默认开启（YES）
- (BOOL)gestureRecognizerShouldBegin;

-(NSString *)backItemImageName;
@end
