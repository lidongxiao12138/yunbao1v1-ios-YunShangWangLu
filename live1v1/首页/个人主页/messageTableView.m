//
//  messageTableView.m
//  live1v1
//
//  Created by IOS1 on 2019/4/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "messageTableView.h"

@implementation messageTableView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    self.backgroundView = ({
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    
    if (self) {
        [self createChildViews];
    }
    return self;
}

- (void)createChildViews{
    [self addSubview:self.titleL];
    [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.centerY.equalTo(self);
    }];
    
    [self addSubview:self.rightImgV];
    [_rightImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-8);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(13);
    }];

    
    [self addSubview:self.giftNumL];
    [_giftNumL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_rightImgV.mas_left).offset(-5);
        make.centerY.equalTo(self);
    }];
    [self addSubview:self.giftL];
    [_giftL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_giftNumL.mas_left).offset(-3);
        make.centerY.equalTo(self);
    }];
    
    
    [self addSubview:self.badL];
    [_badL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-18);
        make.centerY.equalTo(self);
    }];
    [self addSubview:self.badImgV];
    [_badImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_badL.mas_left).offset(-3);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(10);
    }];
    [self addSubview:self.goodL];
    [_goodL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_badImgV.mas_left).offset(-5);
        make.centerY.equalTo(self);
    }];
    [self addSubview:self.goodImgV];
    [_goodImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_goodL.mas_left).offset(-5);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(10);
    }];


}


- (UIImageView *)goodImgV{
    if (!_goodImgV) {
        _goodImgV = [[UIImageView alloc]init];
        _goodImgV.contentMode = UIViewContentModeScaleAspectFit;
        _goodImgV.image = [UIImage imageNamed:@"person_评价好"];
    }
    return _goodImgV;
}
- (UILabel *)goodL{
    if(!_goodL){
        _goodL = [[UILabel alloc] init];
        _goodL.font = [UIFont systemFontOfSize:12];
        _goodL.textColor = RGB_COLOR(@"#505050",1);
    }
    return _goodL;
}
- (UIImageView *)badImgV{
    if (!_badImgV) {
        _badImgV = [[UIImageView alloc]init];
        _badImgV.contentMode = UIViewContentModeScaleAspectFit;
        _badImgV.image = [UIImage imageNamed:@"person_评价差"];
    }
    return _badImgV;
}
- (UILabel *)badL{
    if(!_badL){
        _badL = [[UILabel alloc] init];
        _badL.font = [UIFont systemFontOfSize:12];
        _badL.textColor = RGB_COLOR(@"#505050",1);
    }
    return _badL;
}

- (UIImageView *)rightImgV{
    if (!_rightImgV) {
        _rightImgV = [[UIImageView alloc]init];
        _rightImgV.contentMode = UIViewContentModeScaleAspectFit;
        _rightImgV.image = [UIImage imageNamed:@"person_右箭头"];
    }
    return _rightImgV;
}
- (UILabel *)titleL{
    if(!_titleL){
        _titleL = [[UILabel alloc] init];
        _titleL.font = [UIFont systemFontOfSize:12];
        _titleL.textColor = RGB_COLOR(@"#505050",1);
    }
    return _titleL;
}
- (UILabel *)giftNumL{
    if(!_giftNumL){
        _giftNumL = [[UILabel alloc] init];
        _giftNumL.font = [UIFont systemFontOfSize:12];
        _giftNumL.textColor = RGB_COLOR(@"#505050",1);
    }
    return _giftNumL;
}
- (UILabel *)giftL{
    if(!_giftL){
        _giftL = [[UILabel alloc] init];
        _giftL.font = [UIFont systemFontOfSize:12];
        _giftL.textColor = color96;
    }
    return _giftL;
}


@end
