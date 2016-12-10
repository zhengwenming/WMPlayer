//
//  CRBaseViewController.h
//  CRAnimation
//
//  Created by Bear on 16/10/9.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRBaseViewController : UIViewController

@property (strong, nonatomic) UIColor     *backBtnColor;

- (void)createUI;

- (void)addTopBar;
- (void)popSelf;

@end
