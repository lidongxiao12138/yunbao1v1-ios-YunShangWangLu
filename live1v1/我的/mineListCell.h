//
//  mineListCell.h
//  live1v1
//
//  Created by IOS1 on 2019/4/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol mineListCellDelegate <NSObject>

- (void)reloadMineList;

@end
@interface mineListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgV;
@property (nonatomic,assign) NSString *listID;
@property (nonatomic,weak) id<mineListCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
