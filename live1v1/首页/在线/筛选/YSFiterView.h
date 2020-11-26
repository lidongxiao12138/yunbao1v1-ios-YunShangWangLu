//
//  YSFiterView.h
//  live1v1
//
//  Created by YB007 on 2019/10/24.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^YSFiterBlock)(NSDictionary *dic);

@interface YSFiterView : UIView
@property (nonatomic,copy) YSFiterBlock block;
- (void)show;
@end


