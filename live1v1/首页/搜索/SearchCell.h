//
//  SearchCell.h
//  live1v1
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SearchCellDelegate <NSObject>

- (void)cellBtnClick:(SearchModel *)model;

@end
@interface SearchCell : UICollectionViewCell
@property (nonatomic,strong) SearchModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UIImageView *levelImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *IDL;
@property (weak, nonatomic) IBOutlet UILabel *fansL;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIImageView *coinImgV;
@property (weak, nonatomic) IBOutlet UIImageView *yuyueImgV;
@property (weak, nonatomic) IBOutlet UIButton *fuyueBtn;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgV;
@property (nonatomic,weak) id<SearchCellDelegate> delegate;

/**
 来自哪里 0搜索 1粉丝 2关注
 */
@property (nonatomic,assign) int fromType;

@end

NS_ASSUME_NONNULL_END
