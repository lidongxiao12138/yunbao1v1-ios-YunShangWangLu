//
//  TrendsHomeVC.m
//  live1v1
//
//  Created by ybRRR on 2019/8/5.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "TrendsHomeVC.h"
#import "TrendsViewController.h"
#import "EditTrendsViewController.h"
#import "NewTrendsViewController.h"
#import "FollowTrendsViewController.h"
@interface TrendsHomeVC (){
    UIButton *addBtn;

}
@property(nonatomic,strong)NSArray *infoArrays;
@property (nonatomic,strong) CABasicAnimation *animation;

@end

@implementation TrendsHomeVC
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([[Config getIsUserauth]isEqual:@"1"]) {
        addBtn.hidden = NO;
    }else{
        addBtn.hidden = YES;
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.adjustStatusBarHeight = YES;
    self.type = 0;
    self.cellSpacing = 8;
    self.infoArrays = [NSArray arrayWithObjects:@"最新",@"关注", nil];
    [self setBarStyle:TYPagerBarStyleProgressView];
    [self setContentFrame];
//    //创建发布动态按钮
    [self setView];
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)setView{
    //发布按钮
    addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setImage:[UIImage imageNamed:@"trends发布"] forState:UIControlStateNormal];
    addBtn.frame = CGRectMake(_window_width-40,24 +statusbarHeight,40,40);
    addBtn.contentMode = UIViewContentModeScaleAspectFit;
    [addBtn addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
    addBtn.hidden = YES;
    [self.pagerBarView addSubview:addBtn];
    
}
-(void)addClick{
    EditTrendsViewController *editTrends = [[EditTrendsViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:editTrends animated:YES];
    
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
       NewTrendsViewController * new = [[NewTrendsViewController alloc]init];
        new.pageView = self.pagerBarView;
        return new;
    }else{
        FollowTrendsViewController *follow = [[FollowTrendsViewController alloc]init];
        follow.pageView = self.pagerBarView;
        return follow;
    }
}

// transition from index to index with animated
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex animated:(BOOL)animated{
    [self showTabBar];
    NSLog(@"animatedanimatedanimatedanimatedanimatedanimatedanimatedanimated");
    if (self.curIndex == 0) {
        
    }else{
    }
}

// transition from index to index with progress
- (void)pagerController:(TYPagerController *)pagerController transitionFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress{
    [self showTabBar];
    NSLog(@"progressprogressprogressprogressprogressprogressprogressprogress");
    if (self.curIndex == 0) {
    }else{
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


@end
