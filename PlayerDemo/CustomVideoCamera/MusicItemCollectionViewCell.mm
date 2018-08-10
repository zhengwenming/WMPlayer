//
//  MusicItemCollectionViewCell.m
//  addproject
//
//  Created by 胡阳阳 on 17/3/3.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MusicItemCollectionViewCell.h"
#import "UIView+Tools.h"
#import "Masonry.h"
@implementation MusicItemCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        
//        83, 115

        _iconImgView = [[UIImageView alloc] init];
        [self addSubview:_iconImgView];
        [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.width.height.equalTo(@(70));
            make.centerX.equalTo(self);
        }];
        [_iconImgView makeCornerRadius:35 borderColor:nil borderWidth:0];
        _iconImgView.layer.masksToBounds = YES;
        
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor grayColor];
        [_nameLabel setFont:[UIFont systemFontOfSize:11]];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(_iconImgView.mas_bottom).offset(5);
            make.left.right.equalTo(_iconImgView);
        }];
        
        _CheckMarkImgView = [[UIImageView alloc] init];
        _CheckMarkImgView.image = [UIImage imageNamed:@"EditVideoCheckmark"];
        [self addSubview:_CheckMarkImgView];
        _CheckMarkImgView.frame = CGRectMake(0, 0, 83, 115);
        _CheckMarkImgView.contentMode = UIViewContentModeScaleToFill;
        _CheckMarkImgView.hidden = YES;
    }
    return self;
}
@end
