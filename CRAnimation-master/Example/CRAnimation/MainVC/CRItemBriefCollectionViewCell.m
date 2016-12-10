//
//  CRItemBriefCollectionViewCell.m
//  CRAnimation
//
//  Created by Bear on 16/10/12.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "CRItemBriefCollectionViewCell.h"
#import "FLAnimatedImage.h"

@interface CRItemBriefCollectionViewCell ()
{
    FLAnimatedImage         *_image;
    FLAnimatedImageView     *_imageView;
    
    UIView                  *_labelView;
    UILabel                 *_namelabel;
    UILabel                 *_summaryLabel;
}

@end

@implementation CRItemBriefCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createUI];
    }
    
    return self;
}

- (void)createUI
{
    CGFloat off_x = 5;
    
    _imageView = [[FLAnimatedImageView alloc] init];
    _imageView.frame = self.bounds;
    [self addSubview:_imageView];
    
    _labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
    _labelView.backgroundColor = [color_Master colorWithAlphaComponent:0.6];
    [self addSubview:_labelView];
    
    _namelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width - 2 * off_x, 25)];
    _namelabel.textColor = [UIColor whiteColor];
    _namelabel.font = [UIFont systemFontOfSize:14];
    [_labelView addSubview:_namelabel];
    
    _summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width - 2 * off_x, 25)];
    _summaryLabel.textColor = [UIColor whiteColor];
    _summaryLabel.font = [UIFont systemFontOfSize:12];
    [_labelView addSubview:_summaryLabel];
    
    [_labelView setHeight:_namelabel.height + _summaryLabel.height];
    [_labelView BearSetRelativeLayoutWithDirection:kDIR_DOWN destinationView:nil parentRelation:YES distance:0 center:NO];
    
    [_summaryLabel BearSetRelativeLayoutWithDirection:kDIR_DOWN destinationView:nil parentRelation:YES distance:0 center:YES];
    [_namelabel BearSetRelativeLayoutWithDirection:kDIR_UP destinationView:_summaryLabel parentRelation:NO distance:0 center:YES];
}

- (void)loadDemoInfoModel:(CRDemoInfoModel *)demoInfoModel
{
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:demoInfoModel.demoGifName];
    _image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:path]];
    _imageView.animatedImage = _image;
    
    _namelabel.text = demoInfoModel.demoName;
    _summaryLabel.text = demoInfoModel.demoSummary;
}

@end
