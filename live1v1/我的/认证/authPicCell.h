//
//  authPicCell.h
//  live1v1
//
//  Created by IOS1 on 2019/4/3.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthPicCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN
@protocol authPicCellDelegate <NSObject>

- (void)didSelectPicBtn:(BOOL)isSingle;
- (void)removeImage:(NSIndexPath *)index andSingle:(BOOL)isSingle;
@end
@interface authPicCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,AuthPicCollectionCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UICollectionView *picCollectionV;
@property (nonatomic,assign) BOOL isSingle;
@property (nonatomic,strong) NSMutableArray *picArray;
@property (nonatomic,weak) id<authPicCellDelegate> delegate;
- (void)moveToRight;
@end

NS_ASSUME_NONNULL_END
