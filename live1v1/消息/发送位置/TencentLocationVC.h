//
//  TencentLocationVC.h
//  iphoneLive
//
//  Created by YunBao on 2018/7/20.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LocationBlock)(NSDictionary * locDic);

@interface TencentLocationVC : YBBaseViewController

@property(nonatomic,copy)LocationBlock locationEvent;

@end
