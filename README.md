## 功能
- [x] 支持cocoapods
- [x] 支持旋转屏：全屏模式和小屏模式切换，自动感应旋转
- [x] 支持网络和本地视频资源播放
- [x] 支持播放系统相册中的视频
- [x] 支持cell中播放，列表播放
- [x] 支持手势改变屏幕的亮度（屏幕左半边）
- [x] 支持手势改变音量大小（屏幕右半边）
- [x] 支持手势滑动快进快退、拖动Slider快进快退、点击Slider跳到点击位置播放
- [x] 支持直接跳到某个时间点播放
- [x] 支持全屏锁定🔒
- [x] 支持后台播放视频
- [x] 全面适配iPhone X
- [x] 支持播放器静音
- [x] 支持倍速播放（0.5X、1.0X、1.25X、1.5X、2X）
- [x] 支持列表跳转详情页播放同一个视频资源，达到无缝播放效果，类似今日头条的列表到详情页。
- [x] 支持动态改变播放器的填充模式

---pod使用的问题总结-----

1、pod search WMPlayer
如果pod搜到WMPlayer版本为3.0.6,或者搜索不到，那么请更新Mac的ruby版本为2.4.x，同时更新pod版本为V1.5.3，更新的文章请参考：https://www.cnblogs.com/angelgril/p/6731015.html

2、pod 'WMPlayer'

把pod 'WMPlayer'放进你项目的Podfile里面

3、pod update

4、如果是5.0.0版本，OK，enjoy it。

---

# WMPlayer更新日志

#### Version-4.0.0 (修复视频全屏的bug,具体表现为键盘和状态栏方向不一致)
#### Version-4.1.0 (修复present出来WMPlayer无法全屏显示的bug)
#### Version-4.2.0 (适配iOS 11、适配iPhone X)---------2017.10.15
#### Version-5.0.0 (添加n个新功能)---------2018.05.22

---
微信扫码关注文明的iOS开发公众号
或者微信搜索“iOS开发by文明”

![image](https://github.com/zhengwenming/WMPlayer/blob/master/PlayerDemo/gzh.jpg)

---

WMPlayer视频播放器，AVPlayer的封装，继承UIView，想怎么玩就怎么玩。支持播放mp4、m3u8、3gp、mov，网络和本地视频同时支持。全屏和小屏播放同时支持。
cell中播放视频，全屏小屏切换自如。

![image](https://github.com/zhengwenming/WMPlayer/blob/master/PlayerDemo/WMPlayer.gif)   

## Usage

* 播放网络视频

```
    WMPlayerModel *playerModel = [WMPlayerModel new];
    playerModel.title = self.videoModel.title;
    playerModel.videoURL = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    WMPlayer * wmPlayer = [[WMPlayer alloc]initPlayerModel:playerModel];
    [self.view addSubview:wmPlayer];
    [wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(wmPlayer.mas_width).multipliedBy(9.0/16);
    }];
    [wmPlayer play];
```

* 播放本地视频

```
    WMPlayerModel *playerModel = [WMPlayerModel new];
    playerModel.title = self.videoModel.title;
    NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"4k" ofType:@"mp4"]];
    playerModel.videoURL = [NSURL URLWithString:[URL absoluteString]];
    WMPlayer * wmPlayer = [WMPlayer playerWithModel:playerModel];        
    [self.view addSubview:wmPlayer];
    [wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(wmPlayer.mas_width).multipliedBy(9.0/16);
    }];
    [wmPlayer play]; 
```    
  
 
 
* 全屏播放视频解决方案

*   WMPlayer 同时支持持旋转 view、单独旋转状态栏、旋转ViewController
  
  
  
    1、旋转view
    思路：顾名思义，就是讲WMPlayer旋转90°，然后设置宽高为屏幕的宽和高，先从父视图上（可能是self.view）移除，然后在屏幕旋转的通知里面add到window上，造成全屏的效果，或者说造成全屏的假象吧。
    案例：网易新闻
    代码：比较low，不在维护。但是这个功能是支持的，开发者自行开发，或者看老版本的代码（5.0以前的版本）。
    bug：通知栏的方向不是横屏模式；键盘和UIAlertView的弹出方向还是竖屏模式。
 
 
    2、旋转状态栏
    思路：状态栏可以单独旋转，旋转状态栏，造成旋转VC的假象。（记住项目设置里面勾选☑️其他三个屏幕方向）
    案例：今日头条、新浪新闻
    代码：详见demo中的新浪tab对应的SinaNewsViewController.m里面，一定要添加全屏按钮的点击事件，并添加了代码才能有全屏的效果，不然就是一个普通的Button，点击没反应的。
    bug：键盘和UIAlertView的弹出方向还是竖屏模式。
    
    
    3、旋转ViewController
    思路：真正意义上去旋转VC，然后更新视频播放器的约束。（记住项目设置里面勾选☑️其他三个屏幕方向）
    案例：腾讯视频
    代码：详见demo中的新浪tab对应的DetailViewController.m里面，一定要添加全屏按钮的点击事件，并添加了代码才能有全屏的效果，不然就是一个普通的Button，点击没反应的。
    bug：无
  
# Android拍摄视频，上传服务器，iOS端无法播放，请☞戳下面链接
【链接】Android拍摄的视频无法在iOS播放
http://blog.csdn.net/u012992171/article/details/50673305 

（安卓音频编码使用了AMR_NB，苹果不支持这个音频的解码，请安卓使用苹果端支持的AAC音频编码）

    
# 另外关于程序崩溃在main中，但是手动的过了这个崩溃断点又可以继续运行，貌似又没有崩溃的问题，解释如下：(有些人不知道，总说我在代码中下毒了，冤枉！！！)
这是异常断点导致的，cocoa在某些框架中会加异常的捕获，而这个是系统级别的，AVFoundation这个框架就是。
stackoverflow中有详细的解释，解决方法也有。地址为：
http://stackoverflow.com/questions/26408264/xcode-6-0-1-begins-with-breakpoint-thread-1-breakpoint-1-2


# 升级iOS10后,AVPlayer有时候播放不了的问题
参考以下链接
http://blog.csdn.net/viiimaus/article/details/54926022
https://developer.apple.com/reference/avfoundation/avplayer/1643482-automaticallywaitstominimizestal


The problem is that you have a global Exceptions breakpoint. For some reason, an exception is being thrown. But not every exception is fatal; this one is being caught internally by Cocoa. So, you have two choices:

Hit the Exceptions breakpoint and resume.
Temporarily turn off the Exceptions breakpoint (in the Breakpoints navigator).
It is a little infuriating that this happens, but that's how it is. There are a lot of situations where Cocoa throws and catches an exception internally. (For example, AVFoundation does this a lot.) This would normally go unnoticed, but when you have a global Exceptions breakpoint enabled, it causes a pause whenever this occurs.

依赖库为Masonry。
使用过程中有bug，请联系我，我会及时修复。谢谢大家的支持。

欢迎加入iOS开发技术支持群，479259423，（付费群，手机端可以加，电脑加不了。慎入！）进群必须改名，群名片格式：城市-iOS-名字，例如广州-iOS-文明。
欢迎关注我的斗鱼直播间，用手机下载斗鱼TV，搜索“文明直播间”或者“极端恐惧”就可以找到我的直播间。iOS技术分享直播。点关注不迷路，开播会有推送到大家手机。（个人直播，非机构非机构，适合初级iOS和中级iOS）。
 
