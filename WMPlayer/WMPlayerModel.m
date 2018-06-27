//
//  WMPlayerModel.m
//  
//
//  Created by zhengwenming on 2018/4/26.
//

#import "WMPlayerModel.h"

@implementation WMPlayerModel
-(void)setPresentationSize:(CGSize)presentationSize{
    _presentationSize = presentationSize;
    if (presentationSize.width/presentationSize.height<1) {
        self.verticalVideo = YES;
    }
}
@end
