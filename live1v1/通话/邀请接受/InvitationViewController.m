//
//  InvitationViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/11.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "InvitationViewController.h"
#import "TIMComm.h"
#import "TIMManager.h"
#import "TIMMessage.h"
#import "TIMConversation.h"
#import "AnchorViewController.h"

@interface InvitationViewController (){
    NSDictionary *invitationMsg;
    int invitationType;
    AVPlayer *_avplayer;
    NSTimer *timer;
    int timeCount;
    NSString *hangType;
    NSString *videoOrAudio;

}

@end

@implementation InvitationViewController
- (instancetype)initWithType:(int)type andMessage:(NSDictionary *)msg{
    self = [super init];
    if (self) {
        invitationType = type;
        invitationMsg = msg;
        if (invitationType%2 == 1) {
            videoOrAudio = @"1";
        }else{
            videoOrAudio = @"2";
        }

    }
    return self;
}
#pragma mark ============播放音频=============
- (void)playAudio{
    if (_avplayer) {
        [_avplayer pause];
        _avplayer = nil;
    }
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"ring" withExtension:@"mp3"];
    _avplayer = [[AVPlayer alloc] initWithURL:fileURL];
    _avplayer.volume = 1.0;
    [_avplayer play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeyEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

}
///播放结束
-(void)playeyEnd:(NSNotification*)notify{
    NSLog(@"end");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self playAudio];
    
}
- (void)stopPlayAndRemovePlayer{
    if (_avplayer) {
        [_avplayer pause];
        _avplayer = nil;
    }
}
#pragma mark ============viewDidLoad=============

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    hangType = @"0";
    [self creatUI];
    [self playAudio];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStateChange:) name:@"callStateChange" object:nil];
    if (!timer) {
        timeCount = 60;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(daojishi) userInfo:nil repeats:YES];
    }

}
#pragma mark ============一分钟等待时间结束=============

- (void)daojishi{
    timeCount --;
    if (timeCount <= 0) {
        [timer invalidate];
        timer = nil;
        if (invitationType == 1 || invitationType == 2) {
            [self removeAll];
            hangType = @"1";
            [self cancleBtnClick];
            UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:@"对方未接听，是否预约" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self docancle];
            }];
            [alertContro addAction:cancleAction];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"预约" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self SetSubscribe];
            }];
            [sureAction setValue:normalColors forKey:@"_titleTextColor"];
            [alertContro addAction:sureAction];
            [self presentViewController:alertContro animated:YES completion:nil];

        }else{
            [self docancle];
        }
    }
}
//预约
- (void)SetSubscribe{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%d&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([invitationMsg valueForKey:@"id"]),[Config getOwnToken],invitationType,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Subscribe.SetSubscribe" andParameter:@{@"liveuid":minstr([invitationMsg valueForKey:@"id"]),@"type":@(invitationType),@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        [self docancle];
    } fail:^{
        [self docancle];
    }];

}
//收到对方的回应
- (void)callStateChange:(NSNotification *)not{
    NSDictionary *dic = [not object];
    if ([minstr([dic valueForKey:@"action"]) isEqual:@"5"] || [minstr([dic valueForKey:@"action"]) isEqual:@"7"]) {
        [self docancle];
        [MBProgressHUD showError:@"对方拒绝接听"];
    }
    if ([minstr([dic valueForKey:@"action"]) isEqual:@"4"] || [minstr([dic valueForKey:@"action"]) isEqual:@"6"]) {
        [self doAnchor:invitationMsg];
    }
    if ([minstr([dic valueForKey:@"action"]) isEqual:@"1"] || [minstr([dic valueForKey:@"action"]) isEqual:@"3"]) {
        [self docancle];
    }

}
//创建UI
- (void)creatUI{
    UIImageView *backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    backImgV.image = [UIImage imageNamed:@"通话背景"];
    backImgV.contentMode = UIViewContentModeScaleAspectFill;
    backImgV.clipsToBounds = YES;
    backImgV.userInteractionEnabled = YES;
    [self.view addSubview:backImgV];
    
    UIImageView *headerBackImgV = [[UIImageView alloc]init];
    headerBackImgV.image = [UIImage imageNamed:@"invitation_header_back"];
    [backImgV addSubview:headerBackImgV];
    [headerBackImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV);
        make.centerY.equalTo(backImgV).multipliedBy(0.53);
        make.width.equalTo(backImgV).multipliedBy(0.5);
        make.height.equalTo(headerBackImgV.mas_width);
    }];

    UIImageView *headerImgV = [[UIImageView alloc]init];
    [headerImgV sd_setImageWithURL:[NSURL URLWithString:minstr([invitationMsg valueForKey:@"avatar"])]];
    headerImgV.contentMode = UIViewContentModeScaleAspectFill;
    headerImgV.clipsToBounds = YES;
    [headerBackImgV addSubview:headerImgV];
    [headerImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(headerBackImgV);
        make.width.equalTo(headerBackImgV).multipliedBy(0.615);
        make.height.equalTo(headerImgV.mas_width);
    }];

    UILabel *nameL = [[UILabel alloc]init];
    nameL.font = [UIFont boldSystemFontOfSize:20];
    nameL.textColor = [UIColor whiteColor];
    nameL.text = minstr([invitationMsg valueForKey:@"user_nickname"]);
    [backImgV addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV);
        make.top.equalTo(headerBackImgV.mas_bottom).offset(15);
    }];
    if (invitationType == 1 || invitationType == 2 || invitationType == 7 || invitationType == 8){
        UIImageView *levelImgV = [[UIImageView alloc]init];
        [levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:minstr([invitationMsg valueForKey:@"level_anchor"])]]];
        [backImgV addSubview:levelImgV];
        [levelImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(nameL);
            make.left.equalTo(nameL.mas_right).offset(3);
            make.width.mas_equalTo(25);
            make.height.mas_equalTo(15);
        }];
    }
    
    UILabel *priceL = [[UILabel alloc]init];
    priceL.font = [UIFont systemFontOfSize:13];
    priceL.textColor = [UIColor whiteColor];
    if (invitationType == 1) {
        priceL.text = [NSString stringWithFormat:@"%@%@/分钟",minstr([invitationMsg valueForKey:@"video_value"]),[common name_coin]];
    }else if (invitationType == 2){
        priceL.text = [NSString stringWithFormat:@"%@%@/分钟",minstr([invitationMsg valueForKey:@"voice_value"]),[common name_coin]];
    }else if(invitationType == 7 || invitationType == 8){
        priceL.text = [NSString stringWithFormat:@"%@%@/分钟",minstr([invitationMsg valueForKey:@"total"]),[common name_coin]];
    }else{
        priceL.text = @"";
    }
    [backImgV addSubview:priceL];
    [priceL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV);
        make.top.equalTo(nameL.mas_bottom).offset(10);
    }];

    
    UILabel *messageL = [[UILabel alloc]init];
    messageL.font = [UIFont systemFontOfSize:13];
    messageL.textColor = [UIColor whiteColor];
    if (invitationType == 1 || invitationType == 2 || invitationType == 5 || invitationType == 6) {
        messageL.text = @"正在等待对方接受邀请...";
    }else if (invitationType == 3 || invitationType == 7){
        messageL.text = @"邀请您视频通话...";
    }if (invitationType == 4 || invitationType == 8){
        messageL.text = @"邀请您语音通话...";
    }
    [backImgV addSubview:messageL];
    [messageL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backImgV);
        make.top.equalTo(priceL.mas_bottom).offset(15);
    }];
    if (invitationType == 1 || invitationType == 2 || invitationType == 5 || invitationType == 6) {
        UIButton *btn = [UIButton buttonWithType:0];
        [btn setImage:[UIImage imageNamed:@"invitation_拒绝"] forState:0];
        [btn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [backImgV addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(headerBackImgV.mas_width).multipliedBy(0.45);
            make.centerY.equalTo(backImgV).multipliedBy(1.7);
            make.centerX.equalTo(backImgV);
        }];
        UILabel *tiL = [[UILabel alloc]init];
        tiL.font = [UIFont systemFontOfSize:15];
        tiL.textColor = [UIColor whiteColor];
        tiL.text = @"取消";
        [backImgV addSubview:tiL];
        [tiL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(btn);
            make.top.equalTo(btn.mas_bottom).offset(10);
        }];

    }else{
        NSArray *array = @[@"拒绝",@"接受"];
        NSArray *imgNameArray;

        if (invitationType == 3 || invitationType == 7) {
            imgNameArray = @[@"invitation_拒绝",@"invitation_视频"];
        }else if (invitationType == 4 || invitationType == 8){
            imgNameArray = @[@"invitation_拒绝",@"invitation_语音"];
        }
        for (int i = 0; i < array.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:0];
            [btn setImage:[UIImage imageNamed:imgNameArray[i]] forState:0];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 1000+i;
            [backImgV addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
             make.width.height.equalTo(headerBackImgV.mas_width).multipliedBy(0.45);
                make.centerY.equalTo(backImgV).multipliedBy(1.7);
                make.centerX.equalTo(backImgV).multipliedBy(0.5+i*1);
            }];
            UILabel *tiL = [[UILabel alloc]init];
            tiL.font = [UIFont systemFontOfSize:15];
            tiL.textColor = [UIColor whiteColor];
            tiL.text = array[i];
            [backImgV addSubview:tiL];
            [tiL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(btn);
                make.top.equalTo(btn.mas_bottom).offset(10);
            }];

        }
    }
    [self.view layoutIfNeeded];
    headerImgV.layer.cornerRadius = headerImgV.width/2;
    headerImgV.layer.masksToBounds = YES;
}
//接收方底部两个按钮的点击
- (void)btnClick:(UIButton *)sender{
    if (sender.tag == 1000) {
        if (invitationType == 3 || invitationType == 4) {
            [self anchorHangWithType:@""];
        }else{
            [self cancleBtnClick];
        }
    }else{
        if (invitationType == 3 || invitationType == 4) {
            [self anchorAgreeWithType:[NSString stringWithFormat:@"%d",invitationType-2]];
        }else{
            [self userAgreeMessage];
        }

    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
//主播挂断
- (void)anchorHangWithType:(NSString *)type{
    
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"showid=%@&token=%@&touid=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",_showid,[Config getOwnToken],minstr([invitationMsg valueForKey:@"id"]),[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.AnchorHang" andParameter:@{@"touid":minstr([invitationMsg valueForKey:@"id"]),@"showid":_showid,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        [MBProgressHUD showError:msg];
        [self removeAll];
        [self dismissViewControllerAnimated:YES completion:nil];
    } fail:^{
        [self removeAll];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self sendCancleMessage];

}
//主播同意
- (void)anchorAgreeWithType:(NSString *)type{
    if ([type isEqual:@"2"]) {
        //语音
        if ([YBToolClass checkAudioAuthorization] == 2) {
            //弹出麦克风权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self callllllllllType:type];
                    }else{
                        [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                        [self cancleBtnClick];
                    }
                });
            }];
        }else{
            if ([YBToolClass checkAudioAuthorization] == 1) {
                [self callllllllllType:type];
            }else{
                [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
                [self cancleBtnClick];

                return;
            }
            
        }
    }else{
        if ([YBToolClass checkVideoAuthorization] == 2) {
            //弹出相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self checkYuyinQuanxian:type];
                    }else{
                        [MBProgressHUD showError:@"未允许摄像头权限，不能视频通话"];
                        [self cancleBtnClick];
                    }
                });
                
            }];
        }else{
            if ([YBToolClass checkVideoAuthorization] == 1) {
                [self checkYuyinQuanxian:type];
            }else{
                [MBProgressHUD showError:@"请前往设置中打开摄像头权限"];
                [self cancleBtnClick];

            }
        }
    }
    
    //视频
    
    
}
- (void)checkYuyinQuanxian:(NSString *)type{
    if ([YBToolClass checkAudioAuthorization] == 2) {
        //弹出麦克风权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (granted) {
                [self callllllllllType:type];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                    [self cancleBtnClick];
                });

            }
        }];
    }else{
        if ([YBToolClass checkAudioAuthorization] == 1) {
            [self callllllllllType:type];
        }else{
            [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
            [self cancleBtnClick];
            return;
        }
    }
}
- (void)callllllllllType:(NSString *)type{

    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"showid=%@&token=%@&touid=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",_showid,[Config getOwnToken],minstr([invitationMsg valueForKey:@"id"]),[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.AnchorAnswer" andParameter:@{@"touid":minstr([invitationMsg valueForKey:@"id"]),@"showid":_showid,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSMutableDictionary *infodic = [[info firstObject] mutableCopy];
            [infodic setObject:minstr([invitationMsg valueForKey:@"id"]) forKey:@"id"];
            [infodic setObject:minstr([invitationMsg valueForKey:@"avatar"]) forKey:@"avatar"];
            [infodic setObject:minstr([invitationMsg valueForKey:@"user_nickname"]) forKey:@"user_nickname"];
            [infodic setObject:minstr([invitationMsg valueForKey:@"showid"]) forKey:@"showid"];
            [self sendAgreeMessage:infodic];
            [self doAnchor:infodic];
        }else{
            [self docancle];
            [self anchorHangWithType:@""];
        }
        
    } fail:^{
        [self docancle];
        [self anchorHangWithType:@""];
    }];

}
//用户同意
- (void)userAgreeMessage{
    if ([YBToolClass checkVideoAuthorization] != 1) {
        [MBProgressHUD showError:@"请前往设置中打开摄像头权限"];
        [self cancleBtnClick];
        return;
    }
    if ([YBToolClass checkAudioAuthorization] != 1) {
        [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
        [self cancleBtnClick];
        return;
    }
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([invitationMsg valueForKey:@"id"]),_showid,[Config getOwnToken],[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.UserAnswer" andParameter:@{@"liveuid":minstr([invitationMsg valueForKey:@"id"]),@"showid":_showid,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSMutableDictionary *infodic = [[info firstObject] mutableCopy];
            [infodic setObject:minstr([invitationMsg valueForKey:@"id"]) forKey:@"id"];
            [infodic setObject:minstr([invitationMsg valueForKey:@"avatar"]) forKey:@"avatar"];
            [infodic setObject:minstr([invitationMsg valueForKey:@"user_nickname"]) forKey:@"user_nickname"];
            [infodic setObject:minstr([invitationMsg valueForKey:@"showid"]) forKey:@"showid"];
            [self sendAgreeMessage:infodic];
            [self doAnchor:infodic];
        }else{
            [self docancle];
            [self anchorHangWithType:@""];
        }
        
    } fail:^{
        [self docancle];
        [self anchorHangWithType:@""];
    }];

}
//y发起方取消按钮点击
- (void)cancleBtnClick{
    if (invitationType == 1 || invitationType == 2 || invitationType == 7 || invitationType == 8) {
        [self sendCancleMessage];
        NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([invitationMsg valueForKey:@"id"]),_showid,[Config getOwnToken],[Config getOwnID]]];
        [YBToolClass postNetworkWithUrl:@"Live.UserHang" andParameter:@{@"liveuid":minstr([invitationMsg valueForKey:@"id"]),@"showid":_showid,@"sign":sign,@"hangtype":hangType} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (![hangType isEqual:@"1"]) {
                [self removeAll];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } fail:^{
            if (![hangType isEqual:@"1"]) {
                [self removeAll];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }else{
        [self anchorHangWithType:@""];
    }
    
}
//发送各种d取消消息
- (void)sendCancleMessage{
    NSDictionary *dic;
    if (invitationType == 1 || invitationType == 2) {
        dic = @{
                @"method":@"call",
                @"action":@"1",
                @"type":videoOrAudio,
                };
    }else if (invitationType == 3 || invitationType == 4) {
        dic = @{
                @"method":@"call",
                @"action":@"5",
                @"type":videoOrAudio,
                };
    }else if (invitationType == 5 || invitationType == 6) {
        dic = @{
                @"method":@"call",
                @"action":@"3",
                @"type":videoOrAudio,
                };
    }else{
        dic = @{
                @"method":@"call",
                @"action":@"7",
                @"type":videoOrAudio,
                };
    }
    [self sendMessage:dic];
}
//发送y同意消息
- (void)sendAgreeMessage:(NSDictionary *)msg{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (invitationType == 3 || invitationType == 4) {
        dic = @{
                @"method":@"call",
                @"action":@"4",
                @"type":videoOrAudio,
                }.mutableCopy;
    }else{
        dic = @{
                @"method":@"call",
                @"action":@"6",
                @"type":videoOrAudio,
                }.mutableCopy;
    }
//    [dic addEntriesFromDictionary:msg];
    [self sendMessage:dic];

}
- (void)sendMessage:(NSDictionary *)dic{
    TIMConversation *conversation = [[TIMManager sharedInstance]
                                     getConversation:TIM_C2C
                                     receiver:minstr([invitationMsg valueForKey:@"id"])];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
    [custom_elem setData:data];
    TIMMessage * msg = [[TIMMessage alloc] init];
    [msg addElem:custom_elem];
    [conversation sendMessage:msg succ:^(){
        NSLog(@"SendMsg Succ");
    }fail:^(int code, NSString * err) {
        NSLog(@"SendMsg Failed:%d->%@", code, err);
        [MBProgressHUD showError:@"消息发送失败"];
    }];

}
- (void)removeAll{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    if (_avplayer) {
        [_avplayer pause];
        _avplayer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"callStateChange" object:nil];

}
- (void)docancle{
    [self removeAll];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc{
    [self removeAll];
}
//双方开始1V1
- (void)doAnchor:(NSDictionary *)dic{
    AnchorViewController *vc = [[AnchorViewController alloc]init];
    vc.anchorMsg = dic;
    if (invitationType == 1 ) {
        vc.liveType = @"2";
        vc.hostUrl = minstr([invitationMsg valueForKey:@"push"]);
    }
    if (invitationType == 2) {
        vc.liveType = @"4";
        vc.hostUrl = minstr([invitationMsg valueForKey:@"push"]);

    }
    if (invitationType == 3) {
        vc.liveType = @"1";
        vc.hostUrl = minstr([dic valueForKey:@"push"]);
    }
    if (invitationType == 4) {
        vc.liveType = @"3";
        vc.hostUrl = minstr([dic valueForKey:@"push"]);
    }
    if (invitationType == 5 ) {
        vc.liveType = @"1";
        vc.hostUrl = minstr([invitationMsg valueForKey:@"push"]);
    }
    if (invitationType == 6) {
        vc.liveType = @"3";
        vc.hostUrl = minstr([invitationMsg valueForKey:@"push"]);
        
    }
    if (invitationType == 7) {
        vc.liveType = @"2";
        vc.hostUrl = minstr([dic valueForKey:@"push"]);
    }
    if (invitationType == 8) {
        vc.liveType = @"4";
        vc.hostUrl = minstr([dic valueForKey:@"push"]);
    }

    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
    [self docancle];

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
