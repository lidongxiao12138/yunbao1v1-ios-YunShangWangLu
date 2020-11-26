//
//  personUserCell.m
//  live1v1
//
//  Created by IOS1 on 2019/4/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "personUserCell.h"

@implementation personUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(personUserModel *)model{
    _model = model;
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:_model.uHead]];
    if (_model.impressArray.count == 1) {
        _view1.hidden = NO;
        _view2.hidden = YES;
        _view3.hidden = YES;
    }else
    if (_model.impressArray.count == 2) {
        _view1.hidden = NO;
        _view2.hidden = NO;
        _view3.hidden = YES;
    }else
    if (_model.impressArray.count == 3) {
        _view1.hidden = NO;
        _view2.hidden = NO;
        _view3.hidden = NO;
    }else{
        _view1.hidden = YES;
        _view2.hidden = YES;
        _view3.hidden = YES;
    }

    for (int i = 0; i < _model.impressArray.count; i ++) {
        NSDictionary *dic = _model.impressArray[i];
        if (i == 0) {
            _view1.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
            _label1.text = minstr([dic valueForKey:@"name"]);
        }
        if (i == 1) {
            _view2.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
            _label2.text = minstr([dic valueForKey:@"name"]);
        }
        if (i == 2) {
            _view3.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
            _label3.text = minstr([dic valueForKey:@"name"]);
        }

    }
    _nameL.text = _model.uName;

}
@end
