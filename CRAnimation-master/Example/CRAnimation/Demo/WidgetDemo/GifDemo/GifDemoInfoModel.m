//
//  GifDemoInfoModel.m
//  CRAnimation
//
//  Created by Bear on 16/10/12.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "GifDemoInfoModel.h"

@implementation GifDemoInfoModel

- (void)fillDemoInfo
{
    self.demoName       = @"Gif demo";
    self.demoSummary    = @"Gif播放控件";
    self.author         = @"Bear";
    self.authorMail     = @"648070256@qq.com";
    self.UIDesigner     = @"";
    
    self.UIDesignerMail = @"";
    self.demoVCName     = @"GifDemoVC";
    self.demoGifName    = @"GifPlay.gif";
    self.demoType       = kCRDemoTypeStorage;
    self.CRID           = @"S0003";
}

@end
