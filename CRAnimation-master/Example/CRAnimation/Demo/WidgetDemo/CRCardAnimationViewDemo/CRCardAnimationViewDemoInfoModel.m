//
//  CRCardAnimationViewDemoInfoModel.m
//  CRAnimation
//
//  Created by Bear on 16/10/12.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "CRCardAnimationViewDemoInfoModel.h"

@implementation CRCardAnimationViewDemoInfoModel

- (void)fillDemoInfo
{
    self.demoName       = @"CRCardAnimationView";
    self.demoSummary    = @"卡片切换动效";
    self.author         = @"Bear";
    self.authorMail     = @"648070256@qq.com";
    self.UIDesigner     = @"";
    
    self.UIDesignerMail = @"";
    self.demoVCName     = @"CRCardAnimationViewDemoVC";
    self.demoGifName    = @"CRCardAnimationViewDemoVC.gif";
    self.demoType       = kCRDemoTypeStorage;
    self.CRID           = @"S0001";
}

@end
