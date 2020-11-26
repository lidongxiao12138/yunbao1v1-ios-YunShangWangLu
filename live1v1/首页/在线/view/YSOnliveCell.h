//
//  YSOnliveCell.h
//  live1v1
//
//  Created by YB007 on 2019/10/24.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OnlineBlock)(int eventCode);

@interface YSOnliveCell : UITableViewCell

@property(nonatomic,copy)OnlineBlock onlineEvent;

@property (weak, nonatomic) IBOutlet UIImageView *iconIV;

@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *cityL;

@property (weak, nonatomic) IBOutlet UIImageView *sexIV;
@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;

@property(nonatomic,strong)NSDictionary *dataDic;

+(YSOnliveCell *)cellWithTab:(UITableView *)table index:(NSIndexPath *)index;
@end


