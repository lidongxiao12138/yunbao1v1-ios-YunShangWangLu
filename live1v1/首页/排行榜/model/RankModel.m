//
//  RankModel.m
//  yunbaolive
//
//  Created by YunBao on 2018/2/2.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "RankModel.h"

@implementation RankModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _totalCoinStr = minstr([dic valueForKey:@"totalcoin"]);
        _uidStr = minstr([dic valueForKey:@"uid"]);
        _unameStr = minstr([dic valueForKey:@"user_nickname"]);
        _iconStr = minstr([dic valueForKey:@"avatar_thumb"]);
        if (![dic valueForKey:@"level"]) {
            _levelStr = minstr([dic valueForKey:@"levelAnchor"]);
        }else {
            _levelStr = minstr([dic valueForKey:@"level"]);
        }
        _isAttentionStr = minstr([dic valueForKey:@"isAttention"]);
    }
    return self;
}
+(instancetype)modelWithDic:(NSDictionary *)dic {
     return [[self alloc]initWithDic:dic];
}
@end
