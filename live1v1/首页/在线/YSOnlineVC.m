//
//  YSOnlineVC.m
//  live1v1
//
//  Created by YB007 on 2019/10/24.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "YSOnlineVC.h"
#import "YSOnliveCell.h"
#import "YSFiterView.h"
#import "personSelectActionView.h"
#import "TChatController.h"
#import "TConversationCell.h"
#import "InvitationViewController.h"
#import "TIMComm.h"
#import "TIMManager.h"
#import "TIMMessage.h"
#import "TIMConversation.h"
@interface YSOnlineVC ()<UITableViewDelegate,UITableViewDataSource>
{
    int _paging;
     CGFloat oldOffset;
    int _sexType;
    YSFiterView *_filterView;
    personSelectActionView *actionView;
    NSDictionary *_selPepleDic;
}
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation YSOnlineVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.dataArray.count<=0) {
        [self pullData];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.naviView.hidden = YES;
    
    _paging = 1;
    _sexType = 0;
    self.dataArray = [NSMutableArray array];
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark ============筛选弹窗=============
- (void)showFilterView{
    if (!_filterView) {
        _filterView = [[YSFiterView alloc]init];
        [[UIApplication sharedApplication].delegate.window addSubview:_filterView];
    }
    WeakSelf;
    _filterView.block = ^(NSDictionary * _Nonnull dic) {
        _sexType = [minstr([dic valueForKey:@"sex"]) intValue];
        _paging = 1;
        [weakSelf pullData];
    };
    [_filterView show];
}

#pragma mark -
-(void)pullData {
    [YBToolClass postNetworkWithUrl:@"Home.getOnlineList" andParameter:@{@"sex":@(_sexType),@"p":@(_paging)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        
        if (code == 0) {
            
            NSArray *infoA = [NSArray arrayWithArray:info];
            if (_paging == 1) {
                [_dataArray removeAllObjects];
            }
            if (infoA.count<=0) {
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [_dataArray addObjectsFromArray:infoA];
            }
            if (_dataArray.count == 0) {
                self.nothingView.hidden = NO;
                self.nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
                self.nothingMsgL.text = @"当前暂无在线用户";
                self.nothingBtn.hidden = YES;
                _tableView.hidden = YES;
            }else{
                self.nothingView.hidden = YES;
                _tableView.hidden = NO;
            }
            [_tableView reloadData];
        }else {
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
    }];
}
#pragma mark - UITableViewDelegate、UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YSOnliveCell *cell = [YSOnliveCell cellWithTab:tableView index:indexPath];
    cell.dataDic = _dataArray[indexPath.row];
    WeakSelf;
    cell.onlineEvent = ^(int eventCode) {
        [weakSelf selPaperCall:indexPath];
    };
    return cell;
}
#pragma mark- 通话开始

-(void)selPaperCall:(NSIndexPath *)indexPath {
    _selPepleDic = [NSDictionary dictionaryWithDictionary:_dataArray[indexPath.row]];
    
    if (!actionView) {
        NSArray *imgArray = @[@"person_选择语音",@"person_选择视频"];
//        NSArray *itemArray = @[[NSString stringWithFormat:@"语音通话（%@%@/分钟）",minstr([_liveDic valueForKey:@"voice_value"]),[common name_coin]],[NSString stringWithFormat:@"视频通话（%@%@/分钟）",minstr([_liveDic valueForKey:@"video_value"]),[common name_coin]]];
        NSArray *itemArray = @[@"语音通话",@"视频通话"];
        WeakSelf;
        actionView = [[personSelectActionView alloc]initWithImageArray:imgArray andItemArray:itemArray];
        actionView.block = ^(int item) {
            if (item == 0) {
                [weakSelf sendCallwithType:@"2"];
            }
            if (item == 1) {
                [weakSelf sendCallwithType:@"1"];
            }
        };
        [[UIApplication sharedApplication].delegate.window addSubview:actionView];
    }
    [[UIApplication sharedApplication].delegate.window bringSubviewToFront:actionView];
    [actionView show];
    
}
- (void)sendCallwithType:(NSString *)type{
    if ([type isEqual:@"2"]) {
        //语音
        if ([YBToolClass checkAudioAuthorization] == 2) {
            //弹出麦克风权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self sendVideoOrAudio:type];
                    }else{
                        [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                    }
                });
            }];
        }else{
            if ([YBToolClass checkAudioAuthorization] == 1) {
                [self sendVideoOrAudio:type];
            }else{
                [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
                return;
            }
            
        }
    }else{
        if ([YBToolClass checkVideoAuthorization] == 2) {
            //弹出相机权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self checkYuyinQuanxian:type];
                    }else{
                        [MBProgressHUD showError:@"未允许摄像头权限，不能视频通话"];
                    }
                });
                
            }];
        }else{
            if ([YBToolClass checkVideoAuthorization] == 1) {
                [self checkYuyinQuanxian:type];
            }else{
                [MBProgressHUD showError:@"请前往设置中打开摄像头权限"];
            }
        }
    }
    
    //视频
    
    
}
- (void)checkYuyinQuanxian:(NSString *)type{
    if ([YBToolClass checkAudioAuthorization] == 2) {
        //弹出麦克风权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self sendVideoOrAudio:type];
                }else{
                    [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                }
            });
        }];
    }else{
        if ([YBToolClass checkAudioAuthorization] == 1) {
            [self sendVideoOrAudio:type];
        }else{
            [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
            return;
        }
    }
}
#pragma mark ============视频语音通话=============
- (void)sendVideoOrAudio:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"token=%@&touid=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",[Config getOwnToken],minstr([_selPepleDic valueForKey:@"id"]),[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.checkstatus" andParameter:@{@"touid":minstr([_selPepleDic valueForKey:@"id"]),@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"status"]) isEqual:@"0"]) {
                [self userInvitationAnchor:type];
            }else{
                [self anchorInvitationlUser:type];
            }
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
}

- (void)userInvitationAnchor:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_selPepleDic valueForKey:@"id"]),[Config getOwnToken],type,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.Checklive" andParameter:@{@"liveuid":minstr([_selPepleDic valueForKey:@"id"]),@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            TIMConversation *conversation = [[TIMManager sharedInstance]
                                             getConversation:TIM_C2C
                                             receiver:minstr([_selPepleDic valueForKey:@"id"])];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"0",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":type,
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID]
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
            [custom_elem setData:data];
            TIMMessage * msg = [[TIMMessage alloc] init];
            [msg addElem:custom_elem];
            WeakSelf;
            [conversation sendMessage:msg succ:^(){
                NSLog(@"SendMsg Succ");
                [weakSelf showWaitView:infoDic andType:type];
            }fail:^(int code, NSString * err) {
                NSLog(@"SendMsg Failed:%d->%@", code, err);
                [MBProgressHUD showError:@"消息发送失败"];
                [weakSelf sendMessageFaild:infoDic andType:type];
            }];
            
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
}
- (void)anchorInvitationlUser:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"token=%@&touid=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",[Config getOwnToken],minstr([_selPepleDic valueForKey:@"id"]),type,[Config getOwnID]]];
    
    [YBToolClass postNetworkWithUrl:@"Live.anchorLaunch" andParameter:@{@"touid":minstr([_selPepleDic valueForKey:@"id"]),@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            TIMConversation *conversation = [[TIMManager sharedInstance]
                                             getConversation:TIM_C2C
                                             receiver:minstr([_selPepleDic valueForKey:@"id"])];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"2",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":minstr([infoDic valueForKey:@"type"]),
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID],
                                  @"total":minstr([infoDic valueForKey:@"total"])
                                  };
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
            [custom_elem setData:data];
            TIMMessage * msg = [[TIMMessage alloc] init];
            [msg addElem:custom_elem];
            WeakSelf;
            [conversation sendMessage:msg succ:^(){
                NSLog(@"SendMsg Succ");
                [weakSelf showWaitView:infoDic andType:minstr([infoDic valueForKey:@"type"]) andModel:nil];
            }fail:^(int code, NSString * err) {
                NSLog(@"SendMsg Failed:%d->%@", code, err);
                [MBProgressHUD showError:@"消息发送失败"];
            }];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
}
- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type andModel:(id )model{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:minstr([_selPepleDic valueForKey:@"id"]) forKey:@"id"];
    [muDic setObject:minstr([_selPepleDic valueForKey:@"avatar"]) forKey:@"avatar"];
    [muDic setObject:minstr([_selPepleDic valueForKey:@"user_nickname"]) forKey:@"user_nickname"];
    [muDic setObject:minstr([_selPepleDic valueForKey:@"level_anchor"]) forKey:@"level_anchor"];
    if ([type isEqual:@"1"]) {
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"video_value"];
    }else{
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"voice_value"];
    }
    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue]+4 andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
    
}

- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:minstr([_selPepleDic valueForKey:@"id"]) forKey:@"id"];
    [muDic setObject:minstr([_selPepleDic valueForKey:@"avatar"]) forKey:@"avatar"];
    [muDic setObject:minstr([_selPepleDic valueForKey:@"user_nickname"]) forKey:@"user_nickname"];
    [muDic setObject:minstr([_selPepleDic valueForKey:@"level_anchor"]) forKey:@"level_anchor"];
    if ([type isEqual:@"1"]) {
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"video_value"];
    }else{
        [muDic setObject:minstr([infoDic valueForKey:@"total"]) forKey:@"voice_value"];
    }
    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue] andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];
    
}
- (void)sendMessageFaild:(NSDictionary *)infoDic andType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_selPepleDic valueForKey:@"id"]),minstr([infoDic valueForKey:@"showid"]),[Config getOwnToken],[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.UserHang" andParameter:@{@"liveuid":minstr([_selPepleDic valueForKey:@"id"]),@"showid":minstr([infoDic valueForKey:@"showid"]),@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    } fail:^{
    }];
    
}

#pragma mark- 通话结束

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *subDic = _dataArray[indexPath.row];
    //私信
    TConversationCellData *data = [[TConversationCellData alloc] init];
    data.convId = minstr([subDic valueForKey:@"id"]);
    data.convType = TConv_Type_C2C;
    data.title = minstr([subDic valueForKey:@"user_nickname"]);
    data.userHeader = minstr([subDic valueForKey:@"avatar"]);
    data.userName = minstr([subDic valueForKey:@"user_nickname"]);
    data.level_anchor = minstr([subDic valueForKey:@"level_anchor"]);
    data.isauth = minstr([subDic valueForKey:@"isauth"]);
    data.isAtt = minstr([subDic valueForKey:@"u2t"]);
    data.isVIP = minstr([subDic valueForKey:@"isvip"]);
    data.isblack = minstr([subDic valueForKey:@"isblack"]);
    
    TChatController *chat = [[TChatController alloc] init];
    chat.conversation = data;
//    [self.navigationController pushViewController:chat animated:YES];
    [[MXBADelegate sharedAppDelegate]pushViewController:chat animated:YES];
    
}

#pragma mark - set/get
-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, _window_width, _window_height)style:UITableViewStylePlain];
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = Black_Cor;
        
        WeakSelf;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _paging = 1;
            [weakSelf pullData];
        }];
        
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            _paging +=1;
            [weakSelf pullData];
        }];
        _tableView.contentInset = UIEdgeInsetsMake(64+statusbarHeight, 0, 0, 0);
    }
    return _tableView;
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
@end
