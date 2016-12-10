//
//  CRDemoInfoModel.m
//  CRAnimation
//
//  Created by Bear on 16/10/7.
//  Copyright © 2016年 BearRan. All rights reserved.
//

#import "CRDemoInfoModel.h"

@implementation CRDemoInfoModel

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self fillDemoInfo];
    }
    
    return self;
}

- (void)fillDemoInfo
{
    self.demoName       = @"";
    self.demoSummary    = @"";
    self.demoVCName     = @"";
    self.demoGifName    = @"";
    self.demoType       = kCRDemoTypeStorage;
    self.CRID           = @"S0001";
}

@end
