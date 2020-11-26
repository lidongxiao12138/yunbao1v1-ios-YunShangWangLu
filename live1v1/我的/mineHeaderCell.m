//
//  mineHeaderCell.m
//  live1v1
//
//  Created by IOS1 on 2019/4/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "mineHeaderCell.h"

@implementation mineHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)docoin:(id)sender {
    [self.delegate doCoinVC];
}
- (IBAction)doedit:(id)sender {
    [self.delegate doEditVC];
}
- (IBAction)doFollow:(id)sender {
    [self.delegate doFollowUser];
}
- (IBAction)doFans:(id)sender {
    [self.delegate doFansUser];
}

@end
