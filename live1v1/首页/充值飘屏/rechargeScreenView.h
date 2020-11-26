//
//  rechargeScreenView.h
//  live1v1
//
//  Created by IOS1 on 2019/4/17.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface rechargeScreenView : UIView
@property(nonatomic,assign)int  isMove;// 限制用户进入动画
@property(nonatomic,strong)NSMutableArray *msgArray;//用户进入数组，存放动画
@property(nonatomic,strong)UIImageView *userMoveImageV;//进入动画背景
-(void)addMove:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
