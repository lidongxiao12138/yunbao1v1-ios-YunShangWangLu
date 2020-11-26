//
//  MessageViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MessageViewController.h"
#import "TConversationCell.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "IMMessageExt.h"
#import "TUIKit.h"
#import "TChatController.h"
#import "SubscribeViewController.h"
#import "SystemViewController.h"

@interface MessageViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate>{
    NSString *subscribeNum;
    NSMutableDictionary *sysDic;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation MessageViewController
#pragma mark - navi
-(void)creatNavi {
    
    UIView *navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];
    
    //标题
    UILabel *midLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 22+statusbarHeight, 60, 42)];
    midLabel.backgroundColor = [UIColor clearColor];
    midLabel.font = [UIFont boldSystemFontOfSize:22];
    midLabel.text = @"消息";
    midLabel.textAlignment = NSTextAlignmentCenter;
    [navi addSubview:midLabel];
    UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(22.5, 36, 15, 3)];
    lineV.layer.cornerRadius = 1.5;
    lineV.backgroundColor = normalColors;
    [midLabel addSubview:lineV];
//    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(22.5, 36, 15, 3) andColor:normalColors andView:midLabel];
    
    
    //私信
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 63+statusbarHeight, _window_width, 1) andColor:colorf5 andView:navi];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    subscribeNum = @"暂无预约";
    sysDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"sysnotice"];
    [self creatNavi];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-48-ShowDiff)];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = 0;
    [self.view addSubview:_tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sysnotice:) name:@"sysnotice" object:nil];
}
- (void)requestSystemData{
    [YBToolClass postNetworkWithUrl:@"Im.GetSysNotice" andParameter:@{@"p":@"1"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            if ([info count] > 0) {
                NSDictionary *dic = [info firstObject];

                sysDic = dic.mutableCopy;
                NSString *lastReadSysMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReadSysMessage"];
                [sysDic setObject:minstr([dic valueForKey:@"addtime"]) forKey:@"time"];

                if ([minstr([dic valueForKey:@"addtime"]) isEqual:lastReadSysMessage]) {
                    [sysDic setObject:@"0" forKey:@"unRead"];
                }else{
                    [sysDic setObject:@"9999999" forKey:@"unRead"];
                }

                [_tableView reloadData];
            }
        }
    } fail:^{
    }];
}

- (void)sysnotice:(NSNotification *)not{
    NSDictionary *dic = [not object];
    sysDic = [dic mutableCopy];
    NSString *lastReadSysMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastReadSysMessage"];
    if ([minstr([dic valueForKey:@"time"]) isEqual:lastReadSysMessage]) {
        [sysDic setObject:@"0" forKey:@"unRead"];
    }else{
        [sysDic setObject:@"9999999" forKey:@"unRead"];
    }
    [_tableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshConversations:) name:TUIKitNotification_TIMRefreshListener object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChanged:) name:TUIKitNotification_TIMConnListener object:nil];
    [self requestNums];
    [self updateConversations];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestSystemData];
    });

}
- (void)requestNums{
    [YBToolClass postNetworkWithUrl:@"Subscribe.GetSubscribeNums" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            subscribeNum = [NSString stringWithFormat:@"我有%@个预约",minstr([[info firstObject] valueForKey:@"nums"])];
            [_tableView reloadData];
        }
    } fail:^{
        
    }];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateConversations
{
    _data = [NSMutableArray array];
    TIMManager *manager = [TIMManager sharedInstance];
    NSArray *convs = [manager getConversationList];
    for (TIMConversation *conv in convs) {
        if([conv getType] == TIM_SYSTEM){
            continue;
        }
        //[conv getMessage:[[TUIKit sharedInstance] getConfig].msgCountPerRequest last:nil succ:nil fail:nil];
        TIMMessage *msg = [conv getLastMsg];
        TConversationCellData *data = [[TConversationCellData alloc] init];
        data.unRead = [conv getUnReadMessageNum];
        data.time = [self getDateDisplayString:msg.timestamp];
        data.subTitle = [self getLastDisplayString:conv];
        if([conv getType] == TIM_C2C){
            data.head = TUIKitResource(@"default_head");
        }
        else if([conv getType] == TIM_GROUP){
            data.head = TUIKitResource(@"default_group");
        }
        data.convId = [conv getReceiver];
        data.convType = (TConvType)[conv getType];
        
        if(data.convType == TConv_Type_C2C){
            data.title = data.convId;
        }
        else if(data.convType == TConv_Type_Group){
            data.title = [conv getGroupName];
            continue;
        }
        if ([data.convId isEqual:@"admin"]) {
            [_data insertObject:data atIndex:0];
        }else{
            [_data addObject:data];
        }
    }
    [self requestUserMessage];
}
- (void)requestUserMessage{
    NSString *uids = @"";
    for (TConversationCellData *data in _data) {
        uids = [uids stringByAppendingFormat:@"%@,",data.convId];
    }
    if (uids.length > 0) {
        //去掉最后一个逗号
        uids = [uids substringToIndex:[uids length] - 1];
    }
    [YBToolClass postNetworkWithUrl:[NSString stringWithFormat:@"Im.GetMultiInfo&uids=%@",uids] andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            for (int i = 0; i < [info count]; i ++) {
                TConversationCellData *data = _data[i];
                NSDictionary *dic = info[i];
                data.userName = minstr([dic valueForKey:@"user_nickname"]);
                data.userHeader = minstr([dic valueForKey:@"avatar"]);
                data.isauth = minstr([dic valueForKey:@"isauth"]);
                data.level_anchor = minstr([dic valueForKey:@"level_anchor"]);
                data.isAtt = minstr([dic valueForKey:@"u2t"]);
                data.isVIP = minstr([dic valueForKey:@"isvip"]);
                data.isblack = minstr([dic valueForKey:@"isblack"]);
            }
            [_tableView reloadData];
        }
    } fail:^{
        
    }];

}
- (void)onRefreshConversations:(NSNotification *)notification
{
    [self updateConversations];
}

- (void)onNetworkChanged:(NSNotification *)notification
{
//    TNetStatus status = (TNetStatus)[notification.object intValue];
//    switch (status) {
//        case TNet_Status_Succ:
//            [_titleView setTitle:@"消息"];
//            [_titleView stopAnimating];
//            break;
//        case TNet_Status_Connecting:
//            [_titleView setTitle:@"连接中..."];
//            [_titleView startAnimating];
//            break;
//        case TNet_Status_Disconnect:
//            [_titleView setTitle:@"消息(未连接)"];
//            [_titleView stopAnimating];
//            break;
//        case TNet_Status_ConnFailed:
//            [_titleView setTitle:@"消息(未连接)"];
//            [_titleView stopAnimating];
//            break;
//
//        default:
//            break;
//    }
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return _data.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TConversationCell getSize].height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView *vvv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 5)];
        vvv.backgroundColor = colorf5;
        return vvv;
    }
    return nil;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TConversationCellData *conv = _data[indexPath.row];
    [_data removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    TIMConversationType type = TIM_C2C;
    if(conv.convType == TConv_Type_Group){
        type = TIM_GROUP;
    }
    else if(conv.convType == TConv_Type_C2C){
        type = TIM_C2C;
    }
    [[TIMManager sharedInstance] deleteConversation:type receiver:conv.convId];
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_TIMCancelunread object:nil];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        SubscribeViewController *subscribe = [[SubscribeViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:subscribe animated:YES];
    }else if (indexPath.section == 1) {
        SystemViewController *system = [[SystemViewController alloc]init];
        [[MXBADelegate sharedAppDelegate] pushViewController:system animated:YES];
    }else if (indexPath.section == 2) {
        TChatController *chat = [[TChatController alloc] init];
        chat.conversation = _data[indexPath.row];
        [[MXBADelegate sharedAppDelegate] pushViewController:chat animated:YES];
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TConversationCell *cell  = [tableView dequeueReusableCellWithIdentifier:TConversationCell_ReuseId];
    if(!cell){
        cell = [[TConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TConversationCell_ReuseId];
    }
    if (indexPath.section == 0) {
        TConversationCellData *dataa = [[TConversationCellData alloc] init];
        dataa.head = @"预约头像";
        dataa.title = @"预约";
        dataa.userName = @"预约";
        dataa.subTitle = subscribeNum;
        [cell setData:dataa];

    }else if (indexPath.section == 1){
        TConversationCellData *dataa = [[TConversationCellData alloc] init];
        dataa.head = @"系统头像";
        dataa.title = @"系统消息";
        dataa.userName = @"系统消息";
        if (sysDic) {
            dataa.subTitle = minstr([sysDic valueForKey:@"content"]);
            dataa.time = [self getDateDisplayString:[self nsstringConversionNSDate:minstr([sysDic valueForKey:@"time"])]];
            dataa.unRead = [[sysDic valueForKey:@"unRead"] intValue];
        }else{
            dataa.subTitle = @"--";
            dataa.time = @"--";
        }
        [cell setData:dataa];

    }else{
        [cell setData:[_data objectAtIndex:indexPath.row]];
    }
    return cell;
}
-(NSDate *)nsstringConversionNSDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datestr = [dateFormatter dateFromString:dateStr];
    return datestr;
}

- (void)setData:(NSMutableArray *)data
{
    _data = data;
    [_tableView reloadData];
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

//- (UIModalPresentationStyle)

- (NSString *)getLastDisplayString:(TIMConversation *)conv
{
    NSString *str = @"";
    TIMMessageDraft *draft = [conv getDraft];
    if(draft){
        for (int i = 0; i < draft.elemCount; ++i) {
            TIMElem *elem = [draft getElem:i];
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                str = [NSString stringWithFormat:@"[草稿]%@", text.text];
                break;
            }
            else{
                continue;
            }
        }
        return str;
    }
    
    TIMMessage *msg = [conv getLastMsg];
    if(msg.status == TIM_MSG_STATUS_LOCAL_REVOKED){
        if(msg.isSelf){
            return @"你撤回了一条消息";
        }
        else{
            return [NSString stringWithFormat:@"\"%@\"撤回了一条消息", msg.sender];
        }
    }
    for (int i = 0; i < msg.elemCount; ++i) {
        TIMElem *elem = [msg getElem:i];
        if([elem isKindOfClass:[TIMTextElem class]]){
            TIMTextElem *text = (TIMTextElem *)elem;
            str = text.text;
            break;
        }
        else if([elem isKindOfClass:[TIMCustomElem class]]){
            TIMCustomElem *custom = (TIMCustomElem *)elem;
//            str = custom.ext;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:custom.data options:NSJSONReadingMutableContainers error:nil];
            if ([minstr([jsonDic valueForKey:@"method"]) isEqual:@"sendgift"]) {
                str = [NSString stringWithFormat:@"[%@]",minstr([jsonDic valueForKey:@"giftname"])];
            }else if ([minstr([jsonDic valueForKey:@"method"]) isEqual:@"call"]){
                str = @"[通话]";
            }
            break;
        }
        else if([elem isKindOfClass:[TIMImageElem class]]){
            str = @"[图片]";
            break;
        }
        else if([elem isKindOfClass:[TIMSoundElem class]]){
            str = @"[语音]";
            break;
        }
        else if([elem isKindOfClass:[TIMVideoElem class]]){
            str = @"[视频]";
            break;
        }
        else if([elem isKindOfClass:[TIMFaceElem class]]){
            str = @"[动画表情]";
            break;
        }
        else if([elem isKindOfClass:[TIMFileElem class]]){
            str = @"[文件]";
            break;
        }
        else if([elem isKindOfClass:[TIMGroupTipsElem class]]){
            TIMGroupTipsElem *tips = (TIMGroupTipsElem *)elem;
            switch (tips.type) {
                case TIM_GROUP_TIPS_TYPE_INFO_CHANGE:
                {
                    for (TIMGroupTipsElemGroupInfo *info in tips.groupChangeList) {
                        switch (info.type) {
                            case TIM_GROUP_INFO_CHANGE_GROUP_NAME:
                            {
                                str = [NSString stringWithFormat:@"\"%@\"修改群名为\"%@\"", tips.opUser, info.value];
                            }
                                break;
                            case TIM_GROUP_INFO_CHANGE_GROUP_INTRODUCTION:
                            {
                                str = [NSString stringWithFormat:@"\"%@\"修改群简介为\"%@\"", tips.opUser, info.value];
                            }
                                break;
                            case TIM_GROUP_INFO_CHANGE_GROUP_NOTIFICATION:
                            {
                                str = [NSString stringWithFormat:@"\"%@\"修改群公告为\"%@\"", tips.opUser, info.value];
                            }
                                break;
                            case TIM_GROUP_INFO_CHANGE_GROUP_OWNER:
                            {
                                str = [NSString stringWithFormat:@"\"%@\"修改群主为\"%@\"", tips.opUser, info.value];
                            }
                                break;
                            default:
                                break;
                        }
                    }
                }
                    break;
                case TIM_GROUP_TIPS_TYPE_KICKED:
                {
                    NSString *users = [tips.userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:@"\"%@\"将\"%@\"剔出群组", tips.opUser, users];
                }
                    break;
                case TIM_GROUP_TIPS_TYPE_INVITE:
                {
                    NSString *users = [tips.userList componentsJoinedByString:@"、"];
                    str = [NSString stringWithFormat:@"\"%@\"邀请\"%@\"加入群组", tips.opUser, users];
                }
                    break;
                default:
                    break;
            }
        }
        else{
            continue;
        }
    }
    return str;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
