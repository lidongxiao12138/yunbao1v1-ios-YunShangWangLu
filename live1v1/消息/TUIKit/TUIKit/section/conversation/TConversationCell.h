//
//  TConversationCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/14.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUnReadView.h"

typedef NS_ENUM(NSUInteger, TConvType) {
    TConv_Type_C2C      = 1,
    TConv_Type_Group    = 2,
    TConv_Type_System   = 3,
};

@interface TConversationCellData : NSObject
@property (nonatomic, strong) NSString *convId;
@property (nonatomic, assign) TConvType convType;
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userHeader;
@property (nonatomic, strong) NSString *isauth;
@property (nonatomic, strong) NSString *level_anchor;
@property (nonatomic, strong) NSString *isAtt;
@property (nonatomic, strong) NSString *isVIP;
@property (nonatomic, strong) NSString *isblack;

@property (nonatomic, assign) int unRead;
@end

@interface TConversationCell : UITableViewCell
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TUnReadView *unReadView;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) UIImageView *vipImageView;

+ (CGSize)getSize;
- (void)setData:(TConversationCellData *)data;
@end
