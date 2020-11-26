//
//  TCallCell.h
//  live1v1
//
//  Created by IOS1 on 2019/4/22.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMessageCell.h"
#import "CFGradientLabel.h"

@interface TCallCellData : TMessageCellData
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *content;
@end

@interface TCallCell : TMessageCell
@property (nonatomic,strong) UIImageView *TypeImgV;
@property (nonatomic, strong) UIImageView *bubble;
@property (nonatomic, strong) UILabel *content;

@end

