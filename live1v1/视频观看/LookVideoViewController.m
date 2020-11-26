//
//  LookVideoViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/5/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "LookVideoViewController.h"
#import "JPVideoPlayerKit.h"
#import "fenXiangView.h"
#import "AnchorViewController.h"
#import "TChatController.h"
#import "TConversationCell.h"
#import "InvitationViewController.h"
#import "TIMComm.h"
#import "TIMManager.h"
#import "TIMMessage.h"
#import "TIMConversation.h"
#import "GiftCabinetCell.h"
#import "continueGift.h"
#import "expensiveGiftV.h"//礼物
#import "MineImpressViewController.h"
#import "personSelectActionView.h"
#import "RechargeViewController.h"
#import "liwuview.h"
#import "jubaoVC.h"

@interface LookVideoViewController ()<JPVideoPlayerDelegate,shareDelegate,sendGiftDelegate,haohuadelegate>{
    UIButton *likeBtn;
    UILabel *likesL;
    UILabel *sharesL;
    UILabel *viewsL;
    UIButton *followBtn;
    
    
    NSMutableArray *zanImgArray;
    fenXiangView *shareView;
    
    liwuview *giftView;
    UIButton *giftZheZhao;
    expensiveGiftV *haohualiwuV;//豪华礼物
    continueGift *continueGifts;//连送礼物
    UIView *liansongliwubottomview;
    int callType;
    personSelectActionView *actionView;
    NSString *sign;
    YBAlertView *alert;
}
@property (nonatomic,strong) UIImageView *backImgV;

@end

@implementation LookVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    _backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _backImgV.contentMode = UIViewContentModeScaleAspectFill;
    _backImgV.userInteractionEnabled = YES;
    _backImgV.clipsToBounds = YES;
    [self.view addSubview:_backImgV];
    [_backImgV sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    [self creatUI];
    liansongliwubottomview = [[UIView alloc]init];
    [self.view addSubview:liansongliwubottomview];
    liansongliwubottomview.frame = CGRectMake(0, statusbarHeight + 140,300,140);

    zanImgArray = [NSMutableArray array];
    for (int i = 0; i < 15; i ++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_video_zan_%02d",i+1]];
        [zanImgArray addObject:image];
    }
    sign = [YBToolClass sortString:@{@"uid":[Config getOwnID],@"videoid":_model.videoID}];
    if ([[Config getOwnID] isEqual:minstr([_userDic valueForKey:@"id"])]) {
        [self addViews];
    }
}

- (void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showAlertView{
    WeakSelf;
    alert = [[YBAlertView alloc]initWithTitle:@"提示" andMessage:@"该视频为私密视频，需付费观看或开通VIP后可免费观看" andButtonArrays:@[@"取消",@"设置"] andButtonClick:^(int type) {
        if (type == 2) {
            [weakSelf setPublic];
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
- (void)setPublic{
    [YBToolClass postNetworkWithUrl:@"Video.setPublic" andParameter:@{@"videoid":_model.videoID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            _model.isprivate = @"0";
            [self removeAlertView];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}

//删除
- (void)doDelVideo{
    [YBToolClass postNetworkWithUrl:@"Video.delVideo" andParameter:@{@"videoid":_model.videoID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [self doReturn];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}
- (void)doJubao{
    jubaoVC *jubao = [[jubaoVC alloc]init];
    jubao.dongtaiId = _model.videoID;
    [self.navigationController pushViewController:jubao animated:YES];
}
- (void)rightBtnClick{
    if ([[Config getOwnID] isEqual:minstr([_userDic valueForKey:@"id"])]) {

        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"设置为公开视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showAlertView];
        }];
        [action1 setValue:color32 forKey:@"_titleTextColor"];

        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doDelVideo];
        }];
        [action2 setValue:color32 forKey:@"_titleTextColor"];

        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [cancleAction setValue:color96 forKey:@"_titleTextColor"];
        if ([_model.isprivate isEqual:@"1"]) {
            [alertContro addAction:action1];
        }

        [alertContro addAction:action2];
        [alertContro addAction:cancleAction];
        [self presentViewController:alertContro animated:YES completion:nil];
    }else{
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doJubao];
        }];
        [action2 setValue:color32 forKey:@"_titleTextColor"];
        
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [cancleAction setValue:color96 forKey:@"_titleTextColor"];
        
        [alertContro addAction:action2];
        [alertContro addAction:cancleAction];
        UILabel *appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
        UIFont *font = [UIFont systemFontOfSize:13];
        [appearanceLabel setFont:font];

        [self presentViewController:alertContro animated:YES completion:nil];

    }
}
- (void)creatUI{
    UIButton *rBtn = [UIButton buttonWithType:0];
    rBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
    //    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [rBtn setImage:[UIImage imageNamed:@"video--返回"] forState:0];
    [rBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:0];
    rightBtn.frame = CGRectMake(_window_width-40, 24+statusbarHeight, 40, 40);
    
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setImage:[UIImage imageNamed:@"三点白"] forState:0];
    [self.view  addSubview:rightBtn];

    if (![_model.status isEqual:@"0"]) {

        NSArray *btnArray;
        NSArray *titleArray;
        if ([minstr([_userDic valueForKey:@"id"]) isEqual:[Config getOwnID]]) {
            btnArray = @[@"video--分享",@"video--观看量",[_model.islike isEqual:@"1"] ? @"home_zan_sel":@"home_zan"];
            titleArray = @[_model.shares,_model.views,_model.likes];
        }else{
            NSString *str = @"";
            if ([minstr([_userDic valueForKey:@"isvideo"]) isEqual:@"1"] && [minstr([_userDic valueForKey:@"isvoice"]) isEqual:@"1"]) {
                callType = 1;
                str = @"video--视频语音";
            }else if ([minstr([_userDic valueForKey:@"isvideo"]) isEqual:@"1"] && [minstr([_userDic valueForKey:@"isvoice"]) isEqual:@"0"]){
                callType = 2;
                str = @"video--视频";
            }else if ([minstr([_userDic valueForKey:@"isvideo"]) isEqual:@"0"] && [minstr([_userDic valueForKey:@"isvoice"]) isEqual:@"1"]){
                callType = 3;
                str = @"video--语音";
            }
            if (str.length > 0) {
                btnArray = @[str,@"video--礼物",@"video--分享",@"video--观看量",@"home_zan"];
                titleArray = @[@"",@"",_model.shares,_model.views,_model.likes];

            }else{
                btnArray = @[@"video--礼物",@"video--分享",@"video--观看量",@"home_zan"];
                titleArray = @[@"",_model.shares,_model.views,_model.likes];
            }


        }
    
        for (int i = 0; i < btnArray.count; i ++) {
            
            UILabel *label = [[UILabel alloc]init];
            label.font = SYS_Font(11);
            label.textColor = [UIColor whiteColor];
            label.text = titleArray[i];
            label.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view);
                make.width.mas_equalTo(60);
                make.height.mas_equalTo(25);
                make.bottom.equalTo(self.view).offset(-(30+60*i));
            }];
            UIButton *btn = [UIButton buttonWithType:0];
            [btn setImage:[UIImage imageNamed:btnArray[i]] forState:0];
            [btn addTarget:self action:@selector(rightBtnCLick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(label);
                make.bottom.equalTo(label.mas_top);
                make.width.height.mas_equalTo(30);
            }];
            [btn setTitle:btnArray[i] forState:0];
            [btn setTitleColor:[UIColor clearColor] forState:0];
            btn.tag = 1000+i;
            if ([btnArray[i] rangeOfString:@"home_zan"].location != NSNotFound) {
                likesL = label;
                likeBtn = btn;
            }
            if ([btnArray[i] isEqual:@"video--观看量"]) {
                viewsL = label;
            }
            if ([btnArray[i] isEqual:@"video--分享"]) {
                sharesL = label;
            }

        }
    }
    
    UILabel *titleL = [[UILabel alloc]init];
    titleL.textColor = [UIColor whiteColor];
    titleL.font = SYS_Font(12);
    titleL.numberOfLines = 0;
    titleL.text = _model.title;
    [self.view addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-80);
        make.bottom.equalTo(self.view).offset(-20);
    }];
    
    UIImageView *iconV = [[UIImageView alloc]init];
    [iconV sd_setImageWithURL:[NSURL URLWithString:minstr([_userDic valueForKey:@"avatar_thumb"])]];
    iconV.contentMode= UIViewContentModeScaleAspectFill;
    iconV.clipsToBounds = YES;
    iconV.layer.cornerRadius = 25;
    iconV.layer.masksToBounds = YES;
    [self.view addSubview:iconV];
    [iconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.bottom.equalTo(titleL.mas_top).offset(-15);
        make.height.width.mas_equalTo(50);
    }];
    UILabel *nameL = [[UILabel alloc]init];
    nameL.textColor = [UIColor whiteColor];
    nameL.font = SYS_Font(16);
    nameL.text = minstr([_userDic valueForKey:@"user_nickname"]);
    [self.view addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconV.mas_right).offset(3);
        make.top.equalTo(iconV);
        make.height.equalTo(iconV).multipliedBy(0.5);
    }];
    if (![minstr([_userDic valueForKey:@"id"]) isEqual:[Config getOwnID]]) {
        followBtn = [UIButton buttonWithType:0];
        [followBtn setImage:[UIImage imageNamed:@"video--关注"] forState:0];
        [followBtn setImage:[UIImage imageNamed:@"video--已关注"] forState:UIControlStateSelected];
        if ([minstr([_userDic valueForKey:@"isattent"]) isEqual:@"1"]) {
            followBtn.selected = YES;
        }else{
            followBtn.selected = NO;
        }
        [followBtn addTarget:self action:@selector(dofollow) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:followBtn];
        [followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameL.mas_right).offset(5);
            make.centerY.equalTo(nameL);
            make.height.mas_equalTo(15);
        }];
    }
    UIImageView *stateImgV = [[UIImageView alloc]init];
    NSArray *onlineArr = @[@"离线",@"勿扰",@"在聊",@"在线"];
    stateImgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"主页状态-%@",onlineArr[[minstr([_userDic valueForKey:@"online"]) intValue]]]];
    
    [self.view addSubview:stateImgV];
    //rk_1029
    stateImgV.hidden = YES;
    [stateImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameL);
        make.top.equalTo(nameL.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(36);
    }];

}
- (void)rightBtnCLick:(UIButton *)sender{
    NSString *str = sender.titleLabel.text;
    if ([str rangeOfString:@"home_zan"].location != NSNotFound) {
        [self doLike];
    }else{
        if ([str isEqual:@"video--分享"]) {
            [self doShare];
        }else if ([str isEqual:@"video--礼物"]) {
            if (!giftView) {
                giftView = [[liwuview alloc]initWithDic:@{@"uid":minstr([_userDic valueForKey:@"id"]),@"showid":@"0"} andMyDic:nil];
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
        }else if ([str isEqual:@"video--观看量"]) {
            
        }else{
            [self callBtnClick];
        }
    }
}
- (void)doShare{
    if (!shareView) {
        shareView = [[fenXiangView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        shareView.delegate = self;
        NSDictionary *dic = @{
                              @"title":_model.title,
                              @"videoid":_model.videoID,
                              @"user_nickname":[_userDic valueForKey:@"user_nickname"],
                              @"avatar_thumb":[_userDic valueForKey:@"avatar_thumb"]
                              };
        [shareView GetDIc:dic];
        [self.view addSubview:shareView];
    }
    [shareView show];
}
- (void)shareSuccess{
    [YBToolClass postNetworkWithUrl:@"Video.AddShare" andParameter:@{@"videoid":_model.videoID,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            _model.shares = minstr([dic valueForKey:@"nums"]);
            sharesL.text = _model.likes;
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];

}
- (void)doLike{
    [YBToolClass postNetworkWithUrl:@"Video.AddLike" andParameter:@{@"videoid":_model.videoID,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            _model.islike = minstr([dic valueForKey:@"islike"]);
            _model.likes = minstr([dic valueForKey:@"nums"]);
            likesL.text = _model.likes;
            if ([minstr([dic valueForKey:@"islike"]) isEqual:@"1"]) {
//                [likeBtn.imageView setAnimationImages:zanImgArray];
                likeBtn.imageView.animationImages = zanImgArray;//将序列帧数组赋给UIImageView的animationImages属性
                likeBtn.imageView.animationDuration = 1;//设置动画时间
                likeBtn.imageView.animationRepeatCount = 1;//设置动画次数 0 表示无限
                [likeBtn.imageView startAnimating];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [likeBtn setImage:[UIImage imageNamed:@"home_zan_sel"] forState:0];
                });
            }else{
                [likeBtn setImage:[UIImage imageNamed:@"home_zan"] forState:0];
            }
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}
- (void)addViews{
    [YBToolClass postNetworkWithUrl:@"Video.AddView" andParameter:@{@"videoid":_model.videoID,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            _model.views = minstr([dic valueForKey:@"nums"]);
            sharesL.text = _model.likes;
        }
    } fail:^{
        
    }];

    
}
- (void)dofollow{
    [YBToolClass postNetworkWithUrl:@"User.SetAttent" andParameter:@{@"touid":minstr([_userDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"isattent"]) isEqual:@"1"]) {
                followBtn.selected = YES;
            }else{
                followBtn.selected = NO;
            }
        }
        [MBProgressHUD showError:msg];
        
    } fail:^{
        
    }];

}
#pragma mark ============礼物=============

-(void)sendGiftSuccess:(NSMutableDictionary *)playDic{
    NSString *type = minstr([playDic valueForKey:@"type"]);
    
    if (!continueGifts) {
        continueGifts = [[continueGift alloc]initWithFrame:CGRectMake(0, 0, liansongliwubottomview.width, liansongliwubottomview.height)];
        [liansongliwubottomview addSubview:continueGifts];
        //初始化礼物空位
        [continueGifts initGift];
    }
    if ([type isEqual:@"1"]) {
        [self expensiveGift:playDic];
    }
    else{
        [continueGifts GiftPopView:playDic andLianSong:@"Y"];
    }
    
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

- (void)giftZheZhaoClick{
    giftZheZhao.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
    } completion:^(BOOL finished) {
    }];
}
#pragma mark ============底部按钮点击事件=============
- (void)callBtnClick{
    if (callType == 1) {
        if (!actionView) {
            NSArray *imgArray = @[@"person_选择语音",@"person_选择视频"];
            NSArray *itemArray = @[[NSString stringWithFormat:@"语音通话（%@%@/分钟）",minstr([_userDic valueForKey:@"voice_value"]),[common name_coin]],[NSString stringWithFormat:@"视频通话（%@%@/分钟）",minstr([_userDic valueForKey:@"video_value"]),[common name_coin]]];
            
            WeakSelf;
            actionView = [[personSelectActionView alloc]initWithImageArray:imgArray andItemArray:itemArray];
            actionView.block = ^(int item) {
                if (item == 0) {
                    [weakSelf sendCallwithType:@"2"];
                }
                if (item == 1) {
                    [weakSelf sendCallwithType:@"1"];
                }
            };
            [self.view addSubview:actionView];
        }
        [actionView show];
    }else if (callType == 2){
        [self sendCallwithType:@"1"];
    }else if (callType == 3){
        [self sendCallwithType:@"2"];
    }else{
        [MBProgressHUD showError:@"对方已关闭接听"];
    }
}
#pragma mark ============发起通话=============
- (void)sendCallwithType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_userDic valueForKey:@"id"]),[Config getOwnToken],type,[Config getOwnID]]];
    NSDictionary *dic = @{
                          @"liveuid":minstr([_userDic valueForKey:@"id"]),
                          @"type":type,
                          @"sign":sign
                          };
    [YBToolClass postNetworkWithUrl:@"Live.Checklive" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            TIMConversation *conversation = [[TIMManager sharedInstance]
                                             getConversation:TIM_C2C
                                             receiver:minstr([_userDic valueForKey:@"id"])];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"0",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":type,
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID],
                                  @"content":@"邀请你通话"
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
            
            
        }else if(code == 800){
            [self showYuyue:type andMessage:msg];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
}
- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:minstr([_userDic valueForKey:@"id"]) forKey:@"id"];
    [muDic setObject:minstr([_userDic valueForKey:@"avatar"]) forKey:@"avatar"];
    [muDic setObject:minstr([_userDic valueForKey:@"user_nickname"]) forKey:@"user_nickname"];
    [muDic setObject:minstr([_userDic valueForKey:@"level_anchor"]) forKey:@"level_anchor"];
    [muDic setObject:minstr([_userDic valueForKey:@"video_value"]) forKey:@"video_value"];
    [muDic setObject:minstr([_userDic valueForKey:@"voice_value"]) forKey:@"voice_value"];
    
    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue] andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
    
}
- (void)sendMessageFaild:(NSDictionary *)infoDic andType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_userDic valueForKey:@"id"]),minstr([infoDic valueForKey:@"showid"]),[Config getOwnToken],[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.UserHang" andParameter:@{@"liveuid":minstr([_userDic valueForKey:@"id"]),@"showid":minstr([infoDic valueForKey:@"showid"]),@"sign":sign,@"hangtype":@"0"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    } fail:^{
    }];
    
}
- (void)showYuyue:(NSString *)type andMessage:(NSString *)msg{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"预约" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self SetSubscribe:type];
    }];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];
    
}
- (void)SetSubscribe:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_userDic valueForKey:@"id"]),[Config getOwnToken],type,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Subscribe.SetSubscribe" andParameter:@{@"liveuid":minstr([_userDic valueForKey:@"id"]),@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    } fail:^{
    }];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self.backImgV jp_resumePlayWithURL:[NSURL URLWithString:_model.href]
                           bufferingIndicator:nil
                                  controlView:[UIView new]
                                 progressView:[UIView new]
                                configuration:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
                                }];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[JPVideoPlayerManager sharedManager]stopPlay];
}

#pragma mark - JPVideoPlayerDelegate
- (BOOL)shouldAutoReplayForURL:(nonnull NSURL *)videoURL {
    return NO;
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
