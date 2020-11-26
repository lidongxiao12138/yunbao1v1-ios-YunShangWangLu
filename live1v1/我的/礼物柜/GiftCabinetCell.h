//
//  GiftCabinetCell.h
//  live1v1
//
//  Created by IOS1 on 2019/4/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GiftCabinetCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *giftNumL;

@end

NS_ASSUME_NONNULL_END
