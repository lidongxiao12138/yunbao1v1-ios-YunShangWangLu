//
//  ZYTabBarController.h
//  tabbar增加弹出bar
//
//  Created by tarena on 16/7/2.
//  Copyright © 2016年 张永强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTabBarController.h"

@interface YBTabBarController : MCTabBarController
{
    int unRead;//未读消息
    int sendMessage;
    UILabel *label;
}
@property(nonatomic,strong)NSArray *conversations;//获取会话列表

@end
