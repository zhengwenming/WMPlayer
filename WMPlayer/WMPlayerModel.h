//
//  WMPlayerModel.h
//  
//
//  Created by zhengwenming on 2018/4/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WMPlayerModel : NSObject
//视频标题
@property (nonatomic, copy) NSString   *title;
//视频的URL，本地路径or网络路径http
@property (nonatomic, strong) NSURL    *videoURL;
//跳到seekTime处播放
@property (nonatomic, assign) double   seekTime;
@property (nonatomic, strong) NSIndexPath  *indexPath;

@end
