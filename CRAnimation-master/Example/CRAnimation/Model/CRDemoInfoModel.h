//
//  CRDemoInfoModel.h
//  CRAnimation
//
//  Created by Bear on 16/10/7.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kCRDemoTypeStorage,       //  动效仓库
    kCRDemoTypeCombination,   //  组合动效
} CRDemoType;

@interface CRDemoInfoModel : NSObject

//  动效名称
@property (strong, nonatomic) NSString      *demoName;

//  动效简介
@property (strong, nonatomic) NSString      *demoSummary;

//  demoVC名称（用于push到指定名称的VC）
@property (strong, nonatomic) NSString      *demoVCName;

//  作者
@property (strong, nonatomic) NSString      *author;

//  作者邮箱
@property (strong, nonatomic) NSString      *authorMail;

//  UI设计师
@property (strong, nonatomic) NSString      *UIDesigner;

//  UI设计师邮箱
@property (strong, nonatomic) NSString      *UIDesignerMail;

//  demoGif名称
//  Ex:demoGifName = @"GifPlay.gif"
@property (strong, nonatomic) NSString      *demoGifName;

//  动效类型
//  kCRDemoTypeStorage:         动效仓库
//  kCRDemoTypeCombination:     组合动效
@property (assign, nonatomic) CRDemoType    demoType;

//  ID编号
//  S0001:动效仓库
//  C0001:组合动效
@property (strong, nonatomic) NSString      *CRID;

- (void)fillDemoInfo;

@end
