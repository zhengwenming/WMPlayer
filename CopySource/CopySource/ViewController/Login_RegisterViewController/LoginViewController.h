//
//  LoginViewController.h
//  AIHealth
//
//  Created by 吴亚乾 on 2016/12/21.
//  Copyright © 2016年 郑文明. All rights reserved.
//

#import "BaseViewController.h"


@interface LoginViewController : BaseViewController

@property (nonatomic, copy) void(^userMobilePhoneBlock)(NSString *mobile);

@end
