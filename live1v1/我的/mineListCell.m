//
//  mineListCell.m
//  live1v1
//
//  Created by IOS1 on 2019/4/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "mineListCell.h"

@implementation mineListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)switchChange:(UISwitch *)sender {
    NSString *url;
    NSDictionary *dic;
    
    if ([_listID isEqual:@"6"]) {
        url = @"User.SetVideoSwitch";
        dic = @{@"isvideo":[NSString stringWithFormat:@"%d",sender.on]};
    }else if ([_listID isEqual:@"7"]) {
        url = @"User.SetVoiceSwitch";
        dic = @{@"isvoice":[NSString stringWithFormat:@"%d",sender.on]};
    }else if ([_listID isEqual:@"8"]) {
        url = @"User.SetDisturbSwitch";
        dic = @{@"isdisturb":[NSString stringWithFormat:@"%d",sender.on]};
    }else{
        return;
    }
    [YBToolClass postNetworkWithUrl:url andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [self.delegate reloadMineList];
        }else{
            sender.on = !sender.on;
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        sender.on = !sender.on;
    }];

}

@end
