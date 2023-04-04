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
#import "FullScreenHelperViewController.h"
#import "LandscapeRightViewController.h"
#import "LandscapeLeftViewController.h"
#import "EnterFullScreenTransition.h"
#import "ExitFullScreenTransition.h"

@interface SinaNewsViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,WMPlayerDelegate,UIViewControllerTransitioningDelegate>{

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
    return NO;
}
-(BOOL)shouldAutorotate{
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
-(NSMutableArray *)dataSource{
    if (_dataSource==nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
-(UITableView *)table{
    if(_table==nil){
        _table = [[UITableView alloc] init];
        _table.showsVerticalScrollIndicator = NO;
        _table.delegate = self;
        _table.dataSource = self;
        _table.rowHeight = 274.f;
        _table.separatorStyle=UITableViewCellSeparatorStyleNone;
        if (@available(ios 11.0,*)) {
            UITableView.appearance.estimatedRowHeight = 0;
            UITableView.appearance.estimatedSectionFooterHeight = 0;
            UITableView.appearance.estimatedSectionHeaderHeight = 0;
        }
        if (@available(iOS 15.0, *)) {
            _table.sectionHeaderTopPadding = 0;
                //iOS 刷新机制改变，关闭预取
            _table.prefetchingEnabled = NO;
            } else {
                // Fallback on earlier versions
            }
        [self.view addSubview:_table];
        
        [_table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.leading.trailing.equalTo(self.view);
        }];
    }
    return _table;
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
       if (wmplayer.isFullscreen) {
            [self exitFullScreen];
        }else{
            [self.wmPlayer pause];
            [self releaseWMPlayer];
            self.currentCell.playBtn.hidden = NO;
        }
}
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
   if (self.wmPlayer.viewState==PlayerViewStateSmall) {
            [self enterFullScreen];
       }
}
-(void)enterFullScreen{
    if (self.wmPlayer.viewState!=PlayerViewStateSmall) {
           return;
       }
       LandscapeRightViewController *rightVC = [[LandscapeRightViewController alloc] init];
       [self presentToVC:rightVC];
}
-(void)presentToVC:(FullScreenHelperViewController *)aHelperVC{
     self.wmPlayer.viewState = PlayerViewStateAnimating;
       self.wmPlayer.beforeBounds = self.wmPlayer.bounds;
       self.wmPlayer.beforeCenter = self.wmPlayer.center;
       self.wmPlayer.parentView = self.wmPlayer.superview;
       self.wmPlayer.isFullscreen = YES;
        self.wmPlayer.backBtnStyle = BackBtnStylePop;

       aHelperVC.wmPlayer = self.wmPlayer;
        aHelperVC.modalPresentationStyle = UIModalPresentationFullScreen;
       aHelperVC.transitioningDelegate = self;
       [self presentViewController:aHelperVC animated:YES completion:^{
           self.wmPlayer.viewState = PlayerViewStateFullScreen;
       }];
}
-(void)exitFullScreen{
    if (self.wmPlayer.viewState!=PlayerViewStateFullScreen) {
                 return;
             }
       self.wmPlayer.isFullscreen = NO;
        self.wmPlayer.backBtnStyle = BackBtnStyleClose;
       self.wmPlayer.viewState = PlayerViewStateAnimating;
       [self dismissViewControllerAnimated:YES completion:^{
          self.wmPlayer.viewState  = PlayerViewStateSmall;
       }];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (self.wmPlayer.viewState!=PlayerViewStateSmall) {
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
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
              LandscapeLeftViewController *leftVC = [[LandscapeLeftViewController alloc] init];
            [self presentToVC:leftVC];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            LandscapeRightViewController *rightVC = [[LandscapeRightViewController alloc] init];
            [self presentToVC:rightVC];
        }
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.frame = UIScreen.mainScreen.bounds;
    self.navigationController.navigationBarHidden = NO;
    self.wmPlayer.delegate = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
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
        weakSelf.wmPlayer = [[WMPlayer alloc] initWithFrame:backgroundIV.bounds];
        weakSelf.wmPlayer.delegate = weakSelf;
        weakSelf.wmPlayer.playerModel = playerModel;
        [backgroundIV addSubview:weakSelf.wmPlayer];
        weakSelf.wmPlayer.backBtnStyle = BackBtnStyleClose;
        [backgroundIV bringSubviewToFront:weakSelf.wmPlayer];
        [weakSelf.wmPlayer play];
        [weakSelf.table reloadData];
        weakSelf.wmPlayer.oldFrameToWindow = [weakSelf.wmPlayer convertRect:weakSelf.wmPlayer.bounds toView:[UIApplication sharedApplication].keyWindow];
    };
    
    if (self.wmPlayer&&self.wmPlayer.superview) {
        if (indexPath.row==self.currentCell.videoModel.indexPath.row) {
            cell.playBtn.hidden = YES;
        }else{
            cell.playBtn.hidden = NO;
        }
    }else{
        cell.playBtn.hidden = NO;
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
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[EnterFullScreenTransition alloc] initWithPlayer:self.wmPlayer];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [[ExitFullScreenTransition alloc] initWithPlayer:self.wmPlayer];
}
-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [self releaseWMPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
