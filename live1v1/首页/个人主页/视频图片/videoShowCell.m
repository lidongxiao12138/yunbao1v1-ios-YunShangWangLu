//
//  videoShowCell.m
//  live1v1
//
//  Created by IOS1 on 2019/5/7.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "videoShowCell.h"

@implementation videoShowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setModel:(videoModel *)model{
    _model = model;
    [_thumbImgV sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _titleL.text = _model.title;
    _effectV.alpha = 0.9;

    if ([_model.isprivate isEqual:@"1"]) {
        _effectV.hidden = NO;
    }else{
        _effectV.hidden = YES;
    }
}
@end
