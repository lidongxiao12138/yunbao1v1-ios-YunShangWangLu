//
//  ShowDetailVC.h
//  live1v1
//
//  Created by ybRRR on 2019/8/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "YBBaseViewController.h"

typedef void(^detailDeleteEvent)(NSString *type);
NS_ASSUME_NONNULL_BEGIN

@interface ShowDetailVC : YBBaseViewController

@property(nonatomic, copy) detailDeleteEvent deleteEvent;
@property(nonatomic, strong)NSString * videoPath;
@property(nonatomic, strong)NSString *fromStr;
@end

NS_ASSUME_NONNULL_END
