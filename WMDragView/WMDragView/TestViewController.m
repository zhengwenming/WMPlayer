//
//  TestViewController.m
//  WMDragView
//
//  Created by zhengwenming on 2016/12/18.
//  Copyright © 2016年 zhengwenming. All rights reserved.
//

#import "TestViewController.h"
#import "WMDragView.h"
#import "UIImageView+WebCache.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewDidLoad];

    
    WMDragView *logoView = [[WMDragView alloc] initWithFrame:CGRectMake(0, 0 , 120, 120)];
    logoView.layer.cornerRadius = 14;
    logoView.isKeepBounds = NO;
    //设置网络图片
    [logoView.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://q.qlogo.cn/qqapp/1104706859/189AA89FAADD207E76D066059F924AE0/100"] placeholderImage:[UIImage imageNamed:@"logo1024"]];
    [self.view addSubview:logoView];
    //限定logoView的活动范围
    logoView.freeRect = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    logoView.center = self.view.center;

    ///点击block
    logoView.ClickDragViewBlock = ^(WMDragView *dragView){
        [dragView.imageView sd_setImageWithURL:[NSURL URLWithString:@"http://weixintest.ihk.cn/ihkwx_upload/userPhoto/15914867203-1461920972642.jpg"] placeholderImage:[UIImage imageNamed:@"logo1024"]];
        NSLog(@"点击block");

    };
    ///开始拖曳block
    logoView.BeginDragBlock = ^(WMDragView *dragView){
        NSLog(@"开始拖曳");
    };
    
    ///结束拖曳block
    logoView.EndDragBlock = ^(WMDragView *dragView){
        NSLog(@"结束拖曳");

    };
    
    
}
-(void)dealloc{
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
}
@end
