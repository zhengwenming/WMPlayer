//
//  WNPlayerModel.m
//  PlayerDemo
//
//  Created by apple on 2018/11/10.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "WNPlayerModel.h"

@implementation WNPlayerModel
-(void)setPresentationSize:(CGSize)presentationSize{
    _presentationSize = presentationSize;
    if (presentationSize.width/presentationSize.height<1) {
        self.verticalVideo = YES;
    }
}
@end
