//
//  LookVideoViewController.h
//  live1v1
//
//  Created by IOS1 on 2019/5/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "videoModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface LookVideoViewController : UIViewController
@property (nonatomic,strong) videoModel *model;
@property (nonatomic,strong) NSDictionary *userDic;

@end

NS_ASSUME_NONNULL_END
