//
//  WMLightView.m
//  WMPlayer
//
//  Created by 郑文明 on 16/10/26.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "WMLightView.h"
#import "WMPlayer.h"
#define LIGHT_VIEW_COUNT 16

@interface WMLightView ()
@property (nonatomic, strong) NSTimer			*timer;

@end

@implementation WMLightView
+ (instancetype)sharedLightView{
     WMLightView *lightView = [[WMLightView alloc] init];
        lightView.backgroundColor = [UIColor whiteColor];
    return lightView;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width) * 0.5, ([UIScreen mainScreen].bounds.size.height) * 0.5, 155, 155);
        self.layer.cornerRadius  = 10;
        
        {
            UILabel *titleLabel      = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
            titleLabel.font          = [UIFont boldSystemFontOfSize:16.0];
            titleLabel.textColor     = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text          = @"亮度";
            [self addSubview:titleLabel];
        }
        
        
        {
            self.centerLightIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 79, 76)];
            self.centerLightIV.image        = [UIImage imageNamed:[@"WMPlayer.bundle" stringByAppendingPathComponent:@"play_new_brightness_day"]];
            self.centerLightIV.center = CGPointMake(155 * 0.5, 155 * 0.5);
            [self addSubview:self.centerLightIV];
        }
        

        
        {
        self.lightBackView         = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
        self.lightBackView .backgroundColor = [UIColor colorWithRed:65.0/255.0 green:67.0/255.0 blue:70.0/255.0 alpha:1.0];
        [self addSubview:self.lightBackView ];
        }
    
        
        self.lightViewArr = [NSMutableArray arrayWithCapacity:16];
        CGFloat wiew_width = (self.lightBackView.bounds.size.width - 17) / 16;
        CGFloat wiew_Height = 5;
        CGFloat wiew_Y = 1;
        for (int i = 0; i < LIGHT_VIEW_COUNT; i++) {
            CGFloat wiew_X          = i * (wiew_width + 1) + 1;
            UIView  * view = [[UIView alloc] initWithFrame:CGRectMake(wiew_X, wiew_Y, wiew_width, wiew_Height)];
            view.backgroundColor = [UIColor whiteColor];
            [self.lightViewArr addObject:view];
            [self.lightBackView addSubview:view];
        }
        
        [self updateLongView:[UIScreen mainScreen].brightness];

    
        //通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        //KVO
        [[UIScreen mainScreen] addObserver:self
                                forKeyPath:@"brightness"
                                   options:NSKeyValueObservingOptionNew context:NULL];
        self.alpha = 0.0;
    }
    return self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CGFloat sound = [change[@"new"] floatValue];
    if (self.alpha == 0.0) {
        self.alpha = 1.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideLightView];
        });
    }
    
    [self updateLongView:sound];
}

- (void)onOrientationDidChange:(NSNotification *)notify {
    self.alpha = 0.0;
}
- (void)hideLightView{
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}
#pragma mark - Update View
- (void)updateLongView:(CGFloat)sound {
    CGFloat stage = 1 / 15.0;
    NSInteger level = sound / stage;
    
    for (int i = 0; i < self.lightViewArr.count; i++) {
        UIView *aView = self.lightViewArr[i];
        if (i <= level) {
            aView.hidden = NO;
        } else {
            aView.hidden = YES;
        }
    }
    [self setNeedsLayout];

}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.transform = [WMPlayer getCurrentDeviceOrientation];
    self.transform = CGAffineTransformIdentity;
    self.center = [UIApplication sharedApplication].keyWindow.center;
}
- (void)dealloc {
    self.lightViewArr = nil;
    self.lightBackView = nil;
    NSLog(@"WMLightView dealloc");
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
