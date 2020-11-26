//
//  HomePageViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "HomePageViewController.h"
#import "RecommendViewController.h"
#import "FollowViewController.h"
#import "NearByViewController.h"
#import "SearchViewController.h"
#import "UIImage+GIF.h"
#import "InvitationView.h"
#import "HomeNewViewController.h"
#import "YSOnlineVC.h"
@interface HomePageViewController (){
    RecommendViewController *recommend;
    YSOnlineVC *onlineVC;
    UIButton *screenBtn;
    UIButton *searchBTN;
    InvitationView *invitationV;
}
@property(nonatomic,strong)NSArray *infoArrays;
@property (nonatomic,strong) CABasicAnimation *animation;

@end

@implementation HomePageViewController
- (void)checkAgent{
    [YBToolClass postNetworkWithUrl:@"Agent.Check" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infodic = [info firstObject];
            if (![minstr([infodic valueForKey:@"isfill"]) isEqual:@"1"] || [[Config getIsRegisterlogin] isEqual:@"1"]) {
                
                if ([minstr([infodic valueForKey:@"ismust"]) isEqual:@"1"]) {
                    
                    [Config saveRegisterlogin:@"0"];
                    
                    [self showInvitationView:YES];
                }else{
                    if ([[Config getIsRegisterlogin] isEqual:@"1"]) {
                        [Config saveRegisterlogin:@"0"];
                        [self showInvitationView:NO];
                    }
                }
            }
        }
    } fail:^{
        
    }];
}


- (void)showInvitationView:(BOOL)isForce{
    invitationV = [[InvitationView alloc]initWithType:isForce];
    [[UIApplication sharedApplication].delegate.window addSubview:invitationV];
}
- (void)pipeiBtnClick{
    NSArray * sss = _tabbarContro.tabBar.subviews;
    for (UIView *tabbarbutton in sss) {
        for (UIView *view in tabbarbutton.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                
                [view removeAllSubViews];
            }
        }
    }
    [self showTabBar];
    [_tabbarContro setSelectedIndex:1];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.adjustStatusBarHeight = YES;
    self.type = 0;
    self.cellSpacing = 8;
    self.infoArrays = [NSArray arrayWithObjects:@"推荐",@"附近",@"最新",@"关注",@"在线", nil];
    [self setBarStyle:TYPagerBarStyleProgressView];
    [self setContentFrame];
    //创建搜索按钮
    [self setView];
    self.view.backgroundColor = [UIColor whiteColor];

//    UIImageView *animaitionImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width-80, _window_height-68-ShowDiff-60, 60, 60)];
//    animaitionImgV.image = [UIImage imageNamed:@"home_match_ani"];
//    animaitionImgV.userInteractionEnabled = YES;
//    [self.view addSubview:animaitionImgV];
//
//    UIButton *pipeiBtn = [UIButton buttonWithType:0];
//    pipeiBtn.frame = CGRectMake(_window_width-80, _window_height-68-ShowDiff-60, 60, 60);
//    [pipeiBtn setImage:[UIImage imageNamed:@"home_match"] forState:0];
//    [pipeiBtn addTarget:self action:@selector(pipeiBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:pipeiBtn];
//    _animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//   //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
//    _animation.fromValue = [NSNumber numberWithFloat:0.f];
//    _animation.toValue = [NSNumber numberWithFloat: M_PI *2];
//    _animation.duration = 2.5;
//    _animation.autoreverses = NO;
//    _animation.fillMode = kCAFillModeForwards;
//    _animation.removedOnCompletion = NO;
//    _animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
//    [animaitionImgV.layer addAnimation:_animation forKey:nil];
    [self checkAgent];
}
- (void)setView{
    
    //搜索按钮
    searchBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBTN setImage:[UIImage imageNamed:@"home_search"] forState:UIControlStateNormal];
    searchBTN.frame = CGRectMake(_window_width-40,24 +statusbarHeight,40,40);

    searchBTN.contentMode = UIViewContentModeScaleAspectFit;
    [searchBTN addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [self.pagerBarView addSubview:searchBTN];
    screenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    screenBtn.frame = CGRectMake(searchBTN.left-40,24 +statusbarHeight,40,40);
    screenBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [screenBtn setImage:[UIImage imageNamed:@"home_筛选"] forState:UIControlStateNormal];
    [screenBtn addTarget:self action:@selector(screenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.pagerBarView addSubview:screenBtn];

}
- (void)screenBtnClick{
    
    if (self.curIndex == 0) {
        [recommend showYBScreendView];
    }else if(self.curIndex == 4){
        [onlineVC showFilterView];
    }
}
- (void)search{
    SearchViewController *search = [[SearchViewController alloc]init];
//    search.hidesBottomBarWhenPushed = YES;
    [[MXBADelegate sharedAppDelegate] pushViewController:search animated:YES];
}
#pragma mark - TYPagerControllerDataSource
- (NSInteger)numberOfControllersInPagerController
{
    return self.infoArrays.count;
}
- (NSString *)pagerController:(TYPagerController *)pagerController titleForIndex:(NSInteger)index
{
    return self.infoArrays[index];
}
- (UIViewController *)pagerController:(TYPagerController *)pagerController controllerForIndex:(NSInteger)index
{
    if (index == 0) {
        recommend = [[RecommendViewController alloc]init];
        recommend.pageView = self.pagerBarView;
        return recommend;
    }else if (index == 1){
        NearByViewController *near = [[NearByViewController alloc]init];
        near.pageView = self.pagerBarView;
        return near;

    }else if(index == 2){
        HomeNewViewController *new =[[HomeNewViewController alloc]init];
        new.pageView = self.pagerBarView;
        return new;

    }else if(index == 3){
        FollowViewController *follow = [[FollowViewController alloc]init];
        follow.pageView = self.pagerBarView;
        return follow;
    }else {
        onlineVC = [[YSOnlineVC alloc]init];
        onlineVC.pageView = self.pagerBarView;
        return onlineVC;
    }
}

// transition from index to index with animated
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated{
    [self showTabBar];
    NSLog(@"animatedanimatedanimatedanimatedanimatedanimatedanimatedanimated");
    if (self.curIndex == 0 || self.curIndex == 4) {
        screenBtn.hidden = NO;
//        searchBTN.x = _window_width-80;

    }else{
        screenBtn.hidden = YES;
//        searchBTN.x = _window_width-40;
    }
}

// transition from index to index with progress
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress{
    [self showTabBar];
    NSLog(@"progressprogressprogressprogressprogressprogressprogressprogress");
    if (self.curIndex == 0 || self.curIndex == 4) {
        screenBtn.hidden = NO;
//        searchBTN.x = _window_width-80;
    }else{
        screenBtn.hidden = YES;
//        searchBTN.x = _window_width-40;
    }

}
- (void)showTabBar

{
    if (self.tabBarController.tabBar.hidden == NO)
    {
        return;
    }
    self.pagerBarView.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    
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
