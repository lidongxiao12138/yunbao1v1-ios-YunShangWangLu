//
//  RankCell.h
//  yunbaolive
//
//  Created by YunBao on 2018/2/2.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RankModel.h"

@interface RankCell : UITableViewCell

#pragma mark - 第一行

//没有特殊字段
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthOne;

#pragma mark - 其他行

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthTwo;
@property (weak, nonatomic) IBOutlet UIImageView *kkIV;  //边框
@property (weak, nonatomic) IBOutlet UILabel *otherMCL;  //名次



#pragma mark - 公用
@property (weak, nonatomic) IBOutlet UIImageView *iconIV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *levelIV;
@property (weak, nonatomic) IBOutlet UILabel *moneyL;

@property (nonatomic,strong) RankModel *model;

+(RankCell*)cellWithTab:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;


@end
