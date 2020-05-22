//
//  FullScreenHelperViewController.m
//  PlayerDemo
//
//  Created by apple on 2020/5/18.
//  Copyright © 2020 DS-Team. All rights reserved.
//

#import "FullScreenHelperViewController.h"

@interface FullScreenHelperViewController ()

@end

@implementation FullScreenHelperViewController
-(BOOL)prefersStatusBarHidden{
    return NO;
}
-(BOOL)shouldAutorotate{
    return YES;
}
-(void)setNeedsStatusBarAppearanceUpdate{

}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

@end

