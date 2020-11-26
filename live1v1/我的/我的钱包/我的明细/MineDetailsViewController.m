//
//  MineDetailsViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/11.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MineDetailsViewController.h"
#import <WebKit/WebKit.h>

@interface MineDetailsViewController (){
    UIButton *zhichuBtn;
    UIButton *shouruBtn;
    UIView *lineView;
    
}
@property (nonatomic,strong) WKWebView *WKWebView;

@end

@implementation MineDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatHeader];
    self.WKWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight)];
    [self.view addSubview:self.WKWebView];
    NSString *urls = [NSString stringWithFormat:@"%@/appapi/record/expend&uid=%@&token=%@",h5url,[Config getOwnID],[Config getOwnToken]];
    [self.WKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urls]]];

}
- (void)creatHeader{
    NSArray *array = @[@"支出",@"收入"];
    for (int i = 0; i < array.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(_window_width/2-90+i*(90+30), 24+statusbarHeight, 60, 40);
        [btn setTitle:array[i] forState:0];
        [btn setTitleColor:color96 forState:0];
        [btn setTitleColor:color32 forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            btn.selected = YES;
            zhichuBtn = btn;
            lineView = [[UIView alloc]initWithFrame:CGRectMake(btn.x+22.5, 24+statusbarHeight+36, 15, 4)];
            lineView.backgroundColor = normalColors;
            lineView.layer.cornerRadius = 2;
            lineView.layer.masksToBounds = YES;
            [self.naviView addSubview:lineView];

        }else{
            btn.selected = NO;
            shouruBtn = btn;
        }
        [self.naviView addSubview:btn];
    }
}
- (void)topBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        lineView.centerX = sender.centerX;
    }];
    sender.selected = YES;
    if (sender == zhichuBtn) {
        shouruBtn.selected = NO;
        NSString *urls = [NSString stringWithFormat:@"%@/appapi/record/expend&uid=%@&token=%@",h5url,[Config getOwnID],[Config getOwnToken]];
        [self.WKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urls]]];
    }else{
        zhichuBtn.selected = NO;
        NSString *urls = [NSString stringWithFormat:@"%@/appapi/record/income&uid=%@&token=%@",h5url,[Config getOwnID],[Config getOwnToken]];
        [self.WKWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urls]]];

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
