//
//  roomPayView.m
//  live1v1
//
//  Created by IOS1 on 2019/4/11.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "roomPayView.h"
#import "applePay.h"
#import <WXApi.h>
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "DataVerifier.h"

@interface roomPayView()<applePayDelegate,WXApiDelegate>{
    NSArray *paylist;
    NSArray *rules;
    applePay *applePays;//苹果支付
    UIActivityIndicatorView *testActivityIndicator;//菊花
    UIView *rulesView;
    UIView *payListView;
    NSMutableArray *payTypeArray;
    NSMutableArray *coinArray;
    UIButton *gopaybtn;
    UIView *payListBackView;
    NSString *payType;
    UILabel *getCoinL;
}
@property(nonatomic,strong)NSDictionary *seleDic;//选中的钻石字典
//支付宝
@property(nonatomic,copy)NSString *aliapp_key_ios;
@property(nonatomic,copy)NSString *aliapp_partner;
@property(nonatomic,copy)NSString *aliapp_seller_id;
//微信
@property(nonatomic,copy)NSString *wx_appid;
@end

@implementation roomPayView

- (instancetype)initWithMsg:(NSDictionary *)msg andFrome:(int)from{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        _aliapp_key_ios = [msg valueForKey:@"aliapp_key"];
        _aliapp_partner = [msg valueForKey:@"aliapp_partner"];
        _aliapp_seller_id = [msg valueForKey:@"aliapp_seller_id"];
        //微信的信息
        _wx_appid = [msg valueForKey:@"wx_appid"];
        [WXApi registerApp:_wx_appid];
        paylist = [msg valueForKey:@"paylist"];
        rules = [msg valueForKey:@"rules"];
        payTypeArray = [NSMutableArray array];
        coinArray = [NSMutableArray array];
        applePays = [[applePay alloc]init];
        applePays.delegate = self;

        [self creatUI:from];
    }
    return self;
}
- (void)closebtnClick{
    [UIView animateWithDuration:0.2 animations:^{
        rulesView.y = _window_height;
    }completion:^(BOOL finished) {
        self.hidden = YES;
    }];

}
- (void)show{
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        rulesView.y = _window_height-rulesView.height;
    }];

}

- (void)creatUI:(int)ffff{
    CGFloat btnWidth;
    CGFloat btnSH = 0.0;
    if (IS_IPHONE_5) {
        btnWidth = 90;
        btnSH = 49;
    }else{
        btnWidth = 110;
        btnSH = 60;
    }
    CGFloat speace = (_window_width-30-btnWidth*3)/2;
    NSInteger count = 0;
    if (rules.count % 3 == 0) {
        count = rules.count/3;
    }else{
        count = rules.count/3+1;
    }
    rulesView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, 100+(btnSH + 20)*count+ShowDiff)];
    rulesView.backgroundColor = [UIColor whiteColor];
    rulesView.layer.mask = [[YBToolClass sharedInstance] setViewLeftTop:20 andRightTop:20 andView:rulesView];
    [self addSubview:rulesView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(rulesView.width/2-50, 10, 100, 20)];
    if (ffff == 1) {
        label.text = @"充值";
    }
    if (ffff == 2) {
        label.text = @"余额不足";
    }

    label.font = SYS_Font(14);
    label.textColor = color32;
    label.textAlignment = NSTextAlignmentCenter;
    [rulesView addSubview:label];
    
    UIButton *closeBtn = [UIButton buttonWithType:0];
    closeBtn.frame = CGRectMake(rulesView.width-52, 0, 40, 40);
    [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    [closeBtn addTarget:self action:@selector(closebtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rulesView addSubview:closeBtn];
    for (int j = 0; j < rules.count; j++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(15+j%3 * (btnWidth+speace), 40+(j/3)*(btnSH + 20), btnWidth, btnSH);
        [btn addTarget:self action:@selector(coinBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:colorf5];
        btn.clipsToBounds = NO;
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 1;
        btn.tag = 2000+j;
        [rulesView addSubview:btn];
        NSString *give = minstr([rules[j] valueForKey:@"give"]);
        if (![give isEqual:@"0"]) {
            CGFloat widddth = [[YBToolClass sharedInstance] widthOfString:[NSString stringWithFormat:@"赠送%@%@",give,[common name_coin]] andFont:SYS_Font(10) andHeight:15];
            UIImageView *giveImgV = [[UIImageView alloc]initWithFrame:CGRectMake(btn.right-widddth-5, btn.top-7.5, widddth+10, 20)];
            giveImgV.image = [UIImage imageNamed:@"recharge_send"];
            [rulesView addSubview:giveImgV];
            UILabel *giveLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, widddth, 15)];
            giveLabel.text = [NSString stringWithFormat:@"赠送%@%@",give,[common name_coin]];
            giveLabel.font = SYS_Font(10);
            giveLabel.textColor = [UIColor whiteColor];
            [giveImgV addSubview:giveLabel];
        }
        if (j == 0) {
            btn.layer.borderColor = normalColors.CGColor;
        }else{
            btn.layer.borderColor = [UIColor clearColor].CGColor;
        }
        UILabel *titleL = [[UILabel alloc]init];
        titleL.font = SYS_Font(15);
        titleL.textColor = color32;
        titleL.text = minstr([rules[j] valueForKey:@"coin"]);
        [btn addSubview:titleL];
        [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(btn).multipliedBy(0.73);
            make.centerX.equalTo(btn);
        }];
        UIImageView *imgV = [[UIImageView alloc]init];
        imgV.image = [UIImage imageNamed:@"coin_Icon"];
        [btn addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(btn);
            make.height.width.mas_equalTo(12);
            make.left.equalTo(titleL.mas_right).offset(5);
        }];
        UILabel *moneyL = [[UILabel alloc]init];
        moneyL.font = SYS_Font(12);
        moneyL.textColor = color66;
        moneyL.text = [NSString stringWithFormat:@"¥%@",minstr([rules[j] valueForKey:@"money"])];
        [btn addSubview:moneyL];
        [moneyL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(btn).multipliedBy(1.3);
            make.centerX.equalTo(btn);
        }];
        [coinArray addObject:btn];
        
    }
    _seleDic = rules[0];
    gopaybtn = [UIButton buttonWithType:0];
    gopaybtn.frame = CGRectMake(_window_width *0.1, rulesView.height-ShowDiff-50, _window_width*0.8, 40);
    gopaybtn.userInteractionEnabled = YES;
    [gopaybtn setBackgroundColor:normalColors];
    gopaybtn.titleLabel.font = SYS_Font(14);
    [gopaybtn setTitle:[NSString stringWithFormat:@"确认支付（¥%@）",minstr([_seleDic valueForKey:@"money"])] forState:0];
    [gopaybtn addTarget:self action:@selector(gopaybtnClick) forControlEvents:UIControlEventTouchUpInside];
    gopaybtn.layer.cornerRadius = 20.0;
    gopaybtn.layer.masksToBounds = YES;
    [rulesView addSubview:gopaybtn];
}
- (void)coinBtnClick:(UIButton *)sender{
    for (UIButton *btn in coinArray) {
        if (btn == sender) {
            btn.layer.borderColor = normalColors.CGColor;
        }else{
            btn.layer.borderColor = colorf5.CGColor;
        }
    }
    _seleDic = rules[sender.tag - 2000];
    gopaybtn.userInteractionEnabled = YES;
    [gopaybtn setBackgroundColor:normalColors];
    [gopaybtn setTitle:[NSString stringWithFormat:@"确认支付（¥%@）",minstr([_seleDic valueForKey:@"money"])] forState:0];
}
- (void)gopaybtnClick{
    if (paylist.count <= 0) {
        [MBProgressHUD showError:@"支付未开启"];
        return;
    }
    if (payListBackView) {
        [payListBackView removeFromSuperview];
        payListBackView = nil;
    }

    if (!payListBackView) {
        payType = minstr([paylist[0] valueForKey:@"id"]);
        payListBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        [self addSubview:payListBackView];
        payListView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*0.1, _window_height, _window_width*0.8, 150+paylist.count * 50)];
        payListView.backgroundColor = [UIColor whiteColor];
        payListView.layer.cornerRadius = 20;
        payListView.layer.masksToBounds = YES;
        [payListBackView addSubview:payListView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(payListView.width/2-50, 10, 100, 20)];
        label.text = @"支付方式";
        label.font = SYS_Font(14);
        label.textColor = color32;
        label.textAlignment = NSTextAlignmentCenter;
        [payListView addSubview:label];
        
        UIButton *closeBtn = [UIButton buttonWithType:0];
        closeBtn.frame = CGRectMake(payListView.width-52, 0, 40, 40);
        [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        [closeBtn addTarget:self action:@selector(listClosebtnClick) forControlEvents:UIControlEventTouchUpInside];
        [payListView addSubview:closeBtn];

        getCoinL = [[UILabel alloc]initWithFrame:CGRectMake(payListView.width/2-50, 40, 100, 20)];
        if ([payType isEqual:@"apple"]) {
            getCoinL.text = [NSString stringWithFormat:@"%@%@",minstr([_seleDic valueForKey:@"coin_ios"]),[common name_coin]];
        }else{
            getCoinL.text = [NSString stringWithFormat:@"%@%@",minstr([_seleDic valueForKey:@"coin"]),[common name_coin]];
        }
        getCoinL.textAlignment = NSTextAlignmentCenter;
        getCoinL.font = SYS_Font(11);
        getCoinL.textColor = color96;
        [payListView addSubview:getCoinL];

        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(payListView.width/2-50, 70, 100, 20)];
        label2.text = [NSString stringWithFormat:@"¥%@",minstr([_seleDic valueForKey:@"money"])];
        label2.font = SYS_Font(15);
        label2.textColor = color32;
        label2.textAlignment = NSTextAlignmentCenter;
        [payListView addSubview:label2];

        for (int i = 0; i < paylist.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:0];
            btn.frame = CGRectMake(40, i * 50 + 90, payListView.width-80, 50);
            btn.tag = 4000+i;
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [payListView addSubview:btn];
            UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 17, 16, 16)];
            [imgV sd_setImageWithURL:[NSURL URLWithString:minstr([paylist[i] valueForKey:@"thumb"])]];
            [btn addSubview:imgV];
            UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(imgV.right+5, imgV.top, 100, 16)];
            lable.text = minstr([paylist[i] valueForKey:@"name"]);
            lable.textColor = RGB_COLOR(@"#404040", 1);
            lable.font = SYS_Font(14);
            [btn addSubview:lable];
            
            UIImageView *rightImgV = [[UIImageView alloc]initWithFrame:CGRectMake(btn.width-20, 17.5, 20, 15)];
            [btn addSubview:rightImgV];
            rightImgV.tag = btn.tag+1000;
            if (i == 0) {
                rightImgV.image = [UIImage imageNamed:@"支付选中"];
            }
            [payTypeArray addObject:rightImgV];
            [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 49, btn.width, 1) andColor:RGB_COLOR(@"#f0f0f0", 1) andView:btn];
        }
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(0, 90+paylist.count*50+10, payListView.width, 40);
        [btn setTitle:@"立即支付" forState:0];
        [btn setTitleColor:normalColors forState:0];
        btn.titleLabel.font = SYS_Font(15);
        [btn addTarget:self action:@selector(goPayMoney) forControlEvents:UIControlEventTouchUpInside];
        [payListView addSubview:btn];
        
    }
    payListBackView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        payListView.center  = payListBackView.center;
    }];
    
}
- (void)listClosebtnClick{
    [UIView animateWithDuration:0.2 animations:^{
        payListView.y  = _window_height;
    }completion:^(BOOL finished) {
        payListBackView.hidden = YES;
    }];

}
- (void)btnClick:(UIButton *)sender{
    payType = minstr([paylist[sender.tag-4000] valueForKey:@"id"]);
    if ([payType isEqual:@"apple"]) {
        getCoinL.text = [NSString stringWithFormat:@"%@%@",minstr([_seleDic valueForKey:@"coin_ios"]),[common name_coin]];
    }else{
        getCoinL.text = [NSString stringWithFormat:@"%@%@",minstr([_seleDic valueForKey:@"coin"]),[common name_coin]];
    }

    UIImageView *imageView = (UIImageView *)[sender viewWithTag:sender.tag + 1000];
    for (UIImageView *img in payTypeArray) {
        if (imageView == img) {
            img.image = [UIImage imageNamed:@"支付选中"];
        }else{
            img.image = [UIImage new];
        }
    }
}
- (void)goPayMoney{
    if ([payType isEqual:@"ali"]) {
        //支付宝
        [self doAlipayPay];
    }
    if ([payType isEqual:@"wx"]) {
        //微信
        [self WeiXinPay];
    }
    if ([payType isEqual:@"apple"]) {
        //苹果
        [applePays applePay:_seleDic];

    }

}
/******************   内购  ********************/
-(void)applePayHUD{
    [MBProgressHUD hideHUDForView:self animated:YES];
}
-(void)applePayShowHUD{
    [MBProgressHUD showHUDAddedTo:self animated:YES];
}

//内购成功
-(void)applePaySuccess{
    NSLog(@"苹果支付成功");
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"支付成功"];
    [self listClosebtnClick];
    [self closebtnClick];

}
//微信支付*****************************************************************************************************************
-(void)WeiXinPay{
    NSLog(@"微信支付");
    [MBProgressHUD showMessage:@""];
    
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"changeid":[_seleDic valueForKey:@"id"],
                             @"coin":[_seleDic valueForKey:@"coin"],
                             @"money":[_seleDic valueForKey:@"money"]
                             };
    [YBToolClass postNetworkWithUrl:@"Charge.getWxOrder" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [MBProgressHUD hideHUD];
            NSDictionary *dict = [info firstObject];
            //调起微信支付
            NSString *times = [dict objectForKey:@"timestamp"];
            PayReq* req             = [[PayReq alloc] init];
            req.partnerId           = [dict objectForKey:@"partnerid"];
            NSString *pid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"prepayid"]];
            if ([pid isEqual:[NSNull null]] || pid == NULL || [pid isEqual:@"null"]) {
                pid = @"123";
            }
            req.prepayId            = pid;
            req.nonceStr            = [dict objectForKey:@"noncestr"];
            req.timeStamp           = times.intValue;
            req.package             = [dict objectForKey:@"package"];
            req.sign                = [dict objectForKey:@"sign"];
            [WXApi sendReq:req];
        }
        else{
            [MBProgressHUD hideHUD];
        }
        
    } fail:^{
        [MBProgressHUD hideHUD];
        
    }];
}
-(void)onResp:(BaseResp *)resp{
    //支付返回结果，实际支付结果需要去微信服务器端查询
    NSString *strMsg = [NSString stringWithFormat:@"支付结果"];
    switch (resp.errCode) {
        case WXSuccess:
            strMsg = @"支付结果：成功！";
            NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"支付成功"];
            [self listClosebtnClick];
            [self closebtnClick];

            break;
        default:
            strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
            NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"支付失败"];

            break;
    }
}
//微信支付*****************************************************************************************************************
//支付宝支付*****************************************************************************************************************
- (void)doAlipayPay
{
    NSString *partner = _aliapp_partner;
    NSString *seller =  _aliapp_seller_id;
    NSString *privateKey = _aliapp_key_ios;
    
    
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0){
        [MBProgressHUD showError:@"缺少partner或者seller或者私钥"];
        return;
    }
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    //获取订单id
    //将商品信息拼接成字符串
    
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"changeid":[_seleDic valueForKey:@"id"],
                             @"coin":[_seleDic valueForKey:@"coin"],
                             @"money":[_seleDic valueForKey:@"money"]
                             };
    
    [YBToolClass postNetworkWithUrl:@"Charge.getAliOrder" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *infos = [[info firstObject] valueForKey:@"orderid"];
            order.tradeNO = infos;
            order.notifyURL = [h5url stringByAppendingString:@"/Appapi/Pay/notify_ali"];
            order.amount = [_seleDic valueForKey:@"money"];
            order.productName = [NSString stringWithFormat:@"%@%@",[_seleDic valueForKey:@"coin"],[common name_coin]];
            order.productDescription = @"productDescription";
            //以下配置信息是默认信息,不需要更改.
            order.service = @"mobile.securitypay.pay";
            order.paymentType = @"1";
            order.inputCharset = @"utf-8";
            order.itBPay = @"30m";
            order.showUrl = @"m.alipay.com";
            //应用注册scheme,在AlixPayDemo-Info.plist定义URL types,用于快捷支付成功后重新唤起商户应用
            NSString *appScheme = [[NSBundle mainBundle] bundleIdentifier];
            //将商品信息拼接成字符串
            NSString *orderSpec = [order description];
            NSLog(@"orderSpec = %@",orderSpec);
            //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
            id<DataSigner> signer = CreateRSADataSigner(privateKey);
            NSString *signedString = [signer signString:orderSpec];
            //将签名成功字符串格式化为订单字符串,请严格按照该格式
            NSString *orderString = nil;
            if (signedString != nil) {
                orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                               orderSpec, signedString, @"RSA"];
                
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    NSLog(@"reslut = %@",resultDic);
                    NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
                    NSLog(@"#######%ld",(long)resultStatus);
                    // NSString *publicKey = alipaypublicKey;
                    NSLog(@"支付状态信息---%ld---%@",resultStatus,[resultDic valueForKey:@"memo"]);
                    // 是否支付成功
                    if (9000 == resultStatus) {
                        /*
                         *用公钥验证签名
                         */
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:@"支付成功"];
                        [self listClosebtnClick];
                        [self closebtnClick];
                    }else{
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:@"支付失败"];

                    }
                }];
            }
            
            
        }
    } fail:^{
        
    }];
    
    
    
}

@end
