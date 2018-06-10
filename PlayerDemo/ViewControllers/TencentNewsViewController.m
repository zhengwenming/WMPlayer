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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray arrayWithObjects:@"去相册里面选择一个视频播放", nil];
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}
///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    if (wmplayer.isFullscreen) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        //刷新
        [UIViewController attemptRotationToDeviceOrientation];
    }else{
        self.table.hidden = NO;
        [self releaseWMPlayer];
    }
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
                        [self playWithPlayerItem:playerItem];
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
-(void)playWithPlayerItem:(AVPlayerItem *)playerItem{
    WMPlayerModel *playerModel = [WMPlayerModel new];
    playerModel.playerItem = playerItem;
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
/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
    [self.wmPlayer pause];
    [self.wmPlayer removeFromSuperview];
    self.wmPlayer = nil;
}
@end
