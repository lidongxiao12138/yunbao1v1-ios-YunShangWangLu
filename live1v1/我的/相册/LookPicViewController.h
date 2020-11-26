//
//  LookPicViewController.h
//  live1v1
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "backWallModel.h"
#import "picModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface LookPicViewController : UIViewController
@property (nonatomic,assign) BOOL isBackWall;

@property (nonatomic,strong) picModel *model;
@property (nonatomic,strong) backWallModel *wallModel;

@end

NS_ASSUME_NONNULL_END
