//
//  ScreenView.h
//  live1v1
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^YBScreenViewBlock)(NSDictionary *dic);
@interface YBScreenView : UIView
@property (nonatomic,copy) YBScreenViewBlock block;
- (void)show;
@end

NS_ASSUME_NONNULL_END
