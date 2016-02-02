//
//  SecondViewController.m
//  WMVideoPlayer
//
//  Created by 郑文明 on 15/12/14.
//  Copyright © 2015年 郑文明. All rights reserved.
//

#import "SecondViewController.h"
#import "DetailViewController.h"

@interface SecondViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView *table;
    NSDictionary *dataDict;
}

@end

@implementation SecondViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WMPlayerView";
    self.view.backgroundColor = [UIColor whiteColor];
    dataDict = @{@"本地视频":@[@"3gp",@"mov",@"mp4"],@"网络视频":@[
    @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4",
    @"http://admin.weixin.ihk.cn/ihkwx_upload/test.mp4",
    @"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8",
    @"http://player.56.com/v_NjUwNDUwODI.swf"]};
    
    [self initTable];
}
-(void)initTable{
    table = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    table.dataSource = self;
    table.delegate =  self;
    table.tableFooterView = [UIView new];
    [self.view addSubview:table];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return dataDict.allKeys.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *eachArray = section?dataDict[@"本地视频"]:dataDict[@"网络视频"];
    return eachArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSArray *eachArray = indexPath.section?dataDict[@"本地视频"]:dataDict[@"网络视频"];
    
    cell.textLabel.text = eachArray[indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, table.frame.size.width, 30)];
    
    UILabel *aLabel = [[UILabel alloc]initWithFrame:aHeaderView.bounds];
    
    aLabel.text = section?@"本地视频":@"网络视频";
    [aHeaderView addSubview:aLabel];
    return aHeaderView;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *eachArray = indexPath.section?dataDict[@"本地视频"]:dataDict[@"网络视频"];
    
    NSString *ID = eachArray[indexPath.row];
    NSString *urlstring = @"";
    if ([ID hasPrefix:@"http"]) {
        urlstring = ID;
    }else{
        urlstring = [[NSBundle mainBundle] pathForResource:ID ofType:ID];
    }
    if (urlstring) {
        DetailViewController *detailVC = [[DetailViewController alloc]init];
        detailVC.URLString = urlstring;
        detailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
