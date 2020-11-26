//
//  EndingEvaluationView.h
//  live1v1
//
//  Created by IOS1 on 2019/4/12.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^EndingEvaluationBlock)();
@interface EndingEvaluationView : UIView
- (instancetype)initWithFrame:(CGRect)frame andUserID:(NSString *)uid andTime:(NSString *)timeStr;
@property (nonatomic,copy) EndingEvaluationBlock block;

@end

NS_ASSUME_NONNULL_END
