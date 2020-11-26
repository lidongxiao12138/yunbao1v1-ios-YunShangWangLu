//
//  PreLoginVC.m
//  iphoneLive
//
//  Created by Apple on 2018/11/10.
//  Copyright © 2018 cat. All rights reserved.
//

#import "PreLoginVC.h"
#import "PhoneLoginViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "AppDelegate.h"
#import "YBTabBarController.h"
#import "TUIKit.h"
#import "YSLoginEditeVC.h"
@interface PreLoginVC ()
@property (nonatomic,strong) UIActivityIndicatorView *testActivityIndicator;

@end

@implementation PreLoginVC
{
    UIImageView *_gifImage;
    UIImageView *_logo;
    
    UIButton *_mobileBtn;
    UILabel *_mobileLabel;
    UIButton *_qqBtn;
    UILabel *_qqLabel;
    UIButton *_wechatBtn;
    UILabel *_wechatLabel;
    
    
    
    NSArray *platformsarray;
    
    NSString *_isreg;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    [self createSubviews];
    [self getLoginThird];
    //上下浮动
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat duration = 6.0f;
    animation.duration = duration;
    animation.values = @[@0,@-7.5,@-15,@-22.5,@-30,@-37.5,@-45,@-52.5,@-60,@-67.5,@-75,@-82.5,@-90,@-97.5,@-105,@-112.5,@-120,@-127.5,@-134,@-142.5,@-150,@-157.5,@-165,@-172.5,@-180,@-187.5,@-195,@-202.5,@-210,@-210,@-202.5,@-195,@-187.5,@-180,@-172.5,@-165,@-157.5,@-150,@-142.5,@-134,@-127.5,@-120,@-112.5,@-105,@-97.5,@-90,@-82.5,@-75,@-67.5,@-60,@-52.5,@-45,@-37.5,@-30,@-22.5,@-15,@-7.5,@0];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    [_gifImage.layer addAnimation:animation forKey:@"1111"];
    
}


-(void)getLoginThird{
    [YBToolClass postNetworkWithUrl:@"Login.GetLoginType" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            platformsarray = info;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setthirdview];
            });

        }
    } fail:^{
        
    }];
}
- (void)setthirdview{

    if ([platformsarray containsObject:@"qq"] && [platformsarray containsObject:@"wx"]) {
        //三个按钮都有
        _qqBtn.hidden = NO;
        _qqLabel.hidden = NO;
        _wechatBtn.hidden = NO;
        _wechatLabel.hidden = NO;
        [_mobileBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(0.5);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(self.view).multipliedBy(1.6);
        }];
        [_mobileLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_mobileBtn);
            make.top.equalTo(_mobileBtn.mas_bottom).offset(5);
        }];
        
        [_wechatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(self.view).multipliedBy(1.6);
        }];
        [_wechatLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_wechatBtn);
            make.top.equalTo(_wechatBtn.mas_bottom).offset(5);
        }];
        [_qqBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(1.5);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(_mobileBtn);
        }];
        [_qqLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_qqBtn);
            make.top.equalTo(_qqBtn.mas_bottom).offset(5);
        }];
    }
    else if ([platformsarray containsObject:@"qq"] && ![platformsarray containsObject:@"wx"]){
        _qqBtn.hidden = NO;
        _qqLabel.hidden = NO;
        _wechatBtn.hidden = YES;
        _wechatLabel.hidden = YES;
        [_mobileBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(0.7);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(self.view).multipliedBy(1.6);
        }];
        [_mobileLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_mobileBtn);
            make.top.equalTo(_mobileBtn.mas_bottom).offset(5);
        }];
        [_qqBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(1.3);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(_mobileBtn);
        }];
        [_qqLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_qqBtn);
            make.top.equalTo(_qqBtn.mas_bottom).offset(5);
        }];
        
    }
    else if (![platformsarray containsObject:@"qq"] && [platformsarray containsObject:@"wx"]){
        _qqBtn.hidden = YES;
        _qqLabel.hidden = YES;
        _wechatBtn.hidden = NO;
        _wechatLabel.hidden = NO;
        [_mobileBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(0.7);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(self.view).multipliedBy(1.6);
        }];
        [_mobileLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_mobileBtn);
            make.top.equalTo(_mobileBtn.mas_bottom).offset(5);
        }];
        [_wechatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(1.3);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(self.view).multipliedBy(1.6);
        }];
        [_wechatLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_wechatBtn);
            make.top.equalTo(_wechatBtn.mas_bottom).offset(5);
        }];
    }
    else{
        _qqBtn.hidden = YES;
        _qqLabel.hidden = YES;
        _wechatBtn.hidden = YES;
        _wechatLabel.hidden = YES;
        [_mobileBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(self.view).multipliedBy(1.6);
        }];
        [_mobileLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_mobileBtn);
            make.top.equalTo(_mobileBtn.mas_bottom).offset(5);
        }];
    }
}
- (void)createSubviews{
    [self.navigationController setNavigationBarHidden:YES];
    _gifImage = ({
        UIImageView *image = [[UIImageView alloc] init];
        image.frame = CGRectMake(0, 0, _window_width, _window_height + 300);
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.image = [UIImage imageNamed:@"登录静态"];
//        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"登录" ofType:@"gif"]];
//        [image sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"登录静态"]];
        [self.view addSubview:image];
        image;
    });
    _logo = ({
        UIImageView *image = [[UIImageView alloc] init];
        image.image = [UIImage imageNamed:@"logo"];
        image.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:image];
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        image;
    });
    _mobileBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"login_手机"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(mobileLogin) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(self.view).multipliedBy(1.6);
        }];
        btn;
    });
    _mobileLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"手机登录";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_mobileBtn);
            make.top.equalTo(_mobileBtn.mas_bottom);
        }];
        label;
    });
    
    _wechatBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"login_微信"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(wechatLogin) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(self.view).multipliedBy(1.6);
        }];
        btn;
    });
    _wechatLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"微信登录";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_wechatBtn);
            make.top.equalTo(_wechatBtn.mas_bottom);
        }];
        label;
    });
    
    _qqBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"login_qq"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(qqLogin) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view).multipliedBy(1.5);
            make.size.mas_equalTo(CGSizeMake(_window_width / 6, _window_width / 6));
            make.centerY.equalTo(_mobileBtn);
        }];
        btn;
    });
    _qqLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"QQ登录";
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_qqBtn);
            make.top.equalTo(_qqBtn.mas_bottom);
        }];
        label;
    });
    
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backBtn setImage:[UIImage imageNamed:@"navi_backImg"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBtn];
//    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(20 + statusbarHeight);
//        make.left.equalTo(self.view).offset(10);
//        make.size.mas_equalTo(CGSizeMake(50, 50));
//    }];
    
    CGFloat xbottom;
    if (@available(iOS 11.0, *)) {
        xbottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    } else {
        xbottom = 0;
    }
    NSString *xieyiStr = [NSString stringWithFormat:@"《%@平台协议》",protocolName];

    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"登录即代表同意%@",xieyiStr];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(- 10 - xbottom);
    }];
    NSRange range = [label.text rangeOfString:xieyiStr];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    [str addAttribute:NSForegroundColorAttributeName value:normalColors range:range];
    label.attributedText = str;
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eula)];
    [label addGestureRecognizer:tap];
    
    _qqBtn.hidden = YES;
    _qqLabel.hidden = YES;
    _wechatBtn.hidden = YES;
    _wechatLabel.hidden = YES;
    [self.view layoutIfNeeded];
    [self setlogoImage];
}
- (void)mobileLogin{
    PhoneLoginViewController *nl = [[PhoneLoginViewController alloc] init];
    [self.navigationController pushViewController:nl animated:YES];
}
- (void)qqLogin{
    [ShareSDK cancelAuthorize:SSDKPlatformTypeQQ result:nil];
    [self indicator];
    [self login:@"1" platforms:SSDKPlatformTypeQQ];
}
- (void)wechatLogin{
    [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat result:nil];
    [self indicator];
    [self login:@"2" platforms:SSDKPlatformTypeWechat];
}

- (void)indicator{
    _testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _testActivityIndicator.center = CGPointMake(_window_width/2 - 10, _window_height/2 - 10);
    [self.view addSubview:_testActivityIndicator];
    _testActivityIndicator.color = [UIColor whiteColor];
}
- (void)eula{
    YBWebViewController *VC = [[YBWebViewController alloc]init];
    NSString *paths = [h5url stringByAppendingString:@"/appapi/page/detail?id=1"];
    VC.urls = paths;
    [self.navigationController pushViewController:VC animated:YES];
}
//-------------------
-(void)RequestLogin:(SSDKUser *)user LoginType:(NSString *)LoginType
{
    NSString *icon = nil;
    if ([LoginType isEqualToString:@"1"]) {
        icon = [user.rawData valueForKey:@"figureurl_qq_2"];
    }
    else
    {
        icon = user.icon;
    }
    NSString *unionid;
    if ([LoginType isEqual:@"2"]) {
        unionid = [user.rawData valueForKey:@"unionid"];
    }
    else{
        unionid = user.uid;
    }
    if (!icon) {
        [MBProgressHUD showError:@"未获取到授权，请重试"];
        return;
    }
    NSString *sign = [NSString stringWithFormat:@"openid=%@&400d069a791d51ada8af3e6c2979bcd7",unionid];

    NSDictionary *dic = @{
                          @"openid":[self encodeString:unionid],
                          @"type":[self encodeString:LoginType],
                          @"nicename":[self encodeString:user.nickname],
                          @"avatar":[self encodeString:icon],
                          @"source":@"ios",
                          @"sign":[[YBToolClass sharedInstance] md5:sign],
                          @"pushid":@"",
                          };
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Login.userLoginByThird" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [weakSelf.testActivityIndicator stopAnimating]; // 结束旋转
        [weakSelf.testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            LiveUser *userInfo = [[LiveUser alloc] initWithDic:dic];
            [Config saveProfile:userInfo];
            [self IMLogin];
            
            [weakSelf checkUserInfo];
//            UIApplication *app =[UIApplication sharedApplication];
//            AppDelegate *app2 = (AppDelegate *)app.delegate;
//            YBTabBarController *tabbarV = [[YBTabBarController alloc]init];
//            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:tabbarV];
//            app2.window.rootViewController = nav;

        }else{
            [MBProgressHUD showError:msg];
        }

    } fail:^{
        [weakSelf.testActivityIndicator stopAnimating]; // 结束旋转
        [weakSelf.testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏

    }];
}
-(void)checkUserInfo {
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"User.checkEditStatus" andParameter:@{} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSString *statusStr = minstr([[info firstObject] valueForKey:@"status"]);
            if ([statusStr isEqual:@"0"]) {
                YSLoginEditeVC *yslVC = [[YSLoginEditeVC alloc]init];
                yslVC.isPhone = NO;
                [[MXBADelegate sharedAppDelegate]pushViewController:yslVC animated:YES];
            }else {
                UIApplication *app =[UIApplication sharedApplication];
                AppDelegate *app2 = (AppDelegate *)app.delegate;
                YBTabBarController *tabbarV = [[YBTabBarController alloc]init];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:tabbarV];
                app2.window.rootViewController = nav;
            }
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
    
}

//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    NSString *url = [purl stringByAppendingFormat:@"/?service=Login.userLoginByThird"];
//    [session POST:url parameters:@{
//                                   @"openid":[self encodeString:unionid],
//                                   @"type":[self encodeString:LoginType],
//                                   @"nicename":[self encodeString:user.nickname],
//                                   @"avatar":[self encodeString:icon],
//                                   }
//         progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//             NSNumber *number = [responseObject valueForKey:@"ret"] ;
//             if([number isEqualToNumber:[NSNumber numberWithInt:200]])
//             {
//                 NSArray *data = [responseObject valueForKey:@"data"];
//                 NSNumber *code = [data valueForKey:@"code"];
//                 if([code isEqualToNumber:[NSNumber numberWithInt:0]])
//                 {
//                     NSDictionary *info = [[data valueForKey:@"info"] firstObject];
//                     LiveUser *userInfo = [[LiveUser alloc] initWithDic:info];
//                     [Config saveProfile:userInfo];
//                     [self LoginJM];
//                     //判断第一次登陆
//                     NSString *isreg = minstr([info valueForKey:@"isreg"]);
//                     _isreg = isreg;
//                     [self heartbeats];
//                     if ([minstr([info valueForKey:@"mobile"]) length] > 1) {
//                         [self login];
//                     }else{
//                         [self qubangding];
//                     }
//
//                 }
//                 else{
//                     [MBProgressHUD showError:[data valueForKey:@"msg"]];
//                 }
//             }
//             [_testActivityIndicator stopAnimating]; // 结束旋转
//             [_testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
//         }
//          failure:^(NSURLSessionDataTask *task, NSError *error)
//     {
//         [MBProgressHUD showError:@"请重试"];
//         [_testActivityIndicator stopAnimating]; // 结束旋转
//         [_testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
//     }];
//}
//- (void)heartbeats{
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
////    [delegate onlineTimer];
//}
//- (void)login{
//    [self getConfig];
//    [self dismissViewControllerAnimated:YES completion:nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"getBonus" object:nil];
//}
- (void)IMLogin{
    [[TUIKit sharedInstance] loginKit:[Config getOwnID] userSig:[Config lgetUserSign] succ:^{
        NSLog(@"IM登录成功");
    } fail:^(int code, NSString *msg) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"code:%d msdg:%@ ,请检查 sdkappid,identifier,userSig 是否正确配置",code,msg] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
//        [alert show];
    }];
}

-(NSString*)encodeString:(NSString*)unencodedString{
    NSString*encodedString=(NSString*)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}
-(void)login:(NSString *)types platforms:(SSDKPlatformType)platform{

    WeakSelf;
    [_testActivityIndicator startAnimating]; // 开始旋转
    [ShareSDK getUserInfo:platform
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {

             NSLog(@"uid=%@",user.uid);
             NSLog(@"%@",user.credential);
             NSLog(@"token=%@",user.credential.token);
             NSLog(@"nickname=%@",user.nickname);
             [self RequestLogin:user LoginType:types];

         } else if (state == 2 || state == 3) {
             [weakSelf.testActivityIndicator stopAnimating]; // 结束旋转
             [weakSelf.testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
         }

     }];
}
- (void)dealloc{
    NSLog(@"b dealloc");
}
//-(void)getConfig{
//    //在这里加载后台配置文件
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    NSString *url = [purl stringByAppendingFormat:@"?service=Home.getConfig"];
//    [session POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSNumber *number = [responseObject valueForKey:@"ret"] ;
//        if([number isEqualToNumber:[NSNumber numberWithInt:200]])
//        {
//            NSArray *data = [responseObject valueForKey:@"data"];
//            NSNumber *code = [data valueForKey:@"code"];
//            if([code isEqualToNumber:[NSNumber numberWithInt:0]])
//            {
//                NSDictionary *subdic = [[data valueForKey:@"info"] firstObject];
////                liveCommon *commons = [[liveCommon alloc]initWithDic:subdic];
////                [common saveProfile:commons];
//            }
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//    }];
//}
- (void)setlogoImage{
    UIImage * image1 = [UIImage imageNamed:@"logo"];
    UIImage * image2 = [YBToolClass getAppIcon];
    CGSize size = image1.size;
    UIGraphicsBeginImageContext(size);
    [image1 drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [image2 drawInRect:CGRectMake(305, 236, 140, 140)];
    UIImage *resultingImage =UIGraphicsGetImageFromCurrentImageContext();
    _logo.image = resultingImage;
    UIGraphicsEndImageContext();
    
}
@end
