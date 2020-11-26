//
//  AuthPicCollectionCell.h
//  live1v1
//
//  Created by IOS1 on 2019/4/3.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AuthPicCollectionCellDelegate <NSObject>

- (void)removeCurImage:(NSIndexPath *)curIndex;

@end
@interface AuthPicCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImgV;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIImageView *playImgV;

@property (nonatomic,weak) id<AuthPicCollectionCellDelegate> delegate;
@property (nonatomic,strong) NSIndexPath *curIndex;

@end

NS_ASSUME_NONNULL_END
