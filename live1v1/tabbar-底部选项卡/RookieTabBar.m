//
//  RookieTabBar.m
//  WaWaJiClient
//
//  Created by Rookie on 2017/11/15.
//  Copyright © 2017年 zego. All rights reserved.
//

#import "RookieTabBar.h"
#define angle2Rad(angle) ((angle) / 180.0 * M_PI)

@interface RookieTabBar()

@property (nonatomic,weak) UIView *addBgview;
@property (nonatomic, weak) UIButton *addButton;

@end

@implementation RookieTabBar

- (instancetype)initWithFrame:(CGRect)frame{
    if(self=[super initWithFrame:frame]){
        
        UIView *addBgv = [[UIView alloc]init];
        addBgv.backgroundColor = [UIColor clearColor];
        
        [self addSubview:addBgv];
        self.addBgview = addBgv;
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = addButton.frame;
        //frame.size = addButton.currentBackgroundImage.size;
        frame.size = CGSizeMake(70, 70);
        addButton.frame = frame;
        
        //方式一 图片无文字
//        [addButton setBackgroundImage:[UIImage imageNamed:@"tab_center"] forState:UIControlStateNormal];
//        [addButton setBackgroundImage:[UIImage imageNamed:@"tab_center"] forState:UIControlStateHighlighted];
        
//        _animationView = [[YYAnimatedImageView alloc]init];
//        NSURL *url = [[NSBundle mainBundle] URLForResource:@"tabbar_center" withExtension:@"gif"];
//        _animationView.yy_imageURL = url;
//        _animationView.hidden = NO;
//        [addButton addSubview:_animationView];
//        [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.left.bottom.right.equalTo(addButton).offset(5);
//        }];

        //方式二 图片有文字
       
        [addButton setImage:[UIImage imageNamed:@"tabbarCenter"] forState:UIControlStateNormal];
//        [addButton setImage:[UIImage imageNamed:@"tabbarCenter"] forState:UIControlStateHighlighted];
        [addButton setTitle:@"匹配" forState: UIControlStateNormal];
        [addButton setTitle:@"匹配" forState: UIControlStateHighlighted];
        [addButton setTitleColor:normalColors forState:UIControlStateHighlighted];
        [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        addButton.titleLabel.font = SYS_Font(10);
        [addButton setImageEdgeInsets:UIEdgeInsetsMake(-(65-addButton.imageView.frame.size.height), 4.0, 0.0, -addButton.titleLabel.frame.size.height)];
        [addButton setTitleEdgeInsets:UIEdgeInsetsMake(10, -addButton.imageView.frame.size.height, -(65-addButton.titleLabel.frame.size.height), 0.0)];
       
        [addButton addTarget:self action:@selector(publishClick) forControlEvents:UIControlEventTouchUpInside];
        /** 预留*/
        _animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
        _animation.fromValue = [NSNumber numberWithFloat:0.f];
        _animation.toValue = [NSNumber numberWithFloat: M_PI *2];
        _animation.duration = 2.5;
        _animation.autoreverses = NO;
        _animation.fillMode = kCAFillModeForwards;
        _animation.removedOnCompletion = NO;
        _animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
        [addButton.imageView.layer addAnimation:_animation forKey:nil];

        UIImageView* ceterImg = [[UIImageView alloc]init];
        ceterImg.image = [UIImage imageNamed:@"center_heart"];
        [addButton addSubview:ceterImg];
        [ceterImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(22);
            make.center.equalTo(addButton.imageView);
        }];
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
        anim.keyPath = @"transform.rotation";
        anim.values = @[@(angle2Rad(-10)),@(angle2Rad(10)),@(angle2Rad(-10))];
        anim.repeatCount =  MAXFLOAT;
        anim.duration = 0.8;
        [ceterImg.layer addAnimation:anim forKey:nil];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        // 动画选项设定
        animation.duration = 0.8; // 动画持续时间
        animation.repeatCount = MAXFLOAT; // 重复次数
        animation.autoreverses = YES; // 动画结束时执行逆动画
        // 缩放倍数
        animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
        animation.toValue = [NSNumber numberWithFloat:0.7]; // 结束时的倍率
        animation.removedOnCompletion = NO;
        // 添加动画
        [ceterImg .layer addAnimation:animation forKey:@"scale-layer"];
        
        
        [self addSubview:addButton];
        self.addButton = addButton;
        
    }
    return self;
}
/**
 * 中间按钮点击事件
 */
- (void)publishClick{
    if ([_rookieDelegate respondsToSelector:@selector(centerBtnDidClicked)]) {
        [_rookieDelegate centerBtnDidClicked];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height - ShowDiff;
   
    /**
     *  单独设置中间的按钮
     */
    self.addButton.center = CGPointMake(width * 0.5, height * 0.2);
    self.addBgview.frame = CGRectMake(width*2/5, 0, width/5, height);
    CGFloat buttonY = 0;
    CGFloat buttonW = width / 5;
    CGFloat buttonH = height;
    NSInteger index = 0;
    for (UIControl *button in self.subviews) {
        if (![button isKindOfClass:[UIControl class]] || button == self.addButton) continue;
        /** 中间空出 */
        CGFloat buttonX = buttonW * ((index > 1)?(index + 1):index);
        /** 中间不空 */
//        CGFloat buttonX = buttonW * index;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        index++;
    }
}


@end
