# WMPlayer 2.0.0
WMPlayer视频播放器，AVPlayer的封装，继承UIView，想怎么玩就怎么玩。支持播放mp4、m3u8、3gp、mov，网络和本地视频同时支持。全屏和小屏播放同时支持。
cell中播放视频，全屏小屏切换自如。

![image](https://github.com/zhengwenming/WMPlayer/blob/master/WMPlayer/Resource/WMPlayer.gif)   

#用法，Usage
1.初始化

* 播放网络视频

    wmPlayer = [[WMPlayer alloc]initWithFrame:playerFrame];
    
    [wmPlayer setURLString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    
    [self.view addSubview:wmPlayer];
    
    [wmPlayer play];

* 播放本地视频

    wmPlayer = [[WMPlayer alloc]initWithFrame:playerFrame];
    
     NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"4k" ofType:@"mp4"]];
     
    NSString *urlstring = [URL absoluteString];
    
    [self.wmPlayer setURLString:urlstring];
    
    [self.view addSubview:wmPlayer];
    
    [wmPlayer play]; 
    

依赖库为Masonry。
使用过程中有bug，请联系我，我会及时修复。谢谢大家的支持。

#欢迎加入iOS开发技术支持群，487599875，（2元付费群，手机端可以加，电脑加不了。慎入！）进群必须改名，群名片格式：城市-iOS-名字，例如广州-iOS-文明。
#欢迎关注我的斗鱼直播间，用手机下载斗鱼TV，搜索“文明直播间”或者“极端恐惧”就可以找到我的直播间。iOS技术分享直播。点关注不迷路，开播会有推送到大家手机。（个人直播，非机构非机构，适合初级iOS和中级iOS）。
 
#福利，往期斗鱼直播视频地址  https://yunpan.cn/OcPcBAPbezTdzp

1、runtime的不扯淡不装逼不理论视频，让你学会runtime真正如何运用到项目中。

2、纯代码简单实现微信朋友圈页面的视频等。

