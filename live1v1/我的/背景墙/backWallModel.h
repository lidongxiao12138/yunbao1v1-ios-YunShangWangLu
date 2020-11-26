//
//  backWallModel.h
//  live1v1
//
//  Created by IOS1 on 2019/5/10.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface backWallModel : NSObject
@property (nonatomic,strong) NSString *wallID;
@property (nonatomic,strong) NSString *thumb;
@property (nonatomic,strong) NSString *href;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *userid;

-(instancetype)initWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
