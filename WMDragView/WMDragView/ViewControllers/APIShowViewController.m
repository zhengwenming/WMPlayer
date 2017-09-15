//
//  APIShowViewController.m
//  WMDragView
//
//  Created by zhengwenming on 2017/8/19.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "APIShowViewController.h"
#import "APIDetailViewController.h"

@interface APIShowViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray *dataSource;
@property (strong, nonatomic)UITableView *apiTableView;

@end

@implementation APIShowViewController
/**
 懒加载数据源dataSource
 
 @return dataSource
 */
-(NSMutableArray *)dataSource{
    if (_dataSource==nil) {
        _dataSource = [NSMutableArray array];
    }
    return  _dataSource;
}
/**
 懒加tableView
 
 @return _table
 */

-(UITableView *)apiTableView{
    if (_apiTableView==nil) {
        _apiTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, kNavbarHeight, kScreenWidth, kScreenHeight-kNavbarHeight-kTabBarHeight) style:UITableViewStyleGrouped];
        _apiTableView.delegate = self;
        _apiTableView.dataSource = self;
        [_apiTableView registerClass:NSClassFromString(@"UITableViewCell") forCellReuseIdentifier:@"UITableViewCell"];
        _apiTableView.rowHeight = 80;
        _apiTableView.tableFooterView = [UIView new];
    }
    return _apiTableView;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.dataSource addObjectsFromArray:@[@[@"dragEnable->能否拖曳",@"freeRect->活动范围，默认为父视图的frame范围内",@"dragDirection->拖曳的方向，默认为any，任意方向",@"isKeepBounds->是不是总保持在父视图边界，默认为NO,没有黏贴边界效果"],@[@"clickDragViewBlock->点击的回调",@"beginDragBlock->开始拖动的回调",@"duringDragBlock->拖动中的回调",@"endDragBlock->结束拖动的回调"]]];

    [self.view addSubview:self.apiTableView];
}
#pragma mark ----- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16.f];
    cell.textLabel.numberOfLines = 0;
//    cell.textLabel.textColor = [UIColor lightGrayColor];
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section) {
        return @"事件回调";
    }
    return @"API";
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.000001f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[APIDetailViewController new] animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
