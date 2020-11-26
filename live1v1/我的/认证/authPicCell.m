//
//  authPicCell.m
//  live1v1
//
//  Created by IOS1 on 2019/4/3.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "authPicCell.h"

@implementation authPicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark ============UICollectionView=============
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_isSingle) {
        return _picArray.count == 0 ? 1 : _picArray.count;
    }else{
        if (_picArray.count == 0) {
            return 1;
        }else if (_picArray.count == 6){
            return 6;
        }else{
            return _picArray.count + 1;
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (_isSingle) {
        if (_picArray.count == 0) {
            [self.delegate didSelectPicBtn:_isSingle];
        }
    }else if (_picArray.count< 6) {
        
        if (indexPath.row == _picArray.count || _picArray.count == 0) {
            [self.delegate didSelectPicBtn:_isSingle];
        }
    }
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AuthPicCollectionCell *cell = (AuthPicCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AuthPicCollectionCELL" forIndexPath:indexPath];
    cell.delegate = self;
    cell.curIndex = indexPath;
    if (_picArray.count == 0) {
        if (_isSingle) {
            cell.thumbImgV.image = [UIImage imageNamed:@"auth_正"];
        }else{
            cell.thumbImgV.image = [UIImage imageNamed:@"auth_长"];
        }
        cell.deleteBtn.hidden = YES;

    }else{
        if (_isSingle) {
            id thumb = _picArray[indexPath.row];

            if ([thumb isKindOfClass:[UIImage class]]) {
                cell.thumbImgV.image = _picArray[indexPath.row];
            }else{
                [cell.thumbImgV sd_setImageWithURL:[NSURL URLWithString:thumb]];
            }
            cell.deleteBtn.hidden = NO;

        }else{
            if (_picArray.count == 6) {
                id thumb = _picArray[indexPath.row];

                if ([thumb isKindOfClass:[UIImage class]]) {
                    cell.thumbImgV.image = _picArray[indexPath.row];
                }else{
                    [cell.thumbImgV sd_setImageWithURL:[NSURL URLWithString:thumb]];
                }
                cell.deleteBtn.hidden = NO;
            }else{
                if (indexPath.row==_picArray.count) {
                    cell.thumbImgV.image = [UIImage imageNamed:@"auth_长"];
                    cell.deleteBtn.hidden = YES;
                }else{
                    id thumb = _picArray[indexPath.row];

                    if ([thumb isKindOfClass:[UIImage class]]) {
                        cell.thumbImgV.image = _picArray[indexPath.row];
                    }else{
                        [cell.thumbImgV sd_setImageWithURL:[NSURL URLWithString:thumb]];
                    }
                    cell.deleteBtn.hidden = NO;
                }
            }
        }
    }
    return cell;

    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_isSingle) {
        return CGSizeMake(100, 100);
    }
    return CGSizeMake(100, 160);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 15);
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 15;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}
- (void)removeCurImage:(NSIndexPath *)curIndex{
    [_picArray removeObjectAtIndex:curIndex.row];
    [_picCollectionV reloadData];
    if (!_isSingle) {
        if (_picArray.count < 6) {
            [self moveToRight];
        }
    }
    [self.delegate removeImage:curIndex andSingle:_isSingle];
    
}
- (void)moveToRight{
    NSInteger aaa = 0;
    if (_picArray.count == 0) {
        aaa = 0;
    }else{
        if (_picArray.count == 6) {
            aaa = 5;
        }else{
            aaa = _picArray.count;
        }
    }
    NSIndexPath *index = [NSIndexPath indexPathForRow:aaa inSection:0];
    [_picCollectionV scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}
@end
