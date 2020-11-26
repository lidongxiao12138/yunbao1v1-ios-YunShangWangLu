//
//  MIneVideoViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/5/7.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MIneVideoViewController.h"
#import "videoShowCell.h"
#import "TCVideoRecordViewController.h"
#import "LookVideoViewController.h"
#import "BackWallViewController.h"
#import "TCVideoPublishController.h"
@interface MIneVideoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,TZImagePickerControllerDelegate>{
    int videoPage;
    NSMutableArray *selectArray;
    videoModel *selectModel;
    YBAlertView *alert;
}
@property (nonatomic,strong) UICollectionView *videoCollectionV;
@property (nonatomic,strong) NSMutableArray *videoArray;

@end

@implementation MIneVideoViewController
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
        [_videoCollectionV registerNib:[UINib nibWithNibName:@"videoShowCell" bundle:nil] forCellWithReuseIdentifier:@"videoShowCELL"];
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
    self.titleL.text = @"我的视频";
    self.nothingMsgL.text = @"你还没有上传过视频";
    self.rightBtn.hidden = NO;
    if (_isSelect) {
        [self.rightBtn setTitle:@"确定" forState:0];
    }else{
        [self.rightBtn setImage:[UIImage imageNamed:@"video_add"] forState:0];
    }
    selectArray = [NSMutableArray array];
    [self.view addSubview:self.videoCollectionV];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccess) name:@"reloadlist" object:nil];
    [self pullVideoList];

}
- (void)uploadSuccess{
    [_videoCollectionV.mj_header beginRefreshing];
}
- (void)pullVideoList{
    [YBToolClass postNetworkWithUrl:@"Video.MyVideo" andParameter:@{@"p":@(videoPage)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_videoCollectionV.mj_footer endRefreshing];
        [_videoCollectionV.mj_header endRefreshing];
        if (code == 0) {
            if (videoPage == 1) {
                [_videoArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                videoModel *model = [[videoModel alloc]initWithDic:dic];
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
    videoModel *model = _videoArray[indexPath.row];
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
        NSDictionary *userInfo = @{
                                   @"id":[Config getOwnID],
                                   @"user_nickname":[Config getOwnNicename],
                                   @"avatar_thumb":[Config getavatarThumb],
                                   @"online":@"3"
                                   };
        LookVideoViewController *look = [[LookVideoViewController alloc]init];
        look.model = model;
        look.userDic = userInfo;
        [[MXBADelegate sharedAppDelegate] pushViewController:look animated:YES];
    }
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    videoShowCell *cell = (videoShowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"videoShowCELL" forIndexPath:indexPath];
    videoModel *model = _videoArray[indexPath.row];
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
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *picAction = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //        [self selectThumbWithType:UIImagePickerControllerSourceTypeCamera];
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            ipc.sourceType = UIImagePickerControllerSourceTypeCamera;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
            NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
            ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
            [self presentViewController:ipc animated:YES completion:nil];
            ipc.videoMaximumDuration = 30.0f;//30秒
            ipc.delegate = self;//设置委托
            
        }];
        [picAction setValue:color32 forKey:@"_titleTextColor"];
        [alertContro addAction:picAction];
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"本地视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
            imagePC.showSelectBtn = NO;
            imagePC.allowCrop = NO;
            imagePC.allowPickingOriginalPhoto = NO;
            imagePC.oKButtonTitleColorNormal = normalColors;
            imagePC.allowPickingImage = NO;
            imagePC.allowTakePicture = NO;
            imagePC.allowTakeVideo = NO;
            imagePC.allowPickingVideo = YES;
            imagePC.allowPickingMultipleVideo = NO;
            [self presentViewController:imagePC animated:YES completion:nil];
            
        }];
        [photoAction setValue:color32 forKey:@"_titleTextColor"];
        [alertContro addAction:photoAction];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [cancleAction setValue:color96 forKey:@"_titleTextColor"];
        [alertContro addAction:cancleAction];
        
        [self presentViewController:alertContro animated:YES completion:nil];
        

//        TCVideoRecordViewController *video = [[TCVideoRecordViewController alloc]init];
//        [[MXBADelegate sharedAppDelegate] pushViewController:video animated:YES];
    }
}
- (void)showAlertView{
    WeakSelf;
    alert = [[YBAlertView alloc]initWithTitle:@"提示" andMessage:@"该视频为私密视频，设置为背景墙后将会自动转成公开视频，是否设置" andButtonArrays:@[@"取消",@"设置"] andButtonClick:^(int type) {
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
    [YBToolClass postNetworkWithUrl:@"Wall.setWall" andParameter:@{@"action":_oldID?@"1":@"0",@"oldid":minstr(_oldID),@"type":@"1",@"newid":selectModel.videoID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
#pragma mark------------选择视频------------------------
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    NSLog(@"-dsddddddddd--%@\n===%@",asset,coverImage);
    
    [MBProgressHUD showMessage:@""];
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetMediumQuality success:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        if (outputPath) {
            [MBProgressHUD hideHUD];
            TCVideoPublishController *vc = [[TCVideoPublishController alloc] initWithPath:outputPath
                                                                                 videoMsg:coverImage];
            [self.navigationController pushViewController:vc animated:YES];

        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"请重新选择(iCloud视频请先在本地相册下载后上传)"];
        }
        
    } failure:^(NSString *errorMessage, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:errorMessage];
        NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
    }];
    
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
        NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *outputPath =[sourceURL path];
        UIImage *viodeimg =[self getVideoFirstViewImage:[NSURL fileURLWithPath:outputPath]];
    TCVideoPublishController *vc = [[TCVideoPublishController alloc] initWithPath:outputPath
                                                                         videoMsg:viodeimg];
    [self.navigationController pushViewController:vc animated:YES];

        //以下是压缩视频 暂未用
        //        NSURL *newVideoUrl ; //一般.mp4
        //        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
        //        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        //        newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]] ;//这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
        //        [picker dismissViewControllerAnimated:YES completion:nil];
        //        [self convertVideoQuailtyWithInputURL:sourceURL outputURL:newVideoUrl completeHandler:nil];
        
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}
- (UIImage*)getVideoFirstViewImage:(NSURL *)path {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
    
}

@end
