 //
//  EditVideoViewController.m
//  iShow
//
//  Created by 胡阳阳 on 17/3/8.
//
//

#import "EditVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "UIView+Tools.h"
#import "MusicItemCollectionViewCell.h"
#import "WMPlayer.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "SDAVAssetExportSession.h"
#import "GPUImage.h"
#import "LFGPUImageEmptyFilter.h"
#import "EditingPublishingDynamicViewController.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_LayoutScaleBaseOnIPHEN6(x) (([UIScreen mainScreen].bounds.size.width)/375.00 * x)

@interface MusicData : NSObject

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* eid;
@property (nonatomic,strong) NSString* musicPath;
@property (nonatomic,strong) NSString* iconPath;
@property (nonatomic,assign) BOOL isSelected;

@end
@implementation MusicData

@end

@interface FilterData : NSObject

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* value;
@property (nonatomic,strong) NSString* fillterName;
@property (nonatomic,strong) NSString* iconPath;
@property (nonatomic,assign) BOOL isSelected;

@end
@implementation FilterData

@end

@interface StickersData : NSObject

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* StickersImgPaht;
@property (nonatomic,assign) BOOL isSelected;

@end
@implementation StickersData

@end

typedef NS_ENUM(NSUInteger , choseType)
{
    choseFilter = 1, //
    choseMusic = 2,
    choseStickers = 3,//
};

@interface EditVideoViewController ()<UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) NSMutableArray* musicAry;
@property (nonatomic, strong) NSMutableArray* filterAry;
@property (nonatomic, strong) NSMutableArray* stickersAry;

@property (nonatomic,strong) UIVisualEffectView *visualEffectView;
@property (nonatomic,strong) UIView* musicBottomBar;
@property (nonatomic,strong) NSString* audioPath;

@property (nonatomic,strong) UIButton* musicBtn;
@property (nonatomic ,strong) NSString* filtClassName;
@property (nonatomic ,assign) BOOL isdoing;

@property (nonatomic, assign) choseType choseEditType;


@property (nonatomic ,strong) UICollectionView *musicCollectionView;
@property (nonatomic ,strong) UICollectionView *collectionView;
@property (nonatomic ,strong) UICollectionView *stickersCollectionView;


@property (nonatomic ,strong) UIButton* cancleBtn;
@property (nonatomic ,strong) UIButton* okBtn;
@property (nonatomic ,strong) UIButton* stickersBtn;

@property (nonatomic ,strong) UIButton* editTheOriginaBtn;
@property (nonatomic ,strong) UISwitch* editTheOriginaSwitch;

@property (nonatomic ,strong) GPUImageView *filterView;

@property (nonatomic ,assign) float saturationValue;
@property (nonatomic ,strong) NSIndexPath* lastMusicIndex;
@property (nonatomic ,strong) NSIndexPath* nowMusicIndex;

@property (nonatomic ,strong) NSIndexPath* lastFilterIndex;
@property (nonatomic ,strong) NSIndexPath* nowFilterIndex;

@property (nonatomic ,strong) NSIndexPath* lastStickersIndex;
@property (nonatomic ,strong) NSIndexPath* nowStickersIndex;

@property (nonatomic ,strong) UIImageView* bgImageView;

@property (nonatomic ,strong) UIImageView* stickersImgView;


@end

@implementation EditVideoViewController
{
    GPUImageMovie *movieFile;
    GPUImageMovie* endMovieFile;
    GPUImageOutput<GPUImageInput> *filter;
    
    AVPlayerItem *audioPlayerItem;
    UIImageView* playImg;
    MBProgressHUD*HUD;
    

    
    AVPlayer *mainPlayer;
    AVPlayerLayer *playerLayer;
    AVPlayerItem *playerItem;
    GPUImageMovieWriter *movieWriter;
    
}
@synthesize videoURL;

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    _musicAry = [NSMutableArray arrayWithArray:[self creatMusicData]];
    _filterAry = [NSMutableArray arrayWithArray:[self creatFilterData]];
    _stickersAry = [NSMutableArray arrayWithArray:[self creatStickersData]];
    _audioPlayer = [[AVPlayer alloc ]init];
    
    _lastMusicIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    _lastFilterIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    _lastStickersIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    
    
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    //    [self playMusic];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"预览";
    
    float videoWidth = self.view.frame.size.width;
    
    
    mainPlayer = [[AVPlayer alloc] init];
    playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
    [mainPlayer replaceCurrentItemWithPlayerItem:playerItem];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:mainPlayer];
    
    
    movieFile = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
    movieFile.runBenchmark = YES; movieFile.playAtActualSpeed = YES;
    
    filter = [[LFGPUImageEmptyFilter alloc] init];
    
    _filtClassName = @"LFGPUImageEmptyFilter";
    [movieFile addTarget:filter];
    _filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_filterView];
    [filter addTarget:_filterView];
    
    _bgImageView = [[UIImageView alloc] init];
//    _bgImageView.image = [[AppDelegate appDelegate].cmImageSize getImage:[[videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
    [self.view addSubview:_bgImageView];
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
    
    UIImageView* PlayImge = [[UIImageView alloc] init];
    PlayImge.image = [UIImage imageNamed:@"播放按钮-1"];
    [_bgImageView addSubview:PlayImge];
    [PlayImge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_bgImageView);
        make.width.height.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(60)));
    }];
    
    
    
    playImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    playImg.center = CGPointMake(videoWidth/2, videoWidth/2);
    [playImg setImage:[UIImage imageNamed:@"videoPlay"]];
    [playerLayer addSublayer:playImg.layer];
    playImg.hidden = YES;
    
    //create ui
    UIView* superView = self.view;
    
    _stickersImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
    _stickersImgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    _stickersImgView.hidden = YES;
    [self.view addSubview:_stickersImgView];
    [_stickersImgView setUserInteractionEnabled:YES];
    [_stickersImgView setMultipleTouchEnabled:YES];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [_stickersImgView addGestureRecognizer:panGestureRecognizer];

    
    UIView* headerBar = [[UIView alloc] init];
    headerBar.backgroundColor = [UIColor redColor];
    [self.view addSubview:headerBar];
    headerBar.backgroundColor = [UIColor blackColor];
    [headerBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset([WMPlayer IsiPhoneX]?44:0);
        make.height.equalTo(@(44));
    }];
    headerBar.alpha = .8;
    
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"编辑";
    titleLabel.textColor = [UIColor whiteColor];
    [headerBar addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(headerBar);
    }];
    
//    UIButton* backBtn = [[UIButton alloc] init];
//    backBtn setImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>
    
    UIButton* nextBtn = [[UIButton alloc] init];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [nextBtn addTarget:self action:@selector(clickNextBtn) forControlEvents:UIControlEventTouchUpInside];
    [headerBar addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(headerBar);
        make.width.equalTo(@(80));
    }];
    
    UIButton* BackToVideoCammer = [[UIButton alloc] init];
    [BackToVideoCammer setImage:[UIImage imageNamed:@"BackToVideoCammer"] forState:UIControlStateNormal];
    [BackToVideoCammer addTarget:self action:@selector(clickBackToVideoCammer) forControlEvents:UIControlEventTouchUpInside];
    [headerBar addSubview:BackToVideoCammer];
    [BackToVideoCammer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(headerBar);
        make.width.equalTo(@(60));
    }];
    
    
    _musicBottomBar = [[UIView alloc] init];
    [self.view addSubview:_musicBottomBar];
    [_musicBottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(superView)/*.offset(160)*/;
        make.left.right.equalTo(superView);
        make.height.equalTo(@(160));
    }];
    
    
    
    
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    //毛玻璃视图
    _visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    //    _visualEffectView.alpha = 1;
    [_musicBottomBar addSubview:_visualEffectView];
    
    [_visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.top.bottom.equalTo(_musicBottomBar);
    }];
    
    _cancleBtn = [[UIButton alloc] init];
    [_cancleBtn setTitle:@"滤镜" forState:UIControlStateNormal];
    [_cancleBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_cancleBtn setTitleColor:[UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1] forState:UIControlStateSelected];
    [_cancleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _cancleBtn.backgroundColor = [UIColor clearColor];
    [_cancleBtn addTarget:self action:@selector(clickCancleBtn) forControlEvents:UIControlEventTouchUpInside];
    [_musicBottomBar addSubview:_cancleBtn];
    [_cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_musicBottomBar);
        make.height.equalTo(@(45));
        make.width.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(83)));
    }];
    _cancleBtn.selected = YES;
    self.choseEditType = choseFilter;
    
    _okBtn = [[UIButton alloc] init];
    [_okBtn setTitle:@"音乐" forState:UIControlStateNormal];
    [_okBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_okBtn setTitleColor:[UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1] forState:UIControlStateSelected];
    [_okBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _okBtn.backgroundColor = [UIColor clearColor];
    [_okBtn addTarget:self action:@selector(clickOKBtn) forControlEvents:UIControlEventTouchUpInside];
    [_musicBottomBar addSubview:_okBtn];
    [_okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_musicBottomBar);
        make.left.equalTo(_cancleBtn.mas_right).offset(0);
        make.height.equalTo(@(45));
        make.width.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(83)));
    }];
    
    _stickersBtn = [[UIButton alloc] init];
    [_stickersBtn setTitle:@"贴纸" forState:UIControlStateNormal];
    [_stickersBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_stickersBtn setTitleColor:[UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1] forState:UIControlStateSelected];
    [_stickersBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _stickersBtn.backgroundColor = [UIColor clearColor];
    [_stickersBtn addTarget:self action:@selector(clickStickersBtn) forControlEvents:UIControlEventTouchUpInside];
    [_musicBottomBar addSubview:_stickersBtn];
    [_stickersBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_musicBottomBar);
        make.left.equalTo(_okBtn.mas_right).offset(0);
        make.height.equalTo(@(45));
        make.width.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(83)));
    }];
    
    _editTheOriginaSwitch = [[UISwitch alloc] init];
    _editTheOriginaSwitch.onTintColor = [UIColor colorWithRed:253.0 / 255 green:215.0 / 255 blue:4.0 / 255 alpha:1.0];
    [_editTheOriginaSwitch addTarget:self action:@selector(clickEditOriginalBtn) forControlEvents:UIControlEventTouchUpInside];
    [_musicBottomBar addSubview:_editTheOriginaSwitch];
    [_editTheOriginaSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_okBtn);
        make.right.equalTo(_musicBottomBar).offset(-8);
        make.height.equalTo(@(30));
        make.width.equalTo(@(50));
    }];
    _editTheOriginaSwitch.hidden = YES;
    
    _editTheOriginaBtn = [[UIButton alloc] init];
    [_editTheOriginaBtn setTitle:@"剔除原声" forState:UIControlStateNormal];
    [_editTheOriginaBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_editTheOriginaBtn setTitleColor:[UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1] forState:UIControlStateSelected];
    [_editTheOriginaBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _editTheOriginaBtn.backgroundColor = [UIColor clearColor];
//    [_editTheOriginaBtn addTarget:self action:@selector(clickEditOriginalBtn) forControlEvents:UIControlEventTouchUpInside];
    [_musicBottomBar addSubview:_editTheOriginaBtn];
    [_editTheOriginaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_musicBottomBar);
        make.right.equalTo(_editTheOriginaSwitch.mas_left).offset(0);
        make.height.equalTo(@(45));
        make.width.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(83)));
    }];
    _editTheOriginaBtn.hidden = YES;
    
    
    
    UIView* lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor grayColor];
    [_musicBottomBar addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_okBtn);
        make.left.right.equalTo(_musicBottomBar);
        make.height.equalTo(@(.5));
    }];
    
    
    //collectionView
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(83, 115);
    layout.estimatedItemSize = CGSizeMake(83, 115);
    
    //设置分区的头视图和尾视图是否始终固定在屏幕上边和下边
//    layout.sectionFootersPinToVisibleBounds = YES;
//    layout.sectionHeadersPinToVisibleBounds = YES;
    
    // 设置水平滚动方向
    //水平滚动
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 设置额外滚动区域
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // 设置cell间距
    //设置水平间距, 注意点:系统可能会跳转(计算不准确)
    layout.minimumInteritemSpacing = 0;
    //设置垂直间距
    layout.minimumLineSpacing = 0;
    
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 115) collectionViewLayout:layout];
    
    //设置背景颜色
    _collectionView.backgroundColor = [UIColor clearColor];
    
    
    // 设置数据源,展示数据
    _collectionView.dataSource = self;
    //设置代理,监听
    _collectionView.delegate = self;
    
    // 注册cell
    [_collectionView registerClass:[MusicItemCollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionCell"];
    
    /* 设置UICollectionView的属性 */
    //设置滚动条
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    
    //设置是否需要弹簧效果
    _collectionView.bounces = YES;
    
    [_musicBottomBar addSubview:_collectionView];
    
    
    
    
    
    
    //collectionView
    UICollectionViewFlowLayout* layout2 = [[UICollectionViewFlowLayout alloc] init];
    layout2.itemSize = CGSizeMake(83, 115);
    layout2.estimatedItemSize = CGSizeMake(83, 115);
    
    //设置分区的头视图和尾视图是否始终固定在屏幕上边和下边
//    layout2.sectionFootersPinToVisibleBounds = YES;
//    layout2.sectionHeadersPinToVisibleBounds = YES;
    
    // 设置水平滚动方向
    //水平滚动
    layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 设置额外滚动区域
    layout2.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // 设置cell间距
    //设置水平间距, 注意点:系统可能会跳转(计算不准确)
    layout2.minimumInteritemSpacing = 0;
    //设置垂直间距
    layout2.minimumLineSpacing = 0;
    
    
    
    _musicCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 115) collectionViewLayout:layout2];
    
    //设置背景颜色
    _musicCollectionView.backgroundColor = [UIColor clearColor];
    
    
    // 设置数据源,展示数据
    _musicCollectionView.dataSource = self;
    //设置代理,监听
    _musicCollectionView.delegate = self;
    
    // 注册cell
    [_musicCollectionView registerClass:[MusicItemCollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionCell2"];
    
    /* 设置UICollectionView的属性 */
    //设置滚动条
    _musicCollectionView.showsHorizontalScrollIndicator = NO;
    _musicCollectionView.showsVerticalScrollIndicator = NO;
    
    //设置是否需要弹簧效果
    _musicCollectionView.bounces = YES;
    
    [_musicBottomBar addSubview:_musicCollectionView];
    
    _musicCollectionView.hidden = YES;
    
    
    
    //贴纸collectionView
    UICollectionViewFlowLayout* layout3 = [[UICollectionViewFlowLayout alloc] init];
    layout3.itemSize = CGSizeMake(83, 115);
    layout3.estimatedItemSize = CGSizeMake(83, 115);
    
    //设置分区的头视图和尾视图是否始终固定在屏幕上边和下边
    //    layout2.sectionFootersPinToVisibleBounds = YES;
    //    layout2.sectionHeadersPinToVisibleBounds = YES;
    
    // 设置水平滚动方向
    //水平滚动
    layout3.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 设置额外滚动区域
    layout3.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // 设置cell间距
    //设置水平间距, 注意点:系统可能会跳转(计算不准确)
    layout3.minimumInteritemSpacing = 0;
    //设置垂直间距
    layout3.minimumLineSpacing = 0;
    
    
    
    _stickersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 115) collectionViewLayout:layout3];
    
    //设置背景颜色
    _stickersCollectionView.backgroundColor = [UIColor clearColor];
    
    
    // 设置数据源,展示数据
    _stickersCollectionView.dataSource = self;
    //设置代理,监听
    _stickersCollectionView.delegate = self;
    
    // 注册cell
    [_stickersCollectionView registerClass:[MusicItemCollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionCell3"];
    
    /* 设置UICollectionView的属性 */
    //设置滚动条
    _stickersCollectionView.showsHorizontalScrollIndicator = NO;
    _stickersCollectionView.showsVerticalScrollIndicator = NO;
    
    //设置是否需要弹簧效果
    _stickersCollectionView.bounces = YES;
    
    [_musicBottomBar addSubview:_stickersCollectionView];
    
    _stickersCollectionView.hidden = YES;
    
    
    
    

    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.hidden = YES;
    
    
    //保存到相册
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [mainPlayer play];
        [movieFile startProcessing];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _bgImageView.hidden = YES;
    });
    
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notCloseCor) name:@"closeVideoCamerTwo" object:nil];
}

- (void)compressVideoWithInputVideoUrl:(NSURL *) inputVideoUrl
{
    /* Create Output File Url */
    NSString *documentsDirectory = NSTemporaryDirectory();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *finalVideoURLString = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"compressedVideo%@.mp4",nowTimeStr]];
    NSURL *outputVideoUrl = ([[NSURL URLWithString:finalVideoURLString] isFileURL] == 1)?([NSURL URLWithString:finalVideoURLString]):([NSURL fileURLWithPath:finalVideoURLString]); // Url Should be a file Url, so here we check and convert it into a file Url
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVAsset* asset = [AVURLAsset URLAssetWithURL:inputVideoUrl options:options];
    NSArray* keys = @[@"tracks",@"duration",@"commonMetadata"];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        SDAVAssetExportSession *compressionEncoder = [SDAVAssetExportSession.alloc initWithAsset:asset]; // provide inputVideo Url Here
        compressionEncoder.outputFileType = AVFileTypeMPEG4;
        compressionEncoder.outputURL = outputVideoUrl; //Provide output video Url here
        compressionEncoder.videoSettings = @
        {
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: @720,   //Set your resolution width here
        AVVideoHeightKey: @1280,  //set your resolution height here
        AVVideoCompressionPropertiesKey: @
            {
                //2000*1000  建议800*1000-5000*1000
                //AVVideoAverageBitRateKey: @2500000, // Give your bitrate here for lower size give low values
            AVVideoAverageBitRateKey: _bit,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            AVVideoAverageNonDroppableFrameRateKey: _frameRate,
            },
        };
        compressionEncoder.audioSettings = @
        {
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVNumberOfChannelsKey: @2,
        AVSampleRateKey: @44100,
        AVEncoderBitRateKey: @128000,
        };
        [compressionEncoder exportAsynchronouslyWithCompletionHandler:^
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 //更新UI操作
                 //.....
                 if (compressionEncoder.status == AVAssetExportSessionStatusCompleted)
                 {
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         HUD.hidden = YES;
                         [[NSNotificationCenter defaultCenter] removeObserver:self];
                         EditingPublishingDynamicViewController* cor = [[EditingPublishingDynamicViewController alloc] init];
                         cor.videoURL = compressionEncoder.outputURL;
//                         [[AppDelegate appDelegate] pushViewController:cor animated:YES];
                         [self.navigationController pushViewController:cor animated:YES];
                       
                     });
                     
                 }
                 else if (compressionEncoder.status == AVAssetExportSessionStatusCancelled)
                 {
                     HUD.labelText = @"Compression Failed";
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [[NSNotificationCenter defaultCenter] removeObserver:self];
//                         [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
                         [self.navigationController popToRootViewControllerAnimated:YES];
                         
                     });
                 }
                 else
                 {
                     HUD.labelText = @"ompression Failed";
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [[NSNotificationCenter defaultCenter] removeObserver:self];
//                         [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
                         [self.navigationController popToRootViewControllerAnimated:YES];
                     });
                 }
             });
         }];
    }];
}

-(void)clickBackToVideoCammer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)clickNextBtn
{
    HUD.hidden = NO;
    if ([_filtClassName isEqualToString:@"LFGPUImageEmptyFilter"]) {
        //无滤镜效果
        if (_audioPath||!_stickersImgView.hidden) {
            //音乐混合
            [self mixAudioAndVidoWithInputURL:videoURL];
        }else
        {
            HUD.labelText = @"视频处理中...";
            [self compressVideoWithInputVideoUrl:videoURL];
        
        }
    }else
    {
        //添加滤镜效果
        [self mixFiltWithVideoAndInputVideoURL:videoURL];
    }
}
//添加滤镜效果
-(void)mixFiltWithVideoAndInputVideoURL:(NSURL*)inputURL;
{
    
    HUD.labelText = @"滤镜合成中...";
    _isdoing = YES;
    NSURL *sampleURL = inputURL;
    endMovieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    endMovieFile.runBenchmark = YES;
    endMovieFile.playAtActualSpeed = NO;
    
    GPUImageOutput<GPUImageInput> *endFilter;
    if ([_filtClassName isEqualToString:@"GPUImageSaturationFilter"]) {
        GPUImageSaturationFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
        xxxxfilter.saturation = _saturationValue;
        endFilter = xxxxfilter;
        
    }else{
        endFilter = [[NSClassFromString(_filtClassName) alloc] init];
    }

    
    
    [endMovieFile addTarget:endFilter];
    
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/Movie.mp4"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
     movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    [endFilter  addTarget:movieWriter];
    movieWriter.shouldPassthroughAudio = YES;
    endMovieFile.audioEncodingTarget = movieWriter;
    [endMovieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    [movieWriter startRecording];
    [endMovieFile startProcessing];
  __block  __weak GPUImageMovieWriter *weakmovieWriter = movieWriter;
//    __weak MBProgressHUD *weakHUD = HUD;
    typeof(self) __weak  weakself = self;
    [movieWriter setCompletionBlock:^{
        [endFilter removeTarget:weakmovieWriter];
        [weakmovieWriter finishRecording];
        weakmovieWriter = nil;
      if (weakself.audioPath||!weakself.stickersImgView.hidden) {
        [weakself mixAudioAndVidoWithInputURL:movieURL];
        //音乐混合
      }else
      {
        //压缩
        [weakself compressVideoWithInputVideoUrl:movieURL];
      }


        
    }];
}

-(void)mixAudioAndVidoWithInputURL:(NSURL*)inputURL;
{

    if (_audioPath) {
        [self mixAudioAndVidoWithInputURL2:inputURL];
    }else
    {
        [self mixAudioAndVidoWithInputURL1:inputURL];
    }
//    //    audio529
//    
//    // 路径
//    HUD.labelText = @"音乐合成中...";
//    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
//    
//    // 声音来源
//    
//    //    NSURL *audioInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio529" ofType:@"mp3"]];
//    
//    NSURL *audioInputUrl = [NSURL fileURLWithPath:_audioPath];
//    
//    // 视频来源
//    
//    NSURL *videoInputUrl = inputURL;
//    
//    // 最终合成输出路径
//    
////    NSString *outPutFilePath = [documents stringByAppendingPathComponent:@"videoandoudio.mov"];
//    
//    // 添加合成路径
//    
//    
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyyMMddHHmmss";
//    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
//    NSString *fileName = [[documents stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
//    
//    
//    
//    //    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
//    NSURL *outputFileUrl = [NSURL fileURLWithPath:fileName];
//    
//    // 时间起点
//    
//    CMTime nextClistartTime = kCMTimeZero;
//    
//    // 创建可变的音视频组合
//    
//    AVMutableComposition *comosition = [AVMutableComposition composition];
//    
//    // 视频采集
//    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
//    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:options];
//    
//    // 视频时间范围
//    
//    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
//    
//    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
//    
//    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    
//    // 视频采集通道
//    
//    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
//    
//    //  把采集轨道数据加入到可变轨道之中
//    
//    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
//    
//    // 声音采集
//    
//    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:options];
//    
//    // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
//    
//    CMTimeRange audioTimeRange = videoTimeRange;
//    
//    // 音频通道
//    
//    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    
//    // 音频采集通道
//    
//    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
//    
//    // 加入合成轨道之中
//    
//    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:nextClistartTime error:nil];
//    
//
//    
///*
//    //调整视频音量
//    AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
//    // Create the audio mix input parameters object.
//    AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
//    // Set the volume ramp to slowly fade the audio out over the duration of the composition.
////    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
//    [mixParameters setVolume:.05f atTime:kCMTimeZero];
//    // Attach the input parameters to the audio mix.
//    mutableAudioMix.inputParameters = @[mixParameters];
// */
// 
//    
//    // 原音频轨道
////    AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
////     AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
////    [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
//    
//    
//    if (!_editTheOriginaBtn.selected) {
//        AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
//        // Create the audio mix input parameters object.
//        AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
//        // Set the volume ramp to slowly fade the audio out over the duration of the composition.
//        //    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
//        [mixParameters setVolume:.5f atTime:kCMTimeZero];
//        // Attach the input parameters to the audio mix.
//        mutableAudioMix.inputParameters = @[mixParameters];
//        
//        AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//         AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
//        [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
//        
//
//        //视频贴图
//        CGSize videoSize = [videoTrack naturalSize];
//        CALayer* aLayer = [CALayer layer];
//        UIImage* waterImg = _stickersImgView.image;
//        aLayer.contents = (id)waterImg.CGImage;
//        
//        float bili = 720/ScreenWidth;
//        
//        
//        aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
//        aLayer.opacity = 1;
//        
//        CALayer *parentLayer = [CALayer layer];
//        CALayer *videoLayer = [CALayer layer];
//        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
//        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
//        [parentLayer addSublayer:videoLayer];
//        [parentLayer addSublayer:aLayer];
//        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
//        videoComp.renderSize = videoSize;
//        
//        
//        videoComp.frameDuration = CMTimeMake(1, 30);
//        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
//        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//        
//        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
//        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
//        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
//        videoComp.instructions = [NSArray arrayWithObject: instruction];
//        
//        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
//        
//        assetExport.audioMix = mutableAudioMix;
//        
//        assetExport.videoComposition = videoComp;
//        // 输出类型
//        
//        assetExport.outputFileType = AVFileTypeMPEG4;
//        
//        // 输出地址
//        
//        assetExport.outputURL = outputFileUrl;
//        
//        // 优化
//        
//        assetExport.shouldOptimizeForNetworkUse = YES;
//        
//        // 合成完毕
//        
//        [assetExport exportAsynchronouslyWithCompletionHandler:^{
//            
//            // 回到主线程
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                [self compressVideoWithInputVideoUrl:outputFileUrl];
//                
//            });
//        }];
//    }else
//    {
//        
//        //视频贴图
//        CGSize videoSize = [videoTrack naturalSize];
//        CALayer* aLayer = [CALayer layer];
//        UIImage* waterImg = _stickersImgView.image;
//        aLayer.contents = (id)waterImg.CGImage;
//        float bili = 720/ScreenWidth;
//        aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
//        aLayer.opacity = 1;
//        
//        CALayer *parentLayer = [CALayer layer];
//        CALayer *videoLayer = [CALayer layer];
//        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
//        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
//        [parentLayer addSublayer:videoLayer];
//        [parentLayer addSublayer:aLayer];
//        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
//        videoComp.renderSize = videoSize;
//        
//        
//        videoComp.frameDuration = CMTimeMake(1, 30);
//        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
//        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//        
//        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
//        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
//        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
//        videoComp.instructions = [NSArray arrayWithObject: instruction];
//        
//        // 创建一个输出
//        
//        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
//        
//        assetExport.videoComposition = videoComp;
//        //    assetExport.audioMix = mutableAudioMix;
//        // 输出类型
//        
//        assetExport.outputFileType = AVFileTypeMPEG4;
//        
//        // 输出地址
//        
//        assetExport.outputURL = outputFileUrl;
//        
//        // 优化
//        
//        assetExport.shouldOptimizeForNetworkUse = YES;
//        
//        // 合成完毕
//        
//        [assetExport exportAsynchronouslyWithCompletionHandler:^{
//            
//            // 回到主线程
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                [self compressVideoWithInputVideoUrl:outputFileUrl];
//                
//            });
//        }];
//
//    }
    
    
    
}

// 没有音乐
-(void)mixAudioAndVidoWithInputURL1:(NSURL*)inputURL;
{
    
    
    // 路径
    HUD.labelText = @"贴纸合成中...";
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    
    
    // 视频来源
    
    NSURL *videoInputUrl = inputURL;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[documents stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    
    
    //    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:fileName];
    
    // 时间起点
    
    CMTime nextClistartTime = kCMTimeZero;
    
    // 创建可变的音视频组合
    
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    // 视频采集
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:options];
    
    // 视频时间范围
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 视频采集通道
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    //  把采集轨道数据加入到可变轨道之中
    
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    

    
    // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
    
    CMTimeRange audioTimeRange = videoTimeRange;
    
        AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
        
        //视频贴图
        CGSize videoSize = [videoTrack naturalSize];
        CALayer* aLayer = [CALayer layer];
        UIImage* waterImg = _stickersImgView.image;
        aLayer.contents = (id)waterImg.CGImage;
        float bili = 720/SCREEN_WIDTH;
        aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
        aLayer.opacity = 1;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
        videoComp.renderSize = videoSize;
        
        
        videoComp.frameDuration = CMTimeMake(1, 30);
        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        videoComp.instructions = [NSArray arrayWithObject: instruction];
        
        // 创建一个输出
        
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
        
        assetExport.videoComposition = videoComp;
        //    assetExport.audioMix = mutableAudioMix;
        // 输出类型
        
        assetExport.outputFileType = AVFileTypeMPEG4;
        
        // 输出地址
        
        assetExport.outputURL = outputFileUrl;
        
        // 优化
        
        assetExport.shouldOptimizeForNetworkUse = YES;
        
        // 合成完毕
        
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            
            // 回到主线程
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self compressVideoWithInputVideoUrl:outputFileUrl];
                
            });
        }];
}

//有音乐
-(void)mixAudioAndVidoWithInputURL2:(NSURL*)inputURL;
{
    
    //    audio529
    
    // 路径
    HUD.labelText = @"音乐合成中...";
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    
    // 声音来源
    
    //    NSURL *audioInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio529" ofType:@"mp3"]];
    
    NSURL *audioInputUrl = [NSURL fileURLWithPath:_audioPath];
    
    // 视频来源
    
    NSURL *videoInputUrl = inputURL;
    
    // 最终合成输出路径
    
    //    NSString *outPutFilePath = [documents stringByAppendingPathComponent:@"videoandoudio.mov"];
    
    // 添加合成路径
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[documents stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    
    
    //    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:fileName];
    
    // 时间起点
    
    CMTime nextClistartTime = kCMTimeZero;
    
    // 创建可变的音视频组合
    
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    // 视频采集
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:options];
    
    // 视频时间范围
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 视频采集通道
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    //  把采集轨道数据加入到可变轨道之中
    
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    
    // 声音采集
    
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:options];
    
    // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
    
    CMTimeRange audioTimeRange = videoTimeRange;
    
    // 音频通道
    
    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 音频采集通道
    
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    // 加入合成轨道之中
    
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:nextClistartTime error:nil];
    
    
    
    /*
     //调整视频音量
     AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
     // Create the audio mix input parameters object.
     AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
     // Set the volume ramp to slowly fade the audio out over the duration of the composition.
     //    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
     [mixParameters setVolume:.05f atTime:kCMTimeZero];
     // Attach the input parameters to the audio mix.
     mutableAudioMix.inputParameters = @[mixParameters];
     */
    
    
    // 原音频轨道
    //    AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //     AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //    [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
    
    
    if (!_editTheOriginaBtn.selected) {
        AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
        // Create the audio mix input parameters object.
        AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        // Set the volume ramp to slowly fade the audio out over the duration of the composition.
        //    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
        [mixParameters setVolume:.5f atTime:kCMTimeZero];
        // Attach the input parameters to the audio mix.
        mutableAudioMix.inputParameters = @[mixParameters];
        
        AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
        
        
        //视频贴图
        CGSize videoSize = [videoTrack naturalSize];
        CALayer* aLayer = [CALayer layer];
        UIImage* waterImg = _stickersImgView.image;
        aLayer.contents = (id)waterImg.CGImage;
        
        float bili = 720/SCREEN_WIDTH;
        
        
        aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
        aLayer.opacity = 1;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
        videoComp.renderSize = videoSize;
        
        
        videoComp.frameDuration = CMTimeMake(1, 30);
        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        videoComp.instructions = [NSArray arrayWithObject: instruction];
        
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
        
        assetExport.audioMix = mutableAudioMix;
        
        assetExport.videoComposition = videoComp;
        // 输出类型
        
        assetExport.outputFileType = AVFileTypeMPEG4;
        
        // 输出地址
        
        assetExport.outputURL = outputFileUrl;
        
        // 优化
        
        assetExport.shouldOptimizeForNetworkUse = YES;
        
        // 合成完毕
        
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            
            // 回到主线程
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self compressVideoWithInputVideoUrl:outputFileUrl];
                
            });
        }];
    }else
    {
        
        //视频贴图
        CGSize videoSize = [videoTrack naturalSize];
        CALayer* aLayer = [CALayer layer];
        UIImage* waterImg = _stickersImgView.image;
        aLayer.contents = (id)waterImg.CGImage;
        float bili = 720/SCREEN_WIDTH;
        aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
        aLayer.opacity = 1;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
        videoComp.renderSize = videoSize;
        
        
        videoComp.frameDuration = CMTimeMake(1, 30);
        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        videoComp.instructions = [NSArray arrayWithObject: instruction];
        
        // 创建一个输出
        
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
        
        assetExport.videoComposition = videoComp;
        //    assetExport.audioMix = mutableAudioMix;
        // 输出类型
        
        assetExport.outputFileType = AVFileTypeMPEG4;
        
        // 输出地址
        
        assetExport.outputURL = outputFileUrl;
        
        // 优化
        
        assetExport.shouldOptimizeForNetworkUse = YES;
        
        // 合成完毕
        
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            
            // 回到主线程
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self compressVideoWithInputVideoUrl:outputFileUrl];
                
            });
        }];
        
    }
    
    
    
}


-(void)clickEditOriginalBtn
{
    if (!_editTheOriginaBtn.selected) {
        _editTheOriginaBtn.selected = YES;
        [mainPlayer setVolume:0];
    }else
    {
        [mainPlayer setVolume:1];
        _editTheOriginaBtn.selected = NO;
    }
}
//点击音乐
-(void)clickOKBtn
{
//    [self showEditMusicBar:_musicBtn];
    if (self.choseEditType == choseMusic) {
        
    }else
    {
        self.choseEditType = choseMusic;
        
        _okBtn.selected = YES;
        _cancleBtn.selected = NO;
        _stickersBtn.selected = NO;
        _collectionView.hidden = YES;
        _musicCollectionView.hidden = NO;
        _stickersCollectionView.hidden = YES;

        

    }
    if (_audioPath) {
        _editTheOriginaBtn.hidden = NO;
        _editTheOriginaSwitch.hidden = NO;
    }
}
-(void)clickStickersBtn
{
    _editTheOriginaBtn.hidden = YES;
    _editTheOriginaSwitch.hidden = YES;
    if (self.choseEditType == choseStickers) {
        
    }else
    {
        self.choseEditType = choseStickers;
        
        _okBtn.selected = NO;
        _cancleBtn.selected = NO;
        _stickersBtn.selected = YES;
        _collectionView.hidden = YES;
        _musicCollectionView.hidden = YES;
        _stickersCollectionView.hidden = NO;
    }
}

//点击滤镜
-(void)clickCancleBtn
{
//    [self showEditMusicBar:_musicBtn];
//    _audioPath = nil;
//    [_audioPlayer pause];
    _editTheOriginaBtn.hidden = YES;
    _editTheOriginaSwitch.hidden = YES;
    if (self.choseEditType == choseFilter) {
        
    }else
    {
        self.choseEditType = choseFilter;
        
        _okBtn.selected = NO;
        _cancleBtn.selected = YES;
        _stickersBtn.selected = NO;
        _collectionView.hidden = NO;
        _musicCollectionView.hidden = YES;
        _stickersCollectionView.hidden = YES;

        
    }
}
-(void)showEditMusicBar:(UIButton*)sendr
{
    if (!sendr.selected) {
        sendr.selected = YES;
        [_musicBottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view);
        }];
        // 更新约束
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }else
    {
        [_musicBottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(160);
        }];
        // 更新约束
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        sendr.selected = NO;
    }
}

-(NSArray*)creatMusicData
{
    
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"music2" ofType:@"json"];
    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingAllowFragments error:nil];
    NSArray *items = dic[@"music"];
    int i = 529 ;
    NSMutableArray *array = [NSMutableArray array];
    
    MusicData *effect = [[MusicData alloc] init];
    effect.name = @"原始";
    effect.iconPath = [[NSBundle mainBundle] pathForResource:@"nilMusic" ofType:@"png"];
    effect.isSelected = YES;
    [array addObject:effect];
    
    
    for (NSDictionary *item in items) {
        //        NSString *path = [baseDir stringByAppendingPathComponent:item[@"resourceUrl"]];
        MusicData *effect = [[MusicData alloc] init];
        effect.name = item[@"name"];
        effect.eid = item[@"id"];
        effect.musicPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"audio%d",i] ofType:@"mp3"];
        effect.iconPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"icon%d",i] ofType:@"png"];
        [array addObject:effect];
        i++;
    }
    
    return array;
}
-(NSArray*)creatStickersData
{
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"stickers" ofType:@"json"];
    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingAllowFragments error:nil];
    NSArray *items = dic[@"stickers"];
    int i = 529 ;
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *item in items) {
        //        NSString *path = [baseDir stringByAppendingPathComponent:item[@"resourceUrl"]];
        StickersData* stickersItem = [[StickersData alloc] init];
        stickersItem.name = item[@"name"];
        stickersItem.StickersImgPaht = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"stickers%d",i] ofType:@"jpg"];
        [array addObject:stickersItem];
        i++;
    }
    
    return array;
}

-(NSArray*)creatFilterData
{
    FilterData* filter1 = [self createWithName:@"Empty" andFlieName:@"LFGPUImageEmptyFilter" andValue:nil];
    filter1.isSelected = YES;
    FilterData* filter2 = [self createWithName:@"Amatorka" andFlieName:@"GPUImageAmatorkaFilter" andValue:nil];
    FilterData* filter3 = [self createWithName:@"MissEtikate" andFlieName:@"GPUImageMissEtikateFilter" andValue:nil];
    FilterData* filter4 = [self createWithName:@"Sepia" andFlieName:@"GPUImageSepiaFilter" andValue:nil];
    FilterData* filter5 = [self createWithName:@"Sketch" andFlieName:@"GPUImageSketchFilter" andValue:nil];
    FilterData* filter6 = [self createWithName:@"SoftElegance" andFlieName:@"GPUImageSoftEleganceFilter" andValue:nil];
    FilterData* filter7 = [self createWithName:@"Toon" andFlieName:@"GPUImageToonFilter" andValue:nil];

    FilterData* filter8 = [[FilterData alloc] init];
    filter8.name = @"Saturation0";
    filter8.iconPath = [[NSBundle mainBundle] pathForResource:@"GPUImageSaturationFilter0" ofType:@"png"];
    filter8.fillterName = @"GPUImageSaturationFilter";
    filter8.value = @"0";
    
    FilterData* filter9 = [[FilterData alloc] init];
    filter9.name = @"Saturation2";
    filter9.iconPath = [[NSBundle mainBundle] pathForResource:@"GPUImageSaturationFilter2" ofType:@"png"];
    filter9.fillterName = @"GPUImageSaturationFilter";
    filter9.value = @"2";
    
    return [NSArray arrayWithObjects:filter1,filter2,filter3,filter4,filter5,filter6,filter7,filter8,filter9, nil];
    
}

-(FilterData*)createWithName:(NSString* )name andFlieName:(NSString*)fileName andValue:(NSString*)value
{
    FilterData* filter1 = [[FilterData alloc] init];
    filter1.name = name;
    filter1.iconPath =  [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"];
    filter1.fillterName = fileName;
    if (value) {
        filter1.value = value;
    }
    return filter1;
}
-(void)playMusic
{
    // 路径
    
    
    
    
    NSURL *audioInputUrl = [NSURL fileURLWithPath:_audioPath];
    // 声音来源
    
    //    NSURL *audioInputUrl = [NSURL URLWithString:_audioPath];
    
    
    
    audioPlayerItem =[AVPlayerItem playerItemWithURL:audioInputUrl];
    
    [_audioPlayer replaceCurrentItemWithPlayerItem:audioPlayerItem];
    
    [_audioPlayer play];
}

-(void)playOrPause{
    if (playImg.isHidden) {
        playImg.hidden = NO;
        [mainPlayer pause];
        
    }else{
        playImg.hidden = YES;
        [mainPlayer play];
    }
}

- (void)pressPlayButton
{
    [playerItem seekToTime:kCMTimeZero];
    [mainPlayer play];
    if (_audioPath) {
        [audioPlayerItem seekToTime:kCMTimeZero];
        [_audioPlayer play];
    }
    
}

- (void)playingEnd:(NSNotification *)notification
{
    
    [self pressPlayButton];
    //    if (playImg.isHidden) {
    //        [self pressPlayButton];
    //    }
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_audioPlayer pause];
    [mainPlayer pause];
    [movieFile endProcessing];
}

- (void)onApplicationWillResignActive
{
    
    
    [mainPlayer pause];
    [movieFile endProcessing];
    if (_isdoing) {
        [movieWriter cancelRecording];
        [endMovieFile endProcessing];
        HUD.hidden = YES;
    }
    
    
}

- (void)onApplicationDidBecomeActive
{
    [playerItem seekToTime:kCMTimeZero];
    [mainPlayer play];
    [movieFile startProcessing];
    
    if (_isdoing) {
        
        
    }
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// 告诉系统每组多少个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == _collectionView) {
        return _filterAry.count;
        
    }else if (collectionView == _stickersCollectionView)
    {
        return _stickersAry.count;
    }
    else
    {
        return _musicAry.count;
    }
    
    
}

// 告诉系统每个Cell如何显示
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 1.从缓存池中取
    if (collectionView == _collectionView) {
        static NSString *cellID = @"MyCollectionCell";
        MusicItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        FilterData* data = [_filterAry objectAtIndex:indexPath.row];
        cell.iconImgView.image = [UIImage imageWithContentsOfFile:data.iconPath];
        cell.nameLabel.text = data.name;
        
        cell.CheckMarkImgView.hidden = !data.isSelected;
        return cell;
    }else if (collectionView == _stickersCollectionView)
    {
        static NSString *cellID = @"MyCollectionCell3";
        MusicItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        StickersData* data = [_stickersAry objectAtIndex:indexPath.row];
        cell.iconImgView.image = [UIImage imageWithContentsOfFile:data.StickersImgPaht];
        cell.nameLabel.text = data.name;
        
        cell.CheckMarkImgView.hidden = !data.isSelected;
        return cell;
    }else{
        static NSString *cellID2 = @"MyCollectionCell2";
        MusicItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID2 forIndexPath:indexPath];
        MusicData* data = [_musicAry objectAtIndex:indexPath.row];
        UIImage* image = [UIImage imageWithContentsOfFile:data.iconPath];
        cell.iconImgView.image = image;
        cell.nameLabel.text = data.name;
        cell.CheckMarkImgView.hidden = !data.isSelected;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (collectionView == _collectionView) {
        _nowFilterIndex = indexPath;
        if (_lastFilterIndex.row != _nowFilterIndex.row) {
            
            //1.修改数据源
            FilterData* dataNow = [_filterAry objectAtIndex:indexPath.row];
            dataNow.isSelected = YES;
            [_filterAry replaceObjectAtIndex:indexPath.row withObject:dataNow];
            FilterData* dataLast = [_filterAry objectAtIndex:_lastFilterIndex.row];
            dataLast.isSelected = NO;
            [_filterAry replaceObjectAtIndex:_lastFilterIndex.row withObject:dataLast];
            //2.刷新collectionView
            [_collectionView reloadData];
            _lastFilterIndex = indexPath;
            
        }
        
        if (indexPath.row == 0) {
            [movieFile removeAllTargets];
            
            
            FilterData* data = [_filterAry objectAtIndex:indexPath.row];
            _filtClassName = data.fillterName;
            filter = [[NSClassFromString(_filtClassName) alloc] init];
            [movieFile addTarget:filter];
            [filter addTarget:_filterView];

            
        }else
        {
            [movieFile removeAllTargets];
            
            
            FilterData* data = [_filterAry objectAtIndex:indexPath.row];
            _filtClassName = data.fillterName;
            
            if ([data.fillterName isEqualToString:@"GPUImageSaturationFilter"]) {
                GPUImageSaturationFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
                xxxxfilter.saturation = [data.value floatValue];
                _saturationValue = [data.value floatValue];
                filter = xxxxfilter;

            }else{
                filter = [[NSClassFromString(_filtClassName) alloc] init];
            }
            [movieFile addTarget:filter];
            
            // Only rotate the video for display, leave orientation the same for recording
//            GPUImageView *filterView = (GPUImageView *)self.view;
            [filter addTarget:_filterView];
        }
    
    }else if (collectionView == _stickersCollectionView){
        _nowStickersIndex = indexPath;
        if (_lastStickersIndex.row != _nowStickersIndex.row) {
            
            //1.修改数据源
//            FilterData* dataNow = [_filterAry objectAtIndex:indexPath.row];
            StickersData* dataNow = [_stickersAry objectAtIndex:indexPath.row];
            dataNow.isSelected = YES;
            [_stickersAry replaceObjectAtIndex:indexPath.row withObject:dataNow];
            StickersData* dataLast = [_stickersAry objectAtIndex:_lastStickersIndex.row];
            dataLast.isSelected = NO;
            [_stickersAry replaceObjectAtIndex:_lastStickersIndex.row withObject:dataLast];
            //2.刷新collectionView
            [_stickersCollectionView reloadData];
            _lastStickersIndex = indexPath;
            
        }else
        {
            _stickersImgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        }
        StickersData* data = [_stickersAry objectAtIndex:indexPath.row];
        _stickersImgView.image = [UIImage imageWithContentsOfFile:data.StickersImgPaht];
        _stickersImgView.hidden = NO;
        
    }else{
        
        _nowMusicIndex = indexPath;
        if (_lastMusicIndex.row != _nowMusicIndex.row) {
            
            //1.修改数据源
            FilterData* dataNow = [_musicAry objectAtIndex:indexPath.row];
            dataNow.isSelected = YES;
            [_musicAry replaceObjectAtIndex:indexPath.row withObject:dataNow];
            FilterData* dataLast = [_musicAry objectAtIndex:_lastMusicIndex.row];
            dataLast.isSelected = NO;
            [_musicAry replaceObjectAtIndex:_lastMusicIndex.row withObject:dataLast];
            //刷新collectionView
            [_musicCollectionView reloadData];
            _lastMusicIndex = indexPath;
            
        }
        
        
        if (indexPath.row == 0) {
            _audioPath = nil;
            [_audioPlayer pause];
            
            _editTheOriginaBtn.hidden = YES;
            _editTheOriginaSwitch.hidden = YES;
            [mainPlayer setVolume:1];
            _editTheOriginaBtn.selected = NO;
            _editTheOriginaSwitch.on = NO;
            
        }else
        {
            MusicData* data = [_musicAry objectAtIndex:indexPath.row];
            _audioPath = data.musicPath;
            [self playMusic];
            _editTheOriginaBtn.hidden = NO;
            _editTheOriginaSwitch.hidden = NO;
        }
    }
}
-(void)notCloseCor
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _musicBottomBar.hidden = YES;
    }
    
    if ( panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        _musicBottomBar.hidden = NO;
    }
}
-(void)dealloc{
    NSLog(@"EditVideoViewController 释放了");
}
@end
