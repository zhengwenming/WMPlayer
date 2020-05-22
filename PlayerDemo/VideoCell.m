//
//  VideoCell.m
//  WMVideoPlayer
//
//  Created by zhengwenming on 16/1/17.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "VideoCell.h"
#import "UIImageView+WebCache.h"

@implementation VideoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundIV.backgroundColor = [UIColor blackColor];
    self.backgroundIV.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)startPlayVideo:(UIButton *)sender{
    if (self.startPlayVideoBlcok) {
        self.startPlayVideoBlcok(self.backgroundIV,self.videoModel);
    }
}
-(void)setVideoModel:(VideoDataModel *)videoModel{
    _videoModel = videoModel;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel.text = videoModel.nickname;
    self.descriptionLabel.text = videoModel.location;
    [self.backgroundIV sd_setImageWithURL:[NSURL URLWithString:videoModel.cover_url] placeholderImage:[UIImage imageNamed:@"logo"]];
    self.countLabel.text = [NSString stringWithFormat:@"%ld.%ld万",[videoModel.play_count integerValue]/10000,[videoModel.play_count integerValue]/1000-[videoModel.comment_count integerValue]/10000];
    
}

@end
