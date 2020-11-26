//
//  FollowViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "FollowViewController.h"
#import "recommendCell.h"
#import "PersonMessageViewController.h"

@interface FollowViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    CGFloat oldOffset;
    int page;
}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *infoArray;//获取到的主播列表信息


@end

@implementation FollowViewController
- (void)nothingBtnClick{
    page = 1;
    [self pullInternet];
}
- (void)viewWillAppear:(BOOL)animated{
    if (_infoArray.count == 0) {
        page = 1;
        [self pullInternet];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviView.hidden = YES;
    oldOffset = 0;
    page = 1;
    self.infoArray    =  [NSMutableArray array];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self createCollectionView];
    
}
-(void)createCollectionView{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(_window_width/2-7.5, _window_width/2-7.5);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(5, 5,5, 5);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height) collectionViewLayout:flow];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"recommendCell" bundle:nil] forCellWithReuseIdentifier:@"recommendCELL"];
    
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self pullInternet];
    }];
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        page ++;
        [self pullInternet];
    }];
    
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    _collectionView.contentInset = UIEdgeInsetsMake(64+statusbarHeight, 0, 0, 0);
    
}
//获取网络数据
-(void)pullInternet{
    
    [YBToolClass postNetworkWithUrl:@"Home.GetAttention" andParameter:@{@"p":@(page)} success:^(int code,id info,NSString *msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        if (code == 0) {
            if (page == 1) {
                [_infoArray removeAllObjects];
            }

            NSArray *infoA = info;
            for (NSDictionary *dic in infoA) {
                recommendModel *model = [[recommendModel alloc]initWithDic:dic];
                [_infoArray addObject:model];
            }
            [_collectionView reloadData];
            [_collectionView reloadData];
            if (_infoArray.count == 0) {
                self.nothingView.hidden = NO;
                self.nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
                self.nothingMsgL.text = @"你还没有关注的人";
                self.nothingBtn.hidden = YES;
                _collectionView.hidden = YES;
            }else{
                self.nothingView.hidden = YES;
                _collectionView.hidden = NO;
            }
            if (infoA.count == 0) {
                [_collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
    } fail:^{
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        if (_infoArray.count == 0) {
            _collectionView.hidden = YES;
            self.nothingView.hidden = NO;
            self.nothingImgV.image = [UIImage imageNamed:@"follow_无网络"];
            self.nothingMsgL.text = @"请检查网络链接后重试";
            self.nothingTitleL.text = @"网络请求失败";
            self.nothingBtn.hidden = NO;
            [self.nothingBtn setTitle:@"重试" forState:0];
        }
        
    }];
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _infoArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    recommendModel *model = _infoArray[indexPath.row];
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
    recommendCell *cell = (recommendCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"recommendCELL" forIndexPath:indexPath];
    cell.model = _infoArray[indexPath.row];
    return cell;
}


#pragma mark ================ 隐藏和显示tabbar ===============

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    oldOffset = scrollView.contentOffset.y;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > oldOffset) {
        if (scrollView.contentOffset.y > 0) {
            _pageView.hidden = YES;
            [self hideTabBar];
        }
    }else{
        _pageView.hidden = NO;
        [self showTabBar];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"%f",oldOffset);
}
- (void)hideTabBar {
    
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    self.tabBarController.tabBar.hidden = YES;
}
- (void)showTabBar

{
    if (self.tabBarController.tabBar.hidden == NO)
    {
        return;
    }
    self.tabBarController.tabBar.hidden = NO;
    
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
