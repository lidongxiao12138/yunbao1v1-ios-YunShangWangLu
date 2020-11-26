//
//  personSelectActionView.h
//  live1v1
//
//  Created by IOS1 on 2019/4/17.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^selectActionBlock)(int item);
@interface personSelectActionView : UIView
- (instancetype)initWithImageArray:(NSArray *)array andItemArray:(NSArray *)iArray;
@property (nonatomic,copy) selectActionBlock block;
- (void)show;
@end

NS_ASSUME_NONNULL_END
