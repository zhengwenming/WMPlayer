//
//  TestFFmpegViewController.m
//  PlayerDemo
//
//  Created by apple on 2019/1/10.
//  Copyright © 2019年 DS-Team. All rights reserved.
//

#import "TestFFmpegViewController.h"

#define DocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define BundlePath(res) [[NSBundle mainBundle] pathForResource:res ofType:nil]
#define DocumentPath(res) [DocumentDir stringByAppendingPathComponent:res]

//链接：https://www.jianshu.com/p/c236287e71ec

@interface TestFFmpegViewController ()

@end

@implementation TestFFmpegViewController


//extern int ffmpeg_main(int argc, char * argv[]);
//
//-(void)ffmpegTest:(UIBarButtonItem *)sender{
////    [self logoBtnClick:nil];
//    
////    [self sliceBtnClick:nil];
//    [self transBtnClick:nil];
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"转码" style:0 target:self action:@selector(ffmpegTest:)];
//    
//    
//}
////1、视频切分为图片。
//- (IBAction)sliceBtnClick:(UIButton *)sender
//{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        char *movie = (char *)[BundlePath(@"1.mp4") UTF8String];
//        char *outPic = (char *)[DocumentPath(@"%05d.jpg") UTF8String];
//        char* a[] = {
//            "ffmpeg",
//            "-i",
//            movie,
//            "-r",
//            "10",
//            outPic
//        };
//        ffmpeg_main(sizeof(a)/sizeof(*a), a);
//    });
//}
////图片、声音合成视频。
//- (IBAction)composeBtnClick:(UIButton *)sender
//{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        char *outPic = (char *)[DocumentPath(@"%05d.jpg") UTF8String];
//        char *movie = (char *)[DocumentPath(@"1.mp4") UTF8String];
//        char* a[] = {
//            "ffmpeg",
//            "-i",
//            outPic,
//            "-vcodec",
//            "mpeg4",
//            movie
//        };
//        ffmpeg_main(sizeof(a)/sizeof(*a), a);
//    });
//}
//
//
////视频编码转换。
//- (IBAction)transBtnClick:(UIButton *)sender
//{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        char *outPic = (char *)[DocumentPath(@"out.avi") UTF8String];
//        char *movie = (char *)[BundlePath(@"1.mp4") UTF8String];
//        char* a[] = {
//            "ffmpeg",
//            "-i",
//            movie,
//            "-vcodec",
//            "mpeg4",
//            outPic
//        };
//        ffmpeg_main(sizeof(a)/sizeof(*a), a);
//    });
//}
////视频加水印
//- (IBAction)logoBtnClick:(UIButton *)sender
//{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        char *outPic = (char *)[DocumentPath(@"logo.mp4") UTF8String];
//        char *movie = (char *)[BundlePath(@"1.mp4") UTF8String];
//        char logo[1024];
//        // 左上
//        sprintf(logo, "movie=%s [logo]; [in][logo] overlay=30:10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
//
//        // 左下
//        //sprintf(logo, "movie=%s [logo]; [in][logo] overlay=30:main_h-overlay_h-10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
//
//        // 右下
//        //sprintf(logo, "movie=%s [logo]; [in][logo] overlay=main_w-overlay_w-10:main_h-overlay_h-10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
//
//        // 右上
//        //sprintf(logo, "movie=%s [logo]; [in][logo] overlay=main_w-overlay_w-10:10 [out]", [BundlePath(@"ff.jpg") UTF8String]);
//
//        char* a[] = {
//            "ffmpeg",
//            "-i",
//            movie,
//            "-vf",
//            logo,
//            outPic
//        };
//        ffmpeg_main(sizeof(a)/sizeof(*a), a);
//    });
//}
////视频滤镜
//- (IBAction)filterBtnClick:(id)sender
//{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        char *outPic = (char *)[DocumentPath(@"filter.mp4") UTF8String];
//        char *movie = (char *)[BundlePath(@"1.mp4") UTF8String];
//        // 画格子
//        //char *filter = "drawgrid=w=iw/3:h=ih/3:t=2:c=white@0.5";
//
//        // 画矩形
//        char *filter = "drawbox=x=10:y=20:w=200:h=60:color=red@0.5";
//
//        // 裁剪
//        //char *filter = "crop=in_w/2:in_h/2:(in_w-out_w)/2+((in_w-out_w)/2)*sin(n/10):(in_h-out_h)/2 +((in_h-out_h)/2)*sin(n/7)";
//
//        char* a[] = {
//            "ffmpeg",
//            "-i",
//            movie,
//            "-vf",
//            filter,
//            outPic
//        };
//        ffmpeg_main(sizeof(a)/sizeof(*a), a);
//    });
//}

@end
