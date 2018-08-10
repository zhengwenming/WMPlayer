//
//  EditVideoViewController.h
//  iShow
//
//  Created by 胡阳阳 on 17/3/8.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface EditVideoViewController : BaseViewController


@property(nonatomic,retain) NSURL * videoURL;

@property (nonatomic , strong) NSNumber* width;
@property (nonatomic , strong) NSNumber* hight;
@property (nonatomic , strong) NSNumber* bit;
@property (nonatomic , strong) NSNumber* frameRate;
@end
