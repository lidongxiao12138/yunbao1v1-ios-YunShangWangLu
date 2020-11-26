//
//  roomPayView.h
//  live1v1
//
//  Created by IOS1 on 2019/4/11.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface roomPayView : UIView

/**
 初始化

 @param msg 充值的选项卡
 @param from 来自哪个视图，1:直播间 2:发现
 @return self
 */
- (instancetype)initWithMsg:(NSDictionary *)msg andFrome:(int)from;
- (void)show;
@end

NS_ASSUME_NONNULL_END
