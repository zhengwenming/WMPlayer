//
//  MSServiceContent.m
//  EggplantAlbums
//
//  Created by yeby on 13-8-6.
//  Copyright (c) 2013年 YunInfo. All rights reserved.
//
#define KFacialSizeWidth    32

#define KFacialSizeHeight   32

#define KCharacterWidth     8

#define VIEW_LINE_HEIGHT    32

#define VIEW_LEFT           0

#define VIEW_RIGHT          5

#define VIEW_TOP            8

#define VIEW_WIDTH_MAX      238

#define FACE_NAME_HEAD  @"["

// 表情转义字符的长度（ /s占2个长度，xxx占3个长度，共5个长度 ）
#define FACE_NAME_LEN   4

#define kShowTipsWithHUD 1.5

#import "MSUtil.h"


#import "MBProgressHUD.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>

#include <ctype.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <dirent.h>
#import <CommonCrypto/CommonDigest.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/sockio.h>
#import <objc/runtime.h>
//#import "MobClick.h"
//#import "MessageView.h"
//#import "FaceBoard.h"

#define PATTERN_STR         @"\\[[^\\[\\]]*\\]"

@implementation MSUtil

+(NSDictionary*)dictionaryFromBundleWithName:(NSString*)fileName withType:(NSString*)typeName
{
    NSDictionary * dict = nil;
    NSString *infoPlist = [[NSBundle mainBundle] pathForResource:fileName ofType:typeName];

    if ([[NSFileManager defaultManager] isReadableFileAtPath:infoPlist]) {
        NSDictionary * dict = [[NSDictionary alloc] initWithContentsOfFile:infoPlist];
        return dict;
    }
    return dict;
}


//MD5转换
+ (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];//
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
///sha1
+ (NSString *) sha1:(NSString *)inputStr{
    const char *cstr = [inputStr cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:inputStr.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *outputStr = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH;i++){
        [outputStr appendFormat:@"%02x", digest[i]];
        }
        return outputStr;
}
        
        
+(void)removeLoadingViewAndLabelInView:(UIView*)viewToLoadData
{
    //viewToLoadData.hidden = NO;
    UIActivityIndicatorView * breakingLoadingView = (UIActivityIndicatorView*)[viewToLoadData  viewWithTag:10087];
    [breakingLoadingView stopAnimating];
    
    [[viewToLoadData  viewWithTag:10086] removeFromSuperview];
}



+(void)addLoadingViewAndLabelInView:(UIView*)viewToLoadData usingOrignalYPosition:(CGFloat)yPosition
{
    
    UIView * loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, yPosition, viewToLoadData.frame.size.width , 60)];
    loadingView.tag = 10086;
    
    
    UIFont * labelFont = [UIFont systemFontOfSize:14.0f];
  
//    NSString *string = @"加载中";
    CGSize  labelSize = [@"加载中" sizeWithAttributes:@{NSFontAttributeName:labelFont}];
//    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]};
//    CGSize labelSize = [string sizeWithAttributes:attributes];
    if (![viewToLoadData viewWithTag:10087]) {
        UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.frame = CGRectMake(( loadingView.frame.size.width - labelSize.width-20-5)/2, 15.0f, 20.0f, 20.0f);
        activityIndicatorView.tag = 10087;
        [loadingView addSubview:activityIndicatorView];
          [activityIndicatorView startAnimating];
    }

    
    if (![viewToLoadData viewWithTag:10088]) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([loadingView viewWithTag:10087] .frame.origin.x + 20+5, 10.0f, labelSize.width, 30.0f)];
        label.tag = 10088;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = labelFont;
        label.textColor = [UIColor whiteColor];
        // label.shadowColor = [UIColor colorWithWhite:.9f alpha:1.0f];
        //label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
//        label.textAlignment = UITextAlignmentLeft;
        label.text = @"加载中";
        [loadingView addSubview:label];
    }
    [viewToLoadData addSubview:loadingView];
  
}



#pragma mark - Only ActivityView

+(void)addLoadingViewInView:(UIView*)viewToLoadData usingUIActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)aStyle usingColor:(UIColor*)color
{
    UIActivityIndicatorView * breakingLoadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:aStyle];
    breakingLoadingView.tag = 99;
    breakingLoadingView.center = CGPointMake( (viewToLoadData.frame.size.width-40)/2+20, (viewToLoadData.frame.size.height-40)/2+20);
    breakingLoadingView.color = color;
    [breakingLoadingView startAnimating];
    [viewToLoadData addSubview:breakingLoadingView];
    
    
}


+(void)addLoadingViewInView:(UIView*)viewToLoadData usingUIActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)aStyle
{

//    [self addLoadingViewInView:viewToLoadData usingUIActivityIndicatorViewStyle:aStyle usingColor:[UIColor redColor]];
}

+(void)removeLoadingViewInView:(UIView*)viewToLoadData
{
    UIActivityIndicatorView * breakingLoadingView = (UIActivityIndicatorView*)[viewToLoadData  viewWithTag:99];
    [breakingLoadingView stopAnimating];
    [breakingLoadingView removeFromSuperview];
}

+ (NSDate *)getNowTime
{
    return [NSDate date];
}
+(NSString *)getyyyymmdd{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatDay = [[NSDateFormatter alloc] init];
    formatDay.dateFormat = @"yyyyMMdd";
    NSString *dayStr = [formatDay stringFromDate:now];
    
    return dayStr;

}
+(NSString *)gethhmmss{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatTime = [[NSDateFormatter alloc] init];
    formatTime.dateFormat = @"HHmmss";
    NSString *timeStr = [formatTime stringFromDate:now];
    
    return timeStr;

}
+ (NSString *)get1970timeString{
    return [NSString stringWithFormat:@"%lld",(long long)[[NSDate date] timeIntervalSince1970] * 1000];
}
+ (NSString *)getTimeString:(NSDate *)date{
    return [NSString stringWithFormat:@"%lld",(long long)[date timeIntervalSince1970] * 1];
}

+ (NSString *)timeStringWithTimeStamp:(long long)timeStamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000];
    return [MSUtil stringFromDate:date];
}

+ (void)showTipsWithHUD:(NSString *)labelText showTime:(CGFloat)time
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[[[UIApplication sharedApplication] delegate] window]] ;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = labelText;
    hud.detailsLabelFont = [UIFont systemFontOfSize:15.0];
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:hud];
    
    [hud hide:YES afterDelay:time];
}

+ (void)showTipsWithHUD:(NSString *)labelText
{
    [self showTipsWithHUD:labelText showTime:kShowTipsWithHUD];
}

+ (void)showTipsWithHUD:(NSString*)labelText inView:(UIView *)inView
{
    [MSUtil showTipsWithView:inView labelText:labelText showTime:kShowTipsWithHUD];
}

+ (void)showTipsWithView:(UIView *)uiview labelText:(NSString *)labelText showTime:(CGFloat)time
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:uiview] ;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = labelText;
    hud.detailsLabelFont = [UIFont systemFontOfSize:15.0];
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    [uiview addSubview:hud];
    
    [hud hide:YES afterDelay:time];
}
+ (void)showProgessInView:(UIView *)view withExtBlock:(void (^)())exBlock withComBlock:(void (^)())comBlock
{
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:view];
    hud.color = [UIColor colorWithWhite:0.8 alpha:0.6];
    //    hud.dimBackground = NO;
    [view addSubview:hud];
    hud.labelText = @"正在加载...";
    if (exBlock) {
        [hud showAnimated:YES whileExecutingBlock:exBlock completionBlock:^{
            if (comBlock) {
                comBlock();
            }
            [hud removeFromSuperview];
        }];
        
    }else
        [hud showAnimated:YES whileExecutingBlock:exBlock completionBlock:^{
            [hud removeFromSuperview];
        }];
}

+ (void) showHudMessage:(NSString*) msg hideAfterDelay:(NSInteger) sec uiview:(UIView *)uiview
{
    
    MBProgressHUD* hud2 = [MBProgressHUD showHUDAddedTo:uiview animated:YES];
    hud2.mode = MBProgressHUDModeText;
    hud2.labelText = msg;
    hud2.margin = 12.0f;
    hud2.yOffset = 20.0f;
    hud2.removeFromSuperViewOnHide = YES;
    [hud2 hide:YES afterDelay:sec];
}


+ (void)showNotReachabileTips
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"与服务端连接已断开,请检查您的网络连接是否正常."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
}

+(NSDate *)dateFromString:(NSString *)dateString usingFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: format];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;

}

+ (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
}
+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

+ (NSString *)stringFromDate:(NSDate *)date usingFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
    
}
+ (NSString *)getDeviceOSType
{
    NSString *systemVersion =  [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] systemVersion]];
	return systemVersion;
}
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation //图片旋转
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

//将图片保存到应用程序沙盒中去,imageNameString的格式为 @"upLoad.png"
+ (void)saveImagetoLocal:(UIImage*)image imageName:(NSString *)imageNameString 
{
    if (image == nil || imageNameString.length == 0) {
        return;
    }
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *saveImagePath=[documentsDirectory stringByAppendingPathComponent:imageNameString];
    NSData *imageDataJPG=UIImageJPEGRepresentation(image, 0);//将图片大小进行压缩
//    NSData *imageData=UIImagePNGRepresentation(image);
    [imageDataJPG writeToFile:saveImagePath atomically:YES];
}

//md5转换
+ (NSString *) fileMd5sum:(NSString * )filename
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filename];
    if( handle== nil ) {
		return nil;
	}
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength: 256 ];
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
	
	return s;
}


#pragma mark - 将字符串中的文字和表情解析出来
+ (NSMutableArray *)decorateString:(NSString *)string
{
    NSMutableArray *array =[NSMutableArray array];
    
    NSRegularExpression* regex = [[NSRegularExpression alloc]
                                  initWithPattern:PATTERN_STR
                                  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                  error:nil];
    NSArray* chunks = [regex matchesInString:string options:0
                                       range:NSMakeRange(0, [string length])];
    NSMutableArray *matchRanges = [NSMutableArray array];
    
    for (NSTextCheckingResult *result in chunks) {
        NSString *resultStr = [string substringWithRange:[result range]];
        
        if ([resultStr hasPrefix:@"["] && [resultStr hasSuffix:@"]"]) {
            NSString *name = [resultStr substringWithRange:NSMakeRange(1, [resultStr length]-2)];
            name=[NSString stringWithFormat:@"[%@]",name];
            WMLog(@"name:%@",name);
            NSDictionary *faceMap = [[NSUserDefaults standardUserDefaults] objectForKey:@"FaceMap"];
            if ([[faceMap allValues] containsObject:name]) {
                //                [array addObject:name];
                [matchRanges addObject:[NSValue valueWithRange:result.range]];
            }
        }
    }
    
    NSRange r = NSMakeRange([string length], 0);
    [matchRanges addObject:[NSValue valueWithRange:r]];
    
    NSUInteger lastLoc = 0;
    for (NSValue *v in matchRanges) {
        
        NSRange resultRange = [v rangeValue];
        if (resultRange.location==0) {
            NSString *faceString = [string substringWithRange:resultRange];
            WMLog(@"aaaaaaaaa:faceString:%@",faceString);
            if (faceString.length!=0) {
                [array addObject:faceString];
            }
            
            NSRange normalStringRange = NSMakeRange(lastLoc, resultRange.location - lastLoc);
            NSString *normalString = [string substringWithRange:normalStringRange];
            lastLoc = resultRange.location + resultRange.length;
            WMLog(@"aaaaaaa:normalString:%@",normalString);
            if (normalString.length!=0) {
                [array addObject:normalString];
            }
        }else{
            NSRange normalStringRange = NSMakeRange(lastLoc, resultRange.location - lastLoc);
            NSString *normalString = [string substringWithRange:normalStringRange];
            lastLoc = resultRange.location + resultRange.length;
            WMLog(@"bbbbbbb:normalString:%@",normalString);
            if (normalString.length!=0) {
                [array addObject:normalString];
            }
            
            NSString *faceString = [string substringWithRange:resultRange];
            WMLog(@"bbbbbbbb:faceString:%@",faceString);
            if (faceString.length!=0) {
                [array addObject:faceString];
            }
        }
    }
    if ([matchRanges count]==0) {
        if (string.length!=0) {
            [array addObject:string];
        }
    }
    WMLog(@"array:%@",array);
    
    return array;
}

#pragma mark - 获取文本尺寸
/*
+ (CGFloat)getContentSize:(NSArray *)messageRange
{    
    @synchronized ( self ) {
        CGFloat upX;
        
        CGFloat upY;
        
        CGFloat lastPlusSize;
        
        CGFloat viewWidth;
        
        CGFloat viewHeight;
        
        BOOL isLineReturn;
        
        //        RelayBottleList *mineBottleListObject = [relayBottleArray objectAtIndex:indexPath.row];
        //        NSArray *messageRange = mineBottleListObject.messageRange;
        
        NSDictionary *faceMap = [[NSUserDefaults standardUserDefaults] objectForKey:@"FaceMap"];
        
        UIFont *font = [UIFont systemFontOfSize:16.0f];
        
        isLineReturn = NO;
        
        upX = VIEW_LEFT;
        upY = VIEW_TOP;
        
        for (int index = 0; index < [messageRange count]; index++) {
            
            NSString *str = [messageRange objectAtIndex:index];
            if ( [str hasPrefix:FACE_NAME_HEAD] ) {
                
                //NSString *imageName = [str substringWithRange:NSMakeRange(1, str.length - 2)];
                
                NSArray *imageNames = [faceMap allKeysForObject:str];
                NSString *imageName = nil;
                NSString *imagePath = nil;
                
                if ( imageNames.count > 0 ) {
                    
                    imageName = [imageNames objectAtIndex:0];
                    imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
                }
                
                if ( imagePath ) {
                    
                    if ( upX > ( VIEW_WIDTH_MAX - KFacialSizeWidth ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
                    upX += KFacialSizeWidth;
                    
                    lastPlusSize = KFacialSizeWidth;
                }
                else {
                    
                    for ( int index = 0; index < str.length; index++) {
                        
                        NSString *character = [str substringWithRange:NSMakeRange( index, 1 )];
                        
                        CGSize size = [character sizeWithFont:font
                                            constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];
                        
                        if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
                            
                            isLineReturn = YES;
                            
                            upX = VIEW_LEFT;
                            upY += VIEW_LINE_HEIGHT;
                        }
                        
                        upX += size.width;
                        
                        lastPlusSize = size.width;
                    }
                }
            }
            else {
                
                for ( int index = 0; index < str.length; index++) {
                    
                    NSString *character = [str substringWithRange:NSMakeRange( index, 1 )];
                    
                    CGSize size = [character sizeWithFont:font
                                        constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];
                    
                    if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
                    upX += size.width;
                    
                    lastPlusSize = size.width;
                }
            }
        }
        
        if ( isLineReturn ) {
            
            viewWidth = VIEW_WIDTH_MAX + VIEW_LEFT * 2;
        }
        else {
            
            viewWidth = upX + VIEW_LEFT;
        }
        
        viewHeight = upY + VIEW_LINE_HEIGHT + VIEW_TOP;
        
        NSValue *sizeValue = [NSValue valueWithCGSize:CGSizeMake( viewWidth, viewHeight )];
        WMLog(@"%@",sizeValue);
        //        [sizeList setObject:sizeValue forKey:indexPath];
        //        [sizeList addObject:sizeValue];
        return viewHeight;
    }
}
*/
//正则表达式判断～～～
//#define MOBILE_REG "^1[0-9]{10}$"                                                /* 手机号正则表达式     */
//#define EMAIL_REG  "^[a-zA-Z0-9_+.-]{2,}@([a-zA-Z0-9-]+[.])+[a-zA-Z0-9]{2,4}$"    /* 邮箱正则表达式       */
//#define USRNAM_REG "^[A-Za-z0-9_]{6,20}$"                                         /* 用户名正则表达式     */

//邮箱
+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

// 手机号码验证
+ (BOOL) validateMobile:(NSString *)mobile
{
    /**
     * 手机号码
     * 移动：134, 135, 136, 137, 138, 139, 147, 150, 151, 152, 157, 158, 159, 178, 182, 183, 184, 187, 188
     * 联通：130, 131, 132, 155, 156, 176, 185, 186
     * 电信：133, 153, 189, 180, 181, 177
     */
    NSString *regex = @"^1(3[0-9]|4[57]|5[0-35-9]|7[0-9]|8[0-9]|9[0-9])\\d{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:mobile];
}
/// 身份证号码校验
+ (BOOL)isIdCardNumber:(NSString *)value
{
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    int length =0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray = @[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return false;
    }
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19|20[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19|20[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
            }else {
                return NO;
            }
        default:
            return false;
    }
}
//用户名
+ (BOOL) validateUserName:(NSString *)name
{
//    NSString *userNameRegex = @"^[A-Za-z0-9]{4,20}+$";
    NSString *userNameRegex = @"^[A-Za-z0-9_]{6,20}$";

    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:name];
    return B;
}
//密码
+ (BOOL) validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,18}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}
//昵称
+ (BOOL) validateNickname:(NSString *)nickname
{
    NSString *nicknameRegex = @"([\u4e00-\u9fa5]{2,5})(&middot;[\u4e00-\u9fa5]{2,5})*";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}
//身份证号
+ (BOOL) validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
//银行卡
+ (BOOL) validateBankCardNumber: (NSString *)bankCardNumber
{
    BOOL flag;
    if (bankCardNumber.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{15,30})";
    NSPredicate *bankCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [bankCardPredicate evaluateWithObject:bankCardNumber];
}
//银行卡后四位
+ (BOOL) validateBankCardLastNumber: (NSString *)bankCardNumber
{
    BOOL flag;
    if (bankCardNumber.length != 4) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{4})";
    NSPredicate *bankCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [bankCardPredicate evaluateWithObject:bankCardNumber];
}
//CVN
+ (BOOL) validateCVNCode: (NSString *)cvnCode
{
    BOOL flag;
    if (cvnCode.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{3})";
    NSPredicate *cvnCodePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [cvnCodePredicate evaluateWithObject:cvnCode];
}
//month
+ (BOOL) validateMonth: (NSString *)month
{
    BOOL flag;
    if (!(month.length == 2)) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"(^(0)([0-9])$)|(^(1)([0-2])$)";
    NSPredicate *monthPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [monthPredicate evaluateWithObject:month];
}
//year
+ (BOOL) validateYear: (NSString *)year
{
    BOOL flag;
    if (!(year.length == 2)) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^([1-3])([0-9])$";
    NSPredicate *yearPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [yearPredicate evaluateWithObject:year];
}
//verifyCode
+ (BOOL) validateVerifyCode: (NSString *)verifyCode
{
    BOOL flag;
    if (!(verifyCode.length == 6)) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{6})";
    NSPredicate *verifyCodePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [verifyCodePredicate evaluateWithObject:verifyCode];
}



//加载XIB
//+(id)loadFromXIB:(NSString *)XIBName{
//    NSArray *array = [[NSBundle mainBundle] loadNibNamed:XIBName owner:nil options:nil];
//    if (array && [array count]) {
//        return array[0];
//    }else {
//        return nil;
//    }
//}
+ (int)convertToInt:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }else {
            p++;
        }
    }
    return strlength;
}

- (int)getToInt:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return (int)[da length];
}
//压缩图片质量
+(UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}
//压缩图片尺寸
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

+ (UIColor *)colorWithHexString:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}
//自定义字符串长度
+ (CGSize)getWidthByString:(NSString*)string withFont:(UIFont*)stringFont withStringSize:(CGSize)stringSize
{
    NSDictionary *attribute = @{NSFontAttributeName: stringFont};
    CGSize size = [string boundingRectWithSize:stringSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    //MyLog(@"withd:%f,height:%f",size.width,size.height);
    return size;
}

+ (BOOL)checkNum:(NSString *)str
{
    NSString *regex = @"^[0-9]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        return NO;
    }
    return YES;
}
//一键赋值
+ (NSArray*)propertyKeys:(id)selfObject
{
    
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([selfObject class], &outCount);
    
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:outCount];
    
    for (i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        [keys addObject:propertyName];
        
    }
    
    free(properties);
    
    return keys;
}

+ (BOOL)reflectDataFromOtherObject:(NSObject*)dataSource withNsobject:(id)selfObject

{
    
    BOOL ret = NO;
    
    for (NSString *key in [MSUtil propertyKeys:selfObject]) {
        
        if ([dataSource isKindOfClass:[NSDictionary class]]) {
            
            ret = ([dataSource valueForKey:key]==nil) ? NO : YES;
            
        }
        
        else
            
        {
            
            ret = [dataSource respondsToSelector:NSSelectorFromString(key)];
            
        }
        
        if (ret) {
            
            id propertyValue = [dataSource valueForKey:key];
            
            //该值不为NSNULL，并且也不为nil
            [selfObject setValue:kSafeString(propertyValue) forKey:key];
            WMLog(@"---%@",propertyValue);
        }
        
    }
    return ret;
}



// View转化为图片
+ (UIImage *)getImageFromView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//判断是否打开定位
+ (BOOL)isLocationOpen
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        return NO;
    }else
    {
        return YES;
    }
    
}


/// 判断是否含有非法字符 yes 有  no没有
+ (BOOL)JudgeTheillegalCharacter:(NSString *)content
{
    BOOL result = false;
    if ([content length]){
        // 判断长度大于8位后再接着判断是否同时包含数字/字母
        //        NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,18}$";
        // 包含数字/字母/特殊字符
        NSString *regex = @"^[a-zA-Z\\d`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]$";
        //        NSString *r = @"^[^!！~`\|@#\*\(\)（）｛｝\{\}\[\]【】\<\>《》：:“”%&￥',;=\+\-—?\$、\/\\^]+$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        result = [pred evaluateWithObject:content];
    }
    return result;
}

#pragma mark - 模态界面方法
+ (void)presentViewController:(UIViewController *)VC
                       selfVC:(UINavigationController *)selfNC
                        title:(NSString *)str
                        block:(void (^ __nullable)(void))completion
{
    // 初始化UINavigationController
    UINavigationController *caNC = [[BaseNavigationController alloc] initWithRootViewController:VC];
    // 设置字体
    /*
    [caNC.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:kNavigationTitleSize],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
     */
    // 模态效果
    caNC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    // 模态
    [selfNC.topViewController presentViewController:caNC animated:YES completion:completion];
    
    // 设置title
    VC.navigationItem.title = str;
}

/**
 截取URL中的参数

 @param urlStr URL
 @return 字典形式的参数
 */
+ (NSMutableDictionary *)getURLParameters:(NSString *)urlStr
{
    // 查找参数
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    // 以字典形式将参数返回
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}


/**
 字典转json字符串

 @param dictionary dictionary
 @return jsonString
 */
+ (NSString *)getJsonStringFromNSDictionary:(NSDictionary *)dictionary
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}
+ (id )getObjectWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
+(NSString *)matchTitleWithCode:(NSString *)code{
    if ([code isEqualToString:@"ACCIDENT_PROOF"]) {
      return @"意外事故证明";
    }else if ([code isEqualToString:@"OUTPATIENT_INVOICE"]){
        return @"门诊发票";
    }else if ([code isEqualToString:@"OUTPATIENT_DETAIL"]){
        return @"费用明细单";
    }else if ([code isEqualToString:@"PRESCRIPTION"]){
        return @"处方";
    }else if ([code isEqualToString:@"OUTPATIENT_HISTORY"]){
        return @"门诊病历";
    }else if ([code isEqualToString:@"INSPECT_REPORT"]){
        return @"检查报告";
    }else if ([code isEqualToString:@"CLAIM_SHEET"]){
        return @"理赔分割单";
    }else if ([code isEqualToString:@"INPATIENT_INVOICE"]){
        return @"住院发票";
    }else if ([code isEqualToString:@"INPATIENT_DETAIL"]){
        return @"住院费用明细单";
    }else if ([code isEqualToString:@"SETTLEMENT_SHEET"]){
        return @"结算明细表";
    }else if ([code isEqualToString:@"INPATIENT_HISTORY"]){
        return @"住院病历";
    }else if ([code isEqualToString:@"DISCHARGE_SUMMARY"]){
        return @"出院小结";
    }else if ([code isEqualToString:@"OTHER"]){
        return @"其他";
    }else{
        return @"其他";
    }
}
+ (BOOL) isContainPropertyWithClass:(Class) myClass propertyName:(NSString *)name{
    unsigned int outCount, i;
    Ivar *ivars = class_copyIvarList(myClass, &outCount);
    for (i = 0; i < outCount; i++) {
        Ivar property = ivars[i];
        NSString *keyName = [NSString stringWithCString:ivar_getName(property) encoding:NSUTF8StringEncoding];
        keyName = [keyName stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if ([keyName isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)matchIndexStringWithCode:(NSString *)code{
    if ([code isEqualToString:@"ACCIDENT_PROOF"]) {
        return  @"6";
    }else if ([code isEqualToString:@"OUTPATIENT_INVOICE"]){
        return @"1";
    }else if ([code isEqualToString:@"OUTPATIENT_DETAIL"]){
        return @"2";
    }else if ([code isEqualToString:@"PRESCRIPTION"]){
        return @"3";
    }else if ([code isEqualToString:@"OUTPATIENT_HISTORY"]){
        return @"4";
    }else if ([code isEqualToString:@"INSPECT_REPORT"]){
        return @"5";
    }else if ([code isEqualToString:@"CLAIM_SHEET"]){
        return @"7";
    }else if ([code isEqualToString:@"INPATIENT_INVOICE"]){
        return @"8";
    }else if ([code isEqualToString:@"INPATIENT_DETAIL"]){
        return @"9";
    }else if ([code isEqualToString:@"SETTLEMENT_SHEET"]){
        return @"10";
    }else if ([code isEqualToString:@"INPATIENT_HISTORY"]){
        return @"11";
    }else if ([code isEqualToString:@"DISCHARGE_SUMMARY"]){
        return @"12";
    }else if ([code isEqualToString:@"OTHER"]){
        return @"13";
    }else{
        return @"13";
    }
}
+ (NSInteger )calcAge:(NSString*)birthday {
    NSCalendar *calendar = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //生日
    
    NSString *string = [NSString stringWithFormat:@"%@-%@-%@",[birthday substringToIndex:4],[birthday substringWithRange:NSMakeRange(4, 2)],[birthday substringFromIndex:6]];
    NSDate *birthDay = [dateFormatter dateFromString:string];
    //用来得到详细的时差
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *date = [calendar components:unitFlags fromDate:birthDay toDate:nowDate options:0];
    return [date year];
}
@end
