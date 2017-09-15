

//-------*****************知识点*******************-----------

//1、全屏返回（cell左滑动删除的手势冲突，支持全屏和不支持全屏）
//2、左边返回按钮POP点击事件拦截（获取）
//3、BaseNav和BaseVC封装
//4、关于rootVC（登录登出设计）
//5、关于launchImage（删除了之前旧的image并且删除了手机APP，安装后还是旧图，上线后App Store上下载的也还是旧图，WTF！）
//6、iOS旋转屏幕(视频WMPlayer+浏览器+VR)

//7、“让我们一次性解决导航栏的所有问题”（设计思路或bug或技术问题）
    //7.1、透明导航栏
    //7.2 不同颜色的导航栏
    //7.3 不同返回按钮
    //7.4 不带导航-->push 到 带导航的页面，手势返回bug
    //7.5 动态改变导航栏的透明度



#import "AppDelegate.h"
#import "UserGuideViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
- (void)loadRootVC {
    if (![TheUserDefaults boolForKey:@"firstLaunch"]) {
        [TheUserDefaults setBool:YES forKey:@"firstLaunch"];
        [TheUserDefaults synchronize];
        //如果是第一次启动,使用UserGuideViewController (用户引导页面) 作为根视图
        self.window.rootViewController = [[UserGuideViewController alloc]init];
    }
    else {
        self.window.rootViewController = self.rootTabbar = [[RootTabbarController alloc]init];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    self.window  = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self loadRootVC];
// 
//    [self.window makeKeyAndVisible];
    //程序入口为SB，SB中的init入口为RootTabbarController
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (AppDelegate* )shareAppDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}
@end
