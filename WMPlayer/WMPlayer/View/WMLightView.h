//
//  WMLightView.h
//  WMPlayer
//
//  Created by 郑文明 on 16/10/26.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMLightView : UIView
@property (weak, nonatomic) IBOutlet UIView *lightBackView;
@property (weak, nonatomic) IBOutlet UIImageView *centerLightIV;

@property (nonatomic, strong) NSMutableArray * lightViewArr;

-(void)changeLightViewWithValue:(float)lightValue;
@end
