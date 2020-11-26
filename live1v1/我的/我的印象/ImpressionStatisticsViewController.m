//
//  ImpressionStatisticsViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/4.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "ImpressionStatisticsViewController.h"
#import "authImpressCell.h"

@interface ImpressionStatisticsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    UICollectionView *collectView;
    NSArray *listArray;
}

@end

@implementation ImpressionStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"印象统计";
    self.view.backgroundColor = [UIColor whiteColor];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumLineSpacing = 10;
    flow.minimumInteritemSpacing = 10;
    flow.sectionInset = UIEdgeInsetsMake(5, 10,5, 10);
    
    collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(30,64+statusbarHeight, _window_width-60, _window_height-64-statusbarHeight) collectionViewLayout:flow];
    collectView.delegate   = self;
    collectView.dataSource = self;
    collectView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectView];
    [collectView registerNib:[UINib nibWithNibName:@"authImpressCell" bundle:nil] forCellWithReuseIdentifier:@"authImpressCELL"];
    [self requestData];
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Label.GetEvaluateCount" andParameter:@{@"liveuid":_touid} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            listArray = info;
            [collectView reloadData];
        }
    } fail:^{
        
    }];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return listArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    authImpressCell *cell = (authImpressCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"authImpressCELL" forIndexPath:indexPath];
    NSDictionary *dic = listArray[indexPath.row];
    cell.titleL.text = [NSString stringWithFormat:@"%@ %@",minstr([dic valueForKey:@"name"]),minstr([dic valueForKey:@"nums"])];
    UIColor *color= RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
    cell.titleL.layer.borderColor = color.CGColor;
    cell.titleL.backgroundColor = color;
    cell.titleL.textColor = [UIColor whiteColor];
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = listArray[indexPath.row];
    NSString *str = [NSString stringWithFormat:@"%@ %@",minstr([dic valueForKey:@"name"]),minstr([dic valueForKey:@"nums"])];
    CGFloat width = [[YBToolClass sharedInstance] widthOfString:str andFont:SYS_Font(11) andHeight:22] + 28;
    return CGSizeMake(width, 22);
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
