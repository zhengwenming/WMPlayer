/*!
 @header SinaNewsViewController.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
            作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/19
 
 @version 1.00 16/1/19 Creation(版本信息)
 
   Copyright © 2016年 郑文明. All rights reserved.
 */

#import "SinaNewsViewController.h"
#import "SidModel.h"
#import "VideoCell.h"
#import "VideoModel.h"
#import "WMPlayer.h"
#import "DetailViewController.h"

@interface SinaNewsViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    NSMutableArray *dataSource;
    WMPlayer *wmPlayer;
    NSIndexPath *currentIndexPath;
}

@property(nonatomic,retain)VideoCell *currentCell;

@end

@implementation SinaNewsViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        dataSource = [NSMutableArray array];
    }
    return self;
}
-(void)videoDidFinished:(NSNotification *)notice{
    VideoCell *currentCell = (VideoCell *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
    [wmPlayer removeFromSuperview];
}
-(void)fullScreenBtnClick:(NSNotification *)notice{
    
}
-(void)closeTheVideo:(NSNotification *)obj{
    VideoCell *currentCell = (VideoCell *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
    [self releaseWMPlayer];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //注册播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //注册播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:) name:WMPlayerFullScreenButtonClickedNotification object:nil];
    
    
    [self.table registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    //关闭通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeTheVideo:)
                                                 name:WMPlayerClosedNotification
                                               object:nil
     ];
    [self addMJRefresh];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
    
}
-(void)loadData{

    WS(weakSelf)
    if ([AppDelegate shareAppDelegate].sidArray.count>2) {
        SidModel *sidModl = [AppDelegate shareAppDelegate].sidArray[2];
        [weakSelf addHudWithMessage:@"加载中..."];
        [[DataManager shareManager] getVideoListWithURLString:[NSString stringWithFormat:@"http://c.3g.163.com/nc/video/list/%@/y/0-10.html",sidModl.sid] ListID:sidModl.sid success:^(NSArray *listArray, NSArray *videoArray) {
            
            dataSource =[NSMutableArray arrayWithArray:listArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.table reloadData];
                [weakSelf removeHud];
                [weakSelf.table.mj_header endRefreshing];
            });
        } failed:^(NSError *error) {
            [weakSelf removeHud];
            [weakSelf.table.mj_header endRefreshing];
            
        }];
    }
}
-(void)addMJRefresh{
    WS(weakSelf)

    __unsafe_unretained UITableView *tableView = self.table;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if ([AppDelegate shareAppDelegate].sidArray.count>2) {
            SidModel *sidModl = [AppDelegate shareAppDelegate].sidArray[2];
            [weakSelf addHudWithMessage:@"加载中..."];

            [[DataManager shareManager] getVideoListWithURLString:[NSString stringWithFormat:@"http://c.3g.163.com/nc/video/list/%@/y/0-10.html",sidModl.sid] ListID:sidModl.sid success:^(NSArray *listArray, NSArray *videoArray) {
                dataSource =[NSMutableArray arrayWithArray:listArray];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (currentIndexPath.row>dataSource.count) {
                        [weakSelf releaseWMPlayer];
                    }
                    [tableView reloadData];
                    [weakSelf removeHud];
                    [tableView.mj_header endRefreshing];
                });
            } failed:^(NSError *error) {
                [weakSelf removeHud];

                [self.table.mj_header endRefreshing];
                
            }];

        }
        
    }];
    
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
       SidModel *sidModl = [AppDelegate shareAppDelegate].sidArray[2];
        [weakSelf addHudWithMessage:@"加载中..."];

        NSString *URLString = [NSString stringWithFormat:@"http://c.3g.163.com/nc/video/list/%@/y/%ld-10.html",sidModl.sid,dataSource.count - dataSource.count%10];
        
        
        
        [[DataManager shareManager] getVideoListWithURLString:URLString ListID:sidModl.sid success:^(NSArray *listArray, NSArray *videoArray) {
            [dataSource addObjectsFromArray:listArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView reloadData];
                [weakSelf removeHud];

                [tableView.mj_header endRefreshing];
            });
        } failed:^(NSError *error) {
            [weakSelf removeHud];

            [tableView.mj_header endRefreshing];

        }];
        // 结束刷新
        [tableView.mj_footer endRefreshing];
    }];
    
    
}

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 274;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"VideoCell";
    VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.model = [dataSource objectAtIndex:indexPath.row];
    [cell.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = indexPath.row;
    
    
    if (wmPlayer&&wmPlayer.superview) {
        if (indexPath.row==currentIndexPath.row) {
            [cell.playBtn.superview sendSubviewToBack:cell.playBtn];
        }else{
            [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
        }
        NSArray *indexpaths = [tableView indexPathsForVisibleRows];
        if (![indexpaths containsObject:currentIndexPath]) {//复用
            
            if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:wmPlayer]) {
                wmPlayer.hidden = NO;
                
            }else{
                wmPlayer.hidden = YES;
            }
        }else{
            if ([cell.backgroundIV.subviews containsObject:wmPlayer]) {
                [cell.backgroundIV addSubview:wmPlayer];
                
                [wmPlayer play];
                wmPlayer.playOrPauseBtn.selected = NO;
                wmPlayer.hidden = NO;
            }
            
        }
    }
    
    
    return cell;
}
-(void)startPlayVideo:(UIButton *)sender{
    currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    if ([UIDevice currentDevice].systemVersion.floatValue>=8||[UIDevice currentDevice].systemVersion.floatValue<7) {
        self.currentCell = (VideoCell *)sender.superview.superview;
        
    }else{//ios7系统 UITableViewCell上多了一个层级UITableViewCellScrollView
        self.currentCell = (VideoCell *)sender.superview.superview.subviews;
        
    }
    VideoModel *model = [dataSource objectAtIndex:sender.tag];
    
    if (wmPlayer) {
        [wmPlayer removeFromSuperview];
        [wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
        [wmPlayer setVideoURLStr:model.mp4_url];
        [wmPlayer play];
        
    }else{
        wmPlayer = [[WMPlayer alloc]initWithFrame:self.currentCell.backgroundIV.bounds videoURLStr:model.mp4_url];
        [wmPlayer.player play];
        
    }
    [self.currentCell.backgroundIV addSubview:wmPlayer];
    [self.currentCell.backgroundIV bringSubviewToFront:wmPlayer];
    [self.currentCell.playBtn.superview sendSubviewToBack:self.currentCell.playBtn];
    [self.table reloadData];

}
#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView ==self.table){
        if (wmPlayer==nil) {
            return;
        }
        
        if (wmPlayer.superview) {
            CGRect rectInTableView = [self.table rectForRowAtIndexPath:currentIndexPath];
            CGRect rectInSuperview = [self.table convertRect:rectInTableView toView:[self.table superview]];
            NSLog(@"rectInSuperview = %@",NSStringFromCGRect(rectInSuperview));
   
            if (rectInSuperview.origin.y<-self.currentCell.backgroundIV.frame.size.height||rectInSuperview.origin.y>self.view.frame.size.height-kNavbarHeight-kTabBarHeight) {//往上拖动
                [self releaseWMPlayer];
                [self.currentCell.playBtn.superview bringSubviewToFront:self.currentCell.playBtn];
            }
        }
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VideoModel *   model = [dataSource objectAtIndex:indexPath.row];
    
    DetailViewController *detailVC = [[DetailViewController alloc]init];
    detailVC.URLString  = model.m3u8_url;
    detailVC.title = model.title;

    //    detailVC.URLString = model.mp4_url;
    [self.navigationController pushViewController:detailVC animated:YES];
    
}
/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
    [wmPlayer.player.currentItem cancelPendingSeeks];
    [wmPlayer.player.currentItem.asset cancelLoading];
    [wmPlayer.player pause];
    
    //移除观察者
    [wmPlayer.currentItem removeObserver:wmPlayer forKeyPath:@"status"];
    
    [wmPlayer removeFromSuperview];
    [wmPlayer.playerLayer removeFromSuperlayer];
    [wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    wmPlayer.player = nil;
    wmPlayer.currentItem = nil;
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [wmPlayer.autoDismissTimer invalidate];
    wmPlayer.autoDismissTimer = nil;
    [wmPlayer.durationTimer invalidate];
    wmPlayer.durationTimer = nil;
    
    
    wmPlayer.playOrPauseBtn = nil;
    wmPlayer.playerLayer = nil;
    wmPlayer = nil;
    
    currentIndexPath = nil;
}
-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self releaseWMPlayer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
