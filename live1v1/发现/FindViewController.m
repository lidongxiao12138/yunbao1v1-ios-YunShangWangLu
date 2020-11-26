//
//  FindViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "FindViewController.h"
#import "UIImage+GIF.h"
#import "roomPayView.h"
#import "MatchViewController.h"
#import <YYWebImage/YYWebImage.h>

@interface FindViewController (){
    UIView *moveView;
    NSMutableArray *btnArray;
    UILabel *msgLabel;
    UILabel *btnTitleLabel;
    roomPayView *payView;
    NSDictionary *infoDic;
    NSString *type;
    UIImageView *gifImageView;
}

@end

@implementation FindViewController
#pragma mark - navi

-(void)returnBtnClick{
    [[MXBADelegate sharedAppDelegate] popViewController:YES];

}
-(void)creatNavi {
    
    UIView *navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];
    
//    UIButton *retrunBtn = [UIButton buttonWithType:0];
//    retrunBtn.frame = CGRectMake(10, 22+statusbarHeight, 30, 30);
//    [retrunBtn setImage:[UIImage imageNamed:@"returnback"] forState:0];
//    [retrunBtn addTarget:self action:@selector(returnBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [navi addSubview:retrunBtn];

    //标题
    
    UILabel *midLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 22+statusbarHeight, 60, 42)];
//    UILabel *midLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(retrunBtn.frame)+10, 22+statusbarHeight, _window_width-40*2, 42)];

    midLabel.backgroundColor = [UIColor clearColor];
    midLabel.font = [UIFont boldSystemFontOfSize:18];
    midLabel.text = @"匹配";
    midLabel.textAlignment = NSTextAlignmentCenter;
    [navi addSubview:midLabel];
    UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(midLabel.width/2-7, 36, 15, 3)];
    lineV.layer.cornerRadius = 1.5;
    lineV.backgroundColor = normalColors;
    [midLabel addSubview:lineV];

    
    //私信
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 63+statusbarHeight, _window_width, 1) andColor:colorf5 andView:navi];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.navigationBar.hidden = YES;
//    self.automaticallyAdjustsScrollViewInsets = NO;

    self.view.backgroundColor = [UIColor whiteColor];
    type = @"1";
    [self creatNavi];
    [self creatUI];

}
- (void)viewWillAppear:(BOOL)animated{
    [self requestData];
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Match.GetMatch" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            infoDic = [info firstObject];
            NSURL *imgUrl;
            if (iPhoneX) {
                if ([minstr([infoDic valueForKey:@"isauth"]) isEqual:@"1"]) {
                    imgUrl = [[NSBundle mainBundle] URLForResource:@"find_anchorX" withExtension:@"gif"];
                }else{
                    imgUrl = [[NSBundle mainBundle] URLForResource:@"find_userX" withExtension:@"gif"];
                }
            }else{
                if ([minstr([infoDic valueForKey:@"isauth"]) isEqual:@"1"]) {
                    imgUrl = [[NSBundle mainBundle] URLForResource:@"find_anchorPipei" withExtension:@"gif"];
                }else{
                    imgUrl = [[NSBundle mainBundle] URLForResource:@"find_userPipei" withExtension:@"gif"];
                }
            }
            gifImageView.yy_imageURL = imgUrl;
            [msgLabel setAttributedText:[self setattstrWithString:[NSString stringWithFormat:@"%@%@/分钟（VIP用户：%@%@/分钟）",minstr([infoDic valueForKey:@"video"]),[common name_coin],minstr([infoDic valueForKey:@"video_vip"]),[common name_coin]]]];

        }
    } fail:^{
        
    }];
}
- (void)creatUI{
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width/2-67, 64+statusbarHeight, 134, 45)];
    imgV.image = [UIImage imageNamed:@"find_topBack"];
    imgV.userInteractionEnabled = YES;
    [self.view addSubview:imgV];
    
    moveView = [[UIView alloc]initWithFrame:CGRectMake(7, 7, 60, 31)];
    moveView.layer.cornerRadius = 15.5;
    moveView.layer.masksToBounds = YES;
    moveView.backgroundColor = normalColors;
    [imgV addSubview:moveView];
    NSArray *array = @[@"视频",@"语音"];
    btnArray = [NSMutableArray array];
    for (int i = 0; i < array.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        [btn setTitle:array[i] forState:0];
        btn.frame = CGRectMake(7+i*60, 7, 60, 31);
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setTitleColor:color32 forState:0];
        if (i == 0) {
            btn.selected = YES;
        }
        [btn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [imgV addSubview:btn];
        [btnArray addObject:btn];
    }
    CGFloat gifWidth = _window_width*0.84;
//    UIImageView *gifImageView = [[UIImageView alloc]initWithFrame:CGRectMake((_window_width - gifWidth)/2, imgV.bottom+5, gifWidth, gifWidth * (iPhoneX ? 1.88 : 1.476))];
    gifImageView = [YYAnimatedImageView new];
    gifImageView.frame = CGRectMake((_window_width - gifWidth)/2, imgV.bottom+5, gifWidth, gifWidth * (iPhoneX ? 1.88 : 1.476));
    gifImageView.userInteractionEnabled = YES;
    [self.view addSubview:gifImageView];
    
    UIButton *startBtn = [UIButton buttonWithType:0];
    [startBtn setImage:[UIImage imageNamed:@"find_匹配按钮"] forState:0];
    [startBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [gifImageView addSubview:startBtn];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(gifImageView);
        make.centerY.equalTo(gifImageView).multipliedBy(iPhoneX ? 1.626 : 1.595);
        make.width.equalTo(gifImageView).multipliedBy(0.285);
        make.height.equalTo(startBtn.mas_width);
    }];
    btnTitleLabel = [[UILabel alloc]init];
    btnTitleLabel.font = SYS_Font(10);
    btnTitleLabel.textColor = [UIColor whiteColor];
    [startBtn addSubview:btnTitleLabel];
    [btnTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(startBtn);
        make.centerY.equalTo(startBtn).multipliedBy(1.4);
    }];
    btnTitleLabel.text = @"一键匹配";
    
    msgLabel = [[UILabel alloc]init];
    msgLabel.font = SYS_Font(10);
    msgLabel.textColor = color32;
    [gifImageView addSubview:msgLabel];
    [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(gifImageView);
        make.top.equalTo(startBtn.mas_bottom);
        make.bottom.equalTo(gifImageView);
    }];
}
- (NSAttributedString *)setattstrWithString:(NSString *)str{
    NSRange range = NSMakeRange([str rangeOfString:@"（"].location+1, [str rangeOfString:@"）"].location-[str rangeOfString:@"（"].location);
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc] initWithString:str];
    [attstr addAttribute:NSForegroundColorAttributeName value:normalColors range:range];
    return attstr;
}
- (void)topBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    for (UIButton *btn in btnArray) {
        if (btn == sender) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    if ([sender.titleLabel.text isEqual:@"视频"]) {
        [msgLabel setAttributedText:[self setattstrWithString:[NSString stringWithFormat:@"%@%@/分钟（VIP用户：%@%@/分钟）",minstr([infoDic valueForKey:@"video"]),[common name_coin],minstr([infoDic valueForKey:@"video_vip"]),[common name_coin]]]];
        type = @"1";
    }else{
        [msgLabel setAttributedText:[self setattstrWithString:[NSString stringWithFormat:@"%@%@/分钟（VIP用户：%@%@/分钟）",minstr([infoDic valueForKey:@"voice"]),[common name_coin],minstr([infoDic valueForKey:@"voice_vip"]),[common name_coin]]]];
        type = @"2";

    }
    [UIView animateWithDuration:0.1 animations:^{
        moveView.centerX = sender.centerX;
    }];
}
#pragma mark ============开始匹配=============
- (void)startBtnClick{
    if ([type isEqual:@"2"]) {
        //语音
        if ([YBToolClass checkAudioAuthorization] == 2) {
            //弹出麦克风权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self callllllllllType];
                    }else{
                        [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                    }
                });
            }];
        }else{
            if ([YBToolClass checkAudioAuthorization] == 1) {
                [self callllllllllType];
            }else{
                [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
                return;
            }
            
        }
    }else{
        if ([YBToolClass checkVideoAuthorization] == 2) {
            //弹出相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self checkYuyinQuanxian];
                    }else{
                        [MBProgressHUD showError:@"未允许摄像头权限，不能视频通话"];
                    }
                });
                
            }];
        }else{
            if ([YBToolClass checkVideoAuthorization] == 1) {
                [self checkYuyinQuanxian];
            }else{
                [MBProgressHUD showError:@"请前往设置中打开摄像头权限"];
            }
        }
    }
    
    //视频
    
    
}
- (void)checkYuyinQuanxian{
    if ([YBToolClass checkAudioAuthorization] == 2) {
        //弹出麦克风权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self callllllllllType];
                }else{
                    [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                }
            });
        }];
    }else{
        if ([YBToolClass checkAudioAuthorization] == 1) {
            [self callllllllllType];
        }else{
            [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
            return;
        }
    }
}
- (void)callllllllllType{

    if (!infoDic) {
        return;
    }
    if (![minstr([infoDic valueForKey:@"isauth"]) isEqual:@"1"]) {
        [MBProgressHUD showMessage:@""];
        [YBToolClass postNetworkWithUrl:@"Match.check" andParameter:@{@"type":type} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [MBProgressHUD hideHUD];
            if (code == 0) {
                [self goMatchVC];
            }else if (code == 1008){
                [self doRechargeView];
            }else{
                [MBProgressHUD showError:msg];
            }
        } fail:^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"网络错误"];
        }];

    }else{
        [self goMatchVC];
    }
}
- (void)goMatchVC{
    MatchViewController *match = [[MatchViewController alloc]init];
    match.type = type;
    match.isauth = minstr([infoDic valueForKey:@"isauth"]);
    match.attStr = msgLabel.attributedText;
    [[MXBADelegate sharedAppDelegate] pushViewController:match animated:YES];
}
- (void)doRechargeView{
    if (!payView) {
        [YBToolClass postNetworkWithUrl:@"Charge.GetBalance" andParameter:@{@"type":@"ios"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSDictionary *infoDic = [info firstObject];
                if (!payView) {
                    payView = [[roomPayView alloc]initWithMsg:infoDic andFrome:2];
                    [self.view addSubview:payView];
                }
                [payView show];
                [[UIApplication sharedApplication].delegate.window addSubview:payView];
            }
        } fail:^{
            
        }];
    }else{
        [payView show];
        [[UIApplication sharedApplication].delegate.window bringSubviewToFront:payView];
        
    }

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
