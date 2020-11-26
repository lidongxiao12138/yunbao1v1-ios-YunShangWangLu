//
//  SearchViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchCell.h"
#import "PersonMessageViewController.h"
@interface SearchViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>{
    int page;
}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *infoArray;//获取到的主播列表信息
@property (nonatomic,strong) UITextField *searchT;


@end

@implementation SearchViewController
- (void)creatNavi{
    UIView *navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];
    UIButton *cancleBtn = [UIButton buttonWithType:0];
    cancleBtn.frame = CGRectMake(_window_width-54, 29+statusbarHeight, 54, 30);
    [cancleBtn setTitle:@"取消" forState:0];
    [cancleBtn setTitleColor:color96 forState:0];
    cancleBtn.titleLabel.font = SYS_Font(14);
    [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:cancleBtn];
    _searchT = [[UITextField alloc]initWithFrame:CGRectMake(11, cancleBtn.top, _window_width-65, 30)];
    _searchT.backgroundColor = RGB_COLOR(@"#fafafa", 1);
    _searchT.font = SYS_Font(15);
    _searchT.placeholder = @"请输入主播昵称或ID";
    _searchT.layer.cornerRadius = 15;
    _searchT.layer.masksToBounds = YES;
    _searchT.delegate = self;
    _searchT.leftViewMode = UITextFieldViewModeAlways;
    _searchT.keyboardType = UIKeyboardTypeWebSearch;
    UIImageView *leftImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    leftImgView.image = [UIImage imageNamed:@"left_search"];
    _searchT.leftView = leftImgView;
    [navi addSubview:_searchT];
}
- (void)cancleBtnClick{
    [_searchT resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ================ searchBar代理 ===============
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_searchT resignFirstResponder];
    [self searchAnchorWithText:_searchT.text];
    return YES;
}
- (void)searchAnchorWithText:(NSString *)searchStr{
    [YBToolClass postNetworkWithUrl:[NSString stringWithFormat:@"Home.search&key=%@",searchStr] andParameter:@{@"p":@(page)} success:^(int code,id info,NSString *msg) {
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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviView.hidden = YES;
    page = 1;
    self.infoArray    =  [NSMutableArray array];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self creatNavi];
    [self createCollectionView];
    self.nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
    self.nothingMsgL.text = @"未找到相关内容";
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
        [self searchAnchorWithText:_searchT.text];
    }];
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        page ++;
        [self searchAnchorWithText:_searchT.text];
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
    cell.model = _infoArray[indexPath.row];
    return cell;
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
