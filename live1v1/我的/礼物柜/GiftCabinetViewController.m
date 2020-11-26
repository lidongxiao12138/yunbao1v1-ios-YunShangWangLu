//
//  GiftCabinetViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "GiftCabinetViewController.h"
#import "GiftCabinetCell.h"
@interface GiftCabinetViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSArray *listArray;
    UILabel *allGiftNumL;
    UILabel *allGiftCoinL;
}
@property (nonatomic,strong) UICollectionView *giftCollectionV;

@end

@implementation GiftCabinetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"礼物柜";
    [self creatHeaderV];
    [self createCollectionView];
    [self requestData];
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"User.GetGiftCab" andParameter:@{@"liveuid":_userID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            allGiftNumL.text =  [NSString stringWithFormat: @"礼物数量%@",minstr([infoDic valueForKey:@"nums"])];
            allGiftCoinL.text = minstr([infoDic valueForKey:@"total"]);
            listArray = [infoDic valueForKey:@"list"];
            [_giftCollectionV reloadData];
        }
    } fail:^{
        
    }];
}
- (void)creatHeaderV{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, 50)];
    [self.view addSubview:view];
    allGiftNumL = [[UILabel alloc]init];
    allGiftNumL.font = SYS_Font(12);
    allGiftNumL.textColor = color32;
    allGiftNumL.text = @"礼物数量1233";
    [view addSubview:allGiftNumL];
    [allGiftNumL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.centerY.equalTo(view);
    }];
    UIImageView *coinImgV = [[UIImageView alloc]init];
    coinImgV.image = [UIImage imageNamed:@"coin_Icon"];
    [view addSubview:coinImgV];
    [coinImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-15);
        make.centerY.equalTo(view);
        make.width.height.mas_equalTo(12);
    }];
    allGiftCoinL = [[UILabel alloc]init];
    allGiftCoinL.font = SYS_Font(10);
    allGiftCoinL.textColor = color32;
    allGiftCoinL.text = @"3232233";
    [view addSubview:allGiftCoinL];
    [allGiftCoinL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(coinImgV.mas_left).offset(-3);
        make.centerY.equalTo(view);
    }];
    
    UILabel *label = [[UILabel alloc]init];
    label.font = SYS_Font(10);
    label.textColor = color96;
    label.text = @"总价值";
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(allGiftCoinL.mas_left).offset(-5);
        make.centerY.equalTo(view);
    }];

}
-(void)createCollectionView{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(_window_width/5, _window_width/5+40);
    flow.minimumLineSpacing = 0;
    flow.minimumInteritemSpacing = 0 ;
    flow.sectionInset = UIEdgeInsetsMake(0, 0,0, 0);
    
    _giftCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(0,64+50+statusbarHeight, _window_width, _window_height-64-50-statusbarHeight) collectionViewLayout:flow];
    _giftCollectionV.delegate   = self;
    _giftCollectionV.dataSource = self;
    [self.view addSubview:_giftCollectionV];
    [_giftCollectionV registerNib:[UINib nibWithNibName:@"GiftCabinetCell" bundle:nil] forCellWithReuseIdentifier:@"GiftCabinetCELL"];
    
    _giftCollectionV.backgroundColor = [UIColor whiteColor];

}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return listArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GiftCabinetCell *cell = (GiftCabinetCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GiftCabinetCELL" forIndexPath:indexPath];
    NSDictionary *dic = listArray[indexPath.row];
    [cell.thumbImgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])]];
    cell.nameL.text = minstr([dic valueForKey:@"name"]);
    cell.giftNumL.text = minstr([dic valueForKey:@"total_nums"]);
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
