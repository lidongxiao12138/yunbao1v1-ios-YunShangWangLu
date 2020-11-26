//
//  detailmodel.m
//  iphoneLive
//
//  Created by 王敏欣 on 2017/9/6.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "detailmodel.h"
@implementation detailmodel
-(instancetype)initWithDic:(NSDictionary *)subdic{
    self = [super init];
    if (self) {
        _at_info = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"at_info"]];

        _avatar_thumb = [NSString stringWithFormat:@"%@",[[subdic valueForKey:@"userinfo"] valueForKey:@"avatar"]];
        _user_nicename = [NSString stringWithFormat:@"%@",[[subdic valueForKey:@"userinfo"] valueForKey:@"user_nickname"]];
        _ID = [NSString stringWithFormat:@"%@",[[subdic valueForKey:@"userinfo"] valueForKey:@"id"]];
        _touid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"touid"]];
        _datetime = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"datetime"]];
        _likes = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"likes"]];
        _islike = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"islike"]];
        _touserinfo = [subdic valueForKey:@"touserinfo"];
        _tocommentinfo = [subdic valueForKey:@"tocommentinfo"];
        _parentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];

        if ([_touid intValue] > 0) {
            _content = [NSString stringWithFormat:@"%@%@:%@",@"回复",[_touserinfo valueForKey:@"user_nickname"],[subdic valueForKey:@"content"]];
        }else{
            _content = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"content"]];
        }
        [self setmyframe:nil];
    }
    return self;
}
-(void)setmyframe:(detailmodel *)model{
    //判断是不是回复的回复
    NSString *reply1 = [NSString stringWithFormat:@"%@ %@",_content,_datetime];
    CGSize size = [reply1 boundingRectWithSize:CGSizeMake(_window_width - 90, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    _contentRect = CGRectMake(0,26, size.width, size.height+10);

    _rowH = MAX(0, CGRectGetMaxY(_contentRect)) + 10;
}
+(instancetype)modelWithDic:(NSDictionary *)subdic{
    detailmodel *model = [[detailmodel alloc]initWithDic:subdic];
    return model;
}
@end
