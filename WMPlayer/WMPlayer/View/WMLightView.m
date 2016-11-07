//
//  WMLightView.m
//  WMPlayer
//
//  Created by 郑文明 on 16/10/26.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "WMLightView.h"
#define LIGHT_VIEW_COUNT 16

@implementation WMLightView
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(void)awakeFromNib{
    self.lightViewArr = [[NSMutableArray alloc] init];
    self.layer.cornerRadius = 10.0;
    self.centerLightIV.image = [UIImage imageNamed:[@"WMPlayer.bundle" stringByAppendingPathComponent:@"play_new_brightness_day"]];
    float viewWidth = (155-20 - (16 + 1))/16;//155为总宽度，2*10为左右10个间距空隙，16+1为每个view左右两边的1个单位的空隙，/16的意思是16等分
    for (int i = 0; i < LIGHT_VIEW_COUNT; ++i) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(1 + i * (viewWidth + 1), 1, viewWidth, 6 - 2)];
        view.backgroundColor = [UIColor whiteColor];
        [self.lightViewArr addObject:view];
        [self.lightBackView addSubview:view];
    }
    [super awakeFromNib];
}

-(void)changeLightViewWithValue:(float)lightValue{
    NSInteger allCount = self.lightViewArr.count;
    NSInteger lightCount = lightValue * allCount;
    for (int i = 0; i < allCount; ++i) {
        UIView * view = self.lightViewArr[i];
        if (i < lightCount) {
            view.backgroundColor = [UIColor whiteColor];
        }else{
            view.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:67.0/255.0 blue:70.0/255.0 alpha:1.0];
        }
    }
}

//-(void)hideTheLightViewWithHidden:(BOOL)hidden{
//    if (hidden) {
//        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//            self.alpha = 0.0;
//            if (iOS8) {
//                self.superview.alpha = 0.0;
//            }
//        } completion:nil];
//    }else{
//        self.alpha = 1.0;
//        if (iOS8) {
//            self.superview.alpha = 1.0;
//        }
//    }
//}
- (void)dealloc
{
    self.lightViewArr = nil;
    self.lightBackView = nil;
    NSLog(@"WMLightView dealloc");
}
@end
