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
    //    NSString *apiString = @"https://api.huoshan.com/hotsoon/feed/?type=video&iid=8257698093&os_version=9.3.2&os_api=18&app_name=live_stream_pro&channel=App%20Store&device_platform=iphone&idfa=B265DA9C-569C-4B55-BE8E-3D2EC5310A7A&live_sdk_version=1.7.3&vid=AD78E6CD-4827-4D52-932A-3E74AD30F5CB&openudid=82d61456516d047fbdb667fea5ceb6d87be15bfc&device_type=iPhone8,2&version_code=1.7.3&ac=WIFI&screen_width=1242&device_id=35199776125&aid=1115&action=refresh&live_source=live_small_picture";
    
    
//    NSString *apiString = @"https://api.huoshan.com/hotsoon/feed/?type=video&iid=8257698093&os_version=9.3.2&os_api=18&app_name=live_stream_pro&channel=App%20Store&device_platform=iphone&idfa=B265DA9C-569C-4B55-BE8E-3D2EC5310A7A&live_sdk_version=1.7.3&vid=AD78E6CD-4827-4D52-932A-3E74AD30F5CB&openudid=82d61456516d047fbdb667fea5ceb6d87be15bfc&device_type=iPhone8,2&version_code=2.2.1&ac=WIFI&screen_width=1242&device_id=35199776125&aid=1115&action=refresh&live_source=live_small_picture";
    
    
       NSString *apiString = @"https://api-hl.huoshan.com/hotsoon/feed/?type=video&iid=56693189339&ac=WIFI&ab_version=391711,501253,592609,662547,671134,384501,663932,612165,681210,674736,654193,557631,678843,681232,680055,637814,666872,681693,661943,681616,374104,378844,682009,665355,446763,638535,681229,299910,632485,671292,651646,598627,641184,457535,493546,677944&os_api=18&app_name=live_stream&channel=App%20Store&idfa=59E6123C-45AE-4F64-9192-FD9B0E982923&device_platform=iphone&live_sdk_version=5.4.0&vid=DD5987BE-4451-43E1-B234-68525808A52F&mccmnc=&device_type=iPhone7,1&openudid=62948e3983ef2572b9acc1b524998172d40f5f73&version_code=5.4.0&os_version=12.0&screen_width=1125&aid=1112&device_id=36177005663&req_from=feed_refresh&action=refresh&diff_stream=1&mas=00f6d48a97d7aaa909e3451f22676861b28a07d5ae901270dbe287&as=a2b5c403499e6cf3806834&ts=1546666985";
    
    
    
    AFHTTPSessionManager* afManager = [AFHTTPSessionManager manager];
    afManager.requestSerializer.timeoutInterval = 30;
    [afManager GET:apiString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status_code"] intValue] != 0){
            return ;
        }else
        {
            NSArray* getFromResponse = [responseObject objectForKey:@"data"];
            NSMutableArray* mutablePosts = [NSMutableArray arrayWithCapacity:[getFromResponse count]];
            for (NSDictionary* attributes in getFromResponse) {
                VideoDataModel* dataModel = [[VideoDataModel alloc] initVideoDataWithDic:attributes];
                [mutablePosts addObject:dataModel];
            }
            if (block) {
                block([NSArray arrayWithArray:mutablePosts],nil);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block([NSArray array],error);
        }
        
    }];
}


@end

