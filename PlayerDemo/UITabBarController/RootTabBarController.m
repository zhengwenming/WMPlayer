//
//  RootTabBarController.m
//  WMVideoPlayer
//
//  Created by 郑文明 on 15/12/14.
//  Copyright © 2015年 郑文明. All rights reserved.
//

#import "RootTabBarController.h"
#import "BaseNavigationController.h"
#import "WMTabBar.h"
#import "WMPlayer.h"
@interface RootTabBarController ()<UITabBarControllerDelegate>{
}
@property(nonatomic,strong)NSArray *infoDataArray;
@end

@implementation RootTabBarController
-(NSArray *)infoDataArray{
    if (_infoDataArray==nil) {
        _infoDataArray = @[
@{@"title":@"腾讯",@"selectedImage":@"tab_live_p",@"image":@"tab_live",@"VCName":@"TencentNewsViewController"},
@{@"title":@"",@"selectedImage":@"tab_room_p",@"image":@"tab_room",@"VCName":@"CameraViewController"},
@{@"title":@"新浪",@"selectedImage":@"tab_me_p",@"image":@"tab_me",@"VCName":@"SinaNewsViewController"}];
    }
    return _infoDataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([WMPlayer IsiPhoneX]) {
        WMTabBar *wmTabBar = [[WMTabBar alloc] init];
        [self setValue:wmTabBar forKey:@"tabBar"];
    }
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSDictionary *eachInfo in self.infoDataArray) {
        UIViewController *aVC = [NSClassFromString(eachInfo[@"VCName"]) new];
        aVC.title = eachInfo[@"title"];
        BaseNavigationController *aNav = [[BaseNavigationController alloc]initWithRootViewController:aVC];
        aNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:nil image:[[UIImage imageNamed:eachInfo[@"image"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed: eachInfo[@"selectedImage"]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        aNav.tabBarItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
        [viewControllers addObject:aNav];
    }
    self.viewControllers = viewControllers;
    self.delegate = self;
    [self setupTabBarBackgroundImage];
}

- (void)setupTabBarBackgroundImage {
    //    //隐藏阴影线
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    UIImage *image = [UIImage imageNamed:@"tab_bg"];

    // 指定为拉伸模式，伸缩后重新赋值
    UIImage *TabBgImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(40, 100, 40, 100) resizingMode:UIImageResizingModeStretch];
    self.tabBar.backgroundImage = TabBgImage;
    self.tabBar.shadowImage = [UIImage new];
    [self.tabBar setClipsToBounds:YES];
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UINavigationController *)viewController{
    if ([viewController.topViewController isKindOfClass:NSClassFromString(@"CameraViewController")]) {
        BaseNavigationController *testNav =[[BaseNavigationController alloc]initWithRootViewController:[NSClassFromString(@"VideoRecordViewController") new]];
        [self.selectedViewController presentViewController:testNav animated:YES completion:^{
            
        }];
        return NO;
    }
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
}
@end
