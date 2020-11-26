//
//  YBImageView.m
//  yunbaolive
//
//  Created by IOS1 on 2019/3/1.
//  Copyright © 2019 cat. All rights reserved.
//

#import "YBImageView.h"

@implementation YBImageView{
    UIImageView *bigImgView;
    UITapGestureRecognizer *tap;
    UIImageView *curImageView;
    CGPoint curPoint;
}
- (instancetype)initWithImgView:(UIImageView *)imgV{
    self = [super init];
    curImageView = imgV;
    CGPoint buttonCenter = CGPointMake(imgV.bounds.origin.x ,
                                       imgV.bounds.origin.y);
    curPoint = [imgV convertPoint:buttonCenter toView:[UIApplication sharedApplication].delegate.window];

    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    if (self) {
        self.userInteractionEnabled = YES;
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigView)];
        [self addGestureRecognizer:tap];
        [self showBigView];

    }
    return self;
}
- (void)showBigView{
    if (bigImgView) {
        [UIView animateWithDuration:0.2 animations:^{
            bigImgView.frame = CGRectMake(curPoint.x, curPoint.y, curImageView.width, curImageView.height);
        }completion:^(BOOL finished) {
            [bigImgView removeFromSuperview];
            bigImgView = nil;
            [self removeFromSuperview];
        }];

    }else{
        bigImgView = [[UIImageView alloc]initWithFrame:CGRectMake(curPoint.x, curPoint.y, curImageView.width, curImageView.height)];
        bigImgView.backgroundColor = [UIColor blackColor];
        bigImgView.contentMode = UIViewContentModeScaleAspectFit;
        bigImgView.userInteractionEnabled = YES;
        bigImgView.image = curImageView.image;
        [[UIApplication sharedApplication].delegate.window addSubview:bigImgView];
        [UIView animateWithDuration:0.2 animations:^{
            bigImgView.frame = CGRectMake(0, 0, _window_width, _window_height);
        }];
    }
}

@end
