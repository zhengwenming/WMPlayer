
//  LoginViewController.m
//  AIHealth
//
//  Created by 吴亚乾 on 2016/12/21.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *weChatLoginButton;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    // 设置border
    [self.weChatLoginButton.layer setBorderWidth:1.f];
    [self.weChatLoginButton.layer setBorderColor:kTintColor.CGColor];
    self.userNameTF.tintColor = kTintColor;
    self.passwordTF.tintColor = kTintColor;
    // 设置圆角
    self.weChatLoginButton.clipsToBounds = YES;
    self.weChatLoginButton.layer.cornerRadius = 25.f;
    self.loginButton.alpha = 0.7;
    self.loginButton.layer.cornerRadius = 5;
    self.loginButton.backgroundColor = kTintColor;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithIcon:@"5-1-3" highIcon:nil target:self action:@selector(disMiss)];
}
-(void)disMiss{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
// 登录
- (IBAction)loginButtonDidClicked:(UIButton *)sender
{

    RootTabbarController *rootTabbar = (RootTabbarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
   BaseNavigationController *selectedNav = (BaseNavigationController *)rootTabbar.selectedViewController;
    [selectedNav popToRootViewControllerAnimated:NO];
    rootTabbar.selectedIndex = 0;

        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    
}

// 注册
- (IBAction)registerButtonDidClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
   
}

// 忘记密码
- (IBAction)forgetPasswordButtonDidClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
    
}
- (void)disMissLoginViewController
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)weChatLoginButtonDidClicked:(UIButton *)sender
{
    [self.view endEditing:YES];
}

#pragma mark ----- UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.passwordTF == textField && self.userNameTF.text.length) {
        self.loginButton.alpha = 1.f;
    }else if ([self.passwordTF.text length] && self.userNameTF == textField) {
        self.loginButton.alpha = 1.f;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!self.passwordTF.text.length || !self.userNameTF.text.length) {
        self.loginButton.alpha = 0.7f;
    }
}


- (void)dealloc
{
    WMLog(@"%s dealloc",object_getClassName(self));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
