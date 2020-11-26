//
//  MatchViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/5/10.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MatchViewController.h"
#import "UIImage+GIF.h"
#import "TIMMessage.h"
#import "TIMManager+MsgExt.h"
#import "THeader.h"
#import "IMMessageExt.h"
#import "AnchorViewController.h"
#import <YYWebImage/YYWebImage.h>

@interface MatchViewController (){
    UILabel *userMatchLabel;
    BOOL isTime;
    int timeCount;
    NSTimer *timer;
    YBAlertView *alert;
}

@end

@implementation MatchViewController
- (void)viewWillAppear:(BOOL)animated{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self startMatch];
}
- (void)viewDidDisappear:(BOOL)animated{
    [MBProgressHUD hideHUD];
}
- (void)startMatch{
    NSString *url;
    if ([_isauth isEqual:@"1"]) {
        url = @"Match.AnchorMatch";
    }else{
        url = @"Match.UserMatch";
    }
    [YBToolClass postNetworkWithUrl:url andParameter:@{@"type":_type} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
        }else{
            [MBProgressHUD showError:msg];
            [self doReturn];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络错误"];
        [self doReturn];
    }];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:nil];
    [self.view addGestureRecognizer:pan];
    
    self.titleL.text = @"匹配";
    self.returnBtn.hidden = YES;
    isTime = NO;
    [self creatUI];
    if (!timer) {
        timeCount = 60;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(daojishi) userInfo:nil repeats:YES];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewMessage:) name:TUIKitNotification_TIMMessageListener object:nil];

}
- (void)creatUI{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*0.08, 64+statusbarHeight+10, _window_width*0.84, _window_height-80-74-statusbarHeight)];
    backView.backgroundColor = RGB_COLOR(@"#E8D6FF", 1);
    backView.layer.cornerRadius = 20.0;
    backView.layer.masksToBounds = YES;
    [self.view addSubview:backView];
    
    UIImageView *gifImgV = [YYAnimatedImageView new];
    NSURL *imgUrl = [[NSBundle mainBundle] URLForResource:@"pipei_wait" withExtension:@"gif"];

    gifImgV.yy_imageURL = imgUrl;
    [backView addSubview:gifImgV];
    [gifImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView);
        make.centerY.equalTo(backView).multipliedBy(0.615);
        make.width.equalTo(backView).multipliedBy(0.76);
        make.height.equalTo(gifImgV.mas_width);
    }];
    userMatchLabel = [[UILabel alloc]init];
    userMatchLabel.font = SYS_Font(12);
    userMatchLabel.textColor = color32;
    userMatchLabel.numberOfLines = 2;
    [backView addSubview:userMatchLabel];
    [userMatchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView);
        make.centerY.equalTo(backView).multipliedBy(1.255);
    }];

    UIButton *closeBtn = [UIButton buttonWithType:0];
    [closeBtn setImage:[UIImage imageNamed:@"pipei_duan"] forState:0];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView);
        make.centerY.equalTo(backView).multipliedBy(1.7);
        make.width.equalTo(backView).multipliedBy(0.158);
        make.height.equalTo(closeBtn.mas_width);
    }];
    UILabel *label = [[UILabel alloc]init];
    label.font = SYS_Font(10);
    [backView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView);
        make.centerY.equalTo(backView).multipliedBy(1.9);
    }];

    if ([_isauth isEqual:@"1"]) {
        label.textColor = [UIColor whiteColor];
    }else{
        userMatchLabel.text = @"正在匹配主播";
        label.textColor = color32;
        label.attributedText = _attStr;
    }

}
- (void)closeBtnClick{
    isTime = NO;
    [self doCloseMatch];
}
- (void)daojishi{
    timeCount--;
    if (timeCount <= 0) {
        [timer invalidate];
        timer = nil;
        isTime = YES;
        [self doCloseMatch];
        [self showAlertView];
    }
    
}
- (void)showAlertView{
    WeakSelf;
    alert = [[YBAlertView alloc]initWithTitle:@"提示" andMessage:@"匹配尚未成功，是否继续匹配" andButtonArrays:@[@"退出",@"继续匹配"] andButtonClick:^(int type) {
        if (type == 2) {
            [weakSelf setMatch];
        }else if (type == 1) {
            [weakSelf doReturn];
        }else{
//            [weakSelf removeAlertView];
        }
    }];
    [self.view addSubview:alert];
}
- (void)setMatch{
    [MBProgressHUD showMessage:@""];
    NSString *url;
    if ([_isauth isEqual:@"1"]) {
        url = @"Match.AnchorMatch";
    }else{
        url = @"Match.UserMatch";
    }
    [YBToolClass postNetworkWithUrl:url andParameter:@{@"type":_type} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            [self removeAlertView];
            if (timer) {
                [timer invalidate];
                timer = nil;
            }
            timeCount = 60;
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(daojishi) userInfo:nil repeats:YES];

        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络错误"];
    }];
}
- (void)removeAlertView{
    if (alert) {
        [alert removeFromSuperview];
        alert = nil;
    }
    
}

- (void)doCloseMatch{
    NSString *url;
    if ([_isauth isEqual:@"1"]) {
        url = @"Match.AnchorCancel";
    }else{
        url = @"Match.UserCancel";
    }
    [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (!isTime) {
            [self doReturn];
        }
    } fail:^{
        if (!isTime) {
            [self doReturn];
        }
    }];

}
- (void)doReturn{
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TUIKitNotification_TIMMessageListener object:nil];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    [super doReturn];
}
- (void)onNewMessage:(NSNotification *)notification
{
    NSArray *msgs = notification.object;
    TIMMessage *msg = [msgs lastObject];
    for (int i = 0; i < msg.elemCount; ++i) {
        TIMElem *elem = [msg getElem:i];
        if([elem isKindOfClass:[TIMCustomElem class]]){
            TIMCustomElem *custom = (TIMCustomElem *)elem;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:custom.data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"收到消息------------------\n%@",jsonDic);
            NSString *method = minstr([jsonDic valueForKey:@"method"]);
            if ([method isEqual:@"call"]) {
                //通话
                int action = [minstr([jsonDic valueForKey:@"action"]) intValue];
                if (action == 12) {
                    if (timer) {
                        [timer invalidate];
                        timer = nil;
                    }
                    AnchorViewController *vc = [[AnchorViewController alloc]init];
                    vc.anchorMsg = jsonDic;
                    vc.hostUrl = minstr([jsonDic valueForKey:@"push"]);
                    if ([_isauth isEqual:@"1"]) {
                        if ([_type isEqual:@"1"]) {
                            vc.liveType = @"1";
                        }else{
                            vc.liveType = @"3";
                        }
                    }else{
                        userMatchLabel.text = @"已匹配到主播";
                        if ([_type isEqual:@"1"]) {
                            vc.liveType = @"2";
                        }else{
                            vc.liveType = @"4";
                        }
                    }

                    
                    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

                }
            }
            
        }
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
