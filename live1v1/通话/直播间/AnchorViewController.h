//
//  AnchorViewController.h
//  live1v1
//
//  Created by IOS1 on 2019/4/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnchorViewController : UIViewController

/**
 1:视频主播 2:视频观众 3:语音主播 4:语音观众
 */
@property (nonatomic,strong) NSString *liveType;

@property (nonatomic,strong) NSDictionary *anchorMsg;
@property (nonatomic,strong) NSString *hostUrl;

@end

NS_ASSUME_NONNULL_END
