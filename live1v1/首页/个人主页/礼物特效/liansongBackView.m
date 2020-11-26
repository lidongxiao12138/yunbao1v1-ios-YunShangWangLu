//
//  liansongBackView.m
//  live1v1
//
//  Created by IOS1 on 2019/5/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "liansongBackView.h"

@implementation liansongBackView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//  去除连送礼物view的点击
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        return nil;
    }
    return hitView;
}

@end
