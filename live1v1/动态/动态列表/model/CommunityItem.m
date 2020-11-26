//
//  CommunityItem.m
//  CircleOfFriendsDisplay
//
//  Created by 李云祥 on 16/9/22.
//  Copyright © 2016年 李云祥. All rights reserved.
//

#import "CommunityItem.h"

@implementation CommunityItem
-(id)initWithDict:(NSDictionary *)dic {
    if (self = [super init]) {
        
        _idStr = minstr([dic valueForKey:@"id"]);
        _uidStr = minstr([dic valueForKey:@"uid"]);
        _titleStr = minstr([dic valueForKey:@"title"]);
        _hrefStr = minstr([dic valueForKey:@"href"]);
        _likesStr = minstr([dic valueForKey:@"likes"]);
        _commentStr = minstr([dic valueForKey:@"comments"]);
        _communityType = minstr([dic valueForKey:@"type"]);
        _viewsStr = minstr([dic valueForKey:@"views"]);
        _imgs = [NSArray array];
        if ([[dic valueForKey:@"thumbs"] isKindOfClass:[NSArray class]]) {
            _imgs = [NSArray arrayWithArray:[dic valueForKey:@"thumbs"]];
        }
        _userInfoDic = [NSDictionary dictionary];
        if ([[dic valueForKey:@"userinfo"] isKindOfClass:[NSDictionary class]]) {
            _userInfoDic = [dic valueForKey:@"userinfo"];
        }
        _timeStr = minstr([dic valueForKey:@"datetime"]);
        _isLikeStr = minstr([dic valueForKey:@"islike"]);
        _isAttentStr = minstr([dic valueForKey:@"isattent"]);
        _video_thumb =minstr([dic valueForKey:@"video_thumb"]);
        _city =minstr([dic valueForKey:@"city"]);
        _voice = minstr([dic valueForKey:@"voice"]);
        _length = minstr([dic valueForKey:@"length"]);
        _width = 0;
        _height = 0;
    }
    return self;
}
+(id)dynamicWithDict:(NSDictionary *)dic {
    return [[self alloc]initWithDict:dic];
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key  {
    
}
@end
