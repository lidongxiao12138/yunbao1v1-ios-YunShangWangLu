//
//  RankHeaderView.h
//  live1v1
//
//  Created by ybRRR on 2019/7/31.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RankHeaderView : UIView
{
    UIImageView *headImg;
    UILabel *nameLb;
    UIImageView *levelImg;
    UILabel *coinLb;
    UIImageView *rankheader;
    
}

-(void)setContentData:(int)aaa withmodel:(RankModel*)model;
@end

NS_ASSUME_NONNULL_END
