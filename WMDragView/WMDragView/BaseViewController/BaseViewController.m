//
//  BaseViewController.m
//  TongXueBao
//
//  Created by 郑文明 on 16/9/22.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController ()

@end

@implementation BaseViewController
///右滑返回功能，默认开启（YES）
- (BOOL)gestureRecognizerShouldBegin{
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
    {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
}

-(NSString *)backItemImageName{
    return @"navigator_btn_back";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}
@end
