/*!
 @header SinaNewsViewController.m
 
 @abstract  作者Github地址：https://github.com/zhengwenming
            作者CSDN博客地址:http://blog.csdn.net/wenmingzheng
 
 @author   Created by zhengwenming on  16/1/19
 
 @version 1.00 16/1/19 Creation(版本信息)
 
   Copyright © 2016年 郑文明. All rights reserved.
 */

#import "SinaNewsViewController.h"
#import "VideoCell.h"
#import "WMPlayer.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "Masonry.h"


@interface SinaNewsViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,WMPlayerDelegate>{

}
@property(nonatomic,strong)VideoCell *currentCell;
@property(nonatomic,strong)WMPlayer *wmPlayer;
@property(nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation SinaNewsViewController
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden{
    if (self.wmPlayer.isFullscreen) {
        return self.wmPlayer.prefersStatusBarHidden;
    }
    return NO;
}
-(NSMutableArray *)dataSource{
    if (_dataSource==nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
-(UITableView *)table{
    if(_table==nil){
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
        _table.showsVerticalScrollIndicator = NO;
        _table.delegate = self;
        _table.dataSource = self;
        _table.separatorStyle=UITableViewCellSeparatorStyleNone;
        if (@available(ios 11.0,*)) {
            UITableView.appearance.estimatedRowHeight = 0;
            UITableView.appearance.estimatedSectionFooterHeight = 0;
            UITableView.appearance.estimatedSectionHeaderHeight = 0;
        }
        [self.view addSubview:_table];
    }
    return _table;
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    NSLog(@"didClickedCloseButton");
        if (wmplayer.isFullscreen) {
            [self toOrientation:UIInterfaceOrientationPortrait];
        }else{
            [self.wmPlayer pause];
            [self releaseWMPlayer];
            [self.currentCell.playBtn.superview bringSubviewToFront:self.currentCell.playBtn];
        }
}
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (self.wmPlayer.isFullscreen) {//全屏
        [self toOrientation:UIInterfaceOrientationPortrait];
    }else{//非全屏
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    }
}
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    if(self.wmPlayer.isFullscreen==NO){
        DetailViewController *detailVC = [DetailViewController new];
        detailVC.playerModel = wmplayer.playerModel;
        detailVC.wmPlayer = self.wmPlayer;
        [self.currentCell.playBtn.superview bringSubviewToFront:self.currentCell.playBtn];
        //push测试
        [self.navigationController pushViewController:detailVC animated:YES];
        [self releaseWMPlayer];
        
        //present测试
//        [self presentViewController:detailVC animated:YES completion:^{
//
//        }];
    }else{
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
}
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
}

///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidReadyToPlay");
}
-(void)wmplayerGotVideoSize:(WMPlayer *)wmplayer videoSize:(CGSize )presentationSize{

}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
}
//操作栏隐藏或者显示都会调用此方法
-(void)wmplayer:(WMPlayer *)wmplayer isHiddenTopAndBottomView:(BOOL)isHidden{
    [self setNeedsStatusBarAppearanceUpdate];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer==nil){
        return;
    }
    if (self.wmPlayer.playerModel.verticalVideo) {
        return;
    }
    if (self.wmPlayer.isLockScreen){
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
                [self toOrientation:UIInterfaceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
        }
            break;
        default:
            break;
    }
}
//点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
-(void)toOrientation:(UIInterfaceOrientation)orientation{
    //获取到当前状态条的方向
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self.wmPlayer removeFromSuperview];
    //根据要旋转的方向,使用Masonry重新修改限制
    if (orientation ==UIInterfaceOrientationPortrait) {
        [self.currentCell.backgroundIV addSubview:self.wmPlayer];
        self.wmPlayer.isFullscreen = NO;
        self.wmPlayer.backBtnStyle = BackBtnStyleClose;
        [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.wmPlayer.superview);
        }];
        
    }else{
        [[UIApplication sharedApplication].keyWindow addSubview:self.wmPlayer];
        self.wmPlayer.isFullscreen = YES;
        self.wmPlayer.backBtnStyle = BackBtnStylePop;
        if(currentOrientation ==UIInterfaceOrientationPortrait){
            if (self.wmPlayer.playerModel.verticalVideo) {
                [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.wmPlayer.superview);
                }];
            }else{
                [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@([UIScreen mainScreen].bounds.size.height));
                    make.height.equalTo(@([UIScreen mainScreen].bounds.size.width));
                    make.center.equalTo(self.wmPlayer.superview);
                }];
            }
           
        }else{
            if (self.wmPlayer.playerModel.verticalVideo) {
                [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.wmPlayer.superview);
                }];
            }else{
                [self.wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@([UIScreen mainScreen].bounds.size.width));
                    make.height.equalTo(@([UIScreen mainScreen].bounds.size.height));
                    make.center.equalTo(self.wmPlayer.superview);
                }];
            }
           
        }
    }
    //iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
    //也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
    if (self.wmPlayer.playerModel.verticalVideo) {
        [self setNeedsStatusBarAppearanceUpdate];
    }else{
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
        //更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
        //给你的播放视频的view视图设置旋转
        [UIView animateWithDuration:0.4 animations:^{
            self.wmPlayer.transform = CGAffineTransformIdentity;
            self.wmPlayer.transform = [WMPlayer getCurrentDeviceOrientation];
            [self.wmPlayer layoutIfNeeded];
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                    selector:@selector(onDeviceOrientationChange:)
                    name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [self.table registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
        [self.dataSource addObjectsFromArray:dateAry];
        [self.table reloadData];
    }];
}

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 274;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:@"VideoCell"];
    cell.videoModel = [self.dataSource objectAtIndex:indexPath.row];
    cell.videoModel.indexPath = indexPath;
    __weak __typeof(&*self) weakSelf = self;
    cell.startPlayVideoBlcok = ^(UIImageView *backgroundIV, VideoDataModel *videoModel) {
        [weakSelf releaseWMPlayer];
        weakSelf.currentCell = (VideoCell *)backgroundIV.superview.superview;
        WMPlayerModel *playerModel = [WMPlayerModel new];
        playerModel.title = videoModel.nickname;
        playerModel.videoURL = [NSURL URLWithString:videoModel.video_url];
//        playerModel.videoURL = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];

        
        playerModel.indexPath = indexPath;
        weakSelf.wmPlayer = [[WMPlayer alloc] init];
        weakSelf.wmPlayer.delegate = weakSelf;
        weakSelf.wmPlayer.playerModel = playerModel;
        [backgroundIV addSubview:weakSelf.wmPlayer];
        
        [weakSelf.wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(backgroundIV);
        }];
        [weakSelf.wmPlayer play];
        [weakSelf.table reloadData];
    };
    
    if (self.wmPlayer&&self.wmPlayer.superview) {
        if (indexPath.row==self.currentCell.videoModel.indexPath.row) {
            [cell.playBtn.superview sendSubviewToBack:cell.playBtn];
        }else{
            [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
        }
    }
    return cell;
}

#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView ==self.table){
        if (self.wmPlayer==nil) {
            return;
        }
        if (self.wmPlayer.superview) {
            CGRect rectInTableView = [self.table rectForRowAtIndexPath:self.currentCell.videoModel.indexPath];
            CGRect rectInSuperview = [self.table convertRect:rectInTableView toView:[self.table superview]];
            if (rectInSuperview.origin.y<-self.currentCell.backgroundIV.frame.size.height||rectInSuperview.origin.y>[UIScreen mainScreen].bounds.size.height-([WMPlayer IsiPhoneX]?88:64)-([WMPlayer IsiPhoneX]?83:49)) {//拖动
                [self releaseWMPlayer];
                [self.currentCell.playBtn.superview bringSubviewToFront:self.currentCell.playBtn];
            }
        }
    }
}
/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;
}
-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
