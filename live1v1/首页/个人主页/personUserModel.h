//
//  personUserModel.h
//  live1v1
//
//  Created by IOS1 on 2019/4/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface personUserModel : NSObject
-(instancetype)initWithDic:(NSDictionary *)dic;
@property (nonatomic,strong) NSArray *impressArray;
@property (nonatomic,strong) NSString *uName;
@property (nonatomic,strong) NSString *uHead;


@end

NS_ASSUME_NONNULL_END
