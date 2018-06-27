//
//  WMPlayerModel.h
//  
//
//  Created by zhengwenming on 2018/4/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface WMPlayerModel : NSObject
//视频标题
@property (nonatomic, copy) NSString   *title;
//视频的URL，本地路径or网络路径http
@property (nonatomic, strong) NSURL    *videoURL;
//videoURL和playerItem二选一
@property (nonatomic, strong) AVPlayerItem   *playerItem;
//跳到seekTime处播放
@property (nonatomic, assign) double   seekTime;
@property (nonatomic, strong) NSIndexPath  *indexPath;
//视频尺寸
@property (nonatomic,assign) CGSize presentationSize;
//是否是适合竖屏播放的资源，w：h<1的资源，一般是手机竖屏（人像模式）拍摄的视频资源
@property (nonatomic,assign) BOOL verticalVideo;

@end
