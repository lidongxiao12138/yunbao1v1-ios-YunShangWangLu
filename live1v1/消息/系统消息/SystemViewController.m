//
//  SystemViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/18.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SystemViewController.h"
#import "MsgSysCell.h"
#import "SystemMsgCell.h"
@interface SystemViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *listArray;
    int page;
    UITableView *listTable;
}

@end

@implementation SystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"系统消息";
    listArray = [NSMutableArray array];
    page = 1;
    listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight) style:0];
    listTable.delegate = self;
    listTable.dataSource = self;
    listTable.separatorStyle = 0;
    //先设置预估行高
    listTable.estimatedRowHeight = 100;
    //再设置自动计算行高
    listTable.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:listTable];
    listTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        [self requestData];
    }];
    listTable.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        page ++;
        [self requestData];
    }];
    [self requestData];

}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Im.GetSysNotice" andParameter:@{@"p":@(page)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [listTable.mj_footer endRefreshing];
        [listTable.mj_header endRefreshing];
        if (code == 0) {
            if (page == 1) {
                [listArray removeAllObjects];
            }
            NSArray *infoArray = info;
            [listArray addObjectsFromArray:infoArray];
            if (infoArray.count == 0) {
                [listTable.mj_footer endRefreshingWithNoMoreData];
            }
            [listTable reloadData];
        }
    } fail:^{
        [listTable.mj_footer endRefreshing];
        [listTable.mj_header endRefreshing];

    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return listArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SystemMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SystemMsgCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SystemMsgCell" owner:nil options:nil] lastObject];
//        cell.iconIV.image = [YBToolClass getAppIcon];
    }
    NSDictionary *dic = listArray[indexPath.row];
    cell.contentL.text = minstr([dic valueForKey:@"content"]);
    cell.timeL.text = [self getDateDisplayString:[self nsstringConversionNSDate:minstr([dic valueForKey:@"addtime"])]];
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
-(NSDate *)nsstringConversionNSDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datestr = [dateFormatter dateFromString:dateStr];
    return datestr;
}
- (NSString *)getDateDisplayString:(NSDate *)date
{
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:date];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    
    NSDateComponents *comp =  [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy/MM/dd";
    }
    else{
        if (nowCmps.day==myCmps.day) {
            dateFmt.AMSymbol = @"上午";
            dateFmt.PMSymbol = @"下午";
            dateFmt.dateFormat = @"aaa hh:mm";
        } else if((nowCmps.day-myCmps.day)==1) {
            dateFmt.AMSymbol = @"上午";
            dateFmt.PMSymbol = @"下午";
            dateFmt.dateFormat = @"昨天";
        } else {
            if ((nowCmps.day-myCmps.day) <=7) {
                switch (comp.weekday) {
                    case 1:
                        dateFmt.dateFormat = @"星期日";
                        break;
                    case 2:
                        dateFmt.dateFormat = @"星期一";
                        break;
                    case 3:
                        dateFmt.dateFormat = @"星期二";
                        break;
                    case 4:
                        dateFmt.dateFormat = @"星期三";
                        break;
                    case 5:
                        dateFmt.dateFormat = @"星期四";
                        break;
                    case 6:
                        dateFmt.dateFormat = @"星期五";
                        break;
                    case 7:
                        dateFmt.dateFormat = @"星期六";
                        break;
                    default:
                        break;
                }
            }else {
                dateFmt.dateFormat = @"yyyy/MM/dd";
            }
        }
    }
    return [dateFmt stringFromDate:date];
}
- (void)doReturn{
    if (listArray.count > 0) {
        NSDictionary *dic = listArray[0];
        [[NSUserDefaults standardUserDefaults] setObject:minstr([dic valueForKey:@"addtime"]) forKey:@"lastReadSysMessage"];
    }
    [super doReturn];
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
