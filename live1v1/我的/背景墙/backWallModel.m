//
//  backWallModel.m
//  live1v1
//
//  Created by IOS1 on 2019/5/10.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "backWallModel.h"

@implementation backWallModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _thumb = minstr([dic valueForKey:@"thumb"]);
        _wallID = minstr([dic valueForKey:@"id"]);
        _href = minstr([dic valueForKey:@"href"]);
        _type = minstr([dic valueForKey:@"type"]);
        _userid = minstr([dic valueForKey:@"uid"]);
    }
    return self;
}

@end
