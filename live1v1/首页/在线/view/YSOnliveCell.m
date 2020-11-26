//
//  YSOnliveCell.m
//  live1v1
//
//  Created by YB007 on 2019/10/24.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "YSOnliveCell.h"

@implementation YSOnliveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(YSOnliveCell *)cellWithTab:(UITableView *)table index:(NSIndexPath *)index {
    YSOnliveCell *cell = [table dequeueReusableCellWithIdentifier:@"YSOnliveCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"YSOnliveCell" owner:nil options:nil]objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;
    
    [_iconIV sd_setImageWithURL:[NSURL URLWithString:minstr([_dataDic valueForKey:@"avatar_thumb"])]];
    NSString *sexStr =minstr([_dataDic valueForKey:@"sex"]);
    if ([sexStr isEqual:@"2"]) {
        _sexIV.image = [UIImage imageNamed:@"person_性别女"];
    }else if([sexStr isEqual:@"1"]){
        _sexIV.image = [UIImage imageNamed:@"person_性别男"];
    }
    _nameL.text = minstr([_dataDic valueForKey:@"user_nickname"]);
    _cityL.text = minstr([_dataDic valueForKey:@"city"]);
    
    NSString *isAuth = [Config getIsauth];
    _inviteBtn.hidden = YES;
    if ([isAuth isEqual:@"1"]) {
        _inviteBtn.hidden = NO;
    }
    
}


- (IBAction)clickInviteBtn:(id)sender {
    
    if (self.onlineEvent) {
        self.onlineEvent(1);
    }
}



@end
