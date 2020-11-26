//
//  rechargeScreenView.m
//  live1v1
//
//  Created by IOS1 on 2019/4/17.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "rechargeScreenView.h"

@implementation rechargeScreenView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _isMove = 0;
        _msgArray = [NSMutableArray array];

    }
    return self;
}

-(void)addMove:(NSDictionary *)msg{
    
    if (msg == nil) {
        
        
        
    }
    else
    {
        [_msgArray addObject:msg];
    }
    if(_isMove == 0){
        [self userLoginOne];
    }
}
-(void)userLoginOne{
    
    if (_msgArray.count == 0 || _msgArray == nil) {
        return;
    }
    NSDictionary *Dic = [_msgArray firstObject];
    [_msgArray removeObjectAtIndex:0];
    [self userPlar:Dic];
}
-(void)userPlar:(NSDictionary *)dic{
    _isMove = 1;
    _userMoveImageV = [[UIImageView alloc]init];
    [_userMoveImageV setImage:[UIImage imageNamed:@"飘屏背景"]];
    _userMoveImageV.layer.masksToBounds = YES;
    _userMoveImageV.layer.cornerRadius = 20.0;
    [self addSubview:_userMoveImageV];
    [_userMoveImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.height.equalTo(self);
        make.left.equalTo(self).offset(_window_width);
    }];
    
    UIImageView *laba = [[UIImageView alloc]init];
    laba.image = [UIImage imageNamed:@"飘屏喇叭"];
    [_userMoveImageV addSubview:laba];
    [laba mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_userMoveImageV);
        make.left.equalTo(_userMoveImageV).offset(15);
        make.width.height.mas_equalTo(20);
    }];
    UILabel *label1 = [[UILabel alloc]init];
    label1.text = @"恭喜";
    label1.font = SYS_Font(14);
    label1.textColor = [UIColor whiteColor];
    [_userMoveImageV addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(laba);
        make.left.equalTo(laba.mas_right).offset(7);
    }];
    
    UIImageView *head = [[UIImageView alloc]init];
    [head sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"avatar"])]];
    head.layer.cornerRadius = 10;
    head.layer.masksToBounds = YES;
    head.contentMode = UIViewContentModeScaleAspectFill;
    head.backgroundColor = normalColors;
    [_userMoveImageV addSubview:head];
    [head mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_userMoveImageV);
        make.left.equalTo(label1.mas_right).offset(3);
        make.width.height.mas_equalTo(20);
    }];

    UILabel *name = [[UILabel alloc]init];
    name.text = minstr([dic valueForKey:@"nickname"]);
    name.font = SYS_Font(17);
    name.textColor = RGB_COLOR(@"#ffdd00", 1);
    [_userMoveImageV addSubview:name];
    [name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(laba);
        make.left.equalTo(head.mas_right).offset(3);
    }];

    UILabel *label2 = [[UILabel alloc]init];
    label2.text = [NSString stringWithFormat:@"成功充值%@%@！",minstr([dic valueForKey:@"coin"]),[common name_coin]];
    label2.font = SYS_Font(14);
    label2.textColor = [UIColor whiteColor];
    [_userMoveImageV addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(laba);
        make.left.equalTo(name.mas_right).offset(3);
        make.right.equalTo(_userMoveImageV).offset(-25);
    }];

    [label2 sizeToFit];
    [self layoutIfNeeded];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        _userMoveImageV.x = 20;
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            _userMoveImageV.x = -_window_width;
        } completion:^(BOOL finished) {
            [_userMoveImageV removeFromSuperview];
            _userMoveImageV = nil;
            _isMove = 0;
            if (_msgArray.count >0) {
                [self addMove:nil];
            }
        }];
        
    });

    
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        return nil;
    }
    return hitView;
}

@end
