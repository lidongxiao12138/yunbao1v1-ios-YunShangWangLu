//
//  ZYTabBarController.m
//  tabbar增加弹出bar
//
//  Created by tarena on 16/7/2.
//  Copyright © 2016年 张永强. All rights reserved.
//
#import "YBTabBarController.h"
#import "HomePageViewController.h"
#import "MineViewController.h"
#import "MessageViewController.h"
#import "FindViewController.h"
#import <Lottie/LOTAnimationView.h>
#import "TIMMessage.h"
#import "TIMManager+MsgExt.h"
#import "THeader.h"
#import "IMMessageExt.h"
#import "InvitationViewController.h"
#import "TIMGroupManager.h"
#import <UserNotifications/UserNotifications.h>
#import "TrendsViewController.h"
#import "RookieTabBar.h"
#import "TrendsHomeVC.h"
@import CoreLocation;

@interface YBTabBarController ()<UITabBarDelegate,MCTabBarControllerDelegate,CLLocationManagerDelegate,RookieTabBarDelegate>
{
    UIAlertController *alertupdate;
    NSString *type_val;
    NSString *livetype;
    UIAlertController *md5AlertController;
    NSDictionary *playDic;
    NSString *_yuyueid;
    NSString *_xianmianSecond;
    InvitationViewController *invitationVC;
    
}
@property (nonatomic,strong) CLLocationManager *lbsManager;
@property(nonatomic,strong)NSString *Build;
@property (nonatomic,strong) NSArray *imgParr;
@property (nonatomic,strong) LOTAnimationView *animation;

@end
@implementation YBTabBarController
#pragma mark ============定位=============
- (void)stopLbs {
    [_lbsManager stopUpdatingHeading];
    _lbsManager.delegate = nil;
    _lbsManager = nil;
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        liveCity *city = [cityDefault myProfile];
        city.city = @"好像在火星";
        
        [cityDefault saveProfile:city];

        [self updateUserLocationWithLatitude:@"" andLongitude:@""];
        [self stopLbs];
        
    } else {
        [_lbsManager startUpdatingLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    liveCity *city = [cityDefault myProfile];
    city.city = @"好像在火星";
    
    [cityDefault saveProfile:city];

    [self updateUserLocationWithLatitude:@"" andLongitude:@""];
    [self stopLbs];
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocatioin = locations[0];
    NSString *latitude = [NSString stringWithFormat:@"%f",newLocatioin.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",newLocatioin.coordinate.longitude];
    for (CLLocation *location in locations) {
        // 根据获取到的location实例，反编译地理位置信息
        [self reverseGeocodeWithLocation:location];
    }

    [self updateUserLocationWithLatitude:latitude andLongitude:longitude];
    [self stopLbs];
}
// 反编译地理信息
- (void) reverseGeocodeWithLocation:(CLLocation *) location {
    
    if (!location) {
        return ;
    }
    CLGeocoder *coder = [[CLGeocoder alloc]init];
    [coder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (placemarks && placemarks.count > 0) {
            CLPlacemark *mark = [placemarks firstObject];
            
            // 地级市/直辖市
            NSLog(@"locality %@", mark.locality);
            liveCity *city = [cityDefault myProfile];
            city.city = mark.locality;

            [cityDefault saveProfile:city];

        }
    }];

}
- (void)updateUserLocationWithLatitude:(NSString *)latitude andLongitude:(NSString *)longitude{
    liveCity *city = [cityDefault myProfile];
    city.lat = latitude;
    city.lng = longitude;
    [cityDefault saveProfile:city];
    [YBToolClass postNetworkWithUrl:[NSString stringWithFormat:@"User.SetLocal&lat=%@&lng=%@",latitude,longitude] andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        
    } fail:^{
        
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self getAllUnreadNum];

}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [self buildUpdate];
//    [self.tabBar setBackgroundColor:[UIColor whiteColor]];
    
//    [self.tabBar setBarTintColor:[UIColor whiteColor]];
//    self.tabBar.translucent = NO;
    //选中时的颜色
    self.mcTabbar.tintColor = [UIColor whiteColor];
    //透明设置为NO，显示白色，view的高度到tabbar顶部截止，YES的话到底部
    self.mcTabbar.translucent = NO;
    
    self.mcTabbar.position = MCTabBarCenterButtonPositionBulge;
    self.mcTabbar.centerImage = [UIImage imageNamed:@"tabbarCenter"];
    self.mcDelegate = self;

    //设置子视图
    [self setUpAllChildVc];
    [self setCusTintColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 支持定位才开启lbs
    if (!_lbsManager)
    {
        _lbsManager = [[CLLocationManager alloc] init];
        [_lbsManager setDesiredAccuracy:kCLLocationAccuracyBest];
        _lbsManager.delegate = self;
        // 兼容iOS8定位
        SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [_lbsManager respondsToSelector:requestSelector]) {
            [_lbsManager requestWhenInUseAuthorization];//调用了这句,就会弹出允许框了.
        } else {
            [_lbsManager startUpdatingLocation];
        }
    }

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];  //开始监听 防止第一次安装不显示
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusNotReachable)
        {
            [self buildUpdate];
            return;
        }else if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable){
            NSLog(@"nonetwork-------");
            [self buildUpdate];
        }else if ((status == AFNetworkReachabilityStatusReachableViaWWAN)||(status == AFNetworkReachabilityStatusReachableViaWiFi)){
            [self buildUpdate];
            NSLog(@"wifi-------");
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewMessage:) name:TUIKitNotification_TIMMessageListener object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllUnreadNum) name:TUIKitNotification_TIMCancelunread object:nil];

}
- (void)onNewMessage:(NSNotification *)notification
{
    NSArray *msgs = notification.object;
    TIMMessage *msg = [msgs lastObject];
    for (int i = 0; i < msg.elemCount; ++i) {
        TIMElem *elem = [msg getElem:i];
        if([elem isKindOfClass:[TIMCustomElem class]]){
            TIMCustomElem *custom = (TIMCustomElem *)elem;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:custom.data options:NSJSONReadingMutableContainers error:nil];
            if ([jsonDic isKindOfClass:[NSDictionary class]] && jsonDic.count > 0) {
                NSLog(@"收到消息------------------\n%@",jsonDic);
                NSString *method = minstr([jsonDic valueForKey:@"method"]);
                if ([method isEqual:@"call"]) {
                    //通话
                    int action = [minstr([jsonDic valueForKey:@"action"]) intValue];
                    //                action :    0用户发起   1用户取消
                    //                2主播发起  3主播取消
                    //                4 主播接听   5 主播拒绝
                    //                6 用户接听   7 用户拒绝
                    //                8 主播挂断   9 用户挂断
                    //                10 用户推流成功  11 主播推流成功
                    if (action == 0) {
                        //收到用户发起
                        [self showInvitationView:jsonDic];
                        UIApplicationState state = [UIApplication sharedApplication].applicationState;
                        if(state == UIApplicationStateBackground){
                            //应用在后台的话发送本地推送，展示邀请信息
                            [self showLocalPush:jsonDic];
                        }else if (state == UIApplicationStateActive){
                            NSLog(@"前台");
                        }
                        
                    }else if (action == 1 || action == 3) {
                        //用户取消邀请
                        [MBProgressHUD showError:@"对方取消通话"];
                        invitationVC.view.userInteractionEnabled = NO;
                        [invitationVC docancle];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"callStateChange" object:jsonDic];
                        
                    }else if (action == 2) {
                        //收到用户发起
                        [self showAnchorInvitationView:jsonDic];
                        UIApplicationState state = [UIApplication sharedApplication].applicationState;
                        if(state == UIApplicationStateBackground){
                            
                            [self showLocalPush:jsonDic];
                            
                        }else if (state == UIApplicationStateActive){
                            
                            NSLog(@"前台");
                        }
                        
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"callStateChange" object:jsonDic];
                    }
                    
                    if ([common voiceSwitch]) {
                        NSString *islive = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"islive"]);
                        NSString *ismessageing = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"ismessageing"]);
                        NSString *messageingUserID = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"messageingUserID"]);
                        if (![islive isEqual:@"1"])
                        {
                            if (![ismessageing isEqual:@"1"]) {
                                [self playVoice];
                            }else{
                                if (![messageingUserID isEqual:msg.sender]) {
                                    [self playVoice];
                                }
                            }

                        }
                    }
                    
                    
                }else
                    if ([method isEqual:@"livehandle"] ) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"callStateChange" object:jsonDic];
                        if ([common voiceSwitch]) {
                            NSString *islive = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"islive"]);
                            NSString *ismessageing = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"ismessageing"]);
                            NSString *messageingUserID = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"messageingUserID"]);
                            if (![islive isEqual:@"1"])
                            {
                                if (![ismessageing isEqual:@"1"]) {
                                    [self playVoice];
                                }else{
                                    if (![messageingUserID isEqual:msg.sender]) {
                                        [self playVoice];
                                    }
                                }
                                
                            }
                        }
                        
                    }else if([method isEqual:@"sendgift"]){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"callStateChange" object:jsonDic];
                        
                        if (![minstr([jsonDic valueForKey:@"uid"]) isEqual:[Config getOwnID]]) {
                            if ([common voiceSwitch]) {
                                NSString *islive = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"islive"]);
                                NSString *ismessageing = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"ismessageing"]);
                                NSString *messageingUserID = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"messageingUserID"]);
                                if (![islive isEqual:@"1"])
                                {
                                    if (![ismessageing isEqual:@"1"]) {
                                        [self playVoice];
                                    }else{
                                        if (![messageingUserID isEqual:msg.sender]) {
                                            [self playVoice];
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }else{
                        if ([common voiceSwitch]) {
                            NSString *islive = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"islive"]);
                            NSString *ismessageing = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"ismessageing"]);
                            NSString *messageingUserID = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"messageingUserID"]);
                            if (![islive isEqual:@"1"])
                            {
                                if (![ismessageing isEqual:@"1"]) {
                                    [self playVoice];
                                }else{
                                    if (![messageingUserID isEqual:msg.sender]) {
                                        [self playVoice];
                                    }
                                }
                                
                            }
                        }
                    }

            }

        }else if([elem isKindOfClass:[TIMGroupSystemElem class]]){
            TIMGroupSystemElem *custom = (TIMGroupSystemElem *)elem;
        
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:custom.userData options:NSJSONReadingMutableContainers error:nil];
            if ([jsonDic isKindOfClass:[NSDictionary class]] && jsonDic.count > 0) {

                NSLog(@"收到消息------------------\n%@\nmsg=%@----%@",jsonDic,custom.msg,msg.timestamp);
                NSString *method = minstr([jsonDic valueForKey:@"method"]);
                if ([method isEqual:@"charge"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"userChargeSucess" object:jsonDic];
                }
                if ([method isEqual:@"sysnotice"]) {
                    NSDictionary *sysDic = @{
                                             @"content":minstr([jsonDic valueForKey:@"content"]),
                                             @"time":msg.timestamp
                                             };
                    [[NSUserDefaults standardUserDefaults] setObject:sysDic forKey:@"sysnotice"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sysnotice" object:sysDic];
                }
                if ([common voiceSwitch]) {
                    NSString *islive = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"islive"]);
                    NSString *ismessageing = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"ismessageing"]);
                    NSString *messageingUserID = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"messageingUserID"]);
                    if (![islive isEqual:@"1"])
                    {
                        if (![ismessageing isEqual:@"1"]) {
                            [self playVoice];
                        }else{
                            if (![messageingUserID isEqual:msg.sender]) {
                                [self playVoice];
                            }
                        }
                        
                    }
                }
            }
        }else{
            if (![elem isKindOfClass:[TIMGroupTipsElem class]]) {

                if ([common voiceSwitch]) {
                    NSString *islive = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"islive"]);
                    NSString *ismessageing = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"ismessageing"]);
                    NSString *messageingUserID = minstr([[NSUserDefaults standardUserDefaults] objectForKey:@"messageingUserID"]);
                    if (![islive isEqual:@"1"])
                    {
                        if (![ismessageing isEqual:@"1"]) {
                            [self playVoice];
                        }else{
                            if (![messageingUserID isEqual:msg.sender]) {
                                [self playVoice];
                            }
                        }
                        
                    }
                }
            }

        }
    }
    [self getAllUnreadNum];
    
}
//收到邀请展示本地推送
- (void)showLocalPush:(NSDictionary *)dic{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    // 标题
    content.title = @"通话邀请";
    content.subtitle = @"";
    // 内容
    content.body = [NSString stringWithFormat:@"%@向你发起%@通话邀请",minstr([dic valueForKey:@"user_nickname"]),[minstr([dic valueForKey:@"type"]) intValue] == 1 ? @"视频":@"语音"];
    // 声音
    // 默认声音
//    NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:10] timeIntervalSinceNow];
//    //        NSTimeInterval time = 10;
//    // repeats，是否重复，如果重复的话时间必须大于60s，要不会报错
//    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
    
    /*
     //如果想重复可以使用这个,按日期
     // 周一早上 8：00 上班
     NSDateComponents *components = [[NSDateComponents alloc] init];
     // 注意，weekday默认是从周日开始
     components.weekday = 2;
     components.hour = 8;
     UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
     */
    // 添加通知的标识符，可以用于移除，更新等操作
    NSString *identifier = @"noticeId";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:nil];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        NSLog(@"成功添加推送");
    }];

}
- (void)getAllUnreadNum{
    TIMManager *manager = [TIMManager sharedInstance];
    NSArray *convs = [manager getConversationList];
    int unRead = 0;
    for (int i = 0; i < convs.count; i ++) {
        TIMConversation *conv = convs[i];
        if([conv getType] == TIM_SYSTEM){
            continue;
        }
        if([conv getType] == TIM_GROUP){
            continue;
        }

        int jjj = [conv getUnReadMessageNum];
        unRead += jjj;
        if (i == convs.count - 1) {
            UITabBarItem *item = [[[self tabBar] items] objectAtIndex:3];
            //设置item角标数字
            if (unRead == 0) {
                item.badgeValue= nil;
            }else{
                item.badgeValue= [NSString stringWithFormat:@"%d",unRead];
            }
        }
    }

}

#pragma mark ============通话处理=============

/**
 收到邀请
 @param dic shuju
 */
- (void)showInvitationView:(NSDictionary *)dic{
    invitationVC = [[InvitationViewController alloc]initWithType:[minstr([dic valueForKey:@"type"]) intValue]+2 andMessage:dic];
    invitationVC.showid = minstr([dic valueForKey:@"showid"]);
    invitationVC.total = @"";
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:invitationVC];
    [self presentViewController:navi animated:YES completion:nil];

}
- (void)showAnchorInvitationView:(NSDictionary *)dic{
    invitationVC = [[InvitationViewController alloc]initWithType:[minstr([dic valueForKey:@"type"]) intValue]+6 andMessage:dic];
    invitationVC.showid = minstr([dic valueForKey:@"showid"]);
    invitationVC.total = @"";
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:invitationVC];
    [self presentViewController:navi animated:YES completion:nil];
    
}



#pragma mark  在这里更换 左右tabbar的image
- (void)setUpAllChildVc {
//    RookieTabBar *tabBar = [[RookieTabBar alloc] init];
//    tabBar.rookieDelegate = self;
//    [self setValue:tabBar forKey:@"tabBar"];
//    //透明-不透明
//    [UITabBar appearance].translucent = YES;
//    //    tabBar.backgroundImage = [YBToolClass getImgWithColor:RGB_A(0, 0, 0, 0.09)];
//    tabBar.backgroundColor = [UIColor whiteColor];

    HomePageViewController *home = [HomePageViewController new];
    home.tabbarContro = self;
    FindViewController *find = [FindViewController new];
//    TrendsViewController *trends = [TrendsViewController new];
    TrendsHomeVC *trends = [TrendsHomeVC new];
    MessageViewController *message = [MessageViewController new];
    MineViewController *mine = [MineViewController new];

    [self setUpOneChildVcWithVc:home Image:@"home_gray" selectedImage:@"home_sel" title:@"首页" andTag:0];
    [self setUpOneChildVcWithVc:trends Image:@"find_nor" selectedImage:@"find_sel" title:@"动态" andTag:1];
    
    [self setUpOneChildVcWithVc:find Image:@"" selectedImage:@"" title:@"匹配" andTag:2];

    [self setUpOneChildVcWithVc:message Image:@"msg_nor" selectedImage:@"msg_sel" title:@"消息" andTag:3];
    [self setUpOneChildVcWithVc:mine Image:@"mine_nor" selectedImage:@"mine_sel" title:@"我的" andTag:4];

    

}
#pragma mark - 初始化设置tabBar上面单个按钮的方法
/**
 *  @author li bo, 16/05/10
 *
 *  设置单个tabBarButton
 *
 *  @param Vc            每一个按钮对应的控制器
 *  @param image         每一个按钮对应的普通状态下图片
 *  @param selectedImage 每一个按钮对应的选中状态下的图片
 *  @param title         每一个按钮对应的标题
 */
- (void)setUpOneChildVcWithVc:(UIViewController *)Vc Image:(NSString *)image selectedImage:(NSString *)selectedImage title:(NSString *)title andTag:(int)tttttt
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:Vc];
    UIImage *myImage = [UIImage imageNamed:image];
    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //tabBarItem，是系统提供模型，专门负责tabbar上按钮的文字以及图片展示
    Vc.tabBarItem.image = myImage;
    UIImage *mySelectedImage = [UIImage imageNamed:selectedImage];
    mySelectedImage = [mySelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    Vc.tabBarItem.selectedImage = mySelectedImage;
//    Vc.tabBarItem.title = title;
    Vc.navigationController.navigationBar.hidden = YES;
    Vc.tabBarItem.tag = tttttt;
    Vc.title = title;

    [self addChildViewController:nav];
}
-(void)setCusTintColor {
    [[UITabBarItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,SYS_Font(10),NSFontAttributeName,nil]forState:UIControlStateNormal];
    [[UITabBarItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:normalColors,NSForegroundColorAttributeName,SYS_Font(10),NSFontAttributeName,nil]forState:UIControlStateSelected];
}
//点击开始直播
-(void)buildUpdate{
    //在这里加载后台配置文件
    [YBToolClass postNetworkWithUrl:@"Home.GetConfig" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *subdic = [info firstObject];
            if (![subdic isEqual:[NSNull null]]) {
                [[TIMGroupManager sharedInstance] joinGroup:minstr([subdic valueForKey:@"full_group_id"]) msg:@"IOS Join Group" succ:^(){
                    NSLog(@"Join Succ");
                }fail:^(int code, NSString * err) {
                    NSLog(@"code=%d, err=%@", code, err);
                }];

                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地 build
                NSString *buildsss = [NSString stringWithFormat:@"%@",app_build];
                //如果不相等说明未上架，检测是否是新版本
                if (![buildsss isEqual:[NSString stringWithFormat:@"%@",[subdic valueForKey:@"ios_shelves"]]]) {
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地
                    NSNumber *build = [subdic valueForKey:@"ipa_ver"];//远程
                    NSComparisonResult r = [app_build compare:build];
                    _Build =[NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_url"]];
                    NSString *ipa_des = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"ipa_des"]];
                    if (r == NSOrderedAscending || r == NSOrderedDescending) {//可改为if(r == -1L)
                        alertupdate = [UIAlertController alertControllerWithTitle:@"提示" message:ipa_des preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"使用旧版" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"前往更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_Build]];
                        }];
                        [alertupdate addAction:action1];
                        [alertupdate addAction:action2];
                        [self presentViewController:alertupdate animated:YES completion:nil];
                    }
                    NSString *maintain_switch = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"maintain_switch"]];
                    NSString *maintain_tips = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"maintain_tips"]];
                    if ([maintain_switch isEqual:@"1"]) {
                        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"维护信息" message:maintain_tips preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_Build]];
                        }];
                        [alertC addAction:action2];
                        [self presentViewController:alertC animated:YES completion:nil];
                    }
                }
                liveCommon *commons = [[liveCommon alloc]initWithDic:subdic];
                [common saveProfile:commons];
                NSLog(@"--------%@",[YBToolClass decrypt:[common getTISDKKey]]);
            }

        }
    } fail:^{
        
    }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
//    NSArray * sss = self.tabBar.subviews;
//
//
//    UIView *tabbarbutton = sss[item.tag+1];
//
//
//    for (UIView *view in tabbarbutton.subviews) {
//
//
//
//        if ([view isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
//
//
//            [self.animation removeFromSuperview];
//            NSString * name = self.imgParr[item.tag];
//            CGFloat scale = [[UIScreen mainScreen] scale];
//            name = 3.0 == scale ? [NSString stringWithFormat:@"%@@3x", name] : [NSString stringWithFormat:@"%@@2x", name];
//            LOTAnimationView *animation = [LOTAnimationView animationNamed:name];
//            [view addSubview:animation];
//            animation.bounds = CGRectMake(0, 0,view.bounds.size.width,view.bounds.size.width);
//            animation.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
//            [animation playWithCompletion:^(BOOL animationFinished) {
//                // Do Something
//            }];
//            self.animation = animation;
//        }
//
//    }
    NSArray * sss = self.tabBar.subviews;
    
    
    UIView *tabbarbutton = sss[item.tag+3];
    
    
    for (UIView *view in tabbarbutton.subviews) {
        
        
        
        if ([view isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
            
            
            [self.animation removeFromSuperview];
            NSString * name = self.imgParr[item.tag];
            CGFloat scale = [[UIScreen mainScreen] scale];
            name = 3.0 == scale ? [NSString stringWithFormat:@"%@@3x", name] : [NSString stringWithFormat:@"%@@2x", name];
            LOTAnimationView *animation = [LOTAnimationView animationNamed:name];
            [view addSubview:animation];
            animation.bounds = CGRectMake(0, 0,view.bounds.size.width,view.bounds.size.width);
            animation.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
            [animation playWithCompletion:^(BOOL animationFinished) {
                // Do Something
            }];
            self.animation = animation;
        }
        
    }

}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
//    if ([[viewController.childViewControllers firstObject] isKindOfClass:[FindViewController class]]) {
//        [MBProgressHUD showError:@"暂未开启，敬请期待"];
//        return NO;
//    }
    return YES;
}
-(NSArray *)imgParr
{
    if (!_imgParr) {
        _imgParr =@[@"shouye",@"faxian",@"",@"xiaoxi",@"wode"];
    }
    return _imgParr;
}
- (void)playVoice{
    NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:@"messageVioce" withExtension:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl,&soundID);
    AudioServicesPlaySystemSound(soundID);
}


-(void)centerBtnDidClicked {
    FindViewController *find = [[FindViewController alloc]init];
//    TCVideoRecordViewController *video = [[TCVideoRecordViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:find animated:YES];
    
}
// 使用MCTabBarController 自定义的 选中代理
- (void)mcTabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    
}

@end
