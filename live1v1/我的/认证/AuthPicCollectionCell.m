//
//  AuthPicCollectionCell.m
//  live1v1
//
//  Created by IOS1 on 2019/4/3.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "AuthPicCollectionCell.h"

@implementation AuthPicCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)deleteBtnClick:(id)sender {
    [self.delegate removeCurImage:_curIndex];
}

@end
