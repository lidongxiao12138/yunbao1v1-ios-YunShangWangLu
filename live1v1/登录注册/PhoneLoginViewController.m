//
//  PhoneLoginViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/3/29.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "PhoneLoginViewController.h"
#import "YBTabBarController.h"
#import "AppDelegate.h"
#import "TUIKit.h"
#import "YSLoginEditeVC.h"
@interface PhoneLoginViewController (){
    UILabel *countryNumL;
    UITextField *phoneNumT;
    UITextField *codeNumT;
    UIButton *codeBtn;
    NSTimer *codeTimer;
    int countt;
    UIButton *submitBtn;
}

@end

@implementation PhoneLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeBtnBackground) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)creatUI{
    UILabel *logoLabel = [[UILabel alloc]init];
    logoLabel.font = SYS_Font(20);
    logoLabel.text = @"登录后体验更多精彩瞬间！";
    logoLabel.textColor = color32;
    [self.view addSubview:logoLabel];
    [logoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(60+statusbarHeight+64);
    }];
    UIView *view1 = [[UIView alloc]init];
    view1.backgroundColor = colorf5;
    view1.layer.cornerRadius = 20;
    view1.layer.masksToBounds = YES;
    [self.view addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(logoLabel.mas_bottom).offset(33);
        make.width.equalTo(self.view).multipliedBy(0.9);
        make.height.mas_equalTo(40);
    }];
    UILabel *countryNumLl = [[UILabel alloc]init];
    countryNumLl.textColor = RGB_COLOR(@"#646464", 1);
    countryNumLl.textAlignment = NSTextAlignmentCenter;
    countryNumLl.text = @"+86";
    countryNumLl.font = SYS_Font(15);
    [view1 addSubview:countryNumLl];
    countryNumL = countryNumLl;
    [countryNumLl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(view1);
        make.width.mas_equalTo(55);
    }];
    UIImageView *arrowImgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_arrow"]];
    [view1 addSubview:arrowImgV];
    [arrowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(countryNumLl);
        make.left.equalTo(countryNumLl.mas_right);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(8);
    }];
    
    phoneNumT = [[UITextField alloc]init];
    phoneNumT.placeholder = @"输入手机号码";
    phoneNumT.font = SYS_Font(15);
    phoneNumT.keyboardType = UIKeyboardTypeNumberPad;
    [view1 addSubview:phoneNumT];
    [phoneNumT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(countryNumLl);
        make.left.equalTo(arrowImgV.mas_right).offset(10);
        make.height.equalTo(view1);
        make.right.equalTo(view1).offset(-20);
    }];
    
    UIView *view2 = [[UIView alloc]init];
    view2.backgroundColor = colorf5;
    view2.layer.cornerRadius = 20;
    view2.layer.masksToBounds = YES;
    [self.view addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(view1.mas_bottom).offset(15);
        make.width.height.equalTo(view1);
    }];
    
    UITextField *codeT = [[UITextField alloc]init];
    codeT.placeholder = @"输入验证码";
    codeT.font = SYS_Font(15);
    codeT.keyboardType = UIKeyboardTypeNumberPad;
    [view2 addSubview:codeT];
    codeNumT = codeT;
    [codeT mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(view2);
        make.left.equalTo(view2).offset(18);
        make.width.equalTo(view2).multipliedBy(0.5);
    }];
    
    UIButton *codeButton = [UIButton buttonWithType:0];
    [codeButton setTitle:@"获取验证码" forState:0];
    [codeButton setTitleColor:color32 forState:0];
    codeButton.titleLabel.font = SYS_Font(13);
    [codeButton addTarget:self action:@selector(codeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:codeButton];
    codeBtn = codeButton;
    
    [codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(view2);
        make.width.mas_equalTo(100);
    }];

    submitBtn = [UIButton buttonWithType:0];
    [submitBtn setTitle:@"立即登录" forState:0];
    submitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [submitBtn setBackgroundColor:normalColors];
    submitBtn.userInteractionEnabled = NO;
    submitBtn.layer.cornerRadius = 20;
    submitBtn.layer.masksToBounds = YES;
    [self.view addSubview:submitBtn];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(view2.mas_bottom).offset(30);
        make.width.height.equalTo(view1);
    }];

    CGFloat xbottom;
    if (@available(iOS 11.0, *)) {
        xbottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    } else {
        xbottom = 0;
    }
    NSString *xieyiStr = [NSString stringWithFormat:@"《%@私聊APP协议》",protocolName];

    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"登录即代表同意%@",xieyiStr];
    label.textColor = color32;
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

}
#pragma mark ============获取验证码=============

- (void)codeBtnClick{
    if (phoneNumT.text.length != 11) {
        [MBProgressHUD showError:@"请输入正确的手机号码"];
        return;
    }
    codeBtn.userInteractionEnabled = NO;
    NSString *sign = [NSString stringWithFormat:@"mobile=%@&400d069a791d51ada8af3e6c2979bcd7",phoneNumT.text];
    [YBToolClass postNetworkWithUrl:@"Login.GetCode" andParameter:@{@"mobile":phoneNumT.text,@"sign":[[YBToolClass sharedInstance] md5:sign]} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        if (code == 0) {
            [codeNumT becomeFirstResponder];
            countt = 60;
            if (!codeTimer) {
                codeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(daojishi) userInfo:nil repeats:YES];
            }
        }else{
            codeBtn.userInteractionEnabled = YES;
        }
    } fail:^{
        codeBtn.userInteractionEnabled = YES;
    }];
}
- (void)daojishi{
    [codeBtn setTitle:[NSString stringWithFormat:@"%ds",countt] forState:UIControlStateNormal];
    if (countt<=0) {
        [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        codeBtn.userInteractionEnabled = YES;
        [codeTimer invalidate];
        codeTimer = nil;
        countt = 60;
    }
    countt-=1;

}
- (void)doReturn{
    
    if (codeTimer) {
        [codeTimer invalidate];
        codeTimer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ============立即登录=============

- (void)submitBtnClick{

    WeakSelf;
    [MBProgressHUD showMessage:@"正在登录"];
    [YBToolClass postNetworkWithUrl:@"Login.UserLogin" andParameter:@{@"user_login":phoneNumT.text,@"code":codeNumT.text,@"source":@"ios",@"pushid":@""} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            LiveUser *userInfo = [[LiveUser alloc] initWithDic:dic];
            [Config saveProfile:userInfo];
            [self IMLogin];
//            UIApplication *app =[UIApplication sharedApplication];
//            AppDelegate *app2 = (AppDelegate *)app.delegate;
//            YBTabBarController *tabbarV = [[YBTabBarController alloc]init];
//            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:tabbarV];
//            app2.window.rootViewController = nav;
            [weakSelf checkUserInfo];
        }else{
            [MBProgressHUD showError:msg];
        }

    } fail:^{
        [MBProgressHUD hideHUD];
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
                yslVC.isPhone = YES;
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
#pragma mark ============输入变化通知=============

- (void)ChangeBtnBackground{
    if (phoneNumT.text.length == 11 && codeNumT.text.length > 0) {
        submitBtn.userInteractionEnabled = YES;
    }else{
        submitBtn.userInteractionEnabled = NO;
    }
}
#pragma mark ============隐私协议=============

- (void)eula{
    YBWebViewController *VC = [[YBWebViewController alloc]init];
    NSString *paths = [h5url stringByAppendingString:@"/appapi/page/detail?id=1"];
    VC.urls = paths;
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark ============IM=============

- (void)IMLogin{
    [[TUIKit sharedInstance] loginKit:[Config getOwnID] userSig:[Config lgetUserSign] succ:^{
        NSLog(@"IM登录成功");
    } fail:^(int code, NSString *msg) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"code:%d msdg:%@ ,请检查 sdkappid,identifier,userSig 是否正确配置",code,msg] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
//        [alert show];
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
