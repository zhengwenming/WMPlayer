//
//  BaseViewController.m
//  WMPlayer
//
//  Created by 郑文明 on 16/3/15.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
- (id)init{
    self = [super init];
    if (self) {
        self.enablePanGesture = YES;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor  whiteColor];
    
}

- (void)addHud
{
    if (!_hud) {
        _hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}
- (void)addHudWithMessage:(NSString*)message
{
    if (!_hud)
    {
        _hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText=message;
    }
    
}
- (void)removeHud
{
    if (_hud) {
        [_hud removeFromSuperview];
        _hud=nil;
    }
}
@end
