//
//  LandscapeLeftViewController.m
//  PlayerDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "LandscapeLeftViewController.h"

@interface LandscapeLeftViewController ()

@end

@implementation LandscapeLeftViewController
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeLeft;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)dealloc{
    NSLog(@"LandscapeLeftViewController dealloc");
}
@end
