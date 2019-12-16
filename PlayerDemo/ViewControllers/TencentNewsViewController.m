/*!
 @header TencentNewsViewController.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
            作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/19
 
 @version 1.00 16/1/19 Creation(版本信息)
 
   Copyright © 2016年 郑文明. All rights reserved.
 */

#import "TencentNewsViewController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "HomeVideoCollectionViewCell.h"
#import "WMPlayerModel.h"
#import "DetailViewController.h"

@interface TencentNewsViewController ()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>{
    
}
@property (nonatomic, retain) UICollectionView *videoCollectionView;//热拍
@property (nonatomic, strong) NSMutableArray* videoDataAry;

@end

@implementation TencentNewsViewController
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"视频推荐";
    UICollectionViewFlowLayout* videoFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [videoFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//垂直滚动
    self.videoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height) collectionViewLayout:videoFlowLayout];
    self.videoCollectionView.alwaysBounceVertical = YES;//当不够一屏的话也能滑动
    self.videoCollectionView.delegate = self;
    self.videoCollectionView.dataSource = self;
    [self.videoCollectionView setBackgroundColor:[UIColor whiteColor]];
    [self.videoCollectionView registerClass:[HomeVideoCollectionViewCell class] forCellWithReuseIdentifier:@"HomeVideoCollectionViewCell"];
    [self.view addSubview:self.videoCollectionView];
    self.videoCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshVideoData)];
    self.videoCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(addVideoData)];
    
    [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
        if (!error) {
            _videoDataAry = [NSMutableArray arrayWithArray:dateAry];
            [self.videoCollectionView reloadData];
        }else{
            
        }
    }];
}
-(void)refreshVideoData{
    [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
        if (!error) {
            _videoDataAry = [NSMutableArray arrayWithArray:dateAry];
            [self.videoCollectionView.mj_header endRefreshing];
            [self.videoCollectionView reloadData];
        }else{
            [self.videoCollectionView.mj_header endRefreshing];
        }
    }];
}
-(void)addVideoData{
    [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
        if (!error) {
            //            _videoDataAry = [NSMutableArray arrayWithArray:dateAry];
            [_videoDataAry addObjectsFromArray:dateAry];
            [self.videoCollectionView.mj_footer endRefreshing];
            [self.videoCollectionView reloadData];
        }else{
            [self.videoCollectionView.mj_footer endRefreshing];
        }
    }];
}

#pragma mark UICollectionViewDataSource {
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
//定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _videoDataAry.count;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeVideoCollectionViewCell" forIndexPath:indexPath];
    cell.DataModel = self.videoDataAry[indexPath.row];
    return cell;
}
//返回头headerView的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeZero;
}
//定义每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width)/2 - 2, (([UIScreen mainScreen].bounds.size.width)/2 - 2)*1.6);
}
//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0.0,2.0,0.0,2.0);
}
//每个item之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0f;
}
//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0f;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    VideoDataModel *videoModel = self.videoDataAry[indexPath.row];
    WMPlayerModel *playerModel = [WMPlayerModel new];
    playerModel.videoURL = [NSURL URLWithString:videoModel.video_url];
//    playerModel.videoURL = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    playerModel.title = videoModel.nickname;
    DetailViewController *detailVC = [DetailViewController new];
           detailVC.playerModel = playerModel;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
