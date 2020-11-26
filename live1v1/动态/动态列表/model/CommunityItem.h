//
//  CommunityItem.h
//  CircleOfFriendsDisplay
//
//  Created by 李云祥 on 16/9/22.
//  Copyright © 2016年 李云祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommunityItem : NSObject

@property(nonatomic,strong)NSString *idStr;
@property(nonatomic,strong)NSString *uidStr;
@property (nonatomic, copy) NSString *titleStr;
@property(nonatomic,strong)NSString *hrefStr;           //视频链接
@property(nonatomic,strong)NSString *likesStr;          //点赞数
@property(nonatomic,strong)NSString *commentStr;        //评论数
@property(nonatomic,strong)NSString *communityType;     //0-文字  1-文字+图片  2-文字+视频  3语音+文字
@property(nonatomic,strong)NSString *viewsStr;
@property (nonatomic, strong) NSArray *imgs;
@property(nonatomic,strong)NSDictionary *userInfoDic;
@property (nonatomic, copy) NSString *timeStr;
@property(nonatomic,strong)NSString *isLikeStr;
@property(nonatomic,strong)NSString *isAttentStr;

@property(nonatomic,strong)NSString *video_thumb;
@property(nonatomic,strong)NSString *city;

@property(nonatomic,strong)NSString *voice;
@property(nonatomic,strong)NSString *length;

@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;

-(id)initWithDict:(NSDictionary *)dic;
+(id)dynamicWithDict:(NSDictionary *)dic;

@end
