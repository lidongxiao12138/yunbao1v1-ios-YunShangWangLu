//
//  InvitationViewController.h
//  live1v1
//
//  Created by IOS1 on 2019/4/11.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InvitationViewController : UIViewController

/**
 初始化

 @param type 1:用户发起视频 2:用户发起语音 3:主播被邀请视频 4:主播被邀请语音 5:主播赴约视频 6:主播赴约语音 7:用户被邀请视频 8:用户被邀请语音 
 @param msg 对方的信息
 @return self
 */
- (instancetype)initWithType:(int)type andMessage:(NSDictionary *)msg;
@property (nonatomic,strong) NSString *showid;
@property (nonatomic,strong) NSString *total;
- (void)docancle;
@end

NS_ASSUME_NONNULL_END
