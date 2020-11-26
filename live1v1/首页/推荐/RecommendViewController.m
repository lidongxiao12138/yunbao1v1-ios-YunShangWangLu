//
//  RecommendViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "RecommendViewController.h"
#import "SDCycleScrollView.h"
#import "recommendCell.h"
#import "YBScreenView.h"
#import "PersonMessageViewController.h"
#import "rechargeScreenView.h"
#import "UUMarqueeView.h"
#import "RankVC.h"
#import "YSLoginEditeVC.h"
@interface RecommendViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SDCycleScrollViewDelegate,UUMarqueeViewDelegate>{
    CGFloat oldOffset;
    int page;
    UIView *collectionHeaderView;
    YBScreenView *screenView;
    rechargeScreenView *rechargeV;
    UUMarqueeView *_bannerView;
    NSArray *_meilibangArr;
    NSArray *_tuhaobangArr;

}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *infoArray;//获取到的主播列表信息
@property (nonatomic,strong) SDCycleScrollView *cycleScroll;
@property (nonatomic,strong) NSString *screenSex;
@property (nonatomic,strong) NSString *screenType;
@property (nonatomic,strong) NSArray *sliderArray;

@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviView.hidden = YES;
    oldOffset = 0;
    page = 1;
    _screenSex = @"0";
    _screenType = @"0";
    self.infoArray    =  [NSMutableArray array];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self createCollectionView];
    [self pullInternet];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChargeSucess:) name:@"userChargeSucess" object:nil];
}
- (void)createCollectionHeaderView{
    if (collectionHeaderView) {
        [collectionHeaderView removeFromSuperview];
        collectionHeaderView = nil;
    }
    collectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_width*0.293+_window_width / 7)];
    collectionHeaderView.backgroundColor = [UIColor whiteColor];
    _cycleScroll = [[SDCycleScrollView alloc]initWithFrame:CGRectMake(0, 0, collectionHeaderView.width, collectionHeaderView.height-_window_width / 6)];
    _cycleScroll.delegate = self;
    _cycleScroll.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    [collectionHeaderView addSubview:_cycleScroll];
    _cycleScroll.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _cycleScroll.autoScrollTimeInterval = 3.0;//轮播时间间隔，默认1.0秒，可自定义
    
    _bannerView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(5, _window_width*0.293+5, _window_width-10, _window_width / 7) direction:UUMarqueeViewDirectionUpward];
    _bannerView.layer.cornerRadius = 10;
    _bannerView.layer.borderColor = [UIColor colorWithRed:24/255.0 green:10/255.0 blue:40/255.0 alpha:0.1].CGColor;
    _bannerView.layer.borderWidth = 1;
    
//    _bannerView.layer.shadowColor = [UIColor colorWithRed:24/255.0 green:10/255.0 blue:40/255.0 alpha:0.1].CGColor;
//    _bannerView.layer.shadowOffset = CGSizeMake(1,1);
    _bannerView.layer.masksToBounds = YES;
    _bannerView.touchEnabled = YES;
    _bannerView.delegate = self;
    [collectionHeaderView addSubview:_bannerView];
    [_bannerView reloadData];

}
-(void)createCollectionView{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(_window_width/2-7.5, _window_width/2-7.5);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(5, 5,5, 5);
    flow.headerReferenceSize = CGSizeMake(_window_width, _window_width*0.293+_window_width / 6);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height) collectionViewLayout:flow];
    _collectionView.delegate   = self;
    _collectionView.dataSource = self;
    [self.view addSubview:_collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"recommendCell" bundle:nil] forCellWithReuseIdentifier:@"recommendCELL"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV"];
    
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
    [self pullInternet];
    
}
//获取网络数据
-(void)pullInternet{
    NSDictionary *dic = @{@"sex":_screenSex,
                          @"type":_screenType,
                          @"p":@(page)
                          };
    [YBToolClass postNetworkWithUrl:@"Home.GetHot" andParameter:dic success:^(int code,id info,NSString *msg) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        if (code == 0) {
            NSArray *infoA = [info objectAtIndex:0];
            NSArray *list = [infoA valueForKey:@"list"];
            
            
            _tuhaobangArr = [NSArray arrayWithArray: [infoA valueForKey:@"consumetop"]];
            _meilibangArr = [NSArray arrayWithArray:[infoA valueForKey:@"profittop"]];
            [_bannerView reloadData];

            if (page == 1) {
                [_infoArray removeAllObjects];
                _sliderArray = [infoA valueForKey:@"slide"];
                NSMutableArray *muArr = [NSMutableArray array];
                for (NSDictionary *dic in _sliderArray) {
                    [muArr addObject:minstr([dic valueForKey:@"image"])];
                }
                _cycleScroll.imageURLStringsGroup = muArr;

                if (!collectionHeaderView) {
                    [self createCollectionHeaderView];
                }
                

            }
            for (NSDictionary *dic in list) {
                recommendModel *model = [[recommendModel alloc]initWithDic:dic];
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
        if (_infoArray.count == 0) {
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

#pragma mark ================ collectionview头视图 ===============


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hotHeaderV" forIndexPath:indexPath];
        
        header.backgroundColor = [UIColor whiteColor];
        [header addSubview:collectionHeaderView];
        return header;
    }else{
        return nil;
    }
}
#pragma mark ============轮播图点击=============
-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    YBWebViewController *web = [[YBWebViewController alloc]init];
    web.urls = minstr([_sliderArray[index] valueForKey:@"url"]);
    [[MXBADelegate sharedAppDelegate] pushViewController:web animated:YES];
}
#pragma mark ============筛选弹窗=============
- (void)showYBScreendView{
    if (!screenView) {
        screenView = [[YBScreenView alloc]init];
        [[UIApplication sharedApplication].keyWindow addSubview:screenView];
    }
    WeakSelf;
    screenView.block = ^(NSDictionary * _Nonnull dic) {
        weakSelf.screenSex = [dic valueForKey:@"sex"];
        weakSelf.screenType = [dic valueForKey:@"type"];
        page = 1;
        [weakSelf pullInternet];
    };
    [screenView show];
}

#pragma mark ============充值飘屏=============
- (void)userChargeSucess:(NSNotification *)not{
    NSDictionary *dic = [not object];
    [self showRechargeView:dic];
}
- (void)showRechargeView:(NSDictionary *)dic{
    if (!rechargeV) {
        rechargeV = [[rechargeScreenView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight+20, _window_width, 40)];
        [self.view addSubview:rechargeV];
    }
    [rechargeV addMove:dic];
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
- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
    // 指定可视条目的行数，仅[UUMarqueeViewDirectionUpward]时被调用。
    // 当[UUMarqueeViewDirectionLeftward]时行数固定为1。
    return 1;
}
- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView{
    return 2;
}
- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView{
    UIImageView *jiangbei = [[UIImageView alloc] initWithFrame:CGRectMake(20, _window_width / 24-4, _window_width / 12*0.9, _window_width / 12*0.9)];
    jiangbei.image = [UIImage imageNamed:@"rank_奖杯"];
    [itemView addSubview:jiangbei];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(jiangbei.right + 10, jiangbei.top, _window_width / 4, jiangbei.height)];
    label.text = @"土豪榜";
    label.tag = 111;
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    [itemView addSubview:label];
    
    UIView *paihangV = [[UIView alloc] initWithFrame:CGRectMake(_window_width / 1.8, _window_width / 7 * 0.15, _window_width / 7 * 0.7 * 3 + 10, _window_width / 7 * 0.7)];
    paihangV.tag = 888;
    [itemView addSubview:paihangV];
    
    UIImageView *icon1 = [[UIImageView alloc] initWithFrame:CGRectMake(5,  paihangV.height/2-paihangV.height*0.85/2.5, paihangV.height*0.9, paihangV.height*0.9)];
    icon1.backgroundColor = [UIColor lightGrayColor];
    icon1.tag = 222;
    [paihangV addSubview:icon1];
    
    UIImageView *icon1Back = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"头像1"]];
    icon1Back.frame = CGRectMake(0, 0, paihangV.height*1.4, paihangV.height*1.4);
//    icon1Back.size = CGSizeMake(paihangV.height*1.2, paihangV.height*1.2);
    icon1Back.tag = 223;
    [paihangV addSubview:icon1Back];
    icon1Back.center = icon1.center;
//    icon1Back.center = icon1.center;

    
    UIImageView *icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(icon1.right + 5, paihangV.height/2-paihangV.height*0.85/2.5, paihangV.height*0.9, paihangV.height*0.9)];
    icon2.backgroundColor = [UIColor lightGrayColor];
    icon2.tag = 333;
    [paihangV addSubview:icon2];
    
    UIImageView *icon2Back = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"头像2"]];
    icon2Back.size = CGSizeMake(paihangV.height*1.4, paihangV.height*1.4);
    icon2Back.center = icon2.center;
    icon2Back.tag = 334;
    [paihangV addSubview:icon2Back];

    
    UIImageView *icon3 = [[UIImageView alloc] initWithFrame:CGRectMake(icon2.right + 5, paihangV.height/2-paihangV.height*0.85/2.5, paihangV.height*0.9, paihangV.height*0.9)];
    icon3.backgroundColor = [UIColor lightGrayColor];
    icon3.tag = 444;
    [paihangV addSubview:icon3];
    
    UIImageView *icon3Back = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"头像3"]];
    icon3Back.size = CGSizeMake(paihangV.height*1.4, paihangV.height*1.4);
    icon3Back.center = icon3.center;
    icon3Back.tag = 445;
    [paihangV addSubview:icon3Back];

    
    UIImageView *jiantou = [[UIImageView alloc] initWithFrame:CGRectMake(paihangV.right + 8, paihangV.center.y - 6, 8, 14)];
    jiantou.image = [UIImage imageNamed:@"rank右箭头"];
    [itemView addSubview:jiantou];
    
    icon1.layer.masksToBounds = YES;
    icon1.layer.cornerRadius = icon1.height / 2;
    icon2.layer.masksToBounds = YES;
    icon2.layer.cornerRadius = icon2.height / 2;
    icon3.layer.masksToBounds = YES;
    icon3.layer.cornerRadius = icon3.height / 2;
    
    UILabel *nullLb = [[UILabel alloc]init];
    nullLb.frame= CGRectMake(paihangV.right-80, paihangV.center.y-10, 80, 20);
    nullLb.textAlignment = NSTextAlignmentRight;
    nullLb.textColor = [UIColor grayColor];
    nullLb.font = [UIFont systemFontOfSize:14];
    nullLb.text = @"虚位以待";
    nullLb.tag = 999;
    [itemView addSubview:nullLb];
}
- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView{
    UILabel *label = [itemView viewWithTag:111];
    UIImageView *icon1 = [itemView viewWithTag:222];
    UIImageView *icon2 = [itemView viewWithTag:333];
    UIImageView *icon3 = [itemView viewWithTag:444];
    
    UIImageView *headBack1 = [itemView viewWithTag:223];
    UIImageView *headBack2 = [itemView viewWithTag:334];
    UIImageView *headBack3 = [itemView viewWithTag:445];

    UILabel *nullLb = [itemView viewWithTag:999];
    UIView *paihangV = [itemView viewWithTag:888];
    if (index == 0) {
        label.text = @"土豪榜";
        if (_tuhaobangArr.count == 0) {
            icon1.hidden = YES;
            icon2.hidden = YES;
            icon3.hidden = YES;
            headBack1.hidden = YES;
            headBack2.hidden = YES;
            headBack3.hidden = YES;
            nullLb.hidden = NO;
            
        }
        else if (_tuhaobangArr.count == 1){
            nullLb.hidden = YES;

            icon1.hidden = YES;
            icon2.hidden = YES;
            icon3.hidden = NO;
            headBack1.hidden = YES;
            headBack2.hidden = YES;
            headBack3.hidden = NO;
            [icon3 sd_setImageWithURL:[NSURL URLWithString:minstr([_tuhaobangArr[0] valueForKey:@"avatar"])]];
            
//            icon1.frame = CGRectMake(icon2.right + 5, paihangV.height/2-paihangV.height*0.85/2.5, paihangV.height*0.9, paihangV.height*0.9);
        }
        else if (_tuhaobangArr.count == 2){
            nullLb.hidden = YES;

            icon1.hidden = YES;
            icon2.hidden = NO;
            icon3.hidden = NO;
            headBack1.hidden = YES;
            headBack2.hidden = NO;
            headBack3.hidden = NO;

            [icon2 sd_setImageWithURL:[NSURL URLWithString:minstr([_tuhaobangArr[0] valueForKey:@"avatar"])]];
            [icon3 sd_setImageWithURL:[NSURL URLWithString:minstr([_tuhaobangArr[1] valueForKey:@"avatar"])]];
            
//            icon1.frame = CGRectMake(icon1.right + 5, paihangV.height/2-paihangV.height*0.85/2.5, paihangV.height*0.9, paihangV.height*0.9);
//
//            icon2.frame =CGRectMake(icon2.right + 5, paihangV.height/2-paihangV.height*0.85/2.5, paihangV.height*0.9, paihangV.height*0.9);
//            headBack1.center = icon1.center;
//            headBack2.center = icon2.center;

        }
        else if (_tuhaobangArr.count == 3){
            nullLb.hidden = YES;

            icon1.hidden = NO;
            icon2.hidden = NO;
            icon3.hidden = NO;
            headBack1.hidden = NO;
            headBack2.hidden = NO;
            headBack3.hidden = NO;

            [icon1 sd_setImageWithURL:[NSURL URLWithString:minstr([_tuhaobangArr[0] valueForKey:@"avatar"])]];
            [icon2 sd_setImageWithURL:[NSURL URLWithString:minstr([_tuhaobangArr[1] valueForKey:@"avatar"])]];
            [icon3 sd_setImageWithURL:[NSURL URLWithString:minstr([_tuhaobangArr[2] valueForKey:@"avatar"])]];
        }
    }
    else if (index == 1){
        label.text = @"魅力榜";
        if (_meilibangArr.count == 0) {
            nullLb.hidden = NO;

            icon1.hidden = YES;
            icon2.hidden = YES;
            icon3.hidden = YES;
            headBack1.hidden = YES;
            headBack2.hidden = YES;
            headBack3.hidden = YES;

        }
        else if (_meilibangArr.count == 1){
            nullLb.hidden = YES;

            icon1.hidden = YES;
            icon2.hidden = YES;
            icon3.hidden = NO;
            headBack1.hidden = YES;
            headBack2.hidden = YES;
            headBack3.hidden = NO;

            [icon3 sd_setImageWithURL:[NSURL URLWithString:minstr([_meilibangArr[0] valueForKey:@"avatar"])]];
//            icon1.frame = CGRectMake(icon2.right + 5, paihangV.height/2-paihangV.height*0.85/2.5, paihangV.height*0.9, paihangV.height*0.9);

        }
        else if (_meilibangArr.count == 2){
            nullLb.hidden = YES;

            icon1.hidden = YES;
            icon2.hidden = NO;
            icon3.hidden = NO;
            headBack1.hidden = YES;
            headBack2.hidden = NO;
            headBack3.hidden = NO;

            [icon2 sd_setImageWithURL:[NSURL URLWithString:minstr([_meilibangArr[0] valueForKey:@"avatar"])]];
            [icon3 sd_setImageWithURL:[NSURL URLWithString:minstr([_meilibangArr[1] valueForKey:@"avatar"])]];
          
//            icon1.frame = CGRectMake(icon1.right + 5, paihangV.height/2-paihangV.height*0.85/2.5, paihangV.height*0.9, paihangV.height*0.9);
//
//            icon2.frame =CGRectMake(icon2.right + 5, paihangV.height/2-paihangV.height*0.85/2.5, paihangV.height*0.9, paihangV.height*0.9);
//            headBack1.center = icon1.center;
//            headBack2.center = icon2.center;

        }
        else if (_meilibangArr.count == 3){
            nullLb.hidden = YES;

            icon1.hidden = NO;
            icon2.hidden = NO;
            icon3.hidden = NO;
            headBack1.hidden = NO;
            headBack2.hidden = NO;
            headBack3.hidden = NO;

            [icon1 sd_setImageWithURL:[NSURL URLWithString:minstr([_meilibangArr[0] valueForKey:@"avatar"])]];
            [icon2 sd_setImageWithURL:[NSURL URLWithString:minstr([_meilibangArr[1] valueForKey:@"avatar"])]];
            [icon3 sd_setImageWithURL:[NSURL URLWithString:minstr([_meilibangArr[2] valueForKey:@"avatar"])]];
        }
    }
}
- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView{
    RankVC *rank = [[RankVC alloc] init];
    rank.topIndex = index;
    [[MXBADelegate sharedAppDelegate] pushViewController:rank animated:YES];
}

@end
