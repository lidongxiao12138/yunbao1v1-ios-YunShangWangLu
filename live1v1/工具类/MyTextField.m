//
//  MyTextField.m
//  iphoneLive
//
//  Created by Rookie on 2017/8/19.
//  Copyright © 2017年 cat. All rights reserved.
//

#import "MyTextField.h"

@implementation MyTextField

-(void)drawPlaceholderInRect:(CGRect)rect {
    //设置富文本属性
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[NSFontAttributeName] = self.font;
    dictM[NSForegroundColorAttributeName] = _placeCol ? _placeCol:[UIColor whiteColor];
    CGPoint point = CGPointMake(0, (rect.size.height - self.font.lineHeight) * 0.5);
    [self.placeholder drawAtPoint:point withAttributes:dictM];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    if (_haveInset) {
        iconRect.origin.x += 10;
    }
    return iconRect;
}
- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect iconRect = [super rightViewRectForBounds:bounds];
    if (_haveInset) {
        iconRect.origin.x -= 10;
    }
    return iconRect;
}
//UITextField 文字与输入框的距离
- (CGRect)textRectForBounds:(CGRect)bounds{
    if (_haveInset) {
        return CGRectInset(bounds, 35, 0);
    }
    return CGRectInset(bounds, 8, 0);
}

//控制文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds{
    if (_haveInset) {
        return CGRectInset(bounds, 35, 0);
    }
    return CGRectInset(bounds, 8, 0);
}
@end
