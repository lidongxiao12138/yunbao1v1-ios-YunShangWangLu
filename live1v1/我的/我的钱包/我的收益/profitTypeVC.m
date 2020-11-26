//
//  profitTypeVC.m
//  yunbaolive
//
//  Created by Boom on 2018/10/11.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "profitTypeVC.h"
#import "profitTypeCell.h"
#import "addTypeView.h"
@interface profitTypeVC ()<UITableViewDelegate,UITableViewDataSource,cellDelegate>{
    UITableView *typeTable;
    NSArray *typeArray;
    UILabel *nothingLabel;
    addTypeView *addView;
}

@end

@implementation profitTypeVC
- (void)rightBtnClick{
    if (!addView) {
        addView = [[addTypeView alloc]init];
        [self.view addSubview:addView];
    }else{
        addView.hidden = NO;
    }
    __weak profitTypeVC *weakSelf = self;
    addView.block = ^{
        [weakSelf requestData];
        [addView removeFromSuperview];
        addView = nil;
    };
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"提现账户";
    self.rightBtn.hidden = NO;
    [self.rightBtn setTitle:@"添加" forState:0];

    typeTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight) style:UITableViewStylePlain];
    typeTable.delegate = self;
    typeTable.dataSource = self;
    typeTable.separatorStyle = 0;
    [self.view addSubview:typeTable];
    
    nothingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 150, _window_width, 20)];
    nothingLabel.text = @"您当前还没有设置提现账户";
    nothingLabel.textAlignment = NSTextAlignmentCenter;
    nothingLabel.font = [UIFont systemFontOfSize:14];
    nothingLabel.textColor = RGB_COLOR(@"#333333", 1);
    nothingLabel.hidden = YES;
    [self.view addSubview:nothingLabel];
    self.view.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
    [self requestData];
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Cash.GetUserAccountList" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            typeArray = info;
            if (typeArray.count > 0) {
                nothingLabel.hidden = YES;
                typeTable.hidden = NO;
                [typeTable reloadData];
            }else{
                nothingLabel.hidden = NO;
                typeTable.hidden = YES;
            }
        }else{
        }
    } fail:^{
        nothingLabel.hidden = NO;
        typeTable.hidden = YES;
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return typeArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    profitTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profitTypeCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"profitTypeCell" owner:nil options:nil] lastObject];
    }
    cell.delegate = self;
    cell.indexRow = indexPath.row;
    NSDictionary *dic = typeArray[indexPath.row];
    if ([minstr([dic valueForKey:@"id"])isEqual:_selectID]) {
        cell.stateImgView.image = [UIImage imageNamed:@"profit_sel"];
    }else{
        cell.stateImgView.image = [UIImage imageNamed:@"profit_nor"];
    }
    int type = [minstr([dic valueForKey:@"type"]) intValue];
    switch (type) {
        case 1:
            cell.typeImgView.image = [UIImage imageNamed:@"profit_alipay"];
            cell.nameL.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
            break;
        case 2:
            cell.typeImgView.image = [UIImage imageNamed:@"profit_wx"];
            cell.nameL.text = [NSString stringWithFormat:@"%@",minstr([dic valueForKey:@"account"])];
            break;
        case 3:
            cell.typeImgView.image = [UIImage imageNamed:@"profit_card"];
            cell.nameL.text = [NSString stringWithFormat:@"%@(%@)",minstr([dic valueForKey:@"account"]),minstr([dic valueForKey:@"name"])];
            break;

        default:
            break;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = typeArray[indexPath.row];
    if (![minstr([dic valueForKey:@"id"])isEqual:_selectID]) {
        self.block(dic);
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)delateIndex:(NSInteger)index{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否确定删除此提现账号？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *dic = typeArray[index];
        [YBToolClass postNetworkWithUrl:@"Cash.DelUserAccount" andParameter:@{@"id":minstr([dic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                [MBProgressHUD showError:msg];
                [self requestData];
            }else{
                [MBProgressHUD showError:msg];
            }
        } fail:^{
            
        }];
    }];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];
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
