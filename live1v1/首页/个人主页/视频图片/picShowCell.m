//
//  picShowCell.m
//  live1v1
//
//  Created by IOS1 on 2019/5/7.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "picShowCell.h"

@implementation picShowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setModel:(picModel *)model{
    _model = model;
    _effectV.alpha = 0.9;
    [_thumbImgV sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _lookNumL.text = _model.views;
    if ([_model.isprivate isEqual:@"1"]) {
        _effectV.hidden = NO;
    }else{
        _effectV.hidden = YES;
    }
}

@end
