//
//  messageTableView.h
//  live1v1
//
//  Created by IOS1 on 2019/4/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface messageTableView : UITableViewHeaderFooterView
@property (nonatomic,strong) UILabel *titleL;
@property (nonatomic,strong) UIView *rightV1;
@property (nonatomic,strong) UIView *rightV2;
@property (nonatomic,strong) UIImageView *rightImgV;
@property (nonatomic,strong) UIImageView *goodImgV;
@property (nonatomic,strong) UIImageView *badImgV;
@property (nonatomic,strong) UILabel *giftL;
@property (nonatomic,strong) UILabel *giftNumL;
@property (nonatomic,strong) UILabel *goodL;
@property (nonatomic,strong) UILabel *badL;

@end

NS_ASSUME_NONNULL_END
