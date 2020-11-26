//
//  mineHeaderCell.h
//  live1v1
//
//  Created by IOS1 on 2019/4/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol mineHeaderCellDeleagte <NSObject>

- (void)doCoinVC;
- (void)doEditVC;
- (void)doFollowUser;
- (void)doFansUser;

@end
@interface mineHeaderCell : UITableViewCell
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameL;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *levelImgV;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *IDLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *iconBtn;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *followL;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *fansL;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *coinL;
@property (nonatomic,weak) id<mineHeaderCellDeleagte> delegate;
@property (weak, nonatomic) IBOutlet UILabel *fansTitleL;
@property (weak, nonatomic) IBOutlet UILabel *coinTitleL;
@property (weak, nonatomic) IBOutlet UIImageView *vipImgV;

@end

NS_ASSUME_NONNULL_END
