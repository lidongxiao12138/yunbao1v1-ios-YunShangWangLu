//
//  YSLoginEditeVC.m
//  live1v1
//
//  Created by YB007 on 2019/10/23.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "YSLoginEditeVC.h"

#import "MyTextField.h"
#import <Qiniu/QiniuSDK.h>
#import "AppDelegate.h"
#import "YBTabBarController.h"
@import CoreLocation;

@interface YSLoginEditeVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate>
{
    int _sexType;
    BOOL _selIcon;
    UIImage *_selImg;
}
@property(nonatomic,strong)UIScrollView *bgScrollView;

@property(nonatomic,strong)UIButton *iconBtn;
@property(nonatomic,strong)MyTextField *nameTF;
@property(nonatomic,strong)UIButton *sexWomenBtn;
@property(nonatomic,strong)UIButton *sexMenBtn;
@property(nonatomic,strong)UILabel *cityL;

@property(nonatomic,strong)UIButton *finishBtn;

@property (nonatomic,strong) CLLocationManager *lbsManager;

@end

@implementation YSLoginEditeVC

#pragma mark ============定位=============
- (void)stopLbs {
    [_lbsManager stopUpdatingHeading];
    _lbsManager.delegate = nil;
    _lbsManager = nil;
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        liveCity *city = [cityDefault myProfile];
        city.city = @"好像在火星";
        _cityL.text = minstr(city.city);
        [cityDefault saveProfile:city];
        
        [self updateUserLocationWithLatitude:@"" andLongitude:@""];
        [self stopLbs];
        
    } else {
        [_lbsManager startUpdatingLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    liveCity *city = [cityDefault myProfile];
    city.city = @"好像在火星";
    _cityL.text = minstr(city.city);
    [cityDefault saveProfile:city];
    
    [self updateUserLocationWithLatitude:@"" andLongitude:@""];
    [self stopLbs];
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocatioin = locations[0];
    NSString *latitude = [NSString stringWithFormat:@"%f",newLocatioin.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",newLocatioin.coordinate.longitude];
    for (CLLocation *location in locations) {
        // 根据获取到的location实例，反编译地理位置信息
        [self reverseGeocodeWithLocation:location];
    }
    
    [self updateUserLocationWithLatitude:latitude andLongitude:longitude];
    [self stopLbs];
}
// 反编译地理信息
- (void) reverseGeocodeWithLocation:(CLLocation *) location {
    
    if (!location) {
        return ;
    }
    CLGeocoder *coder = [[CLGeocoder alloc]init];
    [coder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (placemarks && placemarks.count > 0) {
            CLPlacemark *mark = [placemarks firstObject];
            
            // 地级市/直辖市
            NSLog(@"locality %@", mark.locality);
            liveCity *city = [cityDefault myProfile];
            city.city = mark.locality;
            _cityL.text = minstr(city.city);
            [cityDefault saveProfile:city];
            
        }
    }];
    
}
- (void)updateUserLocationWithLatitude:(NSString *)latitude andLongitude:(NSString *)longitude{
    liveCity *city = [cityDefault myProfile];
    city.lat = latitude;
    city.lng = longitude;
    _cityL.text = minstr(city.city);
    [cityDefault saveProfile:city];
    [YBToolClass postNetworkWithUrl:[NSString stringWithFormat:@"User.SetLocal&lat=%@&lng=%@",latitude,longitude] andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        
    } fail:^{
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"编辑资料";
    _sexType = 0;
    _selIcon = NO;
    
    [self.view addSubview:self.bgScrollView];
    
    if (_isPhone == NO) {
        //三方登陆的
        [_iconBtn sd_setImageWithURL:[NSURL URLWithString:[Config getavatar]] forState:0];
        _selIcon = YES;
        _nameTF.text = minstr([Config getOwnNicename]);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shajincheng) name:@"shajincheng" object:nil];
    
    
    // 支持定位才开启lbs
    if (!_lbsManager)
    {
        _lbsManager = [[CLLocationManager alloc] init];
        [_lbsManager setDesiredAccuracy:kCLLocationAccuracyBest];
        _lbsManager.delegate = self;
        // 兼容iOS8定位
        SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [_lbsManager respondsToSelector:requestSelector]) {
            [_lbsManager requestWhenInUseAuthorization];//调用了这句,就会弹出允许框了.
        } else {
            [_lbsManager startUpdatingLocation];
        }
    }
    
}
-(void)shajincheng {
    [[YBToolClass sharedInstance] quitLogin];
}
- (UIScrollView *)bgScrollView {
    if (!_bgScrollView) {
        
        _bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight)];
        
        _bgScrollView.backgroundColor = UIColor.whiteColor;
        _bgScrollView.contentInset = UIEdgeInsetsMake(0, 0, ShowDiff, 0);
        
        _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iconBtn setImage:[UIImage imageNamed:@"头像-默认"] forState:0];
        [_iconBtn addTarget:self action:@selector(clickIconBtn) forControlEvents:UIControlEventTouchUpInside];
        [_bgScrollView addSubview:_iconBtn];
        _iconBtn.layer.cornerRadius = 40;
        _iconBtn.layer.masksToBounds = YES;
        [_iconBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
        _iconBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        _iconBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [_iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bgScrollView.mas_top).offset(30);
            make.width.height.mas_equalTo(80);
            make.centerX.equalTo(_bgScrollView);
        }];
        
        UILabel *desL = [[UILabel alloc]init];
        desL.text = @"点击设置头像";
        desL.font = SYS_Font(10);
        desL.textColor = RGB_COLOR(@"#969696", 1);
        [_bgScrollView addSubview:desL];
        [desL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconBtn.mas_bottom).offset(17.5);
            make.centerX.equalTo(_iconBtn);
        }];
        
        UILabel *nameDesL = [[UILabel alloc]init];
        nameDesL.text = @"昵称";
        nameDesL.textColor = RGB_COLOR(@"#323232", 1);
        nameDesL.font = [UIFont boldSystemFontOfSize:13];
        [_bgScrollView addSubview:nameDesL];
        [nameDesL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(desL.mas_bottom).offset(33);
            make.left.equalTo(_bgScrollView.mas_left).offset(37.5);
        }];
        
        _nameTF = [[MyTextField alloc]init];
        _nameTF.textColor = RGB_COLOR(@"#323232", 1);
        _nameTF.font = SYS_Font(15);
        _nameTF.placeCol = RGB_COLOR(@"#969696", 1);
        _nameTF.placeholder = @"请设置昵称";
        [_nameTF addTarget:self action:@selector(nameTFChange) forControlEvents:UIControlEventEditingChanged];
        [_bgScrollView addSubview:_nameTF];
        [_nameTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(_window_width-37.5*2);
            make.centerX.equalTo(_bgScrollView);
            make.top.equalTo(nameDesL.mas_bottom).offset(16);
            make.height.equalTo(@20);
        }];
        
        UILabel *lineL = [[UILabel alloc]init];
        lineL.backgroundColor = RGB_COLOR(@"#dcdcdc", 1);
        [_bgScrollView addSubview:lineL];
        [lineL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_nameTF);
            make.height.mas_equalTo(1);
            make.top.equalTo(_nameTF.mas_bottom).offset(7.5);
        }];
        
        UILabel *sexDesL = [[UILabel alloc]init];
        sexDesL.text = @"性别（性别已经选择后不可更改）";
        sexDesL.textColor = RGB_COLOR(@"#969696", 1);
        sexDesL.font = nameDesL.font;
        [_bgScrollView addSubview:sexDesL];
        
        NSMutableAttributedString *attStr=[[NSMutableAttributedString alloc]initWithString:sexDesL.text];
        [attStr addAttribute:NSForegroundColorAttributeName value:RGB_COLOR(@"#323232", 1) range:NSMakeRange(0, 2)];
        sexDesL.attributedText = attStr;
        
        [sexDesL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineL.mas_bottom).offset(40);
            make.left.equalTo(nameDesL);
        }];
        
        _sexWomenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sexWomenBtn setImage:[UIImage imageNamed:@"screen_女_nor"] forState:0];
        [_sexWomenBtn setTitleColor:RGB_COLOR(@"#969696", 1) forState:0];
        [_sexWomenBtn setImage:[UIImage imageNamed:@"screen_女_sel"] forState:UIControlStateSelected];
        [_sexWomenBtn setTitleColor:normalColors forState:UIControlStateSelected];
        [_sexWomenBtn addTarget:self action:@selector(clickSexWomenBtn) forControlEvents:UIControlEventTouchUpInside];
        [_sexWomenBtn setTitle:@"女" forState:0];
        _sexWomenBtn.titleLabel.font = SYS_Font(11);
        [_bgScrollView addSubview:_sexWomenBtn];
        [_sexWomenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(70);
            make.top.equalTo(sexDesL.mas_bottom).offset(26.5);
            make.left.equalTo(_bgScrollView).offset(25);
        }];
        
        _sexMenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sexMenBtn setImage:[UIImage imageNamed:@"screen_男_nor"] forState:0];
        [_sexMenBtn setTitleColor:RGB_COLOR(@"#969696", 1) forState:0];
        [_sexMenBtn setImage:[UIImage imageNamed:@"screen_男_sel"] forState:UIControlStateSelected];
        [_sexMenBtn setTitleColor:normalColors forState:UIControlStateSelected];
        [_sexMenBtn addTarget:self action:@selector(clickSexMenBtn) forControlEvents:UIControlEventTouchUpInside];
        [_sexMenBtn setTitle:@"男" forState:0];
        _sexMenBtn.titleLabel.font = SYS_Font(11);
        [_bgScrollView addSubview:_sexMenBtn];
        [_sexMenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.centerY.equalTo(_sexWomenBtn);
            make.left.equalTo(_sexWomenBtn.mas_right).offset(40);
        }];
        
        UILabel *cityDesL = [[UILabel alloc]init];
        cityDesL.text = @"所在城市";
        cityDesL.textColor = nameDesL.textColor;
        cityDesL.font = nameDesL.font;
        [_bgScrollView addSubview:cityDesL];
        [cityDesL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameDesL);
            make.top.equalTo(_sexWomenBtn.mas_bottom).offset(20);
        }];
        
        _cityL = [[UILabel alloc]init];
        _cityL.textColor = RGB_COLOR(@"#323232", 1);
        _cityL.font = [UIFont boldSystemFontOfSize:15];
        _cityL.text = [YBToolClass checkNull:[cityDefault getMyCity]]?@"好像在火星":[cityDefault getMyCity];
        [_bgScrollView addSubview:_cityL];
        [_cityL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cityDesL);
            make.top.equalTo(cityDesL.mas_bottom).offset(16);
        }];
        
        UILabel *lineL1 = [[UILabel alloc]init];
        lineL1.backgroundColor = RGB_COLOR(@"#dcdcdc", 1);
        [_bgScrollView addSubview:lineL1];
        [lineL1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_nameTF);
            make.height.mas_equalTo(1);
            make.top.equalTo(_cityL.mas_bottom).offset(7.5);
        }];
        
        
        _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishBtn setTitle:@"完成" forState:0];
        [_finishBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
        [_finishBtn addTarget:self action:@selector(clickFinishBtn) forControlEvents:UIControlEventTouchUpInside];
        [_bgScrollView addSubview:_finishBtn];
        _finishBtn.layer.cornerRadius = 20;
        _finishBtn.layer.masksToBounds = YES;
        _finishBtn.userInteractionEnabled = NO;
        [_finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_bgScrollView).multipliedBy(0.8);
            make.centerX.equalTo(_bgScrollView.mas_centerX);
            make.top.equalTo(lineL1.mas_bottom).offset(51);
            make.height.mas_equalTo(40);
        }];
        
        [_bgScrollView layoutIfNeeded];
        
        _sexMenBtn = [YBToolClass setUpImgDownText:_sexMenBtn];
        _sexWomenBtn = [YBToolClass setUpImgDownText:_sexWomenBtn];
        
        CGFloat maxY = CGRectGetMaxY(_finishBtn.frame);
        if (maxY<=_window_height-64-statusbarHeight) {
            maxY = _window_height-64-statusbarHeight;
        }
        _bgScrollView.contentSize = CGSizeMake(0, maxY);
        
    }
    return _bgScrollView;
}
-(void)clickIconBtn {
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
    imagePickerController.allowsEditing = YES;
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
        UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        _selImg = image;
        _selIcon = YES;
        [_iconBtn setImage:image forState:UIControlStateNormal];
        [self checkFinshi];
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

-(void)nameTFChange {
    [self checkFinshi];
}
-(void)clickSexWomenBtn {
    _sexType = 2;
    _sexWomenBtn.selected = YES;
    _sexMenBtn.selected = NO;
    [self checkFinshi];
}
-(void)clickSexMenBtn {
    _sexType = 1;
    _sexWomenBtn.selected = NO;
    _sexMenBtn.selected = YES;
    [self checkFinshi];
}

-(void)checkFinshi {
    if (_selIcon && _nameTF.text.length>0 && _sexType>0) {
        _finishBtn.userInteractionEnabled = YES;
        [_finishBtn setBackgroundColor:normalColors];
    }else {
        _finishBtn.userInteractionEnabled = NO;
        [_finishBtn setBackgroundColor:RGB_COLOR(@"#dcdcdc", 1)];
    }
}

-(void)clickFinishBtn {
    WeakSelf;
    if (_selImg) {
        [MBProgressHUD showMessage:@""];
        [YBToolClass postNetworkWithUrl:@"Upload.GetQiniuToken" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSString *token = minstr([[info firstObject] valueForKey:@"token"]);
                [weakSelf uploadPicToQiNiu:token];
            }else{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"提交失败"];
            }
        } fail:^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"提交失败"];
        }];
        
    }else{
        //三方登陆
        [self uploadEditMessage:[Config getavatar]];
    }
    
}

- (void)uploadPicToQiNiu:(NSString *)token{
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        
    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    //获取视频和图片
    NSData *imageData = UIImagePNGRepresentation(_selImg);
    NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"userHeader.png"];
    [upManager putData:imageData key:[NSString stringWithFormat:@"image_%@",imageName] token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            [self uploadEditMessage:key];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"提交失败"];
            return ;
        }
    } option:option];
    
}
- (void)uploadEditMessage:(NSString *)headerName{
    [YBToolClass postNetworkWithUrl:[NSString stringWithFormat:@"User.regUpdateInfo&name=%@&sex=%d&city=%@",_nameTF.text,_sexType,_cityL.text] andParameter:@{@"avatar":minstr(headerName)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSString *avatar = minstr([infoDic valueForKey:@"avatar"]);
            NSString *avatar_thumb = minstr([infoDic valueForKey:@"avatar_thumb"]);
            NSString *user_nickname = minstr([infoDic valueForKey:@"user_nickname"]);
            NSString *sexStr = minstr([infoDic valueForKey:@"sex"]);
            LiveUser *user = [[LiveUser alloc]init];
            user.avatar = avatar;
            user.avatar_thumb = avatar_thumb;
            user.user_nickname = user_nickname;
            user.sex = sexStr;
            [Config updateProfile:user];
            
            UIApplication *app =[UIApplication sharedApplication];
            AppDelegate *app2 = (AppDelegate *)app.delegate;
            YBTabBarController *tabbarV = [[YBTabBarController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:tabbarV];
            app2.window.rootViewController = nav;
        }
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:msg];
    } fail:^{
        [MBProgressHUD hideHUD];
        
    }];
}






@end
