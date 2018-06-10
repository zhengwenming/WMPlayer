//
//  WMPlayerModel.m
//  
//
//  Created by zhengwenming on 2018/4/26.
//

#import "WMPlayerModel.h"

@implementation WMPlayerModel
- (instancetype)init{
    self = [super init];
    if (self) {
        self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
    }
    return self;
}
@end
