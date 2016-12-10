//
//  CRImageGradientDemoInfoModel.m
//  CRAnimation
//
//  Created by Bear on 16/10/12.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "CRImageGradientDemoInfoModel.h"

@implementation CRImageGradientDemoInfoModel

- (void)fillDemoInfo
{
    self.demoName       = @"CRImageGradientView";
    self.demoSummary    = @"ImageView过渡切换动效";
    self.author         = @"Bear";
    self.authorMail     = @"648070256@qq.com";
    self.UIDesigner     = @"";
    
    self.UIDesignerMail = @"";
    self.demoVCName     = @"CRImageGradientDemoVC";
    self.demoGifName    = @"CRImageGradientDemoVC.gif";
    self.demoType       = kCRDemoTypeStorage;
    self.CRID           = @"S0002";
}

@end
