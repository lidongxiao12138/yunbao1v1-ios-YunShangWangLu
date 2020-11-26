//
//  SearchCell.m
//  live1v1
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SearchCell.h"

@implementation SearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(SearchModel *)model{
    _model = model;
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    _nameL.text = _model.user_nickname;
    if ([_model.isVip isEqual:@"1"]) {
        _vipImgV.hidden = NO;
    }else{
        _vipImgV.hidden = YES;
    }
    if (_fromType == 0 || _fromType == 2) {
        _IDL.text = [NSString stringWithFormat:@"ID：%@",_model.userID];
        _fansL.text = [NSString stringWithFormat:@"粉丝：%@",_model.fans];
        [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:_model.level_anchor]]];
    }else if (_fromType == 1){
        _fansL.text = @"";
        _IDL.text = [NSString stringWithFormat:@"余额：%@",_model.coin];
        [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getUserLevelMessage:_model.level]]];
    }else{
        _fansL.text = @"";
        _IDL.text = [NSString stringWithFormat:@"ID：%@",_model.userID];
        [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:_model.level_anchor]]];

    }
}
- (IBAction)cellBtnClick:(id)sender {
    if (self.delegate) {
        [self.delegate cellBtnClick:_model];
    }
}

@end
