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
-(BOOL)shouldAutorotate{
    return YES;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}
@end
