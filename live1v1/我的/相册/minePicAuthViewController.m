//
//  minePicAuthViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "minePicAuthViewController.h"
#import "picShowCell.h"
#import "LookPicViewController.h"
#import "PublistPicViewController.h"
#import "BackWallViewController.h"
#import "YBEditImageViewController.h"
#import "BackWallViewController.h"

@interface minePicAuthViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    int videoPage;
    NSMutableArray *selectArray;
    picModel *selectModel;
    YBAlertView *alert;

}
@property (nonatomic,strong) UICollectionView *videoCollectionV;
@property (nonatomic,strong) NSMutableArray *videoArray;

@end

@implementation minePicAuthViewController

- (UICollectionView *)videoCollectionV{
    if (!_videoCollectionV) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
        flow.itemSize = CGSizeMake((_window_width-4)/3, (_window_width-4)/3*1.33);
        flow.minimumLineSpacing = 2;
        flow.minimumInteritemSpacing = 2;
        flow.sectionInset = UIEdgeInsetsMake(2, 0,2, 0);
        
        _videoCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight) collectionViewLayout:flow];
        _videoCollectionV.backgroundColor = [UIColor whiteColor];
        _videoCollectionV.delegate   = self;
        _videoCollectionV.dataSource = self;
        [_videoCollectionV registerNib:[UINib nibWithNibName:@"picShowCell" bundle:nil] forCellWithReuseIdentifier:@"picShowCELL"];
        _videoCollectionV.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            videoPage = 1;
            [self pullVideoList];
        }];
        
        _videoCollectionV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            videoPage ++;
            [self pullVideoList];
        }];
        _videoArray = [NSMutableArray array];
        videoPage = 1;
    }
    return _videoCollectionV;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"我的相册";
    self.nothingMsgL.text = @"你还没有上传过照片";
    self.rightBtn.hidden = NO;
    if (_isSelect) {
        [self.rightBtn setTitle:@"确定" forState:0];
    }else{
        [self.rightBtn setImage:[UIImage imageNamed:@"video_add"] forState:0];
    }
    selectArray = [NSMutableArray array];
    [self.view addSubview:self.videoCollectionV];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccess) name:@"reloadMinePiclist" object:nil];
    [self pullVideoList];
    
}
- (void)uploadSuccess{
    [_videoCollectionV.mj_header beginRefreshing];
}
- (void)pullVideoList{
    [YBToolClass postNetworkWithUrl:@"Photo.myPhoto" andParameter:@{@"p":@(videoPage)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_videoCollectionV.mj_footer endRefreshing];
        [_videoCollectionV.mj_header endRefreshing];
        if (code == 0) {
            if (videoPage == 1) {
                [_videoArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                picModel *model = [[picModel alloc]initWithDic:dic];
                if (_isSelect) {
                    if ([model.status isEqual:@"1"]) {
                        [_videoArray addObject:model];
                    }
                }else{
                    [_videoArray addObject:model];
                }
                [selectArray addObject:@"0"];
            }
            if (_videoArray.count == 0) {
                _videoCollectionV.hidden = YES;
                self.nothingView.hidden = NO;
            }else{
                _videoCollectionV.hidden = NO;
                self.nothingView.hidden = YES;
            }
            [_videoCollectionV reloadData];
        }
    } fail:^{
        [_videoCollectionV.mj_footer endRefreshing];
        [_videoCollectionV.mj_header endRefreshing];
        
    }];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _videoArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    
    picModel *model = _videoArray[indexPath.row];
    if (_isSelect) {
        NSString *str = selectArray[indexPath.row];
        if([str isEqual:@"1"]){
            selectModel = nil;
            [selectArray replaceObjectAtIndex:indexPath.item withObject:@"0"];
        }else{
            selectModel = model;
            [selectArray removeAllObjects];
            for (int i = 0; i < _videoArray.count; i++) {
                if (i == indexPath.row) {
                    [selectArray addObject:@"1"];
                }else{
                    [selectArray addObject:@"0"];
                }
            }
        }
        [_videoCollectionV reloadData];
    }else{
//        NSDictionary *userInfo = @{
//                                   @"id":[Config getOwnID],
//                                   @"user_nickname":[Config getOwnNicename],
//                                   @"avatar_thumb":[Config getavatarThumb],
//                                   @"online":@"3"
//                                   };
        LookPicViewController *look = [[LookPicViewController alloc]init];
        look.model = model;
//        look.userDic = userInfo;
        [[MXBADelegate sharedAppDelegate] pushViewController:look animated:YES];
    }
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    picShowCell *cell = (picShowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"picShowCELL" forIndexPath:indexPath];
    picModel *model = _videoArray[indexPath.row];
    cell.model = model;
    cell.effectV.hidden = YES;
    if ([model.status isEqual:@"0"]) {
        cell.stateL.hidden = NO;
        cell.stateL.text = @"  审核中  ";
    }else{
        cell.stateL.hidden = YES;
    }
    if (_isSelect) {
        cell.statusImgV.hidden = NO;
        NSString *str = selectArray[indexPath.row];
        if([str isEqual:@"0"]){
            cell.statusImgV.image = [UIImage imageNamed:@"相册未选中"];
        }else{
            cell.statusImgV.image = [UIImage imageNamed:@"jubao_sel"];
        }
    }
    return cell;
    
}
- (void)rightBtnClick{
    if (_isSelect) {
        if (selectModel) {
            if ([selectModel.isprivate isEqual:@"1"]) {
                [self showAlertView];
            }else{
                [self setBackWall];
            }
        }else{
            [MBProgressHUD showError:@"请选择图片"];
        }
    }else{
        PublistPicViewController *publish = [[PublistPicViewController alloc]init];
        [self.navigationController pushViewController:publish animated:YES];
    }
}
- (void)showAlertView{
    WeakSelf;
    alert = [[YBAlertView alloc]initWithTitle:@"提示" andMessage:@"该照片为私密照片，设置为背景墙后将会自动转成公开照片，是否设置" andButtonArrays:@[@"取消",@"设置"] andButtonClick:^(int type) {
        if (type == 2) {
            [weakSelf setBackWall];
        }else{
            [weakSelf removeAlertView];
        }
    }];
    [self.view addSubview:alert];
}
- (void)removeAlertView{
    if (alert) {
        [alert removeFromSuperview];
        alert = nil;
    }
    
}
- (void)setBackWall{
    [YBToolClass postNetworkWithUrl:@"Wall.setWall" andParameter:@{@"action":_oldID?@"1":@"0",@"oldid":minstr(_oldID),@"type":@"0",@"newid":selectModel.picID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[BackWallViewController class]])
                {
                    BackWallViewController *vc = (BackWallViewController *)controller;
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
            
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
