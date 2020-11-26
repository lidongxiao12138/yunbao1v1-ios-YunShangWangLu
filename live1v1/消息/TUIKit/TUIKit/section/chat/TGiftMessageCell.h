//
//  TGiftMessageCell.h
//  live1v1
//
//  Created by IOS1 on 2019/4/12.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMessageCell.h"
#import "CFGradientLabel.h"

@interface TGiftMessageCellData : TMessageCellData
@property (nonatomic, strong) NSString *giftIcon;
@property (nonatomic, strong) NSString *giftNum;
@property (nonatomic, strong) NSString *giftName;
@property (nonatomic, strong) NSData *data;
@end

@interface TGiftMessageCell : TMessageCell
@property (nonatomic,strong) UIImageView *heade;
@property (nonatomic,strong) UILabel *nameL;
@property (nonatomic,strong) CFGradientLabel *numL;

@end

