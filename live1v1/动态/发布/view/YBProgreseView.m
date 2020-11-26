//
//  YBProgreseView.m
//  live1v1
//
//  Created by ybRRR on 2019/7/27.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "YBProgreseView.h"
/*条条间隙*/
#define kDrawMargin 1
#define kDrawLineWidth 1
/*差值*/
#define differenceValue 51
@interface YBProgreseView ()<CAAnimationDelegate>

/*条条 灰色路径*/
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
/*背景黄色*/
@property (nonatomic,strong) CAShapeLayer *backColorLayer;
@property (nonatomic,strong) CAShapeLayer *maskLayer;
@end

@implementation YBProgreseView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self.layer addSublayer:self.shapeLayer];
        [self.layer addSublayer:self.backColorLayer];
        self.persentage = 0.0;
    }
    return self;
}
#pragma mark ---Layers
/**
 初始化layer 在完成frame赋值后调用一下
 */
-(void)initLayers{
    [self initStrokeLayer];
    [self setBackColorLayer];
}
/*灰色路径*/
-(void)initStrokeLayer{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat maxWidth = self.frame.size.width;
    CGFloat drawHeight = self.frame.size.height;
    CGFloat x = 0.0;
    while (x+kDrawLineWidth<=maxWidth) {
        [path moveToPoint:CGPointMake(x-kDrawLineWidth/2, 2)];
        [path addLineToPoint:CGPointMake(x-kDrawLineWidth/2, drawHeight-4)];

        x+=kDrawLineWidth;
        x+=kDrawMargin;
    }

    self.shapeLayer.path = path.CGPath;
    self.backColorLayer.path = path.CGPath;
}
/*设置背景layer*/
-(void)setBackColorLayer{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.frame.size.height/2)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2)];
    self.maskLayer.frame = self.bounds;
    self.maskLayer.lineWidth = self.frame.size.width;
    self.maskLayer.path= path.CGPath;
    self.backColorLayer.mask = self.maskLayer;
}

-(void)setAnimationPersentage:(CGFloat)persentage{
    CGFloat startPersentage = self.persentage;
    [self setPersentage:persentage];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:startPersentage];
    pathAnimation.toValue = [NSNumber numberWithFloat:persentage];
    pathAnimation.autoreverses = NO;
    pathAnimation.delegate = self;
    [self.maskLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
}
/**
 *  在修改百分比的时候，修改彩色遮罩的大小
 *
 *  @param persentage 百分比
 */
- (void)setPersentage:(CGFloat)persentage {
    
    _persentage = persentage;
    self.maskLayer.strokeEnd = persentage;
}
#pragma mark ---G
-(CAShapeLayer*)shapeLayer{
    if(!_shapeLayer){
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.lineWidth = kDrawLineWidth;
        _shapeLayer.fillColor = [UIColor whiteColor].CGColor; // 填充色为透明（不设置为黑色）
//        _shapeLayer.lineCap = kCALineCapRound; // 设置线为圆角
        _shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor; // 路径颜色颜色
    }
    return _shapeLayer;
}
-(CAShapeLayer*)backColorLayer{
    if(!_backColorLayer){
        _backColorLayer = [[CAShapeLayer alloc] init];
        _backColorLayer.lineWidth = kDrawLineWidth;
        _backColorLayer.fillColor = [UIColor whiteColor].CGColor; // 填充色为透明（不设置为黑色）
//        _backColorLayer.lineCap = kCALineCapRound; // 设置线为圆角
        _backColorLayer.strokeColor = normalColors.CGColor; // 路径颜色颜色
    }
    return _backColorLayer;
}
-(CAShapeLayer*)maskLayer{
    if(!_maskLayer){
        _maskLayer = [[CAShapeLayer alloc] init];
        _maskLayer.strokeColor = normalColors.CGColor; // 路径颜色颜色
    }
    return _maskLayer;
}

@end
