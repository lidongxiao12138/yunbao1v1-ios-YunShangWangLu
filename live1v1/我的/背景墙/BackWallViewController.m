//
//  BackWallViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "BackWallViewController.h"
#import "AuthPicCollectionCell.h"
#import "LookPicViewController.h"
#import "backWallModel.h"
#import "minePicAuthViewController.h"
#import "MIneVideoViewController.h"

@interface BackWallViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *videoCollectionV;
@property (nonatomic,strong) NSMutableArray *videoArray;
@property (nonatomic,strong) UILabel *tipLabel;

@end

@implementation BackWallViewController
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
        [_videoCollectionV registerNib:[UINib nibWithNibName:@"AuthPicCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"AuthPicCollectionCELL"];
    }
    return _videoCollectionV;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"背景墙";
    [self.view addSubview:self.videoCollectionV];
    UIView *bottomV = [[UIView alloc]init];
    bottomV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomV];
    [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
    }];
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.font = SYS_Font(10);
    _tipLabel.textColor = color32;
    _tipLabel.numberOfLines = 0;
    _tipLabel.text = @"*设置说明\n背景墙位置最多可选取六个，最少保证有一张背景图；可以在“我的相册”“我的视频”中选取图片或视频，视频只能选取一个；";
    [bottomV addSubview:_tipLabel];
    
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomV).offset(15);
        make.right.equalTo(bottomV).offset(-40);
        make.bottom.equalTo(bottomV).offset(-20);
        make.top.equalTo(bottomV);
    }];
}
- (void)viewWillAppear:(BOOL)animated{
    _videoArray = [NSMutableArray array];
    [self pullVideoList];
}
- (void)pullVideoList{
    [YBToolClass postNetworkWithUrl:@"Wall.myWall" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            for (NSDictionary *dic in info) {
                backWallModel *model = [[backWallModel alloc]initWithDic:dic];
                [_videoArray addObject:model];
            }
            [_videoCollectionV reloadData];
        }
    } fail:^{
        
    }];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _videoArray.count < 6 ? _videoArray.count+1 : _videoArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _videoArray.count) {
        backWallModel *model = _videoArray[indexPath.row];
        LookPicViewController *look = [[LookPicViewController alloc]init];
        look.wallModel = model;
        [[MXBADelegate sharedAppDelegate] pushViewController:look animated:YES];
    }else{
        [self showAlert];
    }
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AuthPicCollectionCell *cell = (AuthPicCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AuthPicCollectionCELL" forIndexPath:indexPath];

    cell.deleteBtn.hidden = YES;
    
    if (indexPath.row < _videoArray.count) {
        backWallModel *model = _videoArray[indexPath.row];
        [cell.thumbImgV sd_setImageWithURL:[NSURL URLWithString:model.thumb]];
        if ([model.type isEqual:@"1"]) {
            cell.playImgV.hidden = NO;
        }else{
            cell.playImgV.hidden = YES;
        }
    }else{
        cell.thumbImgV.image = [UIImage imageNamed:@"auth_长"];
        cell.playImgV.hidden = YES;
    }
    return cell;
    
}
- (void)showAlert{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"添加图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        minePicAuthViewController *pic = [[minePicAuthViewController alloc]init];
        pic.isSelect = YES;
        [self.navigationController pushViewController:pic animated:YES];
    }];
    [action1 setValue:color32 forKey:@"_titleTextColor"];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"添加视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        

        if (_videoArray.count > 0) {
            backWallModel *model = _videoArray[0];
            if ([model.type isEqual:@"1"]) {
                [MBProgressHUD showError:@"背景墙已有视频，无法再次添加"];
                return ;
            }
        }
        MIneVideoViewController *video = [[MIneVideoViewController alloc]init];
        video.isSelect = YES;
        [self.navigationController pushViewController:video animated:YES];

    }];
    [action2 setValue:color32 forKey:@"_titleTextColor"];
    
    
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:action1];
    [alertContro addAction:action2];
    [alertContro addAction:cancleAction];
    [self presentViewController:alertContro animated:YES completion:nil];
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
