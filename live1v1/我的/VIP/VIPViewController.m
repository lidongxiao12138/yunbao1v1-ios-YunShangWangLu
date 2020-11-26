//
//  VIPViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "VIPViewController.h"
#import "vipBuyView.h"

@interface VIPViewController (){
    UILabel *vipL;
    UILabel *statusL;
    UIButton *kaitongBtn;
    NSDictionary *infoDic;
    vipBuyView *buyView;
}

@end

@implementation VIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"会员中心";
    [self creatUI];
    [self requestData];
}
- (void)creatUI{
    UIImageView *headerImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_width*0.426)];
    headerImgV.userInteractionEnabled = YES;
    headerImgV.image = [UIImage imageNamed:@"vip_header"];
    [self.view addSubview:headerImgV];
    vipL = [[UILabel alloc]init];
    vipL.textColor = [UIColor whiteColor];
    vipL.font = SYS_Font(16);
    [headerImgV addSubview:vipL];
    [vipL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV).multipliedBy(0.6);
    }];
    
    statusL = [[UILabel alloc]init];
    statusL.textColor = [UIColor whiteColor];
    statusL.font = SYS_Font(11);
    [headerImgV addSubview:statusL];
    [statusL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV);
    }];
    
    kaitongBtn = [UIButton buttonWithType:0];
    [kaitongBtn setBackgroundColor:[UIColor whiteColor]];
    [kaitongBtn setTitleColor:normalColors forState:0];
    kaitongBtn.titleLabel.font = SYS_Font(12);
    [kaitongBtn addTarget:self action:@selector(kaitongBtnClick) forControlEvents:UIControlEventTouchUpInside];
    kaitongBtn.layer.cornerRadius = _window_width*0.04;
    kaitongBtn.layer.masksToBounds = YES;
    [headerImgV addSubview:kaitongBtn];
    [kaitongBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV).multipliedBy(1.5);
        make.height.mas_equalTo(_window_width*0.08);
        make.width.equalTo(kaitongBtn.mas_height).multipliedBy(3);
    }];
    
    UIImageView *bottomImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, headerImgV.bottom, _window_width, _window_width*0.875)];
    bottomImgV.userInteractionEnabled = YES;
    bottomImgV.image = [UIImage imageNamed:@"vip_footer"];
    [self.view addSubview:bottomImgV];

}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Vip.myVip" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"isvip"]) isEqual:@"1"]) {
                vipL.text = @"您已开通VIP会员";
                statusL.text = [NSString stringWithFormat:@"会员到期时间：%@",minstr([infoDic valueForKey:@"endtime"])];
                [kaitongBtn setTitle:@"续费VIP" forState:0];
            }else{
                vipL.text = @"您还不是VIP会员";
                statusL.text = @"无法享受会员特权";
                [kaitongBtn setTitle:@"开通VIP" forState:0];
            }
        }
    } fail:^{
        
    }];
}
- (void)kaitongBtnClick{
    if (!buyView) {
        buyView = [[vipBuyView alloc]initWithMsg:infoDic];
        [self.view addSubview:buyView];
    }
    WeakSelf;
    buyView.block = ^{
        [weakSelf requestData];
    };
    [buyView show];
    [self.view bringSubviewToFront:buyView];

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
