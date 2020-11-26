//
//  SubscribeViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/18.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SubscribeViewController.h"
#import "SearchCell.h"
#import "PersonMessageViewController.h"
#import "InvitationViewController.h"
#import "TIMComm.h"
#import "TIMManager.h"
#import "TIMMessage.h"
#import "TIMConversation.h"

@interface SubscribeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SearchCellDelegate>{
    int page;
    UIButton *leftBtn;
    UIButton *rightBtn;
    UIView *lineView;
    NSString *method;

}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *infoArray;
@end

@implementation SubscribeViewController
- (void)navi{
    if ([[Config getIsauth] isEqual:@"1"]) {
        method = @"Subscribe.GetTome";
        self.titleL.hidden = YES;
        NSArray *arr = @[@"预约我的",@"我预约的"];
        for (int i = 0; i < arr.count; i++) {
            UIButton *btn = [UIButton buttonWithType:0];
            btn.frame = CGRectMake(_window_width/2-90+i*90, 24+statusbarHeight, 90, 40);
            [btn setTitle:arr[i] forState:0];
            [btn setTitleColor:color32 forState:UIControlStateSelected];
            [btn setTitleColor:color96 forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(topBtnclick:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = SYS_Font(15);
            [self.naviView addSubview:btn];
            if (i== 0) {
                btn.selected = YES;
                leftBtn = btn;
                lineView = [[UIView alloc]initWithFrame:CGRectMake(btn.centerX-7.5, 60+statusbarHeight, 15, 4)];
                lineView.layer.cornerRadius = 2;
                lineView.layer.masksToBounds = YES;
                [self.naviView addSubview:lineView];
            }else{
                btn.selected = NO;
                rightBtn = btn;
            }
        }
    }else{
        self.titleL.text = @"预约";
        method = @"Subscribe.GetMeto";
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self navi];
    page = 1;
    self.infoArray    =  [NSMutableArray array];
    [self createCollectionView];

    [self requestData];
}
- (void)topBtnclick:(UIButton *)sender{
    if (!sender.selected) {
        sender.selected = YES;
        [UIView animateWithDuration:0.2 animations:^{
            lineView.centerX = sender.centerX;
        }];
        if (sender == leftBtn) {
            method = @"Subscribe.GetTome";

            rightBtn.selected = NO;
        }else{
            method = @"Subscribe.GetMeto";
            leftBtn.selected = NO;
        }
        page = 1;
        [self requestData];
    }
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:method andParameter:@{@"p":@(page)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        if (code == 0) {
            NSArray *list = info;
            if (page == 1) {
                [_infoArray removeAllObjects];
            }
            for (NSDictionary *dic in list) {
                SearchModel *model = [[SearchModel alloc]initWithDic:dic];
                [_infoArray addObject:model];
            }
            [_collectionView reloadData];
            
            if (list.count == 0) {
                [_collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }

    } fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
    }];
}
-(void)createCollectionView{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(_window_width, 70);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-64-statusbarHeight) collectionViewLayout:flow];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SearchCell" bundle:nil] forCellWithReuseIdentifier:@"SearchCELL"];
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self requestData];
    }];
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        page ++;
        [self requestData];
    }];
    
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _infoArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SearchModel *model = _infoArray[indexPath.row];

    if (!leftBtn || rightBtn.selected) {
        [MBProgressHUD showMessage:@""];
        [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":model.userID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
    //    PersonMessageViewController *person = [[PersonMessageViewController alloc]init];
    //    [self.navigationController pushViewController:person animated:YES];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SearchCell *cell = (SearchCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCELL" forIndexPath:indexPath];
    cell.delegate = self;
    if (!leftBtn || rightBtn.selected) {
        cell.coinImgV.hidden = YES;
        cell.rightBtn.hidden = YES;
        cell.fromType = 3;
        cell.yuyueImgV.hidden = NO;
        cell.fuyueBtn.hidden = YES;
    }else{
        cell.coinImgV.hidden = NO;
        cell.rightBtn.hidden = YES;
        cell.yuyueImgV.hidden = YES;
        cell.fuyueBtn.hidden = NO;
        cell.fromType = 1;

    }
    cell.model = _infoArray[indexPath.row];
    return cell;
}
- (void)cellBtnClick:(SearchModel *)model{
    if (leftBtn && leftBtn.selected == YES) {
        NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"subscribeid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",model.subscribeid,[Config getOwnToken],[Config getOwnID]]];
        
        [YBToolClass postNetworkWithUrl:@"Live.ToAppointment" andParameter:@{@"subscribeid":model.subscribeid,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSDictionary *infoDic = [info firstObject];
                TIMConversation *conversation = [[TIMManager sharedInstance]
                                                 getConversation:TIM_C2C
                                                 receiver:model.userID];
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
                    [weakSelf showWaitView:infoDic andType:minstr([infoDic valueForKey:@"type"]) andModel:model];
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
}
- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type andModel:(SearchModel *)model{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:model.userID forKey:@"id"];
    [muDic setObject:model.avatar forKey:@"avatar"];
    [muDic setObject:model.user_nickname forKey:@"user_nickname"];
    [muDic setObject:model.level_anchor forKey:@"level_anchor"];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
