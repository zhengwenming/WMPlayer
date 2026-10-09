//
//  WMPlayer+FullScreen.m
//  WMPlayer
//
//  重构拆分：统一“小屏 <-> 全屏”的转场入口，消除各 Demo VC 里重复的
//  presentToVC / exitFullScreen 样板代码。
//

#import "WMPlayer+Private.h"
#import "FullScreenHelperViewController.h"

@implementation WMPlayer (FullScreen)

- (void)enterFullScreenFromViewController:(UIViewController *)sourceVC
                      helperViewController:(FullScreenHelperViewController *)helperVC {
    if (self.viewState != PlayerViewStateSmall) {
        return;
    }
    self.viewState = PlayerViewStateAnimating;
    // 显式记录小屏 frame，避免 originFrame 被 isFullscreen 置 YES 前的任何布局事件污染
    self.originFrame = self.frame;
    self.beforeBounds = self.bounds;
    self.beforeCenter = self.center;
    self.parentView = self.superview;
    self.isFullscreen = YES;

    helperVC.wmPlayer = self;
    helperVC.modalPresentationStyle = UIModalPresentationFullScreen;
    if ([sourceVC conformsToProtocol:@protocol(UIViewControllerTransitioningDelegate)]) {
        helperVC.transitioningDelegate = (id<UIViewControllerTransitioningDelegate>)sourceVC;
    }
    [sourceVC presentViewController:helperVC animated:YES completion:^{
        self.viewState = PlayerViewStateFullScreen;
        NSLog(@"[WMPlayer-FullScreen] enter completion -> viewState=FullScreen");
    }];
}

- (void)exitFullScreenFromViewController:(UIViewController *)sourceVC {
    // 仅在小屏（尚未进入全屏）时忽略；进入动画进行中（Animating）也允许退出，
    // 避免 present 的 completion 因旋转被延迟/跳过时 viewState 卡在 Animating 导致无法退出。
    if (self.viewState == PlayerViewStateSmall) {
        return;
    }
    self.viewState = PlayerViewStateAnimating;
    UIViewController *dismissingVC = sourceVC;
    // 真正 present 全屏 VC 的“小屏 VC”：dismiss 后由它负责状态栏显示，
    // 用它来触发状态栏淡入（sourceVC 可能是全屏容器 VC，其 presentingViewController 才是小屏 VC）。
    UIViewController *presentingVC = sourceVC.presentingViewController ?: sourceVC;
    NSLog(@"[WMPlayer-FullScreen] exit begin, viewState=%lu, sourceVC=%@", (unsigned long)self.viewState, sourceVC);
    // isFullscreen 延后到转场动画完成后再置 NO，避免动画开始前 player.frame 被提前改成小屏导致画面跳变
    [dismissingVC dismissViewControllerAnimated:YES completion:^{
        // 兜底：用进入全屏前记录的小屏 bounds/center 重建 originFrame，确保首次退出也能还原原始尺寸与位置
        self.originFrame = CGRectMake(self.beforeCenter.x - self.beforeBounds.size.width/2,
                                      self.beforeCenter.y - self.beforeBounds.size.height/2,
                                      self.beforeBounds.size.width,
                                      self.beforeBounds.size.height);
        self.isFullscreen = NO;
        self.viewState = PlayerViewStateSmall;
        // 全屏期间状态栏是隐藏的；转场/旋转全部完成后再让状态栏淡入，
        // 避免旋转过程中状态栏闪现并把页面往下顶导致卡顿。
        [presentingVC setNeedsStatusBarAppearanceUpdate];
        NSLog(@"[WMPlayer-FullScreen] exit completion -> viewState=Small");
    }];
}

@end
