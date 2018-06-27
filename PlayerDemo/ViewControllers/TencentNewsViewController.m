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
#import "TZImagePickerController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TencentNewsViewController ()<UITableViewDelegate,UITableViewDataSource,TZImagePickerControllerDelegate,WMPlayerDelegate>{
    
}
@property(nonatomic,retain)VideoCell *currentCell;
@property(nonatomic,retain)NSMutableArray *dataSource;
@property(nonatomic,strong)WMPlayer *wmPlayer;
@end

@implementation TencentNewsViewController
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden{
    if (self.wmPlayer.isFullscreen) {
        return self.wmPlayer.prefersStatusBarHidden;
    }
    return NO;
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
        [self.view addSubview:self.wmPlayer];
        self.wmPlayer.isFullscreen = NO;
        self.wmPlayer.backBtnStyle = BackBtnStyleClose;
        
        
        [self.wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.wmPlayer.superview).offset([WMPlayer IsiPhoneX]?88:64);
            make.leading.trailing.equalTo(self.wmPlayer.superview);
            make.height.equalTo(@(([UIScreen mainScreen].bounds.size.width)*9/16.0));
            make.width.equalTo(@([UIScreen mainScreen].bounds.size.width));
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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray arrayWithObjects:@"去相册里面选择一个视频播放", nil];
    //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(onDeviceOrientationChange:)
                name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    NSLog(@"didClickedCloseButton");
    if (wmplayer.isFullscreen) {
        [self toOrientation:UIInterfaceOrientationPortrait];
    }else{
        [self releaseWMPlayer];
        self.table.hidden =NO;
    }
}
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (self.wmPlayer.isFullscreen) {//全屏
        [self toOrientation:UIInterfaceOrientationPortrait];
    }else{//非全屏
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    }
}
//操作栏隐藏或者显示都会调用此方法
-(void)wmplayer:(WMPlayer *)wmplayer isHiddenTopAndBottomView:(BOOL)isHidden{
    [self setNeedsStatusBarAppearanceUpdate];
}
-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.textLabel.numberOfLines = 3;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, id asset) {
            if ([asset isKindOfClass:[PHAsset class]]) {
                PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
                option.networkAccessAllowed = YES;
                option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%.2f",progress);
                    });
                };
                [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *title = info[@"PHImageFileSandboxExtensionTokenKey"];
                        
                        [self playWithPlayerItem:playerItem videoTitle:[title componentsSeparatedByString:@"/"].lastObject];
                    });
                }];
            } else if ([asset isKindOfClass:[ALAsset class]]) {
                ALAsset *alAsset = (ALAsset *)asset;
                ALAssetRepresentation *defaultRepresentation = [alAsset defaultRepresentation];
                NSString *uti = [defaultRepresentation UTI];
                NSURL *videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
                [self playWithVideoUrl:videoURL];
            }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
-(void)playWithVideoUrl:(NSURL *)videoUrl{
    WMPlayerModel *playerModel = [WMPlayerModel new];
    playerModel.videoURL = videoUrl;
    self.wmPlayer = [[WMPlayer alloc] init];
    self.wmPlayer.delegate = self;
    self.wmPlayer.playerModel = playerModel;
    [self.view addSubview:self.wmPlayer];
    [self.wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.wmPlayer.superview).offset([WMPlayer IsiPhoneX]?88:64);
        make.leading.trailing.equalTo(self.wmPlayer.superview);
        make.height.equalTo(@(([UIScreen mainScreen].bounds.size.width)*9/16.0));
        make.width.equalTo(@([UIScreen mainScreen].bounds.size.width));
    }];
    [self.wmPlayer play];
    self.table.hidden = YES;
}
-(void)playWithPlayerItem:(AVPlayerItem *)playerItem videoTitle:(NSString *)videoTitle{
    WMPlayerModel *playerModel = [WMPlayerModel new];
    playerModel.playerItem = playerItem;
    playerModel.title = videoTitle;
    self.wmPlayer = [WMPlayer playerWithModel:playerModel];
    self.wmPlayer.delegate = self;
    [self.view addSubview:self.wmPlayer];
    
    [self.wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.wmPlayer.superview).offset([WMPlayer IsiPhoneX]?88:64);
        make.leading.trailing.equalTo(self.wmPlayer.superview);
        make.height.equalTo(@(([UIScreen mainScreen].bounds.size.width)*9/16.0));
        make.width.equalTo(@([UIScreen mainScreen].bounds.size.width));
    }];
    [self.wmPlayer play];
    self.table.hidden = YES;
}
/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
    [self.wmPlayer pause];
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;
}
-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
