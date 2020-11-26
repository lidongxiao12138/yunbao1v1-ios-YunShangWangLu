//
//  recommendModel.h
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface recommendModel : NSObject
@property (nonatomic,strong) NSArray *typeArray;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *level_anchor;
@property (nonatomic,strong) NSString *online;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSString *signature;
@property (nonatomic,strong) NSString *thumb;
@property (nonatomic,strong) NSString *user_nickname;
@property (nonatomic,strong) NSString *distance;

@property (nonatomic,assign) int isvideo;
@property (nonatomic,assign) int isvoice;

-(instancetype)initWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
