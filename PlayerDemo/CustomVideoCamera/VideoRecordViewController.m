//
//  VideoRecordViewController.m
//  iShow
//
//  Created by 胡阳阳 on 17/3/8.
//
//

#import "VideoRecordViewController.h"
#import "VideoCameraView.h"
@interface VideoRecordViewController ()<VideoCameraDelegate>
@property (nonatomic ,strong) UITextField* configWidth;
@property (nonatomic ,strong) UITextField* configHight;
@property (nonatomic ,strong) UITextField* configBit;
@property (nonatomic ,strong) UITextField* configFrameRate;
@property (nonatomic ,strong) UIButton* okBtn;

@end

@implementation VideoRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self clickOKBtn];
}
-(void)clickBackHome{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)clickOKBtn{
    int width,hight,bit,framRate;
    {
        width = 720;
        hight = 1280;
    }
    {
        bit = 2500000;
    }
    {
        framRate = 30;
    }
    bool needNewVideoCamera = YES;
    for (UIView* subView in self.view.subviews) {
        if ([subView isKindOfClass:[VideoCameraView class]]) {
            needNewVideoCamera = NO;
        }
    }
    if (needNewVideoCamera) {
        CGRect frame = [[UIScreen mainScreen] bounds];
        VideoCameraView* videoCameraView = [[VideoCameraView alloc] initWithFrame:frame];
        videoCameraView.delegate = self;
        videoCameraView.width = [NSNumber numberWithInteger:width];
        videoCameraView.hight = [NSNumber numberWithInteger:hight];
        videoCameraView.bit = [NSNumber numberWithInteger:bit];
        videoCameraView.frameRate = [NSNumber numberWithInteger:framRate];
        typeof(self) __weak weakself = self;
        videoCameraView.backToHomeBlock = ^(){
          [weakself.navigationController dismissViewControllerAnimated:NO completion:nil];
        };
        [self.view addSubview:videoCameraView];
    }
}
-(void)presentCor:(UIViewController *)cor{
  [self presentViewController:cor animated:YES completion:nil];
}

-(void)pushCor:(UIViewController *)cor{
  [self.navigationController pushViewController:cor animated:YES];
}
- (BOOL)prefersStatusBarHidden{
  return YES;
}
-(void)dealloc{
    NSLog(@"%@释放了",self.class);
}
@end
