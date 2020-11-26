//
//  picModel.m
//  live1v1
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "picModel.h"

@implementation picModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _thumb = minstr([dic valueForKey:@"thumb"]);
        _picID = minstr([dic valueForKey:@"id"]);
        _views = minstr([dic valueForKey:@"views"]);
        _isprivate = minstr([dic valueForKey:@"isprivate"]);
        _coin = minstr([dic valueForKey:@"coin"]);
        _status = minstr([dic valueForKey:@"status"]);
        _cansee = minstr([dic valueForKey:@"cansee"]);

    }
    return self;
}

@end
