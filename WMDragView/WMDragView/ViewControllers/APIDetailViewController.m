//
//  APIDetailViewController.m
//  WMDragView
//
//  Created by zhengwenming on 2017/8/19.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "APIDetailViewController.h"

@interface APIDetailViewController ()
@property(nonatomic,strong)WMDragView *dragView;
@property(nonatomic,strong)UILabel *leftLabel;
@property(nonatomic,strong)UILabel *rightLabel;

@property(nonatomic,strong)UISwitch *leftSwitch;
@property(nonatomic,strong)UISwitch *rightSwitch;
@property(nonatomic,strong)UILabel *tipsLabel;

@property(nonatomic,strong)UIView *bgView;

@end

@implementation APIDetailViewController

-(UIView *)bgView{
    if (_bgView==nil) {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-30, kScreenWidth-40*2, kScreenWidth-40*2)];
        _bgView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _bgView.layer.borderWidth = 1.f;
        _bgView.hidden = YES;
        _bgView.center = self.view.center;
    }
    return _bgView;
}
-(UILabel *)tipsLabel{
    if (_tipsLabel==nil) {
        _tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kNavbarHeight, kScreenWidth, 30)];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont systemFontOfSize:15.f];
        _tipsLabel.hidden = YES;
        _tipsLabel.textColor = [UIColor redColor];
    }
    return _tipsLabel;
}

-(UILabel *)leftLabel{
    if (_leftLabel==nil) {
        _leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kScreenHeight-30, kScreenWidth/2, 30)];
        _leftLabel.text = @"打开or关闭黏贴边界效果";
        _leftLabel.font = [UIFont systemFontOfSize:14.f];
    }
    return _leftLabel;
}
-(UILabel *)rightLabel{
    if (_rightLabel==nil) {
        _rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2, kScreenHeight-30, kScreenWidth/2, 30)];
        _rightLabel.text = @"把dragView限定在框内";
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.font = [UIFont systemFontOfSize:14.f];
    }
    return _rightLabel;
}
-(UISwitch *)leftSwitch{
    if (_leftSwitch==nil) {
        _leftSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0, self.leftLabel.frame.origin.y-40, 30, 30)];
        [_leftSwitch addTarget:self action:@selector(boundsOrNot:) forControlEvents:UIControlEventValueChanged];
    }
    return _leftSwitch;
}
-(UISwitch *)rightSwitch{
    if (_rightSwitch==nil) {
        _rightSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(kScreenWidth-60, self.rightLabel.frame.origin.y-40, 30, 30)];
        [_rightSwitch addTarget:self action:@selector(setFreeRect:) forControlEvents:UIControlEventValueChanged];
    }
    return _rightSwitch;
}
-(void)setFreeRect:(UISwitch *)sender{
    if (sender.on) {
        self.dragView.freeRect = self.bgView.frame;
    }else{
        self.dragView.freeRect = self.view.frame;
    }
    self.bgView.hidden = !sender.on;
}
-(void)boundsOrNot:(UISwitch *)sender{
        self.dragView.isKeepBounds = sender.on;
        [self.view layoutIfNeeded];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"WMDragView的API详解";
    
    [self.view addSubview:self.leftLabel];
    [self.view addSubview:self.rightLabel];
    [self.view addSubview:self.tipsLabel];

    [self.view addSubview:self.leftSwitch];
    [self.view addSubview:self.rightSwitch];

    [self.view addSubview:self.bgView];
    
    
    
    self.dragView = [[WMDragView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.dragView.button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.dragView.button setTitle:@"可拖曳" forState:UIControlStateNormal];
    [self.dragView.button setTitle:@"不可拖曳" forState:UIControlStateSelected];

    self.dragView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.dragView];
    self.dragView.center = self.view.center;
    
    WEAKSELF;
    
    self.dragView.clickDragViewBlock = ^(WMDragView *dragView){
        NSLog(@"clickDragViewBlock");
        dragView.button.selected = dragView.dragEnable;
        dragView.dragEnable = !dragView.dragEnable;

        weakSelf.tipsLabel.hidden = NO;
        weakSelf.tipsLabel.text = dragView.button.titleLabel.text;
        [weakSelf.tipsLabel performSelector:@selector(setHidden:) withObject:@(YES) afterDelay:2];
    };
    
    self.dragView.beginDragBlock = ^(WMDragView *dragView) {
        NSLog(@"开始拖曳");
        weakSelf.tipsLabel.hidden = NO;
        weakSelf.tipsLabel.text = @"开始拖曳";
    };
    
    self.dragView.endDragBlock = ^(WMDragView *dragView) {
        NSLog(@"结束拖曳");
        weakSelf.tipsLabel.text = @"结束拖曳";
        [weakSelf.tipsLabel performSelector:@selector(setHidden:) withObject:@(YES) afterDelay:1.5];
    };
    
    self.dragView.duringDragBlock = ^(WMDragView *dragView) {
        NSLog(@"拖曳中...");
        weakSelf.tipsLabel.hidden = NO;
        weakSelf.tipsLabel.text = @"拖曳中...";
    };
    
}
@end
