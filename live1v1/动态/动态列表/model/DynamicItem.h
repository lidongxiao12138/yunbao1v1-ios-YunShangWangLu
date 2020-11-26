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
@property(nonatomic,strong)NSString *authorStr;
@property(nonatomic,strong)NSString *addtypeStr;  //是否后台添加 0-否  1-是
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *avatarStr;
@property (nonatomic, copy) NSString *contentStr;
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, strong) NSArray *imgs;

@property(nonatomic,strong)NSString *isAttentStr;
@property(nonatomic,strong)NSString *hitStr; //观看数量
@property(nonatomic,strong)NSString *repeatStr;//分享数
@property(nonatomic,strong)NSString *commentStr;//评论数
@property(nonatomic,strong)NSString *isLikeStr;
@property(nonatomic,strong)NSString *likeStr; //点赞数

//预留
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *statusID;
@property (nonatomic, strong) NSArray *commentList;
@property (nonatomic, copy) NSString *MsgType;
@property (nonatomic, assign)BOOL textOpenFlag;

-(id)initWithDict:(NSDictionary *)dic;
+(id)dynamicWithDict:(NSDictionary *)dic;

@end
