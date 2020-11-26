//
//  MineImpressViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/4.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MineImpressViewController.h"
#import "personUserCell.h"
#import "ImpressionStatisticsViewController.h"

@interface MineImpressViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *listTable;
    NSMutableArray *listArray;
    int page;
}

@end

@implementation MineImpressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([_touid isEqual:[Config getOwnID]]) {
        self.titleL.text = @"我的印象";
    }else{
        self.titleL.text = @"TA的印象";
    }
    [self.rightBtn setTitle:@"印象统计" forState:0];
    self.rightBtn.hidden = NO;
    listArray = [NSMutableArray array];
    page = 1;
    listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight) style:0];
    listTable.delegate = self;
    listTable.dataSource = self;
    listTable.separatorStyle = 0;
    [self.view addSubview:listTable];
    listTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self requestData];
    }];
    listTable.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        page ++;
        [self requestData];
    }];
    [self requestData];

}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Label.GetEvaluateList" andParameter:@{@"liveuid":_touid,@"p":@(page)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [listTable.mj_header endRefreshing];
        [listTable.mj_footer endRefreshing];

        if (code == 0) {
            if (page == 1) {
                [listArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                [listArray addObject:[[personUserModel alloc] initWithDic:dic]];
            }
            [listTable reloadData];
            if ([info count] == 0) {
                [listTable.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } fail:^{
        [listTable.mj_header endRefreshing];
        [listTable.mj_footer endRefreshing];
    }];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    personUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personUserCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"personUserCell" owner:nil options:nil] lastObject];
    }
    cell.model = listArray[indexPath.row];
    return cell;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)rightBtnClick{
    ImpressionStatisticsViewController *vc = [[ImpressionStatisticsViewController alloc]init];
    vc.touid = _touid;
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}

@end
