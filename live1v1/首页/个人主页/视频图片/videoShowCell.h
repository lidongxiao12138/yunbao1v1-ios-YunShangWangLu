//
//  videoShowCell.h
//  live1v1
//
//  Created by IOS1 on 2019/5/7.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "videoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface videoShowCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *effectV;
@property (nonatomic,strong) videoModel *model;
@property (weak, nonatomic) IBOutlet UILabel *stateL;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgV;

@end

NS_ASSUME_NONNULL_END
