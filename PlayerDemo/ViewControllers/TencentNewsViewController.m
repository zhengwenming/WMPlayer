/*!
 @header TencentNewsViewController.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
            作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/19
 
 @version 1.00 16/1/19 Creation(版本信息)
 
   Copyright © 2016年 郑文明. All rights reserved.
 */

#import "TencentNewsViewController.h"
#import "SidModel.h"
#import "VideoCell.h"
#import "VideoModel.h"
#import "WMPlayer.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "Masonry.h"


@interface TencentNewsViewController (){
    
}
@property(nonatomic,retain)VideoCell *currentCell;
@property(nonatomic,retain)NSMutableArray *dataSource;

@end

@implementation TencentNewsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
