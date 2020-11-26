//
//  YBProgreseView.h
//  live1v1
//
//  Created by ybRRR on 2019/7/27.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBProgreseView : UIView
//无动画设置 进度
@property (assign, nonatomic) CGFloat persentage;
//有动画设置 进度 0~1
-(void)setAnimationPersentage:(CGFloat)persentage;
/**
 初始化layer 在完成frame赋值后调用一下
 */
-(void)initLayers;

@end

NS_ASSUME_NONNULL_END
