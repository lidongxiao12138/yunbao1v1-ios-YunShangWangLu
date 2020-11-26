//
//  BlackUserViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/5/11.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "BlackUserViewController.h"
#import "SearchCell.h"
#import "PersonMessageViewController.h"

@interface BlackUserViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SearchCellDelegate>{
    int page;
}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *infoArray;


@end

@implementation BlackUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"黑名单";
    self.nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
    self.nothingMsgL.text = @"你还没有拉黑的人";
    
    page = 1;
    self.infoArray    =  [NSMutableArray array];
    [self createCollectionView];
    [self requestData];
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"User.getBlackList" andParameter:@{@"p":@(page)} success:^(int code,id info,NSString *msg) {
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
        if (_infoArray.count == 0) {
            self.nothingView.hidden = NO;
            self.nothingImgV.hidden = NO;
            self.nothingMsgL.hidden = NO;
            _collectionView.hidden = YES;
        }else{
            self.nothingView.hidden = YES;
            
            self.nothingImgV.hidden = YES;
            self.nothingMsgL.hidden = YES;
            _collectionView.hidden = NO;
        }
        
    } fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        if (_infoArray.count == 0) {
            self.nothingView.hidden = NO;
            self.nothingImgV.hidden = NO;
            self.nothingMsgL.hidden = NO;
            _collectionView.hidden = YES;
        }else{
            self.nothingView.hidden = YES;
            self.nothingImgV.hidden = YES;
            self.nothingMsgL.hidden = YES;
            _collectionView.hidden = NO;
        }
        
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
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SearchCell *cell = (SearchCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCELL" forIndexPath:indexPath];
    cell.rightBtn.hidden = NO;
    [cell.rightBtn setTitle:@"  解除拉黑  " forState:0];
    [cell.rightBtn setBackgroundColor:RGB_COLOR(@"#f0f0f0", 1)];
    [cell.rightBtn setTitleColor:RGB_COLOR(@"#b3b3b3", 1) forState:0];
    SearchModel *model = _infoArray[indexPath.row];
    
    cell.delegate = self;
    cell.fromType = 5;
    cell.model = model;
    return cell;
}
- (void)cellBtnClick:(SearchModel *)model{
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"User.SetBlack" andParameter:@{@"touid":model.userID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            [_infoArray removeObject:model];
            [_collectionView reloadData];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
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
