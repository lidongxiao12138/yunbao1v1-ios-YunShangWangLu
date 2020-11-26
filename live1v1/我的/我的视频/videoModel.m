//
//  videoModel.m
//  live1v1
//
//  Created by IOS1 on 2019/5/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "videoModel.h"

@implementation videoModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _thumb = minstr([dic valueForKey:@"thumb"]);
        _href = minstr([dic valueForKey:@"href"]);
        _title = minstr([dic valueForKey:@"title"]);
        _videoID = minstr([dic valueForKey:@"id"]);
        _likes = minstr([dic valueForKey:@"likes"]);
        _views = minstr([dic valueForKey:@"views"]);
        _shares = minstr([dic valueForKey:@"shares"]);
        _isprivate = minstr([dic valueForKey:@"isprivate"]);
        _coin = minstr([dic valueForKey:@"coin"]);
        _islike = minstr([dic valueForKey:@"islike"]);
        _status = minstr([dic valueForKey:@"status"]);
        _cansee = minstr([dic valueForKey:@"cansee"]);

    }
    return self;
}

@end
