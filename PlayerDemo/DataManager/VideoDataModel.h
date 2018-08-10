//
//  VideoDataModel.h
//  PlayerDemo
//
//  Created by apple on 2018/8/10.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

@interface CommentDataModel : NSObject

/**
 动态id
 */
@property (nonatomic ,strong) NSString* dynamicID;

/**
 评论的上级UID
 */
@property (nonatomic ,strong) NSString* referUID;

/**
 评论者ID
 */
@property (nonatomic ,strong) NSString* selfUID;

/**
 评论者昵称
 */
@property (nonatomic ,strong) NSString* selfNickName;

/**
 评论内容
 */
@property (nonatomic ,strong) NSString* content;

/**
 创建时间
 */
@property (nonatomic ,strong) NSString* createdTime;

/**
 头像
 */
@property (nonatomic ,strong) NSString* faceurl;

/**
 头像
 */
@property (nonatomic ,strong) NSString* iconIndex;


/**
 获取视频动态的评论列表
 
 @param DynamicID  动态ID
 @param page  页数
 @param block block中dateary返回模型类数据列表error返回网络错误码
 */
+(void)getCommentDataWithBlockWithDynamicID:(NSString*)DynamicID forFlag:(int)flag  AndPage:(NSString*)page ForHandelBlock:(void (^)(NSArray* dateAry, int code))block;
@end




@interface VideoDataModel : NSObject
@property (nonatomic, strong) NSIndexPath *indexPath;
/**
 视频标题
 */
@property (nonatomic ,strong) NSString* title;

/**
 位置信息
 */
@property (nonatomic ,strong) NSString* location;

/**
 用户昵称
 */
@property (nonatomic ,strong) NSString* nickname;

/**
 用户头像
 */
@property (nonatomic ,strong) NSString* avatar_thumb;

/**
 视频地址
 */
@property (nonatomic ,strong) NSString* video_url;

/**
 视频首帧画面
 */
@property (nonatomic ,strong) NSString* cover_url;

/**
 视频火力值
 */
@property (nonatomic ,strong) NSString* stats_tips;


/**
 评论次数
 */
@property (nonatomic ,strong) NSString* comment_count;

/**
 点赞次数
 */
@property (nonatomic ,strong) NSString* digg_count;

/**
 播放次数
 */
@property (nonatomic ,strong) NSString* play_count;

/**
 分享次数
 */
@property (nonatomic ,strong) NSString* share_count;

@property (nonatomic ,strong) NSString* AuthorUid;

@property (nonatomic ,strong) NSString* dyid;

/**
 头像
 */
@property (nonatomic ,strong) NSString* iconIndex;

/**
 获取火山直播首页video页签数据接口
 
 @param block block中dateary返回模型类数据列表error返回网络错误码
 */
+(void)getHomePageVideoDataWithBlock:(void (^)(NSArray* dateAry, NSError* error))block;


@end

