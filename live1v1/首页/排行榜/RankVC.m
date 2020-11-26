//
//  RankVC.m
//  live1v1
//
//  Created by ybRRR on 2019/7/23.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "RankVC.h"
#import "RankHeaderView.h"
#import "RankModel.h"
#import "RankCell.h"
#import "PersonMessageViewController.h"
@interface RankVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UISegmentedControl *segment1;    //收益榜、消费榜榜
    UILabel *line1;                  //收益榜下划线
    UILabel *line2;                  //消费榜榜下划线
    UISegmentedControl *segment2;    //日周月榜
    int paging;
    NSArray *oneArr;                  //收益-消费
    NSArray *twoArr;                  //日-周-月-总
    UIView *headview;               //头部视图
    UIImageView *backImg;
    
    RankHeaderView *_rankHeader1;
    RankHeaderView *_rankHeader2;
    RankHeaderView *_rankHeader3;
    
    NSString *typeStr;
    
    UIButton *_dayBtn;
    UIButton *_weekBtn;

    UIButton *_monthBtn;
    UIButton *_allBtn;
    
    UIView *nothingView;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *models;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation RankVC


-(void)creatNothingView{
    nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight+50, _window_width,300)];
    [self.view addSubview:nothingView];
    nothingView.center = self.view.center;
    
    UILabel *nothingLb = [[UILabel alloc]initWithFrame:CGRectMake(0, nothingView.height/2+10, 100, 20)];
    nothingLb.text = @"虚位以待";
    nothingLb.font = [UIFont systemFontOfSize:14];
    nothingLb.textAlignment = NSTextAlignmentCenter;
    nothingLb.textColor = [UIColor lightGrayColor];
    [nothingView addSubview:nothingLb];
    
    nothingLb.centerX = nothingView.centerX;
    
    UIImageView *iconImg = [[UIImageView alloc]init];
    iconImg.frame = CGRectMake(0,nothingLb.origin.y-70, 60, 60);
    iconImg.image = [UIImage imageNamed:@"icon_main_list_no_data"];
    [nothingView addSubview:iconImg];
    iconImg.centerX = nothingLb.centerX;
    nothingView.hidden = YES;
    
}
-(void)pullData {
    NSString *postUrl =oneArr[segment1.selectedSegmentIndex];
    NSDictionary *parameterDic = @{@"uid":[Config getOwnID],
                              @"type":typeStr,
                              @"p":@(paging)
                              };
    
    [YBToolClass postNetworkWithUrl:postUrl andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSArray *infoA = info;
            if (paging == 1) {
                [_dataArray removeAllObjects];
            }
            if (infoA.count <=0) {
                [_tableView.mj_footer endRefreshingWithNoMoreData];
                [_tableView.mj_header endRefreshing];
            }else {
                [_dataArray addObjectsFromArray:infoA];
            }
            [_tableView.mj_footer endRefreshingWithNoMoreData];
            [_tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        }else {
            [MBProgressHUD showError:msg];
        }
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        [_tableView.mj_header endRefreshing];
    } fail:^{
        [MBProgressHUD hideHUD];
        [_tableView.mj_footer endRefreshingWithNoMoreData];
        [_tableView.mj_header endRefreshing];

    }];

}
-(NSArray *)models {
    NSMutableArray *m_arry = [NSMutableArray array];
    for (NSDictionary *dic in _dataArray) {
        RankModel *model = [RankModel modelWithDic:dic];
        [m_arry addObject:model];
    }
    _models = m_arry;
    return _models;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];

    self.dataArray = [NSMutableArray array];
    self.models = [NSArray array];
    oneArr = @[@"Home.consumeList",@"Home.profitList"];
    twoArr = @[@"day",@"week",@"month",@"total"];
    typeStr = twoArr[0];
    [self creatNavi];
    [self creatNothingView];
    paging = 1;
    NSArray *sgArr2 = [NSArray arrayWithObjects:@"日榜",@"周榜",@"月榜", nil];
    for (int i = 0; i < sgArr2.count; i++) {
        UIButton*btn = [UIButton buttonWithType:0];
        [btn setTitle:sgArr2[i] forState:0];
        [btn setTitleColor:[UIColor lightGrayColor] forState:0];
        btn.frame = CGRectMake(10+50 *i, 75+statusbarHeight, 50, 20);
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.tag = 10000+i;
        [btn addTarget:self action:@selector(selRank:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        if (i== 0) {
            _dayBtn = btn;
        }else if(i == 1){
            _weekBtn = btn;
        }else if(i == 2){
            _monthBtn = btn;
        }
    }
    [_dayBtn setTitleColor:[UIColor blackColor] forState:0];

    UIButton *allRank = [UIButton buttonWithType:0];
    allRank.frame = CGRectMake(_window_width-60, 75+statusbarHeight, 50, 20);
    [allRank setTitle:@"总榜" forState:0];
    allRank.titleLabel.font = [UIFont systemFontOfSize:13];

    allRank.tag = 10003;
    [allRank setTitleColor:[UIColor lightGrayColor] forState:0];

    [allRank addTarget:self action:@selector(selRank:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:allRank];
    _allBtn = allRank;
    
    [self.view addSubview:self.tableView];
    
    [self pullData];

}
-(void)selRank:(UIButton *)sender{
    switch (sender.tag) {
        case 10000:
            NSLog(@"---------日榜-------------");
            [_dayBtn setTitleColor:[UIColor blackColor] forState:0];
            [_weekBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            [_monthBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            [_allBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            typeStr = twoArr[0];
            break;
        case 10001:
            NSLog(@"---------周榜-------------");
            [_dayBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            [_weekBtn setTitleColor:[UIColor blackColor] forState:0];
            [_monthBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            [_allBtn setTitleColor:[UIColor lightGrayColor] forState:0];

            typeStr = twoArr[1];

            break;
        case 10002:
            NSLog(@"---------月榜-------------");
            [_dayBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            [_weekBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            [_monthBtn setTitleColor:[UIColor blackColor] forState:0];
            [_allBtn setTitleColor:[UIColor lightGrayColor] forState:0];

            typeStr = twoArr[2];

            break;
        case 10003:
            NSLog(@"---------总榜-------------");
            [_dayBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            [_weekBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            [_monthBtn setTitleColor:[UIColor lightGrayColor] forState:0];
            [_allBtn setTitleColor:[UIColor blackColor] forState:0];

            typeStr = twoArr[3];

            break;

        default:
            break;
    }
    [self pullData];

}


#pragma mark -
#pragma mark - navi
-(void)creatNavi {
    UIView *navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];
    NSArray *sgArr1 = [NSArray arrayWithObjects:@"土豪榜",@"魅力榜", nil];
    segment1 = [[UISegmentedControl alloc]initWithItems:sgArr1];
    segment1.frame = CGRectMake(_window_width/2-80, 27+statusbarHeight, 160, 30);
    segment1.tintColor = [UIColor clearColor];
    NSDictionary *nomalC = [NSDictionary dictionaryWithObjectsAndKeys:fontMT(16),NSFontAttributeName,[UIColor grayColor], NSForegroundColorAttributeName, nil];
    [segment1 setTitleTextAttributes:nomalC forState:UIControlStateNormal];
    NSDictionary *selC = [NSDictionary dictionaryWithObjectsAndKeys:fontMT(16),NSFontAttributeName,[UIColor blackColor], NSForegroundColorAttributeName, nil];
    [segment1 setTitleTextAttributes:selC forState:UIControlStateSelected];
    segment1.selectedSegmentIndex = _topIndex;
    [segment1 addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    [navi addSubview:segment1];
    
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    returnBtn.tintColor = [UIColor blackColor];
    UIButton *bigBTN = [[UIButton alloc]initWithFrame:CGRectMake(0, 0+statusbarHeight, _window_width/3,60)];
    [bigBTN addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:bigBTN];
    returnBtn.frame = CGRectMake(10,30+statusbarHeight,30,20);[returnBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [returnBtn setImage:[UIImage imageNamed:@"navi_backImg"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:returnBtn];
    
    line1 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2-80+30, segment1.bottom, 20, 2)];
    line1.backgroundColor = normalColors;
    line1.layer.cornerRadius =1;
    line1.layer.masksToBounds = YES;
    line1.hidden = NO;
    [navi addSubview:line1];
    line2 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2-80+30+80, segment1.bottom, 20, 2)];
    line2.backgroundColor = normalColors;
    line2.layer.cornerRadius =1;
    line2.layer.masksToBounds = YES;
    line2.hidden = YES;
    [navi addSubview:line2];
    if (segment1.selectedSegmentIndex == 0) {
        line1.hidden = NO;
        line2.hidden = YES;
    }else if (segment1.selectedSegmentIndex == 1){
        line1.hidden = YES;
        line2.hidden = NO;
    }
}
- (void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark - UISegmentedControl
- (void)segmentChange:(UISegmentedControl *)seg{
    if (segment1.selectedSegmentIndex == 0) {
        line1.hidden = NO;
        line2.hidden = YES;
    }else if (segment1.selectedSegmentIndex == 1){
        line1.hidden = YES;
        line2.hidden = NO;
    }
    paging = 1;
//    [_tableView reloadData];
    [self pullData];
}
#pragma mark -
#pragma mark - tableView
-(UITableView *)tableView {
    CGFloat xb = 0;
    if (IS_IPHONE_X) {
        xb = 34;
    }
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, statusbarHeight+110, _window_width, _window_height-statusbarHeight-xb-110) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.tableHeaderView = headview;
        _tableView.backgroundView.backgroundColor = [UIColor whiteColor];
        _tableView.contentInset=UIEdgeInsetsMake(-40,0,0, 0);
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView setSeparatorColor : RGBA(245, 245, 245, 1)];
        


        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            paging = 1;
            [self pullData];
        }];
        _tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
            paging +=1;
            [self pullData];
        }];
    }
    return _tableView;
}
#pragma mark -
#pragma mark - UITableViewDelegate,UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (_window_width*2/3*296/626 + 50);
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self creatHeadview];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.models.count-3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RankModel *model = _models[indexPath.row+3];
    RankCell *cell = [RankCell cellWithTab:tableView indexPath:indexPath];
    //收益榜-0 消费榜-1
    if (segment1.selectedSegmentIndex==0) {
        model.type = @"0";
    }else{
        model.type = @"1";
    }
//    if (indexPath.row == 0) {
//        //什么都不处理
//    }else if (indexPath.row == 1){
//        cell.kkIV.image = [UIImage imageNamed:@"rank_second"];
//        cell.otherMCL.hidden = YES;
//    }else if (indexPath.row == 2){
//        cell.kkIV.image = [UIImage imageNamed:@"rank_third"];
//        cell.otherMCL.hidden = YES;
//    }else {
//        cell.otherMCL.hidden = NO;
    cell.otherMCL.text = [NSString stringWithFormat:@"%ld",indexPath.row+4];
//    }
    cell.model = model;
//    if (segment1.selectedSegmentIndex==0) {
//        cell.widthOne.constant = 20.0;
//        cell.widthTwo.constant = 20.0;
//    }else{
//        cell.widthOne.constant = 40.0;
//        cell.widthTwo.constant = 40.0;
//    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RankModel *model = _models[indexPath.row+3];

    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":model.uidStr} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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

-(void)Header2Click{
    RankModel *model = _models[1];
    
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":model.uidStr} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
-(void)Header3Click{
    RankModel *model = _models[2];
    
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":model.uidStr} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
-(void)Header1Click{
    RankModel *model = _models[0];
    
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":model.uidStr} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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

-(UIView *)creatHeadview{
    
    if (!headview) {
        headview = [[UIView alloc]init];
        headview.frame = CGRectMake(0, 0, _window_width, _window_width*2/3*296/626 + 50);
        headview.backgroundColor = [UIColor whiteColor];
        backImg= [[UIImageView alloc]init];
        backImg.frame = CGRectMake(10, 5, headview.width-20, headview.height-10);
        backImg.layer.cornerRadius = 10;
        backImg.layer.masksToBounds = YES;
        backImg.userInteractionEnabled = YES;
        [headview addSubview:backImg];

        _rankHeader1 = [[RankHeaderView alloc]initWithFrame: CGRectMake(backImg.width/3, 0, backImg.width/3, backImg.height)];
        [backImg addSubview:_rankHeader1];
        
        UITapGestureRecognizer *headTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Header1Click)];
        [_rankHeader1 addGestureRecognizer:headTap1];

        
        _rankHeader2 =[[RankHeaderView alloc]initWithFrame: CGRectMake(0, 0, backImg.width/3, backImg.height)];

        [backImg addSubview:_rankHeader2];
        UITapGestureRecognizer *headTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Header2Click)];
        [_rankHeader2 addGestureRecognizer:headTap2];

        _rankHeader3 =[[RankHeaderView alloc]initWithFrame: CGRectMake(backImg.width/3*2, 0, backImg.width/3, backImg.height)];
        [backImg addSubview:_rankHeader3];
        UITapGestureRecognizer *headTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Header3Click)];
        [_rankHeader3 addGestureRecognizer:headTap3];

    }
    if (_models.count==1) {
        RankModel *model1 = _models[0];
        if (segment1.selectedSegmentIndex==0) {
            model1.type = @"0";
        }else{
            model1.type = @"1";
        }

        [_rankHeader1 setContentData:1 withmodel: model1];
        _rankHeader1.hidden = NO;
        _rankHeader2.hidden = YES;
        _rankHeader3.hidden = YES;

    }else if(_models.count ==2){
        RankModel *model1 = _models[0];
        if (segment1.selectedSegmentIndex==0) {
            model1.type = @"0";
        }else{
            model1.type = @"1";
        }

        [_rankHeader1 setContentData:1 withmodel: model1];

        RankModel *model2 = _models[1];
        if (segment1.selectedSegmentIndex==0) {
            model2.type = @"0";
        }else{
            model2.type = @"1";
        }

        [_rankHeader2 setContentData:2 withmodel: model2];
        
        _rankHeader1.hidden = NO;
        _rankHeader2.hidden = NO;

        _rankHeader3.hidden = YES;


    }else if(_models.count >2){
        
        RankModel *model1 = _models[0];
        if (segment1.selectedSegmentIndex==0) {
            model1.type = @"0";
        }else{
            model1.type = @"1";
        }

        [_rankHeader1 setContentData:1 withmodel: model1];
        
        RankModel *model2 = _models[1];
        if (segment1.selectedSegmentIndex==0) {
            model2.type = @"0";
        }else{
            model2.type = @"1";
        }

        [_rankHeader2 setContentData:2 withmodel: model2];

        RankModel *model3 = _models[2];
        if (segment1.selectedSegmentIndex==0) {
            model3.type = @"0";
        }else{
            model3.type = @"1";
        }

        [_rankHeader3 setContentData:3 withmodel: model3];
        _rankHeader1.hidden = NO;
        _rankHeader2.hidden = NO;
        _rankHeader3.hidden = NO;


    }else{
        _rankHeader1.hidden = YES;
        _rankHeader2.hidden = YES;
        _rankHeader3.hidden = YES;

//        RankModel *model1;
//        model1.unameStr = @"";
//        model1.totalCoinStr = @"";
//        model1.iconStr = @"";
//        [_rankHeader1 setContentData:1 withmodel: model1];
//
//        [_rankHeader2  setContentData:2 withmodel: model1];
//
//        [_rankHeader3 setContentData:3 withmodel: model1];

    }

    if (segment1.selectedSegmentIndex==0) {
        if (_models.count== 0) {
            backImg.hidden = YES;
            nothingView.hidden = NO;
            [self.view bringSubviewToFront:nothingView];

        }else{
            nothingView.hidden = YES;

            backImg.hidden = NO;
            backImg.image = [UIImage imageNamed:@"背景土豪榜"];
        }
    }else{
        if (_models.count == 0) {
            backImg.hidden = YES;
            nothingView.hidden = NO;
            [self.view bringSubviewToFront:nothingView];

        }else{
            nothingView.hidden = YES;

            backImg.hidden = NO;
            backImg.image = [UIImage imageNamed:@"背景魅力榜"];
        }
    }
    return headview;
}
@end
