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
- [x] 支持循环播放
- [x] 支持画中画功能PictureInPicture
- [x] 支持倍速播放（0.5X、1.0X、1.25X、1.5X、2X）
- [x] 支持列表跳转详情页播放同一个视频资源，达到无缝播放效果，类似今日头条的列表到详情页。
- [x] 支持动态改变播放器的填充模式

备注：有关视频缓存到本地的第三方库，请移步唱吧开源的项目https://github.com/ChangbaDevs/KTVHTTPCache


## pod使用的问题总结

1、pod search WMPlayer
如果pod搜到WMPlayer版本为3.0.6,或者搜索不到，那么请更新Mac的ruby版本为2.4.x，同时更新pod版本为V1.5.3，更新的文章请参考：https://www.cnblogs.com/angelgril/p/6731015.html

2、pod 'WMPlayer'

把pod 'WMPlayer'放进你项目的Podfile里面

3、pod update

4、如果是5.0.2版本，OK，enjoy it。

5、如果不行，那么直接从GitHub上下载，用下面的命令：

    pod 'WMPlayer',  :git => 'https://github.com/zhengwenming/WMPlayer.git'
或者：pod 'WMPlayer', '~> 5.2.0'
    
---

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
 
 
    2、旋转ViewController
    思路：真正意义上去旋转VC，然后更新视频播放器的约束。（记住项目设置里面勾选☑️其他三个屏幕方向）
    案例：腾讯视频
  
    
    3、自定义转场动画
    思路：present出一个全屏的VC，同时WMPlayer做动画到全屏VC上。具体可以参考demo代码
    案例：爱奇艺客户端
    代码：详见demo中的新浪tab对应的DetailViewController.m里面，一定要添加全屏按钮的点击事件，并添加了代码才能有全屏的效果，不然就是一个普通的Button，点击没反应的。
  

使用过程中有bug，请联系我，我会及时修复。谢谢大家的支持。

欢迎加入WMPlayer+WNPlayer开发交流群

加本人微信18824905363，备注WMPlayer，我会拉你入群
