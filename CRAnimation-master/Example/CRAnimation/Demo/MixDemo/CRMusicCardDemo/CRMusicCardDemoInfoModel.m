//
//  CRMusicCardDemoInfoModel.m
//  CRAnimation
//
//  Created by Bear on 16/10/12.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "CRMusicCardDemoInfoModel.h"

@implementation CRMusicCardDemoInfoModel

- (void)fillDemoInfo
{
    self.demoName       = @"音乐切换动效";
    self.demoSummary    = @"CRCardAnimationView和CRImageGradientView的组合动效";
    self.author         = @"Bear";
    self.authorMail     = @"648070256@qq.com";
    self.UIDesigner     = @"";
    
    self.UIDesignerMail = @"";
    self.demoVCName     = @"CRMusicCardDemoVC";
    self.demoGifName    = @"CRMusicCardDemoVC.gif";
    self.demoType       = kCRDemoTypeStorage;
    self.CRID           = @"C0001";
}

@end
