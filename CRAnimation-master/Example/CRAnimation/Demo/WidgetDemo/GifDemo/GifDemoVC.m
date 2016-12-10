//
//  GifDemoVC.m
//  CRAnimation
//
//  Created by Bear on 16/10/12.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "GifDemoVC.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface GifDemoVC ()

@end

@implementation GifDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    
    self.backBtnColor = [UIColor blackColor];
    [self addTopBar];
}

- (void)createUI
{
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"GifPlay.gif"];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:path]];
//    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif"]]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.frame = CGRectMake(0.0, 0.0, WIDTH, HEIGHT);
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
