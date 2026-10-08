//
//  VideoDataModel.m
//  PlayerDemo
//
//  Created by apple on 2018/8/10.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "VideoDataModel.h"
#import "AFNetworking.h"
@implementation CommentDataModel
-(id)initCommentDataWithDic:(NSDictionary*)Dic
{
    if (self = [super init]) {
        /*
         content = "\U6211\U6765\U53d1\U4e00\U6761\U54c8\U54c8";
         "created_time" = 1490157509;
         "dynamic_id" = 39;
         faceurl = "http://userface.ispeak.cn/default/1000";
         "from_nickname" = "\U9633\U773c\U7684\U718a";
         "from_uid" = 80061831;
         "iconindex" = 1000;
         "refer_uid" = "<null>";
         */
        if ([Dic objectForKey:@"content"] && ![[Dic objectForKey:@"content"] isKindOfClass:[NSNull class]]) {
            self.content = [Dic objectForKey:@"content"];
        }
        if ([Dic objectForKey:@"created_time"] && ![[Dic objectForKey:@"created_time"] isKindOfClass:[NSNull class]]) {
            self.createdTime = [self updateTimeForRow:[Dic objectForKey:@"created_time"]];
        }
        if ([Dic objectForKey:@"dynamic_id"] && ![[Dic objectForKey:@"dynamic_id"] isKindOfClass:[NSNull class]]) {
            self.dynamicID = [Dic objectForKey:@"dynamic_id"];
        }
        int iconIndex = 0;
        if ([Dic objectForKey:@"iconindex"] && ![[Dic objectForKey:@"iconindex"] isKindOfClass:[NSNull class]]) {
            iconIndex = [[Dic objectForKey:@"iconindex"] intValue];
        }
        self.iconIndex = [NSString stringWithFormat:@"%d",iconIndex];
        if ([Dic objectForKey:@"faceurl"] && ![[Dic objectForKey:@"faceurl"] isKindOfClass:[NSNull class]]) {
            if (iconIndex == 1000) {
                //                self.faceurl = [[NSBundle mainBundle]pathForResource:kDefaultAvatarIcon ofType:kPngName];
            }else
            {
                self.faceurl = [Dic objectForKey:@"faceurl"];
            }
        }
        if ([Dic objectForKey:@"from_nickname"] && ![[Dic objectForKey:@"from_nickname"] isKindOfClass:[NSNull class]]) {
            self.selfNickName = [Dic objectForKey:@"from_nickname"];
        }
        if ([Dic objectForKey:@"from_uid"] && ![[Dic objectForKey:@"from_uid"] isKindOfClass:[NSNull class]]) {
            self.selfUID = [Dic objectForKey:@"from_uid"];
        }
        if ([Dic objectForKey:@"refer_uid"] && ![[Dic objectForKey:@"refer_uid"] isKindOfClass:[NSNull class]]) {
            self.referUID = [Dic objectForKey:@"refer_uid"];
        }
    }
    return self;
}
- (NSString *)updateTimeForRow:(NSString *)createTimeString {
    
    // 获取当前时时间戳 1466386762.345715 十位整数 6位小数
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    // 创建歌曲时间戳(后台返回的时间 一般是13位数字)
    NSTimeInterval createTime = [createTimeString longLongValue];
    // 时间差
    NSTimeInterval time = currentTime - createTime;
    
    NSInteger sec = time/60;
    if (sec<60) {
        return [NSString stringWithFormat:@"%ld分钟前",(long)sec];
    }
    
    // 秒转小时
    NSInteger hours = time/3600;
    if (hours<24) {
        return [NSString stringWithFormat:@"%ld小时前",(long)hours];
    }
    //秒转天数
    NSInteger days = time/3600/24;
    if (days < 30) {
        return [NSString stringWithFormat:@"%ld天前",(long)days];
    }
    //秒转月
    NSInteger months = time/3600/24/30;
    if (months < 12) {
        return [NSString stringWithFormat:@"%ld月前",(long)months];
    }
    //秒转年
    NSInteger years = time/3600/24/30/12;
    return [NSString stringWithFormat:@"%ld年前",(long)years];
}
+(void)getCommentDataWithBlockWithDynamicID:(NSString*)DynamicID forFlag:(int)flag  AndPage:(NSString*)page ForHandelBlock:(void (^)(NSArray* dateAry, int code))block
{
    
    
}

@end


@implementation VideoDataModel
-(id)initVideoDataWithDic:(NSDictionary*)Dic
{
    if (self = [super init]) {
        if ([Dic objectForKey:@"data"] && ![[Dic objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
            NSDictionary* videoInfo = [Dic objectForKey:@"data"];
            self.title = [videoInfo objectForKey:@"text"];
            self.stats_tips = [videoInfo objectForKey:@"tips"];
            self.location = [videoInfo objectForKey:@"location"];
            if ([videoInfo objectForKey:@"author"] && ![[videoInfo objectForKey:@"author"] isKindOfClass:[NSNull class]]) {
                NSDictionary* authorDic = [videoInfo objectForKey:@"author"];
                self.nickname = [authorDic objectForKey:@"nickname"];
                self.avatar_thumb = [[[authorDic objectForKey:@"avatar_thumb"] objectForKey:@"url_list"] objectAtIndex:0];
            }
            
            if ([videoInfo objectForKey:@"video"] && ![[videoInfo objectForKey:@"video"] isKindOfClass:[NSNull class]]) {
                NSDictionary* videoUrlDic = [videoInfo objectForKey:@"video"];
                self.cover_url = [[[videoUrlDic objectForKey:@"cover"] objectForKey:@"url_list"] objectAtIndex:0];
                self.video_url = [[videoUrlDic objectForKey:@"download_url"] objectAtIndex:0];
            }
            
            if ([videoInfo objectForKey:@"stats"] && ![[videoInfo objectForKey:@"stats"] isKindOfClass:[NSNull class]]) {
                NSDictionary* statsDic = [videoInfo objectForKey:@"stats"];
                self.comment_count = [NSString stringWithFormat:@"%d",[[statsDic objectForKey:@"comment_count"] intValue]];
                self.digg_count = [NSString stringWithFormat:@"%d",[[statsDic objectForKey:@"digg_count"] intValue]];
                self.play_count = [NSString stringWithFormat:@"%d",[[statsDic objectForKey:@"play_count"] intValue]];
                self.share_count = [NSString stringWithFormat:@"%d",[[statsDic objectForKey:@"share_count"] intValue]];
            }
        }
    }
    return self;
}


+(void)getHomePageVideoDataWithBlock:(void (^)(NSArray* dateAry, NSError* error))block
{
    // 原火山小视频接口已下线，此处改为返回一组固定的公开测试视频
    NSArray *videos = @[
        @{@"title" : @"Apple BipBop 高级示例（HLS）",
          @"nickname" : @"BipBop",
          @"location" : @"苹果官方示例",
          @"video_url" : @"https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8",
          @"cover_url" : @"https://picsum.photos/seed/bipbop/400/600",
          @"avatar_thumb" : @"https://picsum.photos/seed/bipbop/100/100",
          @"play_count" : @"128000",
          @"comment_count" : @"3200"},
        @{@"title" : @"Apple BipBop 4:3（HLS）",
          @"nickname" : @"BipBop 4:3",
          @"location" : @"苹果官方示例",
          @"video_url" : @"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8",
          @"cover_url" : @"https://picsum.photos/seed/bipbop43/400/600",
          @"avatar_thumb" : @"https://picsum.photos/seed/bipbop43/100/100",
          @"play_count" : @"96000",
          @"comment_count" : @"2100"},
        @{@"title" : @"Sintel 预告片",
          @"nickname" : @"Sintel",
          @"location" : @"W3C 媒体测试",
          @"video_url" : @"https://media.w3.org/2010/05/sintel/trailer.mp4",
          @"cover_url" : @"https://media.w3.org/2010/05/sintel/poster.png",
          @"avatar_thumb" : @"https://picsum.photos/seed/sintel/100/100",
          @"play_count" : @"215000",
          @"comment_count" : @"5400"},
        @{@"title" : @"Big Buck Bunny 预告片",
          @"nickname" : @"Big Buck Bunny",
          @"location" : @"W3C 媒体测试",
          @"video_url" : @"https://media.w3.org/2010/05/bunny/trailer.mp4",
          @"cover_url" : @"https://picsum.photos/seed/bunny/400/600",
          @"avatar_thumb" : @"https://picsum.photos/seed/bunny/100/100",
          @"play_count" : @"302000",
          @"comment_count" : @"6800"},
        @{@"title" : @"Oceans",
          @"nickname" : @"Oceans",
          @"location" : @"Video.js 示例",
          @"video_url" : @"https://vjs.zencdn.net/v/oceans.mp4",
          @"cover_url" : @"https://picsum.photos/seed/oceans/400/600",
          @"avatar_thumb" : @"https://picsum.photos/seed/oceans/100/100",
          @"play_count" : @"180000",
          @"comment_count" : @"4100"},
    ];

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:videos.count];
    for (NSDictionary *info in videos) {
        VideoDataModel *model = [[VideoDataModel alloc] init];
        model.title = info[@"title"];
        model.nickname = info[@"nickname"];
        model.location = info[@"location"];
        model.video_url = info[@"video_url"];
        model.cover_url = info[@"cover_url"];
        model.avatar_thumb = info[@"avatar_thumb"];
        model.play_count = info[@"play_count"];
        model.comment_count = info[@"comment_count"];
        model.digg_count = @"0";
        model.share_count = @"0";
        [result addObject:model];
    }

    if (block) {
        block([NSArray arrayWithArray:result], nil);
    }
}



@end

