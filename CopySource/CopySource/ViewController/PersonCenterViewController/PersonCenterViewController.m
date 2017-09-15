//
//  PersonCenterViewController.m
//  CopySource
//
//  Created by zhengwenming on 2017/4/9.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "PersonCenterViewController.h"
#import "SetViewController.h"
#import "MessageViewController.h"
#import "PopBlockTestViewController.h"

@interface PersonCenterViewController ()

@end

@implementation PersonCenterViewController
-(BOOL)gestureRecognizerShouldBegin{
    return YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar wm_setBackgroundColor:[UIColor greenColor] isHiddenBottomBlackLine:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar wm_reset];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithIcon:@"message" highIcon:nil target:self action:@selector(messageItemDidAction:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"setting" highIcon:nil target:self action:@selector(setItemDidAction:)];
    
    
    
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-2*10, 100)];
    testLabel.text = @"点击我测试-->拦截导航“返回”按钮事件，并且不屏蔽此VC的全屏返回手势";
    testLabel.backgroundColor = [UIColor cyanColor];
    testLabel.numberOfLines = 0;
    testLabel.center = self.view.center;
    testLabel.userInteractionEnabled = YES;
    [self.view addSubview:testLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(testPopBlock:)];
    [testLabel addGestureRecognizer:tap];
}
-(void)testPopBlock:(UITapGestureRecognizer *)sender{
    PopBlockTestViewController *popBlockTest = [PopBlockTestViewController new];
    [self.navigationController pushViewController:popBlockTest animated:YES];
}
-(void)setItemDidAction:(UIBarButtonItem *)sender{
    SetViewController *setVC = [SetViewController new];
    [self.navigationController pushViewController:setVC animated:YES];
}
-(void)messageItemDidAction:(UIBarButtonItem *)sender{
    [self.navigationController pushViewController:[MessageViewController new] animated:YES];

}
-(BOOL)shouldAutorotate{
    return NO;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
