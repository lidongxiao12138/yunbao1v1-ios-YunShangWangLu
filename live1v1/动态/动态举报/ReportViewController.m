//
//  ReportViewController.m
//  live1v1
//
//  Created by ybRRR on 2019/7/31.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "ReportViewController.h"
#import "jubaoCell.h"

@interface ReportViewController ()<UITableViewDelegate, UITableViewDataSource,UITextViewDelegate>
{
    NSDictionary *selctDic;
    NSInteger selctCount;
    UITextView *jubaoTextView;
    CGFloat textHeight;
    UILabel *placeLabel;
    UILabel *headerLabel;
    
    UIColor *bg_corlor;

}
@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,strong)UITableView *table;

@end

@implementation ReportViewController

-(void)doReturn{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requetData];
    
    //关闭IQKeyboard
    //    [IQKeyboardManager sharedManager].enable = NO;
    //    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"举报";
    self.dataArr = [NSMutableArray array];
    bg_corlor = RGB_COLOR(@"#f4f5f6", 1);
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-ShowDiff) style:UITableViewStylePlain];
    _table.delegate = self;
    _table.dataSource = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.backgroundColor = bg_corlor;//RGB(240, 240, 240);
    selctCount = 100000;
    textHeight = 0.0;
    self.view.backgroundColor = bg_corlor;
    [self.view addSubview:_table];
    
    //键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)requetData{
    [YBToolClass postNetworkWithUrl:@"Dynamic.getReport" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            _dataArr = [NSMutableArray array];
            _dataArr = [NSMutableArray arrayWithArray:info];
            [_table reloadData];
        }
        
    } fail:^{
        
    }];
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (!headerLabel) {
        headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
        headerLabel.text = @"   选择举报的理由";
        headerLabel.textColor = RGB_COLOR(@"#959697", 1);
        headerLabel.font = [UIFont systemFontOfSize:13];
        headerLabel.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
    }
    return headerLabel;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 80+110)];
    view.backgroundColor = bg_corlor;//_table.backgroundColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, _window_width-20, 30)];
    label.textColor = RGB_COLOR(@"#959697", 1);
    label.text = @"更多详细信息请在说明框中描述（选填）";
    label.font = [UIFont systemFontOfSize:13];
    [view addSubview:label];
    jubaoTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, label.bottom, _window_width-20,90)];
    jubaoTextView.delegate = self;
    jubaoTextView.layer.masksToBounds = YES;
    jubaoTextView.layer.cornerRadius = 5.0;
    jubaoTextView.font = SYS_Font(13);
    jubaoTextView.textColor = RGB_COLOR(@"#333333", 1);//RGB_COLOR(@"#333333", 1);
    jubaoTextView.backgroundColor = [UIColor whiteColor];
    [view addSubview:jubaoTextView];
    placeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 120, 15)];
    placeLabel.font = SYS_Font(12);
    placeLabel.textColor = RGB_COLOR(@"#999999", 1);
    //    placeLabel.text = @"输入举报理由";
    [jubaoTextView addSubview:placeLabel];
    UIButton *btn = [UIButton buttonWithType:0];
    btn.frame = CGRectMake(20, jubaoTextView.bottom+10, _window_width-40, 40);
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 20.0;
    [btn setBackgroundColor:normalColors];
    [btn setTitle:@"提交" forState:0];
    
    [btn addTarget:self action:@selector(dojubao) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 80+110;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    jubaoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"jubaoCell"];
    if (!cell) {
        cell = [[jubaoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"jubaoCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.leftLabel.text = [_dataArr[indexPath.row] valueForKey:@"name"];
    if (indexPath.row == selctCount) {
        cell.rightImage.image = [UIImage imageNamed:@"举报选中"];//ask_jubao2
    }else{
        cell.rightImage.image = [UIImage imageNamed:@"举报未选中"];//ask_jubao1
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self hideKeboard];
    selctDic = [NSDictionary dictionaryWithDictionary:_dataArr[indexPath.row]];
    selctCount = indexPath.row;
    [_table reloadData];
}
- (void)dojubao{
    [self hideKeboard];
    if (selctCount == 100000) {
        [MBProgressHUD showError:@"请选择举报理由"];
        return;
    }
    
    NSString *content;
    if (jubaoTextView.text == nil || jubaoTextView.text == NULL || jubaoTextView.text.length == 0) {
        content = minstr([selctDic valueForKey:@"name"]);
    }else{
        content = [NSString stringWithFormat:@"%@ %@",minstr([selctDic valueForKey:@"name"]),jubaoTextView.text];
    }
    
    
    NSMutableDictionary *parameterDic = @{
                                          @"uid":[Config getOwnID],
                                          @"dynamicid":_dongtaiId,
                                          @"content":content,
                                          }.mutableCopy;
    NSString *sign = [YBToolClass sortString:parameterDic];
    [parameterDic setObject:sign forKey:@"sign"];
    [parameterDic setObject:[Config getOwnToken] forKey:@"token"];
    [YBToolClass postNetworkWithUrl:@"Dynamic.setReport" andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [MBProgressHUD showError:msg];
            [UIView animateWithDuration:0.5 animations:^{
                [self doReturn];
            }];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (![text isEqualToString:@""]) {
        placeLabel.hidden = YES;
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        placeLabel.hidden = NO;
    }
    
    
    return YES;
}
- (void)hideKeboard{
    [jubaoTextView resignFirstResponder];
}
#pragma mark -- 获取键盘高度
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //    CGFloat height = keyboardRect.origin.y;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0.0f, -keyboardRect.size.height, _window_width, _window_height);
    }];
}
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame =CGRectMake(0, 0, _window_width, _window_height);
    }];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [jubaoTextView resignFirstResponder];
}

//-(void)creatNavi {
//    YBNavi *navi = [[YBNavi alloc]init];
//    navi.leftHidden = NO;
//    navi.rightHidden = YES;
////    navi.imgTitleSameR = YES;
//    [navi ybNaviLeft:^(id btnBack) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        [self.navigationController popViewControllerAnimated:YES];
//        [self dismissViewControllerAnimated:YES completion:nil];
//    } andRightName:nil andRight:^(id btnBack) {
//
//    } andMidTitle:YZMsg(@"举报")];
//
//    [self.view addSubview:navi];
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
