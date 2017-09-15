//
//  SetViewController.m
//  TongXueBao
//
//  Created by 吴亚乾 on 2016/12/7.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "SetViewController.h"
#import "PersonCenterViewController.h"
#import "LoginViewController.h"

#import "BaseWebViewController.h"



@interface SetViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_itemsArray;
}

@property (nonatomic, strong) UITableView *SetTableView;

@property (nonatomic, assign) BOOL isLogout;

@end

@implementation SetViewController
-(NSString *)backItemImageName{
    return @"back_green";
}
-(BOOL)gestureRecognizerShouldBegin{
    return YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self.navigationController.navigationBar wm_setBackgroundColor:[UIColor redColor] isHiddenBottomBlackLine:NO];
    [super viewWillAppear:animated];
    _itemsArray = @[@[@"意见反馈",@"关于我们",@"版本信息",@"清除缓存"],@[@"修改密码"],@[@"退出登录"]].mutableCopy;
    [self layoutTableView];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar wm_reset];

    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    
}
- (void)layoutTableView
{
    self.SetTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, kNavbarHeight, kScreenWidth, kScreenHeight - kNavbarHeight) style:UITableViewStyleGrouped];
    self.SetTableView.delegate = self;
    self.SetTableView.dataSource = self;
    self.SetTableView.tableFooterView = [UIView new];
    self.SetTableView.tableHeaderView = [UIView new];
    self.SetTableView.rowHeight = 45.f;
    self.SetTableView.showsVerticalScrollIndicator = NO;
    self.SetTableView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.SetTableView ];
}

#pragma mark ----- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  
    return _itemsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemsArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _itemsArray[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16.f];
    cell.textLabel.textColor = [MSUtil colorWithHexString:@"444444"];
    
    if(indexPath.section == 0 && indexPath.row ==3){
        cell.accessoryType = UITableViewCellAccessoryNone;
        // 计算缓存
        cell.detailTextLabel.text = @"3M";
        // 设置字体及颜色
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }else if (indexPath.section == _itemsArray.count - 1) {
        UITableViewCell *logouCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logout"];
        logouCell.textLabel.text = _itemsArray[indexPath.section][indexPath.row];
        logouCell.accessoryType = UITableViewCellAccessoryNone;
        logouCell.textLabel.textColor = [MSUtil colorWithHexString:@"FF9393"];
        logouCell.textLabel.textAlignment = NSTextAlignmentCenter;
        return logouCell;
    }
    return cell;
}

/// 取消系统cell的separatorView
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == _itemsArray.count -1) {
        [self performSelector:@selector(setSeparatorLineColor:) withObject:cell afterDelay:0.1];
    }
}
- (void)setSeparatorLineColor:(UITableViewCell *)cell
{
    // 获取系统cell的separatorView
    UIView * view = [cell valueForKey:@"separatorView"];
    view.backgroundColor = [UIColor whiteColor];
}

#pragma mark ----- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return 10.f;
    }else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == _itemsArray.count -1) {
        LoginViewController *loginVC =[LoginViewController new];
        BaseNavigationController *baseNav = [[BaseNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:baseNav animated:YES completion:nil];
    }else{
        BaseWebViewController *webView = [BaseWebViewController new];
        webView.urlString = @"https://www.baidu.com";
        [self.navigationController pushViewController:webView animated:YES]; 
    }
}

- (void)dealloc
{

    WMLog(@"%s dealloc",object_getClassName(self));
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
