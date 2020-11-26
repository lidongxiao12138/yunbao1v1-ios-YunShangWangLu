//
//  RookieTabBar.h
//  WaWaJiClient
//
//  Created by Rookie on 2017/11/15.
//  Copyright © 2017年 zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>

@protocol RookieTabBarDelegate <NSObject>

-(void)centerBtnDidClicked;

@end

@interface RookieTabBar : UITabBar

@property (nonatomic,weak) id<RookieTabBarDelegate> rookieDelegate;
@property (strong, nonatomic)  YYAnimatedImageView *animationView;
@property (nonatomic,strong) CABasicAnimation *animation;

@end
