//
//  RankCell.m
//  yunbaolive
//
//  Created by YunBao on 2018/2/2.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "RankCell.h"

@implementation RankCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}
+(RankCell *)cellWithTab:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    RankCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"RankCell" owner:nil options:nil]objectAtIndex:0];
    }
    cell.iconIV.layer.masksToBounds = YES;
    cell.iconIV.layer.cornerRadius = 20;
    return cell;
}
-(void)setModel:(RankModel *)model {
    _model = model;
    [_iconIV sd_setImageWithURL:[NSURL URLWithString:_model.iconStr] placeholderImage:[UIImage imageNamed:@"bg1"]];
    _nameL.text = _model.unameStr;
    //收益榜-0 消费榜-1
    if([model.type isEqual:@"0"]){
        [_levelIV sd_setImageWithURL:[NSURL URLWithString:[common getUserLevelMessage:minstr(_model.levelStr)]]];

    }else{
        [_levelIV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:minstr(_model.levelStr)]]];

    }
    _moneyL.text = _model.totalCoinStr;
    
}


@end
