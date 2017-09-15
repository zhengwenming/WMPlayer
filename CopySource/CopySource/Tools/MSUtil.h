//
//  MSServiceContent.m
//  EggplantAlbums
//
//  Created by yeby on 13-8-6.
//  Copyright (c) 2013年 YunInfo. All rights reserved.
//
#import "MBProgressHUD.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/NSObject.h>
#import <CoreLocation/CoreLocation.h>

@interface MSUtil : NSObject

+ (NSDictionary *)dictionaryFromBundleWithName:(NSString*)fileName withType:(NSString*)typeName;
//字符串MD5转换
+ (NSString *)md5HexDigest:(NSString*)input;
+ (NSString *)fileMd5sum:(NSString * )filename; //md5转换
///sha1算法
+ (NSString *)sha1:(NSString *)inputStr;
//时间格式
+ (NSDate *)getNowTime;
+ (NSString *)getyyyymmdd;
+ (NSString *)get1970timeString;
+ (NSString *)getTimeString:(NSDate *)date;
+ (NSString *)gethhmmss;


+ (void)showTipsWithHUD:(NSString *)labelText;
+ (void)showTipsWithHUD:(NSString *)labelText inView:(UIView *)inView;
+ (void)showTipsWithView:(UIView *)uiview labelText:(NSString *)labelText showTime:(CGFloat)time;
+ (void) showHudMessage:(NSString*) msg hideAfterDelay:(NSInteger) sec uiview:(UIView *)uiview;

+ (void)showNotReachabileTips;

+ (NSDate *)dateFromString:(NSString *)dateString usingFormat:(NSString*)format;
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringFromDate:(NSDate *)date usingFormat:(NSString*)format;

/**
 根据时间戳获取时间
 
 @param timeStamp long long 的时间戳参数
 @return 格式化后的时间字符串
 */
+ (NSString *)timeStringWithTimeStamp:(long long)timeStamp;

/**
 截取URL中的参数
 
 @param urlStr URL
 @return 字典形式的参数
 */
+ (NSMutableDictionary *)getURLParameters:(NSString *)urlStr;


//获取后台服务器主机名
//+(NSString*)readFromUmengOlineHostname;

//loadingView方法集
+(void)addLoadingViewInView:(UIView*)viewToLoadData usingUIActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)aStyle;
+(void)removeLoadingViewInView:(UIView*)viewToLoadData;
+(void)addLoadingViewInView:(UIView*)viewToLoadData usingUIActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)aStyle usingColor:(UIColor*)color;
+(void)removeLoadingViewAndLabelInView:(UIView*)viewToLoadData;
+(void)addLoadingViewAndLabelInView:(UIView*)viewToLoadData usingOrignalYPosition:(CGFloat)yPosition;
+(void)showProgessInView:(UIView *)view withExtBlock:(void (^)())exBlock withComBlock:(void (^)())comBlock;
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation; //图片旋转

//将图片保存到应用程序沙盒中去,imageNameString的格式为 @"upLoad.png" 
+ (void)saveImagetoLocal:(UIImage*)image imageName:(NSString *)imageNameString;
+ (NSString *)getDeviceOSType;


//判断字符串长度
+ (int)convertToInt:(NSString*)strtemp;
//end

+(NSMutableArray *)decorateString:(NSString *)string;
//正则表达式部分
+ (BOOL) validateEmail:(NSString *)email;
/// 手机号码验证
+ (BOOL) validateMobile:(NSString *)mobile;
/// 身份证号码校验
+ (BOOL)isIdCardNumber:(NSString *)value;
//用户名
+ (BOOL)validateUserName:(NSString *)name;
//密码
+ (BOOL)validatePassword:(NSString *)passWord;
//昵称
+ (BOOL)validateNickname:(NSString *)nickname;
//身份证号
+ (BOOL)validateIdentityCard: (NSString *)identityCard;
//银行卡
+ (BOOL)validateBankCardNumber: (NSString *)bankCardNumber;
//银行卡后四位
+ (BOOL)validateBankCardLastNumber: (NSString *)bankCardNumber;
//CVN
+ (BOOL)validateCVNCode: (NSString *)cvnCode;
//month
+ (BOOL)validateMonth: (NSString *)month;
//year
+ (BOOL) validateYear: (NSString *)year;
//verifyCode
+ (BOOL) validateVerifyCode: (NSString *)verifyCode;
//压缩图片质量
+(UIImage *)reduceImage:(UIImage *)image percent:(float)percent;
//压缩图片尺寸
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIColor *) colorWithHexString: (NSString *)color;
/**
 *  返回字符串所占用的尺寸
 *
 *  @param stringFont    字体
 *  @param stringSize 最大尺寸
 */
+ (CGSize)getWidthByString:(NSString*)string withFont:(UIFont*)stringFont withStringSize:(CGSize)stringSize;
/**
 *  正则表达式验证数字
 */
+ (BOOL)checkNum:(NSString *)str;
/**
 *  一键赋值
 */
+ (BOOL)reflectDataFromOtherObject:(NSObject*)dataSource withNsobject:(id)selfObject;
// View转化为图片
+ (UIImage *)getImageFromView:(UIView *)view;
+ (BOOL)isLocationOpen;//判断是否打开定位

/// 判断是否含有非法字符 yes 有  no没有
+ (BOOL)JudgeTheillegalCharacter:(NSString *)content;
#pragma mark - 模态界面方法

/**
 模态界面方法

 @param VC presntViewController
 @param selfVC 当前控制器
 @param str 控制器标题
 @param completion 完成后的回调
 */
+ (void)presentViewController:(UIViewController *)VC
                       selfVC:(UIViewController *)selfVC
                        title:(NSString *)str
                        block:(void (^ __nullable)(void))completion;

/**
 字典转json字符串
 @param dictionary dictionary
 @return jsonString
 */
+ (NSString *)getJsonStringFromNSDictionary:(NSDictionary *)dictionary;

/**
 json字符串转成obj
 @param jsonString json格式的字符串
 @return 一个id对象（数组或者字典）
 */
+ (id )getObjectWithJsonString:(NSString *)jsonString;
+(NSString *)matchTitleWithCode:(NSString *)code;
+ (BOOL) isContainPropertyWithClass:(Class) myClass propertyName:(NSString *)name;
+ (NSString *)matchIndexStringWithCode:(NSString *)code;
+ (NSInteger )calcAge:(NSString*)birthday;

@end
