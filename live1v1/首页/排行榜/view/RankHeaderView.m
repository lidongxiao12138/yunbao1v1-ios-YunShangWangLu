//
//  RankHeaderView.m
//  live1v1
//
//  Created by ybRRR on 2019/7/31.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "RankHeaderView.h"
@implementation RankHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatUI];
    }
    return self;
}

-(void)creatUI{
    
    CGFloat wwhh = 60;
    
    headImg  = [[UIImageView alloc]init];
    headImg.layer.cornerRadius = wwhh/2;
    headImg.layer.masksToBounds = YES;
    [self addSubview:headImg];
    [headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.width.height.mas_equalTo(wwhh);
        make.centerX.equalTo(self);
    }];
    
    rankheader = [[UIImageView alloc]init];
    [self addSubview:rankheader];
    [rankheader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headImg.mas_bottom).offset(-10);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(22);
        make.centerX.equalTo(self);
    }];
    
    nameLb = [[UILabel alloc]init];
    nameLb.font = [UIFont systemFontOfSize:15];
    nameLb.textColor  = [UIColor whiteColor];
    nameLb.textAlignment = NSTextAlignmentCenter;
    [self addSubview:nameLb];
    [nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rankheader.mas_bottom).offset(5);
        make.width.equalTo(self);
        make.height.mas_equalTo(15);
        make.centerX.equalTo(self);
    }];
    
    
    
    levelImg = [[UIImageView alloc]init];
//    levelImg.layer.cornerRadius = 8;
//    levelImg.layer.masksToBounds  = YES;
    levelImg.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:levelImg];
    [levelImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLb.mas_bottom).offset(5);
        make.width.mas_equalTo(25);
        make.height.mas_equalTo(15);
        make.centerX.equalTo(self);
    }];
    
    coinLb = [[UILabel alloc]init];
    coinLb.textColor = [UIColor whiteColor];
    coinLb.font = [UIFont systemFontOfSize:13];
    coinLb.text = @"888888";
    [self addSubview:coinLb];
    [coinLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(15);
        make.top.equalTo(levelImg.mas_bottom).offset(5);
        make.centerX.equalTo(self);
    }];
    
    UIImageView *coinImg = [[UIImageView alloc]init];
    coinImg.image = [UIImage imageNamed:@"coin_Icon.png"];
    [self addSubview:coinImg];
    [coinImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(12);
        make.right.equalTo(coinLb.mas_left).offset(-5);
        make.centerY.equalTo(coinLb.mas_centerY);
    }];
}

-(void)setContentData:(int)aaa withmodel:(RankModel *)model{
    if (aaa == 1) {
        [headImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(60);
            make.top.equalTo(self).offset(10);
            
        }];
        headImg.layer.cornerRadius = 30;
        rankheader.image = [UIImage imageNamed:@"排名1"];
    }else if (aaa == 2){
        [headImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(50);
            
        }];
        headImg.layer.cornerRadius = 25;
        rankheader.image = [UIImage imageNamed:@"排名2"];

    }else{
        [headImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(50);
            
        }];
        headImg.layer.cornerRadius = 25;
        rankheader.image = [UIImage imageNamed:@"排名3"];

    }
    [headImg sd_setImageWithURL:[NSURL URLWithString:model.iconStr]];
    nameLb.text = model.unameStr;
    coinLb.text = model.totalCoinStr;
    
    if([model.type isEqual:@"0"]){
//        levelImg.size = CGSizeMake(30, 14);
        [levelImg sd_setImageWithURL:[NSURL URLWithString:[common getUserLevelMessage:minstr(model.levelStr)]]];
        
    }else{
//        levelImg.size = CGSizeMake(25, 15);

        [levelImg sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:minstr(model.levelStr)]]];
        
    }

}
@end
