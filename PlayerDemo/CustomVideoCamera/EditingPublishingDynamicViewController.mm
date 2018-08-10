//
//  EditingPublishingDynamicViewController.m
//  iShow
//
//  Created by 胡阳阳 on 17/3/18.
//
//

#import "EditingPublishingDynamicViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
 #import <CoreLocation/CoreLocation.h>
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoDataModel.h"
#define SCREEN_LayoutScaleBaseOnIPHEN6(x) (([UIScreen mainScreen].bounds.size.width)/375.00 * x)
#define kSignatureContextLengths 20

#define COLOR_FONT_LIGHTGRAY 0x999999
#define COLOR_LINEVIEW_DARKGRAY  0x666666
#define COLOR_BACKBG_DARKGRAY 0x666666
#define COLOR_FONT_YELLOW 0xFDD854
#define COLOR_FONT_WHITE 0xFFFFFF

#define RGB16(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface EditingPublishingDynamicViewController ()<UITextViewDelegate,CLLocationManagerDelegate>
{
    MBProgressHUD* HUD;
    BOOL isExceed_cai;
}
@property (nonatomic ,strong) UIImage* videoCoverImg;

@property (strong, nonatomic) UILabel *limitLabel;
@property (strong, nonatomic) UITextView *contentTextField;
@property (strong, nonatomic) UIButton* lefthWXBtn;
@property (strong, nonatomic) UIButton* rightWXBtn;

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSString* cityName;
@end

@implementation EditingPublishingDynamicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.navigationController.navigationBarHidden = YES;
//    _videoCoverImg = [[AppDelegate appDelegate].cmImageSize getImage:[[_videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
    _videoCoverImg = [self getImage:[[_videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
    UIImageView* bgImgView = [[UIImageView alloc] initWithImage:_videoCoverImg];
    [self.view addSubview:bgImgView];
    UIView* superView = self.view;
    bgImgView.frame  = self.view.bounds;
    [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.height.equalTo(superView);
    }];
    
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    //毛玻璃视图
    UIVisualEffectView* visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    visualEffectView.alpha = .7;
    [bgImgView addSubview:visualEffectView];
    visualEffectView.frame = self.view.bounds;
    [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.top.bottom.equalTo(superView);
    }];
    
    UIView* headerBar = [[UIView alloc] init];
    [self.view addSubview:headerBar];
    headerBar.backgroundColor = [UIColor blackColor];
    [headerBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(44));
    }];
    headerBar.alpha = .8;
    
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"发布";
    titleLabel.textColor = [UIColor whiteColor];
    [headerBar addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(headerBar);
    }];
    
    //    UIButton* backBtn = [[UIButton alloc] init];
    //    backBtn setImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>
    
    UIButton* nextBtn = [[UIButton alloc] init];
    [nextBtn setTitle:@"保存至本地" forState:UIControlStateNormal];
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [nextBtn addTarget:self action:@selector(saveVideoToLoacl) forControlEvents:UIControlEventTouchUpInside];
    
    [headerBar addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.equalTo(headerBar);
        make.width.equalTo(@(100));
    }];
    
    UIButton* BackToVideoCammer = [[UIButton alloc] init];
    [BackToVideoCammer setImage:[UIImage imageNamed:@"BackToVideoCammer"] forState:UIControlStateNormal];
    [BackToVideoCammer addTarget:self action:@selector(backToEditVideoCor) forControlEvents:UIControlEventTouchUpInside];
    [headerBar addSubview:BackToVideoCammer];
    [BackToVideoCammer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(headerBar);
        make.width.equalTo(@(60));
    }];
    
    UIImageView* changeImageView = [[UIImageView alloc] init];
//    changeImageView.image = [[AppDelegate appDelegate].cmImageSize getImage:[[_videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
    changeImageView.image = [self getImage:[[_videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
//    [[AppDelegate appDelegate].cmImageSize getImage:[[_videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]]
    changeImageView.contentMode = UIViewContentModeScaleAspectFill;
    changeImageView.clipsToBounds = YES;
    [superView addSubview:changeImageView];
    [changeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superView);
        make.width.height.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(150)));
        make.top.equalTo(superView).offset(SCREEN_LayoutScaleBaseOnIPHEN6( 85.5));
    }];
//    [[AppDelegate appDelegate].cmImageSize setImagesRounded:changeImageView cornerRadiusValue:3 borderWidthValue:0 borderColorWidthValue:[UIColor clearColor] ];
    changeImageView.layer.masksToBounds = YES;
    changeImageView.layer.cornerRadius = 3;
  
    UIButton* changeVideoCovBtn = [UIButton new];
    changeVideoCovBtn.titleLabel.font = [UIFont systemFontOfSize:SCREEN_LayoutScaleBaseOnIPHEN6(13.0)];
    changeVideoCovBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
//    [changeVideoCovBtn setTitle:@"更换封面" forState:UIControlStateNormal];
    [changeVideoCovBtn setTitle:@"视频封面" forState:UIControlStateNormal];
    [changeImageView addSubview:changeVideoCovBtn];
    [changeVideoCovBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(changeImageView);
        make.height.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(30)));
    }];
//    [[AppDelegate appDelegate].cmImageSize setButtonsRounded:changeVideoCovBtn cornerRadiusValue:SCREEN_LayoutScaleBaseOnIPHEN6(3) borderWidthValue:0 borderColorWidthValue:RGB16(COLOR_FONT_WHITE)];

    changeVideoCovBtn.layer.masksToBounds = YES;
    changeVideoCovBtn.layer.cornerRadius = SCREEN_LayoutScaleBaseOnIPHEN6(3);
    
    
    UIView* bottomBarView0 = [[UIView alloc] init];
    [superView addSubview:bottomBarView0];
    bottomBarView0.backgroundColor = [UIColor blackColor];
    [bottomBarView0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(superView);
        make.height.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(390)));
    }];
    bottomBarView0.alpha = .7;
    
    UIView* bottomBarView = [[UIView alloc] init];
    [superView addSubview:bottomBarView];
    bottomBarView.backgroundColor = [UIColor clearColor];
    [bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(superView);
        make.height.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(390)));
    }];
    
    
    
    UIButton* backBtn = [UIButton new];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:SCREEN_LayoutScaleBaseOnIPHEN6(18.0)];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBtn.backgroundColor = RGB16(COLOR_FONT_YELLOW);
    [backBtn setTitle:@"发布" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(publishingDynamic:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomBarView).offset(SCREEN_LayoutScaleBaseOnIPHEN6(40.0));
        make.right.equalTo(bottomBarView).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(40.0));
        make.bottom.equalTo(bottomBarView).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(38.0));
        make.height.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(45.0)));
    }];
//    [[AppDelegate appDelegate].cmImageSize setButtonsRounded:backBtn cornerRadiusValue:SCREEN_LayoutScaleBaseOnIPHEN6(45.0)/2.0 borderWidthValue:0 borderColorWidthValue:RGB16(COLOR_FONT_WHITE)];
    backBtn.layer.masksToBounds = YES;
    backBtn.layer.cornerRadius = SCREEN_LayoutScaleBaseOnIPHEN6(45.0)/2.0;
  
    UILabel* leftWXLabel = [UILabel new];
    leftWXLabel.font = [UIFont systemFontOfSize:SCREEN_LayoutScaleBaseOnIPHEN6(12.0)];
    leftWXLabel.textColor = RGB16(COLOR_FONT_LIGHTGRAY);
    leftWXLabel.text = @"朋友圈";
    [bottomBarView addSubview:leftWXLabel];
    [leftWXLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bottomBarView).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(60.0));
        make.bottom.equalTo(backBtn.mas_top).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(33.0));
    }];
    
    UILabel* rightWXLabel = [UILabel new];
    rightWXLabel.font = [UIFont systemFontOfSize:SCREEN_LayoutScaleBaseOnIPHEN6(12.0)];
    rightWXLabel.textColor = RGB16(COLOR_FONT_LIGHTGRAY);
    rightWXLabel.text = @"微信好友";
    [bottomBarView addSubview:rightWXLabel];
    [rightWXLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bottomBarView).offset(SCREEN_LayoutScaleBaseOnIPHEN6(60.0));
        make.bottom.equalTo(backBtn.mas_top).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(33.0));
    }];
    
    _lefthWXBtn = [UIButton new]; /*kInitvitionFriendImage*/
    [_lefthWXBtn setImage:[UIImage imageNamed:@"朋友圈选中"] forState:UIControlStateSelected];
    [_lefthWXBtn setImage:[UIImage imageNamed:@"朋友圈"] forState:UIControlStateNormal];
    [_lefthWXBtn addTarget:self action:@selector(clickWXFriendSShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:_lefthWXBtn];
    [_lefthWXBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(leftWXLabel);
        make.bottom.equalTo(leftWXLabel.mas_top).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(10.0));
        make.width.height.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(44.0)));
    }];
    
    _rightWXBtn = [UIButton new];
    [_rightWXBtn setImage:[UIImage imageNamed:@"微信选中"] forState:UIControlStateSelected];
    [_rightWXBtn setImage:[UIImage imageNamed:@"微信"] forState:UIControlStateNormal];
    [_rightWXBtn addTarget:self action:@selector(clickWeChatShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:_rightWXBtn];
    [_rightWXBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(rightWXLabel);
        make.bottom.equalTo(rightWXLabel.mas_top).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(10.0));
        make.width.height.equalTo(@(SCREEN_LayoutScaleBaseOnIPHEN6(44.0)));
    }];
    
    UILabel* shareTipLabel = [UILabel new];
    shareTipLabel.font = [UIFont systemFontOfSize:SCREEN_LayoutScaleBaseOnIPHEN6(12.0)];
    shareTipLabel.textColor = [UIColor whiteColor];;
    shareTipLabel.text = @"同步分享给好友";
    [bottomBarView addSubview:shareTipLabel];
    [shareTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bottomBarView);
        make.bottom.equalTo(_rightWXBtn.mas_top).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(27.0));
    }];
    
    UIView* leftLineView = [UIView new];
    leftLineView.backgroundColor = RGB16(COLOR_LINEVIEW_DARKGRAY);
    [bottomBarView addSubview:leftLineView];
    [leftLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomBarView).offset(SCREEN_LayoutScaleBaseOnIPHEN6(40.0));
        make.right.equalTo(shareTipLabel.mas_left).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(8.0));
        make.height.equalTo(@(0.7));
        make.centerY.equalTo(shareTipLabel);
    }];
    UIView* rightLineView = [UIView new];
    rightLineView.backgroundColor = RGB16(COLOR_LINEVIEW_DARKGRAY);
    [bottomBarView addSubview:rightLineView];
    [rightLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bottomBarView).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(40.0));
        make.left.equalTo(shareTipLabel.mas_right).offset(SCREEN_LayoutScaleBaseOnIPHEN6(8.0));
        make.height.equalTo(@(0.7));
        make.centerY.equalTo(shareTipLabel);
    }];

    

    _contentTextField = [[UITextView alloc ] init];
    _contentTextField.returnKeyType = UIReturnKeyDone;
    _contentTextField.text = @"点击添加描述(最多20个字)";
    _contentTextField.textColor = [UIColor lightGrayColor];
    [_contentTextField setFont:[UIFont systemFontOfSize:SCREEN_LayoutScaleBaseOnIPHEN6(15.0)]];
    [_contentTextField setDelegate:self];
    [bottomBarView addSubview:_contentTextField];
    [_contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomBarView).offset(SCREEN_LayoutScaleBaseOnIPHEN6(30));
        make.bottom.equalTo(shareTipLabel.mas_top).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(70));
        make.left.equalTo(bottomBarView).offset(SCREEN_LayoutScaleBaseOnIPHEN6(20));
        make.right.equalTo(bottomBarView).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(20));
    }];
//    [[AppDelegate appDelegate].cmImageSize setTextViewsRounded:_contentTextField cornerRadiusValue:4 borderWidthValue:0 borderColorWidthValue:[UIColor clearColor]];
    _contentTextField.layer.masksToBounds = YES;
    _contentTextField.layer.cornerRadius = 4;
    
    _limitLabel = [[UILabel alloc] init];
    _limitLabel.text = @"0/20";
    _limitLabel.font = [UIFont systemFontOfSize:SCREEN_LayoutScaleBaseOnIPHEN6(13.0)];
    _limitLabel.textColor = [UIColor blackColor];
    [bottomBarView addSubview:_limitLabel];
    [_limitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_contentTextField.mas_bottom).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(5));
        make.right.equalTo(_contentTextField.mas_right).offset(-SCREEN_LayoutScaleBaseOnIPHEN6(5));
//        make.center.equalTo(_contentTextField);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notCloseCor) name:@"closeVideoCamerThird" object:nil];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    _cityName = [AppDelegate appDelegate].appDelegatePlatformUserStructure.userCity;
////    1.实例化定位管理器
//    _locationManager = [[CLLocationManager alloc] init];
////    2.设置代理
//    _locationManager.delegate = self;
//    //3.定位精度
//    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
//    //4.请求用户权限：分为：4.1只在前台开启定位4.2在后台也可定位，
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
//        [_locationManager requestWhenInUseAuthorization];//4.1只在前台开启定位
////        [_locationManager requestAlwaysAuthorization];//4.2在后台也可定位
//    }
////    5.0更新用户位置
//    [_locationManager startUpdatingLocation];
}
//#pragma mark - CLLocationManagerDelegate -
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations  {
//    CLLocation *newLocation = locations[0];
//    
//    CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
//    
//    NSLog(@"旧的经度：%f,旧的纬度：%f",oldCoordinate.longitude,oldCoordinate.latitude);
//    
//    
//    
//    [manager stopUpdatingLocation];
//    
//    
//    
//    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
//    
//    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        
//        
//        
//        for (CLPlacemark *place in placemarks) {
//            
//            NSLog(@"name,%@",place.name);                       // 位置名
//            
//            NSLog(@"thoroughfare,%@",place.thoroughfare);       // 街道
//            
//            NSLog(@"subThoroughfare,%@",place.subThoroughfare); // 子街道
//            
//            NSLog(@"locality,%@",place.locality);               // 市
//            _cityName = place.locality;
//            if ([_cityName hasSuffix:@"市"]) {
//                _cityName = [_cityName stringByReplacingOccurrencesOfString:@"市" withString:@""];
//                NSLog(@"NewCity:%@",_cityName);
//            }
//            
//            
//            NSLog(@"subLocality,%@",place.subLocality);         // 区
//            
//            NSLog(@"country,%@",place.country);                 // 国家
//            
//            
//        }
//        
//    }];
//    
//}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_contentTextField resignFirstResponder];
}
#pragma mark - keyboard events -
///键盘显示事件
- (void) keyboardWillShow:(NSNotification *)notification {
    
    
//    if (SCREEN_MODE_IPHONE5) {
//        //获取键盘高度，在不同设备上，以及中英文下是不同的
//        CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//        
//        //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
//        //    CGFloat offset = (panelInputTextView.frame.origin.y+panelInputTextView.frame.size.height+INTERVAL_KEYBOARD) - (self.frame.size.height - kbHeight);
//        CGFloat offset =  kbHeight - (ScreenHeight - _fourShareBgView.frame.origin.y);
//        
//        // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
//        double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//        
//        //将视图上移计算好的偏移
//        if(offset > 0) {
//            [UIView animateWithDuration:duration animations:^{
//                self.frame = CGRectMake(0.0f, -offset, self.frame.size.width, self.frame.size.height);
//            }];
//        }
//        
//    }
    
}

///键盘消失事件
- (void) keyboardWillHide:(NSNotification *)notify {
//    // 键盘动画时间
//    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    
//    //视图下沉恢复原状
//    [UIView animateWithDuration:duration animations:^{
//        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
//    }];
}


#pragma mark textViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView.tag == 0) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
        textView.tag = 1;
    }
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        //        textView.text = @"说点什么吧...";
        //        textView.textColor = [UIColor lightGrayColor];
        //        textView.tag = 0 ;
    }
    NSString *lengthString;
    if ([textView.text length] > kSignatureContextLengths) {
        lengthString = [[NSString alloc] initWithFormat:@"内容超出:%lu/%d",(unsigned long)[textView.text length],kSignatureContextLengths];
        _limitLabel.textColor = [UIColor redColor];
        isExceed_cai = YES;
    }
    else  {
        lengthString = [[NSString alloc] initWithFormat:@"%lu/%d",(unsigned long)[textView.text length],kSignatureContextLengths];
        _limitLabel.textColor = [UIColor blackColor];
        isExceed_cai = NO;
    }
    _limitLabel.text = lengthString;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        textView.text = @"点击添加描述(最多20个字)";
        textView.textColor = [UIColor lightGrayColor];
        textView.tag = 0 ;
    }
    return YES;
    
}

//点击键盘完成后 收键盘
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [_contentTextField resignFirstResponder];
        return NO;
    }
    
    return YES;
}


- (IBAction)publishingDynamic:(id)sender {
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
    HUD.labelText = @"此处逻辑需根据业务自行实现";
    [HUD hide:YES afterDelay:2.0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    });
    
//
    
//    if ([_contentTextField.text length] > kSignatureContextLengths) {
//        return;
//    }
//    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
//    HUD.labelText = @"上传中";
}

-(void)backToEditVideoCor
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)saveVideoToLoacl
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"保存成功";
    [HUD hide:YES afterDelay:1.0];
    UISaveVideoAtPathToSavedPhotosAlbum([[_videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""], nil, nil, nil);
}


/**
 点击微信朋友圈分享按钮

 @param sender 微信朋友圈Btn
 */
- (void)clickWXFriendSShareBtn:(UIButton *)sender {

    if (!sender.selected) {
        sender.selected = YES;
        _rightWXBtn.selected = NO;
    }else
    {
        sender.selected = NO;
    }
}

/**
 点击微信分享按钮

 @param sender 微信Btn
 */
- (void)clickWeChatShareBtn:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = YES;
        _lefthWXBtn.selected = NO;
    }else
    {
        sender.selected = NO;
    }
}

-(void)notCloseCor
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
  return YES;
}

#pragma mark 通过视频的URL，获得视频缩略图
-(UIImage *)getImage:(NSString *)videoURL

{
  
  AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
  
  AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
  
  gen.appliesPreferredTrackTransform = YES;
  
  CMTime time = CMTimeMakeWithSeconds(0.0, 600);
  
  NSError *error = nil;
  
  CMTime actualTime;
  
  CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
  
  UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
  
  CGImageRelease(image);
  
  return thumb;
}

-(void)dealloc
{
    NSLog(@"%@释放了",self.class);
}

@end
