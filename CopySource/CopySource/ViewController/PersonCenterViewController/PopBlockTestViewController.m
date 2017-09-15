//
//  PopBlockTestViewController.m
//  CopySource
//
//  Created by zhengwenming on 2017/8/19.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "PopBlockTestViewController.h"

@interface PopBlockTestViewController ()

@end

@implementation PopBlockTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"拦截back事件";
    WEAKSELF;
        self.popBlock = ^(UIBarButtonItem *backItem){
            [weakSelf showAlert];
        };
}
-(void)showAlert{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定返回？" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
   
    
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}
@end
