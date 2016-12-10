//
//  CRBaseViewController.m
//  CRAnimation
//
//  Created by Bear on 16/10/9.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "CRBaseViewController.h"


@interface CRBaseViewController ()
{
    UIButton    *_backBtn;
    UIView      *_topBarView;
}

@end

@implementation CRBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = color_Master;
    _backBtnColor = [UIColor whiteColor];
}

- (void)createUI
{
        
}

- (void)setBackBtnColor:(UIColor *)backBtnColor
{
    _backBtnColor = backBtnColor;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, (44-69/3.0)/2.0, 48/3.0, 69/3.0)];
    [imageView setImage:[[UIImage imageNamed:@"share_iconShare"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    imageView.tintColor = [UIColor whiteColor];
}

- (void)addTopBar
{
    if (!_topBarView) {
        _topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_HEIGHT, WIDTH, 40)];
        [self.view addSubview:_topBarView];
    }
    
    if (!_backBtn) {
        
        UIImage *backImage = [[UIImage imageNamed:@"back_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:backImage forState:UIControlStateNormal];
        [_backBtn setTintColor:_backBtnColor];
        [_backBtn sizeToFit];
        [_backBtn addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
        [_topBarView addSubview:_backBtn];
        [_backBtn BearSetRelativeLayoutWithDirection:kDIR_LEFT destinationView:nil parentRelation:YES distance:15 center:YES];
    }
}


- (void)popSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
