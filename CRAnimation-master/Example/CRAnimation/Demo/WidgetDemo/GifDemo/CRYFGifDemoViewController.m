//
//  CRYFGifDemoViewController.m
//  CRAnimation
//
//  Created by Bear on 16/10/12.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "CRYFGifDemoViewController.h"
#import "YLImageView.h"
#import "YLGIFImage.h"

@interface CRYFGifDemoViewController ()

@end

@implementation CRYFGifDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    [self addTopBar];
}

- (void)createUI
{
    YLImageView* imageView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [self.view addSubview:imageView];
    imageView.image = [YLGIFImage imageNamed:@"CardFlipGif.gif"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
