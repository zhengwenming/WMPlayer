
//
//  Macro.h
//  TongXueBao
//
//  Created by 郑文明 on 16/9/22.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

///颜色相关
//主题色
//#define kThemeColor ([UIColor colorWithRed:97.0/255.0 green:194.0/255.0 blue:67.0/255.0 alpha:1.0])

#define kThemeColor ([UIColor colorWithRed:252.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1.0])

//#define kTintColor ([UIColor colorWithRed:67.0/255.0 green:194.0/255.0 blue:71.0/255.0 alpha:1.0])
#define kTintColor [UIColor redColor]





///适配相关
#define kTopScrollerViewHight 44
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kDeviceVersion [[UIDevice currentDevice].systemVersion floatValue]
#define kNavbarHeight ((kDeviceVersion>=7.0)? 64 :44 )
#define kIOS7DELTA   ((kDeviceVersion>=7.0)? 20 :0 )
#define kTabBarHeight 49
// navigation fontSize
#define kPolicyDetailHeaderViewHeight 77.f
#define kReimbursedByThirdPartyButtonTag 500
#define kIphone5TextFont 13.f


#define TheUserDefaults [NSUserDefaults standardUserDefaults]


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kSCREEN_MAX_LENGTH (MAX(kScreenWidth, kScreenHeight))
#define kSCREEN_MIN_LENGTH (MIN(kScreenWidth, kScreenHeight))

#define IS_IPHONE4 (IS_IPHONE && kSCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE5 (IS_IPHONE && kSCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE6 (IS_IPHONE && kSCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE6P (IS_IPHONE && kSCREEN_MAX_LENGTH == 736.0)



#define kSafeString(__X__)        [__X__ isKindOfClass:[NSNull class]] ? @"" : [NSString stringWithFormat:@"%@", (__X__)]





/** 弱引用 */
#define WEAKSELF __weak typeof(self) weakSelf = self

#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;

/** 避免self的提前释放 */
#define STRONGSELF __weak typeof(weakSelf) strongSelf = weakSelf
/** 设置图片 */
#define kGetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]
/** 修改Log,debug：WMLog，执行NSLog，release，自动忽略 */
#ifdef DEBUG
#define WMLog(...) NSLog(__VA_ARGS__)
#else
#define WMLog(...)
#endif

#endif /* Macro_h */
