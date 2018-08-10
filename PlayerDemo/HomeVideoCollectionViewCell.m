//
//  HomeVideoCollectionViewCell.m
//  PlayerDemo
//
//  Created by apple on 2018/8/10.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "HomeVideoCollectionViewCell.h"
#import "UIImageView+WebCache.h"

#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
@interface HomeVideoCollectionViewCell(){
    
}

@property (nonatomic ,strong) UIImageView *videoCoverImageView;
@property (nonatomic ,strong) UILabel* titleLabel;
@property (nonatomic ,strong) UILabel* locationLabel;
@property (nonatomic ,strong) UIImageView* iconImgView;
@property (nonatomic ,strong) UILabel* nickeNameLabel;
@property (nonatomic ,strong) UILabel* comment_countLabel;

@end

@implementation HomeVideoCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        self.backgroundColor = [UIColor whiteColor];
        _videoCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, (ScreenWidth/2 - 2)-2, (ScreenWidth/2 - 2)*1.6 -2)];
        //        _videoCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:_videoCoverImageView];
        UIView* superView = self.contentView;
        //        [[AppDelegate appDelegate].cmImageSize setImagesRounded:_videoCoverImageView cornerRadiusValue:3 borderWidthValue:0 borderColorWidthValue:[UIColor whiteColor]];
        _videoCoverImageView.layer.masksToBounds = true;
        _videoCoverImageView.layer.cornerRadius = 3;
        _videoCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_videoCoverImageView setClipsToBounds:YES];
        
        
        
        _locationLabel = [[UILabel alloc]init];
        _locationLabel.text = @"";
        _locationLabel.textColor = [UIColor whiteColor];
        _locationLabel.textAlignment = NSTextAlignmentCenter;
        _locationLabel.font = [UIFont systemFontOfSize:11];
        [superView addSubview:_locationLabel];
        [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(superView).offset(10);
            make.right.equalTo(superView).offset(-15);
        }];
        
        UIImageView* locationImgView = [[UIImageView alloc] init];
        locationImgView.image = [UIImage imageNamed:@"location"];
        [superView addSubview:locationImgView];
        [locationImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_locationLabel);
            make.right.equalTo(_locationLabel.mas_left).offset(-1);
            make.height.equalTo(@(14));
            make.width.equalTo(@(14));
        }];
        
        UIView* locationBGView = [[UIView alloc] init];
        locationBGView.backgroundColor = [UIColor darkGrayColor];
        locationBGView.alpha = .6;
        [_videoCoverImageView addSubview:locationBGView];
        [locationBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_locationLabel);
            make.right.equalTo(superView).offset(-10);
            make.height.equalTo(@(20));
            make.left.equalTo(locationImgView.mas_left).offset(-5);
        }];
        //        [[AppDelegate appDelegate].cmImageSize setViewsRounded:locationBGView cornerRadiusValue:10 borderWidthValue:0 borderColorWidthValue:nil];
        locationBGView.layer.masksToBounds = true;
        locationBGView.layer.cornerRadius = 10;
        
        UIView* bottomBarView = [[UIView alloc] init];
        bottomBarView.backgroundColor = [UIColor clearColor];
        [superView addSubview:bottomBarView];
        [bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(_videoCoverImageView);
            make.height.equalTo(@(30));
        }];
        
        _iconImgView = [[UIImageView alloc] init];
        [superView addSubview:_iconImgView];
        [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(bottomBarView);
            make.left.equalTo(_videoCoverImageView).offset(5);
            make.width.height.equalTo(@(20));
        }];
        //        [[AppDelegate appDelegate].cmImageSize setImagesRounded:_iconImgView cornerRadiusValue:10 borderWidthValue:0 borderColorWidthValue:[UIColor whiteColor]];
        _iconImgView.layer.masksToBounds = true;
        _iconImgView.layer.cornerRadius = 10;
        
        
        
        _comment_countLabel = [[UILabel alloc] init];
        _comment_countLabel.textAlignment = NSTextAlignmentCenter;
        //        _comment_countLabel.textColor = [UIColor colorWithRed:205/256.0 green:205/256.0 blue:205/256.0 alpha:1];
        _comment_countLabel.textColor = [UIColor whiteColor];
        
        _comment_countLabel.font = [UIFont systemFontOfSize:10];
        [superView addSubview:_comment_countLabel];
        [_comment_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomBarView);
            make.right.equalTo(_videoCoverImageView).offset(-5);
        }];
        
        UIImageView* commentImgView = [[UIImageView alloc] init];
        commentImgView.image = [UIImage imageNamed:@"comment"];
        [superView addSubview:commentImgView];
        [commentImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomBarView);
            make.right.equalTo(_comment_countLabel.mas_left).offset(-3);
            make.height.width.equalTo(@(14));
        }];
        
        _nickeNameLabel = [[UILabel alloc] init];
        _nickeNameLabel.textAlignment = NSTextAlignmentCenter;
        _nickeNameLabel.textColor = [UIColor colorWithRed:201/256.0 green:201/256.0 blue:201/256.0 alpha:1];
        //        _nickeNameLabel.textColor = [UIColor whiteColor];
        _nickeNameLabel.font = [UIFont systemFontOfSize:10];
        [superView addSubview:_nickeNameLabel];
        [_nickeNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomBarView);
            make.left.equalTo(_iconImgView.mas_right).offset(3);
            make.right.lessThanOrEqualTo(commentImgView.mas_left).offset(-3);
        }];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        [superView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(bottomBarView.mas_top);
            make.left.equalTo(superView).offset(10);
            make.right.equalTo(superView).offset(-20);
        }];
    }
    return self;
}

-(void)setDataModel:(VideoDataModel *)DataModel
{
    _DataModel = DataModel;
    [_videoCoverImageView sd_setImageWithURL:[NSURL URLWithString:DataModel.cover_url] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"usericon02" ofType:@"png"]]];
    [_iconImgView sd_setImageWithURL:[NSURL URLWithString:DataModel.avatar_thumb] placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"usericon02" ofType:@"png"]]];
    _locationLabel.text = (DataModel.location.length > 0)?DataModel.location:@"中国";
    //    _nickeNameLabel.text = DataModel.nickname;
    [self toSetUpThree_dimensionalShadows:_nickeNameLabel andString:DataModel.nickname];
    
    //    _comment_countLabel.text = DataModel.comment_count;
    [self toSetUpThree_dimensionalShadows:_comment_countLabel andString:DataModel.comment_count];
    
    //    _titleLabel.text = DataModel.title;
    [self toSetUpThree_dimensionalShadows:_titleLabel andString:DataModel.title];
}
-(void)toSetUpThree_dimensionalShadows:(UILabel*)Label andString:(NSString*)str
{
    if (str == nil || str == NULL) {
        str = @"";
    }
    if ([str isKindOfClass:[NSNull class]]) {
        str = @"";
    }
    if (!(str.length >0)) {
        str = @"";
    }
    NSShadow *shadow = [[NSShadow alloc]init];
    shadow.shadowBlurRadius = 0.5;
    shadow.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    shadow.shadowOffset = CGSizeMake(0, .6);
    NSMutableAttributedString* labelAttribute = [[NSMutableAttributedString alloc]initWithString:str];
    [labelAttribute addAttributes:@{NSStrokeColorAttributeName:[UIColor whiteColor],NSStrokeWidthAttributeName:@(-0.4),NSShadowAttributeName:shadow} range:NSMakeRange(0, labelAttribute.length)];
    [Label setAttributedText:labelAttribute];
}
@end
