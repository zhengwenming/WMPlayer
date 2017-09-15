//
//  HomeViewController.m
//  CopySource
//
//  Created by zhengwenming on 2017/4/9.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "HomeViewController.h"
#import "SDCycleScrollView.h"
#import "SetViewController.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,SDCycleScrollViewDelegate>
{
    NSArray *dataSource;
}
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) UIColor *navColor;
@end

@implementation HomeViewController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar wm_reset];

    if (self.navColor) {
        [self.navigationController.navigationBar wm_setBackgroundColor:self.navColor isHiddenBottomBlackLine:YES];
    }else{
        [self.navigationController.navigationBar wm_setBackgroundColor:[UIColor clearColor] isHiddenBottomBlackLine:YES];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navColor = [self.navigationController.navigationBar wm_getBackgroundColor];
    [self.navigationController.navigationBar wm_reset];
}
/**
 懒加载轮播图
 
 @return _cycleScrollView
 */
-(SDCycleScrollView *)cycleScrollView{
    if (_cycleScrollView==nil) {
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, 192.f) delegate:self  placeholderImage:nil];
        _cycleScrollView.bannerImageViewContentMode = UIViewContentModeCenter;
        _cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        //    cycleScrollView2.titlesGroup = titles;
        _cycleScrollView.imageURLStringsGroup = @[@"banner2"];
        _cycleScrollView.currentPageDotColor = kTintColor; // 自定义分页控件小圆标颜色
        _cycleScrollView.pageDotColor = [UIColor whiteColor];
    }
    return _cycleScrollView;
}
/**
 懒加tableView
 
 @return _table
 */

-(UITableView *)table{
    if (_table==nil) {
        _table  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.tableFooterView = [UIView new];
        _table.tableHeaderView = self.cycleScrollView;
        _table.rowHeight = 70.f;
    }
    return _table;
    
}
-(void)scanEwm:(UIBarButtonItem *)sender{
    NSLog(@"ewm");
}
-(void)searchAction:(UIBarButtonItem *)sender{
    NSLog(@"searchAction");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    dataSource = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    self.navigationItem.title = @"推荐";
    [self.view addSubview:self.table];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ewm"] style:UIBarButtonItemStylePlain target:self action:@selector(scanEwm:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white_search"] style:UIBarButtonItemStylePlain target:self action:@selector(searchAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = dataSource[indexPath.row];
    return cell;
}
///监听scrollView的滚动事件
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView==self.table) {
        CGFloat offsetY = scrollView.contentOffset.y;
        //        NSLog(@"offsetY = %f",offsetY);
        
        if (offsetY >0) {
            CGFloat alpha = (offsetY -64) / 64 ;
            alpha = MIN(alpha, 0.99);
            //            NSLog(@"alpha =%f",alpha);
            [self.navigationController.navigationBar wm_setBackgroundColor:[kTintColor colorWithAlphaComponent:alpha] isHiddenBottomBlackLine:YES];
            if (alpha>=0.99) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                self.navigationItem.title = @"推荐";
            }
        } else {
            [self.navigationController.navigationBar wm_setBackgroundColor:[UIColor clearColor] isHiddenBottomBlackLine:YES];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            self.navigationItem.title = @"";
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SetViewController *setVC = [SetViewController new];
    [self.navigationController pushViewController:setVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate{
    return NO;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
