//
//  WMPlayer+Private.h
//  WMPlayer
//
//  播放器内部共享的私有状态与方法。
//  仅供 WMPlayer 及其 category、转场类使用，属于实现细节，勿对外暴露。
//

#import "WMPlayer.h"
#import "WMPlayerUtils.h"

@class FullScreenHelperViewController;

// ------------------------------ 宏 ------------------------------
#define WMPlayerSrcName(file) [@"WMPlayer.bundle" stringByAppendingPathComponent:file]
#define WMPlayerFrameworkSrcName(file) [@"Frameworks/WMPlayer.framework/WMPlayer.bundle" stringByAppendingPathComponent:file]
#define WMPlayerImage(file) ([UIImage imageNamed:WMPlayerSrcName(file)] ?: [UIImage imageNamed:WMPlayerFrameworkSrcName(file)])

// 整屏横向滑动代表的时间（秒）
#define WMPlayerTotalScreenTime 90
// 判定“手指确实发生移动”的最小距离
#define WMPlayerLeastDistance 15

// ------------------------------ 转场状态机（内部枚举，勿对外暴露） ------------------------------
typedef NS_ENUM(NSUInteger, WMPlayerViewState) {
    PlayerViewStateSmall,
    PlayerViewStateFullScreen,
    PlayerViewStateAnimating,
};

// ------------------------------ KVO context ------------------------------
extern void *WMPlayerStatusObservationContext;

@interface WMPlayer () <UIGestureRecognizerDelegate, AVRoutePickerViewDelegate, AVPictureInPictureControllerDelegate>

#pragma mark - 转场状态（原公开属性，已收敛为内部实现细节）
@property (nonatomic, assign) WMPlayerViewState viewState;
@property (nonatomic, strong) UIView *parentView;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, assign) CGRect oldFrameToWindow;
@property (nonatomic, assign) CGRect beforeBounds;
@property (nonatomic, assign) CGPoint beforeCenter;

#pragma mark - 公开 readonly 属性（内部可写）
@property (nonatomic, assign) BOOL prefersStatusBarHidden;
@property (nonatomic, assign) BOOL isLockScreen;

#pragma mark - 播放状态
@property (nonatomic, strong) AVPictureInPictureController *AVPictureInPictureController;
@property (nonatomic, assign) BOOL isInitPlayer;
@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, assign) BOOL isPauseBySystem;
@property (nonatomic, assign) WMPlayerState state;
@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, assign) double seekTime;
@property (nonatomic, copy) NSString *videoGravity;
@property (nonatomic, strong) id playbackTimeObserver;
@property (nonatomic, assign) NSInteger dragingSliderStatus;

#pragma mark - 控件
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UIImageView *bottomView;
@property (nonatomic, strong) WMLightView *lightView;
@property (nonatomic, strong) FastForwardView *FF_View;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *loadFailedLabel;
@property (nonatomic, strong) UIButton *fullScreenBtn;
@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property (nonatomic, strong) UIButton *lockBtn;
@property (nonatomic, strong) UIButton *pipBtn;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *rateBtn;
@property (nonatomic, strong) UIButton *resetPinchBtn;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UIProgressView *loadingProgress;
@property (nonatomic, strong) UIProgressView *bottomProgress;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIView *airPlayView;

#pragma mark - 手势状态
@property (nonatomic, assign) BOOL hasMoved;
@property (nonatomic, assign) CGFloat touchBeginValue;
@property (nonatomic, assign) CGFloat touchBeginLightValue;
@property (nonatomic, assign) CGFloat touchBeginVoiceValue;
@property (nonatomic, assign) CGPoint touchBeginPoint;
@property (nonatomic, assign) WMControlType controlType;
@property (nonatomic, strong) UITapGestureRecognizer *progressTap;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, assign) CGFloat currentScale;
@property (nonatomic, assign) CGFloat lastScale;
@property (nonatomic, assign) BOOL isHiddenTopAndBottomView;
@property (nonatomic, assign) BOOL hiddenStatusBar;

#pragma mark - 跨文件共享的私有方法
- (void)initWMPlayer;
- (void)creatWMPlayerAndReadyToPlay;
- (NSString *)convertTime:(float)second;
- (BOOL)isPausedByUser;
- (void)showControlView;
- (void)hiddenControlView;
- (void)dismissControlView;
- (void)autoDismissControlView;
- (void)hiddenLockBtn;
- (void)resetPinchZoom;
- (void)enterZoomMode;
- (void)exitZoomMode;
- (void)resetPinchAction:(UIButton *)sender;
- (void)seekToTimeToPlay:(double)seekTime;
- (NSTimeInterval)availableDuration;
- (void)initTimer;
- (void)syncScrubber;
- (CMTime)playerItemDuration;
- (void)loadedTimeRanges;
- (void)setupSuport;
- (void)stratDragSlide:(UISlider *)slider;
- (void)updateProgress:(UISlider *)slider;
- (void)actionTapGesture:(UITapGestureRecognizer *)sender;
- (void)handleSingleTap:(UITapGestureRecognizer *)sender;
- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap;
- (void)handlePinch:(UIPinchGestureRecognizer *)pinch;
- (float)moveProgressControllWithTempPoint:(CGPoint)tempPoint;
- (void)timeValueChangingWithValue:(float)value;
- (void)lockAction:(UIButton *)sender;
- (void)fullScreenAction:(UIButton *)sender;
- (void)colseTheVideo:(UIButton *)sender;
- (void)pipAction:(UIButton *)sender;
- (void)switchRate:(UIButton *)rateBtn;
- (void)appDidEnterBackground:(NSNotification *)note;
- (void)appWillEnterForeground:(NSNotification *)note;
- (void)moviePlayDidEnd:(NSNotification *)notification;
- (void)enterFullScreenFromViewController:(UIViewController *)sourceVC helperViewController:(FullScreenHelperViewController *)helperVC;
- (void)exitFullScreenFromViewController:(UIViewController *)sourceVC;

@end
