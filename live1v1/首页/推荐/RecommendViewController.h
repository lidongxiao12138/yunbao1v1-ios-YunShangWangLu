//
//  RecommendViewController.h
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecommendViewController : YBBaseViewController
@property (nonatomic,strong,nonnull)UIView *pageView;
- (void)showYBScreendView;
- (void)showRechargeView:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
