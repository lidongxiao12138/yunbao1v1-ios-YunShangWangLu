//
//  ReportViewController.h
//  live1v1
//
//  Created by ybRRR on 2019/7/31.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "YBBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportViewController : YBBaseViewController
@property (nonatomic,copy)NSString *dongtaiId;
@property (nonatomic,copy)NSString *dongtaiUserID;
@property (nonatomic,copy)NSString *fromWhere;
@property (nonatomic,assign) BOOL isLive;

@end

NS_ASSUME_NONNULL_END
