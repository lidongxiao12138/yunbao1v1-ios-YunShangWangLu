//
//  picShowCell.h
//  live1v1
//
//  Created by IOS1 on 2019/5/7.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "picModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface picShowCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *lookNumL;
@property (weak, nonatomic) IBOutlet UILabel *stateL;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgV;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *effectV;
@property (nonatomic,strong) picModel *model;

@end

NS_ASSUME_NONNULL_END
