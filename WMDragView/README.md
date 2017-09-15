# WMDragView
拖吗？拖！拖就用WMDragView吧。WMDragView致力于让任意View都可以自由移动、悬浮、拖动、拖曳。WMDragView是可以自由拖曳的view，可以悬浮移动，也可以设置内部的图片，轻量级的控件。
demo效果图：

![image](https://github.com/zhengwenming/WMDragView/blob/master/WMDragView/WMDragView.gif)  应用场景1：![image](https://github.com/zhengwenming/WMDragView/blob/master/WMDragView/WMPlayer.gif) 应用场景2：![image](https://github.com/zhengwenming/WMDragView/blob/master/WMDragView/douyu.gif) 



#WMDragView：用法和API

1、把需要拖曳view的父类从原本继承UIView，改成继承WMDragView就OK了。

2、dragEnable=YES，可拖曳

   dragEnable=NO，不可拖曳
   
3、freeRect可以任意设置活动范围，默认为活动范围为父视图大小frame，

4、回调block

	点击的回调		clickDragViewBlock
	
	开始拖动的回调		beginDragBlock
	
	拖动中回调		duringDragBlock
	
	结束拖动的回调 	endDragBlock
	
5、isKeepBounds是不是又自动黏贴边界效果

 isKeepBounds = YES，自动黏贴边界，而且是最近的边界
 isKeepBounds = NO， 不会黏贴在边界，它是free(自由)状态，跟随手指到任意位置，但是也不可以拖出规定的范围

6、可以设置网络图片

7、可以自定义view加到dragView中，比如一个视频，一个自定义按钮等等。



欢迎加入iOS开发技术支持群，479259423，（付费群，手机端可以加，电脑加不了。慎入！）进群必须改名，群名片格式：城市-iOS-名字，例如广州-iOS-文明。

