//
//  FansViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/10.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "FansViewController.h"
#import "SearchCell.h"
#import "PersonMessageViewController.h"
#import "TChatController.h"
#import "TConversationCell.h"

@interface FansViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SearchCellDelegate>{
    int page;
}
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray *infoArray;


@end

@implementation FansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"粉丝";
    self.nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
    self.nothingMsgL.text = @"你还没有粉丝";

    page = 1;
    self.infoArray    =  [NSMutableArray array];
    [self createCollectionView];
    [self requestData];
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"User.GetFansList" andParameter:@{@"p":@(page)} success:^(int code,id info,NSString *msg) {
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
//    PersonMessageViewController *person = [[PersonMessageViewController alloc]init];
//    [self.navigationController pushViewController:person animated:YES];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SearchCell *cell = (SearchCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SearchCELL" forIndexPath:indexPath];
    cell.delegate = self;
    cell.rightBtn.hidden = NO;
    cell.coinImgV.hidden = NO;
    [cell.rightBtn setTitle:@"    私信    " forState:0];
    [cell.rightBtn setTitleColor:normalColors forState:0];
    cell.rightBtn.layer.borderColor = normalColors.CGColor;

    cell.fromType = 1;
    cell.model = _infoArray[indexPath.row];
    return cell;
}
- (void)cellBtnClick:(SearchModel *)model{
    //消息
    TConversationCellData *data = [[TConversationCellData alloc] init];
    data.convId = model.userID;
    data.convType = TConv_Type_C2C;
    data.title = model.user_nickname;
    data.userHeader = model.avatar;
    data.userName = model.user_nickname;
    data.level_anchor = model.level_anchor;
    data.isauth = model.isauth;
    data.isVIP = model.isVip;
    data.isblack = model.isblack;
    TChatController *chat = [[TChatController alloc] init];
    chat.conversation = data;
    [self.navigationController pushViewController:chat animated:YES];

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
