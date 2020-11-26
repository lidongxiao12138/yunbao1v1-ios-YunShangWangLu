//
//  personUserModel.m
//  live1v1
//
//  Created by IOS1 on 2019/4/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "personUserModel.h"

@implementation personUserModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _impressArray = [dic valueForKey:@"label"];
        _uName = minstr([dic valueForKey:@"user_nickname"]);
        _uHead = minstr([dic valueForKey:@"avatar"]);

    }
    return self;
}

@end
