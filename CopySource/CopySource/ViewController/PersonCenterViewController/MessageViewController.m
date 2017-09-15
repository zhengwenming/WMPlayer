//
//  MessageViewController.m
//  CopySource
//
//  Created by zhengwenming on 2017/8/19.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSString *applicantId;
}
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property(nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation MessageViewController
-(NSString *)backItemImageName{
    return @"back_gold";
}
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.messageTableView registerClass:NSClassFromString(@"UITableViewCell") forCellReuseIdentifier:@"UITableViewCell"];
    self.messageTableView.rowHeight = 50;

    self.navigationItem.title = @"试试旋转屏幕";
    for (NSUInteger index = 0; index<20; index++) {
        [self.dataSource addObject:[NSString stringWithFormat:@"左滑删除%@",@(index)]];
    }

}

//支不支持删除
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//滑动删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return@"删除";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [self.dataSource removeObjectAtIndex:indexPath.row];
        
        
        [tableView deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationBottom];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =  (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataSource[indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
}
//- (BOOL)shouldAutorotate{
//    //是否允许转屏
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    //viewController所支持的全部旋转方向
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    //viewController初始显示的方向
//    return UIDeviceOrientationLandscapeRight;
//}

- (void)dealloc
{
    WMLog(@"%s dealloc",object_getClassName(self));
}

@end

