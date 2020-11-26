//
//  MineWalletViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/4.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MineWalletViewController.h"
#import "RechargeViewController.h"
#import "myProfitVC.h"
#import "MineDetailsViewController.h"

@interface MineWalletViewController ()
@property (nonatomic,strong) UILabel *coinL;

@end

@implementation MineWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"我的钱包";
    self.view.backgroundColor = colorf5;
    UIImageView *headerImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_width*0.4)];
    headerImgV.userInteractionEnabled = YES;
    headerImgV.image = [UIImage imageNamed:@"wallet_背景"];
    [self.view addSubview:headerImgV];
    
    UILabel *labelll = [[UILabel alloc]init];
    labelll.textColor = [UIColor whiteColor];
    labelll.font = SYS_Font(12);
    labelll.text = [NSString stringWithFormat:@"我的%@",[common name_coin]];
    [headerImgV addSubview:labelll];
    [labelll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV).multipliedBy(0.65);
    }];
    _coinL = [[UILabel alloc]init];
    _coinL.textColor = [UIColor whiteColor];
    _coinL.font = [UIFont boldSystemFontOfSize:28];
    _coinL.text = _coin;
    [headerImgV addSubview:_coinL];
    [_coinL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV).multipliedBy(1.11);
    }];

    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(30, headerImgV.bottom-30, _window_width-60, 150)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    [self.view addSubview:view];
    
    NSArray *titleA = @[@"充值",@"我的明细",@"我的收益"];
    NSArray *imageNameA = @[@"钱包-充值",@"钱包-明细",@"钱包-收益"];
    for (int i = 0; i < titleA.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(0, i * 50, view.width, 50);
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(20, 17, 16, 16)];
        imgV.image = [UIImage imageNamed:imageNameA[i]];
        [btn addSubview:imgV];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(imgV.right+5, imgV.top, 100, 16)];
        lable.text = titleA[i];
        lable.textColor = RGB_COLOR(@"#404040", 1);
        lable.font = SYS_Font(14);
        [btn addSubview:lable];
        if (i < titleA.count-1) {
            [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(20, 49, view.width-40, 1) andColor:RGB_COLOR(@"#eeeeee", 1) andView:btn];
        }
    }
}
- (void)btnClick:(UIButton *)sender{
    if (sender.tag == 1000) {
        //充值
        RechargeViewController * recharge = [[RechargeViewController alloc]init];
        WeakSelf;
        recharge.block = ^(NSString * _Nonnull coin) {
           weakSelf.coinL.text = coin;
        };
        [[MXBADelegate sharedAppDelegate] pushViewController:recharge animated:YES];
    }else
    if (sender.tag == 1001) {
        //明细
        MineDetailsViewController *details = [[MineDetailsViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:details animated:YES];
    }else
    {
        //收益
        myProfitVC *profit = [[myProfitVC alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:profit animated:YES];
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
