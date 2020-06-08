//
//  LandscapeRightViewController.m
//  PlayerDemo
//
//  Created by apple on 2020/5/20.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "LandscapeRightViewController.h"

@interface LandscapeRightViewController ()

@end

@implementation LandscapeRightViewController

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)dealloc{
    NSLog(@"LandscapeRightViewController dealloc");
}
@end
