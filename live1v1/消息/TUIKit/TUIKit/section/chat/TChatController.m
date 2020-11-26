//
//  TChatController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TChatController.h"
#import "THeader.h"
#import "TZImagePickerController.h"
#import "TImageMessageCell.h"
#import "ImageViewController.h"
#import "InvitationViewController.h"
#import "liwuview.h"
#import "PersonMessageViewController.h"
#import "TIMManager.h"
#import "TIMConversation+MsgExt.h"
#import "continueGift.h"
#import "expensiveGiftV.h"//礼物
#import "RechargeViewController.h"
#import "VIPViewController.h"

@interface TChatController () <TMessageControllerDelegate, TInputControllerDelegate,TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,sendGiftDelegate,haohuadelegate>{
    liwuview *giftView;
    UIButton *giftZheZhao;
    expensiveGiftV *haohualiwuV;//豪华礼物
    continueGift *continueGifts;//连送礼物
    UIView *liansongliwubottomview;
    YBAlertView *alert;

}
@end

@implementation TChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:nil];
    [self.view addGestureRecognizer:pan];

    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"ismessageing"];
    [[NSUserDefaults standardUserDefaults] setObject:_conversation.convId forKey:@"messageingUserID"];

    self.titleL.text = _conversation.userName;
    self.rightBtn.hidden = NO;
    [self.rightBtn setImage:[UIImage imageNamed:@"三点"] forState:UIControlStateNormal];
    if ([_conversation.isVIP isEqual:@"1"]) {
        UIImageView *vip = [[UIImageView alloc]init];
        vip.image = [UIImage imageNamed:@"vip"];
        [self.naviView addSubview:vip];
        [vip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleL.mas_right).offset(3);
            make.centerY.equalTo(self.titleL);
            make.width.mas_equalTo(25);
            make.height.mas_equalTo(15);
        }];
    }

    [self setupViews];
}

- (void)setupViews
{
    
    //message
    _messageController = [[TMessageController alloc] init];
    _messageController.view.frame = CGRectMake(0, 64+statusbarHeight, _window_width, _window_height - TTextView_Height - Bottom_SafeHeight-(64+statusbarHeight));
    _messageController.delegate = self;
    [self addChildViewController:_messageController];
    [self.view addSubview:_messageController.view];
    [_messageController setConversation:_conversation];
    if (![_conversation.convId isEqual:@"admin"]) {
        //input
        _inputController = [[TInputController alloc] init];
        _inputController.view.frame = CGRectMake(0, _window_height - TTextView_Height - Bottom_SafeHeight, _window_width, TTextView_Height + Bottom_SafeHeight);
        _inputController.delegate = self;
        [self addChildViewController:_inputController];
        [self.view addSubview:_inputController.view];
        
        
        liansongliwubottomview = [[UIView alloc]init];
        liansongliwubottomview.userInteractionEnabled = NO;
        [self.view addSubview:liansongliwubottomview];
        liansongliwubottomview.frame = CGRectMake(0, statusbarHeight + 140,300,140);
    }else{
        self.rightBtn.hidden = YES;
        _messageController.view.frame = CGRectMake(0, 64+statusbarHeight, _window_width, _window_height - Bottom_SafeHeight-(64+statusbarHeight));
    }

}
- (void)doPersonMessage{
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":_conversation.convId} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *subDic = [info firstObject];
            PersonMessageViewController *person = [[PersonMessageViewController alloc]init];
            person.liveDic = subDic;
            [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
- (void)doFollow{
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"User.SetAttent" andParameter:@{@"touid":_conversation.convId} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"isattent"]) isEqual:@"1"]) {
                _conversation.isAtt = @"1";
            }else{
                _conversation.isAtt = @"0";
            }
        }

        [MBProgressHUD showError:msg];
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
- (void)doSetBlack{
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"User.SetBlack" andParameter:@{@"touid":_conversation.convId} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"isblack"]) isEqual:@"1"]) {
                _conversation.isblack = @"1";
            }else{
                _conversation.isblack = @"0";
            }
        }
        
        [MBProgressHUD showError:msg];
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
- (void)rightBtnClick{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"查看TA的主页" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doPersonMessage];
    }];
    [cancleAction setValue:color32 forKey:@"_titleTextColor"];

//    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"清除聊天记录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [action2 setValue:RGB_COLOR(@"#ff6262", 1) forKey:@"_titleTextColor"];
//    [alertContro addAction:action2];
    NSString *attStr;
    if ([_conversation.isAtt isEqualToString:@"1"]) {
        attStr = @"取消关注";
    }else{
        attStr = @"关注";
    }
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:attStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doFollow];
    }];
    [action3 setValue:color32 forKey:@"_titleTextColor"];

    NSString *blackStr;
    if ([_conversation.isblack isEqualToString:@"1"]) {
        blackStr = @"解除拉黑";
    }else{
        blackStr = @"拉黑";
    }

    UIAlertAction *action4 = [UIAlertAction actionWithTitle:blackStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doSetBlack];
    }];
    [action4 setValue:color32 forKey:@"_titleTextColor"];

    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [sureAction setValue:color96 forKey:@"_titleTextColor"];
    if ([_conversation.isauth isEqual:@"1"]) {
        [alertContro addAction:cancleAction];
        [alertContro addAction:action3];
    }
    [alertContro addAction:action4];
    [alertContro addAction:sureAction];

    [self presentViewController:alertContro animated:YES completion:nil];

}

- (void)doReturn{
    if (haohualiwuV) {
        [haohualiwuV removeFromSuperview];
        haohualiwuV = nil;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"ismessageing"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"messageingUserID"];


    TIMConversation * conv = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:_conversation.convId];
    [conv setReadMessage:nil succ:^{
        NSLog(@"++++++++++++++++++++++++++");
    } fail:^(int code, NSString *msg) {
        NSLog(@"--------------------------");
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMCancelunread object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inputController:(TInputController *)inputController didChangeHeight:(CGFloat)height
{
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = ws.messageController.view.frame;
        msgFrame.size.height = ws.view.frame.size.height - height-64-statusbarHeight;
        ws.messageController.view.frame = msgFrame;
//        if (ws.messageController.view.height >= _window_height - TTextView_Height - Bottom_SafeHeight-(64+statusbarHeight)) {
//            ws.messageController.view.height = _window_height - TTextView_Height - Bottom_SafeHeight-(64+statusbarHeight);
//            msgFrame = ws.messageController.view.frame;
//
//        }
        CGRect inputFrame = ws.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        ws.inputController.view.frame = inputFrame;
        [ws.messageController scrollToBottom:NO];
    } completion:nil];
}

- (void)inputController:(TInputController *)inputController didSendMessage:(TMessageCellData *)msg
{
    [self checkBlack:msg];
}

- (void)inputController:(TInputController *)inputController didSelectMoreAtIndex:(NSInteger)index
{
    NSLog(@"----------%ld",index);
    [_inputController reset];
    if (index == 0) {
        TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
        imagePC.allowCameraLocation = YES;
        imagePC.allowTakeVideo = NO;
        imagePC.allowPickingVideo = NO;
        imagePC.doneBtnTitleStr = @"发送";
        [self presentViewController:imagePC animated:YES completion:nil];
    }else if (index == 1){
        //语音通话
        //语音
        if ([YBToolClass checkAudioAuthorization] == 2) {
            //弹出麦克风权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self sendVideoOrAudio:@"2"];
                    }else{
                        [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                    }
                });
            }];
        }else{
            if ([YBToolClass checkAudioAuthorization] == 1) {
                [self sendVideoOrAudio:@"2"];
            }else{
                [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
                return;
            }
            
        }

    }else if (index == 2){
        //拍摄
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode =UIImagePickerControllerCameraCaptureModePhoto;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];

    }else if (index == 4){
        //礼物
        if ([_conversation.isauth isEqual:@"1"]) {
            [self doliwu];
        }else{
            [MBProgressHUD showError:@"对方未认证"];
        }
    }else if (index == 6){
        //视频通话
//
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
//    if(_delegate && [_delegate respondsToSelector:@selector(chatController:didSelectMoreAtIndex:)]){
//        [_delegate chatController:self didSelectMoreAtIndex:index];
//    }
}
- (void)checkYuyinQuanxian{
    if ([YBToolClass checkAudioAuthorization] == 2) {
        //弹出麦克风权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self sendVideoOrAudio:@"1"];
                }else{
                    [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                }
            });
        }];
    }else{
        if ([YBToolClass checkAudioAuthorization] == 1) {
            [self sendVideoOrAudio:@"1"];
        }else{
            [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
            return;
        }
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    for (int i = 0;i < photos.count;i++) {
        UIImage *img = photos[i];
        [self sendImageMessage:img andIndex:i];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageOrientation imageOrientation=  image.imageOrientation;
        if(imageOrientation != UIImageOrientationUp)
        {
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        [self sendImageMessage:image andIndex:0];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)didTapInMessageController:(TMessageController *)controller
{
    [_inputController reset];
}

- (BOOL)messageController:(TMessageController *)controller willShowMenuInCell:(TMessageCell *)cell
{
    if([_inputController.textView.inputTextView isFirstResponder]){
        _inputController.textView.inputTextView.overrideNextResponder = cell;
        return YES;
    }
    return NO;
}

- (void)didHideMenuInMessageController:(TMessageController *)controller
{
    _inputController.textView.inputTextView.overrideNextResponder = nil;
}

- (void)messageController:(TMessageController *)controller didSelectMessages:(NSMutableArray *)msgs atIndex:(NSInteger)index
{
    TMessageCellData *data = msgs[index];
    if([data isKindOfClass:[TImageMessageCellData class]]){
        ImageViewController *image = [[ImageViewController alloc] init];
        image.data = (TImageMessageCellData *)data;
        [self presentViewController:image animated:YES completion:nil];
    }

//    if(_delegate && [_delegate respondsToSelector:@selector(chatController:didSelectMessages:atIndex:)]){
//        [_delegate chatController:self didSelectMessages:msgs atIndex:index];
//    }
}

- (void)sendImageMessage:(UIImage *)image andIndex:(int)index;
{
    [self checkBlack:image];
}

- (void)sendVideoMessage:(NSURL *)url
{
    [_messageController sendVideoMessage:url];
}

- (void)sendFileMessage:(NSURL *)url
{
    [_messageController sendFileMessage:url];
}
#pragma mark ============gift=============
- (void)doliwu{
    if (!giftView) {
        NSDictionary *dic = @{@"uid":_conversation.convId,@"showid":@"0"};
        giftView = [[liwuview alloc]initWithDic:dic andMyDic:nil];
        giftView.giftDelegate = self;
        giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
        [self.view addSubview:giftView];
        giftZheZhao = [UIButton buttonWithType:0];
        giftZheZhao.frame = CGRectMake(0, 0, _window_width, _window_height-(_window_width/2+100+ShowDiff));
        [giftZheZhao addTarget:self action:@selector(giftZheZhaoClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:giftZheZhao];
        giftZheZhao.hidden = YES;
    }
    [UIView animateWithDuration:0.2 animations:^{
        giftView.frame = CGRectMake(0,_window_height-(_window_width/2+100+ShowDiff), _window_width, _window_width/2+100+ShowDiff);
    } completion:^(BOOL finished) {
        giftZheZhao.hidden = NO;
    }];

}
- (void)giftZheZhaoClick{
    giftZheZhao.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
    } completion:^(BOOL finished) {
    }];
    
}

-(void)sendGiftSuccess:(NSMutableDictionary *)playDic{
//    [_messageController sendCustomMessage:playDic];
//    NSString *type = minstr([playDic valueForKey:@"type"]);
//    
//    if (!continueGifts) {
//        continueGifts = [[continueGift alloc]initWithFrame:CGRectMake(0, 0, liansongliwubottomview.width, liansongliwubottomview.height)];
//        [liansongliwubottomview addSubview:continueGifts];
//        //初始化礼物空位
//        [continueGifts initGift];
//    }
//    if ([type isEqual:@"1"]) {
//        [self expensiveGift:playDic];
//    }
//    else{
//        [continueGifts GiftPopView:playDic andLianSong:@"Y"];
//    }

}
- (void)pushCoinV{
    RechargeViewController *recharge = [[RechargeViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:recharge animated:YES];
}

/************ 礼物弹出及队列显示开始 *************/
-(void)expensiveGiftdelegate:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        [self.view addSubview:haohualiwuV];
    }
    if (giftData == nil) {
        
        
    }
    else
    {
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }
}
-(void)expensiveGift:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        //         [backScrollView insertSubview:haohualiwuV atIndex:8];
        [self.view addSubview:haohualiwuV];
    }
    if (giftData == nil) {
        
        
        
    }
    else
    {
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }
}
- (void)reciveGiftMessage:(NSDictionary *)giftDic{
    NSString *type = minstr([giftDic valueForKey:@"type"]);
    
    if (!continueGifts) {
        continueGifts = [[continueGift alloc]initWithFrame:CGRectMake(0, 0, liansongliwubottomview.width, liansongliwubottomview.height)];
        [liansongliwubottomview addSubview:continueGifts];
        //初始化礼物空位
        [continueGifts initGift];
    }
    if ([type isEqual:@"1"]) {
        [self expensiveGift:giftDic];
    }
    else{
        [continueGifts GiftPopView:giftDic andLianSong:@"Y"];
    }

}
#pragma mark ============视频语音通话=============
- (void)sendVideoOrAudio:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"token=%@&touid=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",[Config getOwnToken],_conversation.convId,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.checkstatus" andParameter:@{@"touid":_conversation.convId,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"status"]) isEqual:@"0"]) {
                [self userInvitationAnchor:type];
            }else{
                [self anchorInvitationlUser:type];
            }
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
}

- (void)userInvitationAnchor:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",_conversation.convId,[Config getOwnToken],type,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.Checklive" andParameter:@{@"liveuid":_conversation.convId,@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            TIMConversation *conversation = [[TIMManager sharedInstance]
                                             getConversation:TIM_C2C
                                             receiver:_conversation.convId];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"0",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":type,
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID]
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
            [custom_elem setData:data];
            TIMMessage * msg = [[TIMMessage alloc] init];
            [msg addElem:custom_elem];
            WeakSelf;
            [conversation sendMessage:msg succ:^(){
                NSLog(@"SendMsg Succ");
                [weakSelf showWaitView:infoDic andType:type];
            }fail:^(int code, NSString * err) {
                NSLog(@"SendMsg Failed:%d->%@", code, err);
                [MBProgressHUD showError:@"消息发送失败"];
                [weakSelf sendMessageFaild:infoDic andType:type];
            }];
            
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];

}
- (void)anchorInvitationlUser:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"token=%@&touid=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",[Config getOwnToken],_conversation.convId,type,[Config getOwnID]]];
    
    [YBToolClass postNetworkWithUrl:@"Live.anchorLaunch" andParameter:@{@"touid":_conversation.convId,@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            TIMConversation *conversation = [[TIMManager sharedInstance]
                                             getConversation:TIM_C2C
                                             receiver:_conversation.convId];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"2",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":minstr([infoDic valueForKey:@"type"]),
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID],
                                  @"total":minstr([infoDic valueForKey:@"total"])
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
            [custom_elem setData:data];
            TIMMessage * msg = [[TIMMessage alloc] init];
            [msg addElem:custom_elem];
            WeakSelf;
            [conversation sendMessage:msg succ:^(){
                NSLog(@"SendMsg Succ");
                [weakSelf showWaitView:infoDic andType:minstr([infoDic valueForKey:@"type"]) andModel:nil];
            }fail:^(int code, NSString * err) {
                NSLog(@"SendMsg Failed:%d->%@", code, err);
                [MBProgressHUD showError:@"消息发送失败"];
            }];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];

}
- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type andModel:(id )model{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:_conversation.convId forKey:@"id"];
    [muDic setObject:_conversation.userHeader forKey:@"avatar"];
    [muDic setObject:_conversation.userName forKey:@"user_nickname"];
    [muDic setObject:_conversation.level_anchor forKey:@"level_anchor"];
    if ([type isEqual:@"1"]) {
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"video_value"];
    }else{
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"voice_value"];
    }
    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue]+4 andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
    
}

- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:_conversation.convId forKey:@"id"];
    [muDic setObject:_conversation.userHeader forKey:@"avatar"];
    [muDic setObject:_conversation.userName forKey:@"user_nickname"];
    [muDic setObject:_conversation.level_anchor forKey:@"level_anchor"];
    if ([type isEqual:@"1"]) {
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"video_value"];
    }else{
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"voice_value"];
    }
    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue] andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
    
}
- (void)sendMessageFaild:(NSDictionary *)infoDic andType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",_conversation.convId,minstr([infoDic valueForKey:@"showid"]),[Config getOwnToken],[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.UserHang" andParameter:@{@"liveuid":_conversation.convId,@"showid":minstr([infoDic valueForKey:@"showid"]),@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    } fail:^{
    }];
    
}


- (void)checkBlack:(id)datamsg{
    [YBToolClass postNetworkWithUrl:@"Im.Check" andParameter:@{@"touid":_conversation.convId} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            if ([datamsg isKindOfClass:[UIImage class]]) {
                [_messageController sendImageMessage:datamsg andIndex:0];
            }else{
                [_messageController sendMessage:datamsg];
            }
        }else if (code == 900){
            [_inputController.textView resignFirstResponder];
            [self didTapInMessageController:_messageController];
            [self showAlertView:msg andMessage:datamsg];
        }else{
            [_inputController.inputView resignFirstResponder];
            [MBProgressHUD showError:msg];
        }
    } fail:^{

    }];
}
- (void)showAlertView:(NSString *)message andMessage:(id)datamsg{
    WeakSelf;
    alert = [[YBAlertView alloc]initWithTitle:@"提示" andMessage:message andButtonArrays:@[@"开通会员",@"付费发送"] andButtonClick:^(int type) {
        if (type == 2) {
            [weakSelf doPayWithData:datamsg];
        }else if (type == 1) {
            [weakSelf doVIP];
        }
        [weakSelf removeAlertView];
        
    }];
    [self.view addSubview:alert];
}
- (void)removeAlertView{
    if (alert) {
        [alert removeFromSuperview];
        alert = nil;
    }
    
}
- (void)doVIP{
    [self removeAlertView];
    VIPViewController *vip = [[VIPViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vip animated:YES];
}
- (void)doPayWithData:(id)datamsg{

    [YBToolClass postNetworkWithUrl:@"Im.BuyIm" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            if ([datamsg isKindOfClass:[UIImage class]]) {
                [_messageController sendImageMessage:datamsg andIndex:0];
            }else{
                [_messageController sendMessage:datamsg];
            }
            [self removeAlertView];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{

    }];
    
}
- (void)dealloc{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"ismessageing"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"messageingUserID"];

}
@end
