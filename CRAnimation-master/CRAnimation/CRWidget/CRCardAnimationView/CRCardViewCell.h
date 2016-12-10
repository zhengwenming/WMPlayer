//
//  CRCardViewCell.h
//  MusicWidgetAnimation
//
//  Created by Bear on 16/5/28.
//  Copyright © 2016年 Bear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRCardViewCell : UIView

@property (strong, nonatomic) NSString  *reuseIdentifier;

@property (strong, nonatomic) CABasicAnimation  *scaleAnimation;
@property (strong, nonatomic) CABasicAnimation  *rotationAnimation;
@property (strong, nonatomic) CABasicAnimation  *flipAnimation;

- (instancetype)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end
