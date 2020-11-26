//
//  PublistPicViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "PublistPicViewController.h"
#import <Qiniu/QiniuSDK.h>
#import "instructionCell.h"

@interface PublistPicViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource>{
    UIImage *selectImage;
    UIButton *selectImgBtn;
    UIView *pickBackView;
    UIView *wihteView;
    UIView *instructionView;
    UIPickerView *coinPicker;
    NSArray *videoArray;
    int videoMaxSelectIndex;
    int curVideoIndex;
    UITableView *instructionTable;
    NSArray *instructionArray;
    NSString *coastCoinStr;

}
@property (nonatomic,strong) UISwitch *coastSwitch;

@property (nonatomic,strong) UIButton *coastPriceBtn;

@property (nonatomic,strong) UILabel *tipsLable;
@property(nonatomic,strong)UIView *locationV;

@end

@implementation PublistPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"传相册";
    [self.returnBtn setImage:[UIImage new] forState:0];
    [self.returnBtn setTitle:@"取消" forState:0];
    self.returnBtn.titleLabel.font = SYS_Font(15);
    [self.returnBtn setTitleColor:normalColors forState:0];
    self.rightBtn.hidden = NO;
    [self.rightBtn setTitle:@"上传" forState:0];
    coastCoinStr = @"0";
    selectImgBtn = [UIButton buttonWithType:0];
    [selectImgBtn setImage:[UIImage imageNamed:@"auth_正"] forState:0];
    selectImgBtn.frame = CGRectMake(10, 64+statusbarHeight+10, 110, 110);
    [selectImgBtn addTarget:self action:@selector(doSelect) forControlEvents:UIControlEventTouchUpInside];
    selectImgBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:selectImgBtn];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, selectImgBtn.bottom+10, _window_width, 5) andColor:colorf5 andView:self.view];
    [self.view addSubview:self.locationV];
    [self.view addSubview:self.tipsLable];
    [_tipsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_locationV.mas_bottom).offset(3);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];

    [self getVideoCoastList];
}
-(UIView *)locationV {
    if (!_locationV) {
        //显示定位
        _locationV = [[UIView alloc]initWithFrame:CGRectMake(0, selectImgBtn.bottom+15, _window_width, 50)];
        _locationV.backgroundColor = [UIColor whiteColor];;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 65, 50)];
        label.font = SYS_Font(15);
        label.textColor = color32;
        label.text = @"私密设置";
        [_locationV addSubview:label];

        _coastSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(label.right + 5, 10, 100, 30)];
        _coastSwitch.on = NO;
        _coastSwitch.transform = CGAffineTransformMakeScale(0.65, 0.65);
        [_coastSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:(UIControlEventValueChanged)];
        [_locationV addSubview:_coastSwitch];
        
        _coastPriceBtn = [UIButton buttonWithType:0];
        [_coastPriceBtn setTitleColor:color96 forState:0];
        _coastPriceBtn.titleLabel.font = SYS_Font(15);
        [_coastPriceBtn addTarget:self action:@selector(coastPriceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_locationV addSubview:_coastPriceBtn];
        [_coastPriceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.height.equalTo(_locationV);
            make.right.equalTo(_locationV).offset(-10);
        }];
        [_coastPriceBtn setTitle:[NSString stringWithFormat:@"%@%@",coastCoinStr,[common name_coin]] forState:0];
    }
    return _locationV;
}
- (void)valueChanged:(UISwitch*)swt{
//    if (_coastSwitch.on) {
//        [self coastPriceBtnClick];
//    }
}
- (void)getVideoCoastList{
    [YBToolClass postNetworkWithUrl:@"Photo.GetFee" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            _tipsLable.text = minstr([[info firstObject] valueForKey:@"tips"]);
            curVideoIndex = 0;
            videoArray = [[info firstObject] valueForKey:@"list"];
            videoMaxSelectIndex = (int)[videoArray count] - 1;
            for (int i = 0; i < videoArray.count; i++) {
                NSDictionary *dic = videoArray[i];
                //                if ([minstr([dic valueForKey:@"coin"]) isEqual:curVideoValue]) {
                //                    curVideoIndex = i;
                //                }
                if(i == 0 ){
                    coastCoinStr = minstr([dic valueForKey:@"coin"]);
                    [_coastPriceBtn setTitle:[NSString stringWithFormat:@"%@%@",coastCoinStr,[common name_coin]] forState:0];

                }

                if ([minstr([dic valueForKey:@"canselect"]) isEqual:@"0"]) {
                    videoMaxSelectIndex = i-1;
                    if (videoMaxSelectIndex<0) {
                        videoMaxSelectIndex = 0;
                    }
                    break;
                }
            }
            
        }
    } fail:^{
        
    }];
}
- (void)coastPriceBtnClick{
    pickBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    pickBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [[UIApplication sharedApplication].keyWindow addSubview:pickBackView];
    wihteView = [[UIView alloc]initWithFrame:CGRectMake(30, _window_height, _window_width-60, 200)];
    wihteView.backgroundColor = [UIColor whiteColor];
    wihteView.layer.cornerRadius = 10;
    wihteView.layer.masksToBounds  = YES;
    [pickBackView addSubview:wihteView];
    
    UIButton *messageBtn = [UIButton buttonWithType:0];
    messageBtn.frame = CGRectMake(15, 7, 85, 30);
    [messageBtn setImage:[UIImage imageNamed:@"mine_message"] forState:0];
    [messageBtn setTitle:@"收费标准说明" forState:0];
    [messageBtn setTitleColor:color96 forState:0];
    messageBtn.titleLabel.font = SYS_Font(10);
    [messageBtn addTarget:self action:@selector(messageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [wihteView addSubview:messageBtn];
    UIButton *closeBtn = [UIButton buttonWithType:0];
    closeBtn.frame = CGRectMake(wihteView.width-41, 0, 41, 41);
    [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [closeBtn addTarget:self action:@selector(closebtnClick) forControlEvents:UIControlEventTouchUpInside];
    [wihteView addSubview:closeBtn];
    
    coinPicker = [[UIPickerView alloc]initWithFrame:CGRectMake((wihteView.width-80)/2, 40, 80, 120)];
    coinPicker.backgroundColor = [UIColor whiteColor];
    coinPicker.delegate = self;
    coinPicker.dataSource = self;
    coinPicker.showsSelectionIndicator = YES;
    [wihteView addSubview:coinPicker];
    
    UILabel *leftL = [[UILabel alloc]initWithFrame:CGRectMake(20, 90, (wihteView.width-80)/2-20, 20)];
    leftL.font = SYS_Font(14);
    leftL.textColor = RGB_COLOR(@"#646464", 1);
    leftL.text = @"向TA收费";
    leftL.textAlignment = NSTextAlignmentCenter;
    [wihteView addSubview:leftL];
    
    UILabel *rightL = [[UILabel alloc]initWithFrame:CGRectMake(coinPicker.right, 90, (wihteView.width-80)/2-20, 20)];
    rightL.font = SYS_Font(14);
    rightL.textColor = RGB_COLOR(@"#646464", 1);
    rightL.text = [common name_coin];
    rightL.textAlignment = NSTextAlignmentCenter;
    [wihteView addSubview:rightL];
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 160, wihteView.width, 1) andColor:RGB_COLOR(@"#DCDCDC", 1) andView:wihteView];
    
    UIButton *sureBtn = [UIButton buttonWithType:0];
    sureBtn.frame = CGRectMake(0, 160, wihteView.width, 40);
    [sureBtn setTitleColor:normalColors forState:0];
    [sureBtn setTitle:@"确定" forState:0];
    sureBtn.titleLabel.font = SYS_Font(14);
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [wihteView addSubview:sureBtn];
    [self showCoinPicker];
    
}
- (void)showCoinPicker{
    [coinPicker selectRow:curVideoIndex inComponent:0 animated:YES];
    [coinPicker reloadAllComponents];
    pickBackView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        wihteView.center = pickBackView.center;
    }];
}
- (void)messageBtnClick{
    
    [YBToolClass postNetworkWithUrl:@"Video.getFeeInfo" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            instructionArray = info;
            if (!instructionView) {
                instructionView = [[UIView alloc]initWithFrame:CGRectMake(30, _window_height, _window_width-60, 330)];
                instructionView.backgroundColor = [UIColor whiteColor];
                instructionView.layer.cornerRadius = 10;
                instructionView.layer.masksToBounds  = YES;
                [pickBackView addSubview:instructionView];
                UIButton *closeBtn = [UIButton buttonWithType:0];
                closeBtn.frame = CGRectMake(wihteView.width-41, 0, 41, 41);
                [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
                closeBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
                [closeBtn addTarget:self action:@selector(closeInstructionViewClick) forControlEvents:UIControlEventTouchUpInside];
                [instructionView addSubview:closeBtn];
                UILabel *labelll = [[UILabel alloc]initWithFrame:CGRectMake(instructionView.width/2-40, 13, 80, 47)];
                labelll.textAlignment = NSTextAlignmentCenter;
                labelll.font = SYS_Font(14);
                labelll.text =@"收费说明";
                [instructionView addSubview:labelll];
                
                instructionTable = [[UITableView alloc]initWithFrame:CGRectMake(35, 60, instructionView.width-70, 244) style:0];
                instructionTable.delegate = self;
                instructionTable.dataSource = self;
                instructionTable.separatorStyle = 0;
                [instructionView addSubview:instructionTable];
                
            }
            [self showInstructionTable];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
}
- (void)showInstructionTable{
    [instructionTable reloadData];
    instructionView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        instructionView.center = pickBackView.center;
    }];
}
- (void)closeInstructionViewClick{
    [UIView animateWithDuration:0.3 animations:^{
        instructionView.y = _window_height;
    }completion:^(BOOL finished) {
        instructionView.hidden = YES;
    }];
    
}
- (void)closebtnClick{
    if ([coastCoinStr isEqual:@"0"]) {
        _coastSwitch.on = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        wihteView.y = _window_height;
    }completion:^(BOOL finished) {
        pickBackView.hidden = YES;
    }];
    
}
- (void)sureBtnClick{
    //    NSString *url;
    //    NSDictionary *dic;
    NSInteger index = [coinPicker selectedRowInComponent: 0];
    coastCoinStr = minstr([videoArray[index] valueForKey:@"coin"]);
    [_coastPriceBtn setTitle:[NSString stringWithFormat:@"%@%@",coastCoinStr,[common name_coin]] forState:0];
    [self closebtnClick];
    if ([coastCoinStr isEqual:@"0"]) {
        _coastSwitch.on = NO;
    }
    
    //        url = @"User.SetVideoValue";
    //        dic = @{@"value":minstr([videoArray[index] valueForKey:@"coin"])};
    //    [YBToolClass postNetworkWithUrl:url andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    //        if (code == 0) {
    ////            [self requestData];
    //            [self closebtnClick];
    //        }
    //        [MBProgressHUD showError:msg];
    //    } fail:^{
    //
    //    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return instructionArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    instructionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"instructionCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"instructionCell" owner:nil options:nil] lastObject];
    }
    NSDictionary *dic = instructionArray[indexPath.row];
    [cell.levelImgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])]];
    cell.coinL.text = [NSString stringWithFormat:@"≤ %@",minstr([dic valueForKey:@"coin"])];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == instructionTable) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, instructionTable.width, 40)];
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width/2, 40)];
        label1.font = SYS_Font(12);
        label1.textColor = RGB_COLOR(@"#646464", 1);
        label1.text = @"主播星级";
        label1.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label1];
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(view.width/2, 0, view.width/2, 40)];
        label2.font = SYS_Font(12);
        label2.textColor = RGB_COLOR(@"#646464", 1);
        label2.text = @"收费价格";
        label2.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label2];
        [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, view.width, 1) andColor:RGB_COLOR(@"#dcdcdc", 1) andView:view];
        return view;
    }
    return nil;
}

#pragma mark- Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [videoArray count];
    
}


#pragma mark- Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return minstr([[videoArray objectAtIndex: row] valueForKey:@"coin"]);
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (row > videoMaxSelectIndex) {
        [pickerView selectRow:videoMaxSelectIndex inComponent:0 animated:YES];
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 80;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 40)];
    myView.textAlignment = NSTextAlignmentCenter;
    myView.text = minstr([[videoArray objectAtIndex: row] valueForKey:@"coin"]);
    myView.font = [UIFont systemFontOfSize:16];
    myView.backgroundColor = [UIColor clearColor];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, 80, 1) andColor:RGB_COLOR(@"#DCDCDC", 1) andView:myView];
    return myView;
}
-(UILabel *)tipsLable {
    if (!_tipsLable) {
        _tipsLable = [[UILabel alloc]init];
        _tipsLable.font = SYS_Font(10);
        _tipsLable.textColor = color96;
        _tipsLable.numberOfLines = 0;
    }
    return _tipsLable;
}

- (void)doSelect{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *picAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectThumbWithType:UIImagePickerControllerSourceTypeCamera];
    }];
    [picAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:picAction];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectThumbWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    [photoAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:photoAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:cancleAction];
    
    [self presentViewController:alertContro animated:YES completion:nil];

}
- (void)selectThumbWithType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = type;
    imagePickerController.allowsEditing = NO;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImageOrientation imageOrientation = image.imageOrientation;
        if(imageOrientation!=UIImageOrientationUp)
        {
            // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
            // 以下为调整图片角度的部分
            UIGraphicsBeginImageContext(image.size);
                        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // 调整图片角度完毕
        }

        selectImage = image;
        [selectImgBtn setImage:image forState:UIControlStateNormal];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}

- (void)doReturn{
    if (selectImage) {
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"放弃上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [photoAction setValue:RGB_COLOR(@"#FF6262", 1) forKey:@"_titleTextColor"];
        [alertContro addAction:photoAction];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [cancleAction setValue:color96 forKey:@"_titleTextColor"];
        [alertContro addAction:cancleAction];
        
        [self presentViewController:alertContro animated:YES completion:nil];

    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)rightBtnClick{
    if (!selectImage) {
        [MBProgressHUD showError:@"请选择照片"];
        return;
    }
    [MBProgressHUD showMessage:@"正在上传"];
    [YBToolClass postNetworkWithUrl:@"Upload.GetQiniuToken" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic =  [info firstObject];
            NSString *qntoken = [NSString stringWithFormat:@"%@",[infoDic valueForKey:@"token"]];
            [self uploadqn:qntoken];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
            self.rightBtn.enabled = YES;
        }
        
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络连接断开，视频上传失败"];
        self.rightBtn.enabled = YES;
    }];

}
- (void)uploadqn:(NSString *)token{
    WeakSelf;
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        
    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    //获取视频和图片
    NSData *imageData = UIImagePNGRepresentation(selectImage);
    NSString *imageName = [YBToolClass getNameBaseCurrentTime:@".png"];
    //传图片
    [upManager putData:imageData key:[NSString stringWithFormat:@"image_%@",imageName] token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        if (info.ok) {
            //图片成功
            [weakSelf uploadimagesuccess:key];
            //传视频
        }
        else {
            [MBProgressHUD hideHUD];
            //图片失败
            NSLog(@"%@",info.error);
            [MBProgressHUD showError:@"上传失败"];
            self.rightBtn.enabled = YES;
        }
    } option:option];

}
- (void)uploadimagesuccess:(NSString *)thumb{
    NSMutableDictionary *pullDic = @{
                                     @"uid":[Config getOwnID],
                                     @"thumb":thumb,
                                     @"isprivate":@(_coastSwitch.on),
                                     }.mutableCopy;
    NSString *sign = [YBToolClass sortString:pullDic];
    [pullDic setObject:sign forKey:@"sign"];
    [pullDic setObject:coastCoinStr forKey:@"coin"];
    
    [YBToolClass postNetworkWithUrl:@"Photo.setPhoto" andParameter:pullDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"上传成功，请等待审核"];
            selectImage = nil;
            [selectImgBtn setImage:[UIImage imageNamed:@"auth_正"] forState:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMinePiclist" object:nil];
            self.rightBtn.enabled = YES;
        }else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
            self.rightBtn.enabled = YES;
        }
        
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络连接断开，视频上传失败"];
        self.rightBtn.enabled = YES;
        
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
