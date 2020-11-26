//
//  videoModel.h
//  live1v1
//
//  Created by IOS1 on 2019/5/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface videoModel : NSObject
@property (nonatomic,strong) NSString *videoID;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *thumb;
@property (nonatomic,strong) NSString *href;
@property (nonatomic,strong) NSString *likes;
@property (nonatomic,strong) NSString *views;
@property (nonatomic,strong) NSString *shares;
@property (nonatomic,strong) NSString *isprivate;
@property (nonatomic,strong) NSString *coin;
@property (nonatomic,strong) NSString *islike;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *cansee;


-(instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
