//
//  TrendsViewController.m
//  live1v1
//
//  Created by ybRRR on 2019/7/25.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "TrendsViewController.h"
#import "EditTrendsViewController.h"
#import "ZoneView.h"
#import "ImageBrowserViewController.h"
#import "ShowDetailVC.h"
@interface TrendsViewController ()<ZoneViewDelegate>{
    UISegmentedControl *segment1;
    
    UIButton *_newBtn;
    UIButton *_followBtn;
    UIButton *addBtn;
}

@property(nonatomic,strong)ZoneView *zoneView;

@end

@implementation TrendsViewController
-(void)creatNavi {
    
    UIView *navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];
    
    //标题
    UILabel *midLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 22+statusbarHeight, 60, 42)];
    midLabel.backgroundColor = [UIColor clearColor];
    midLabel.font = [UIFont boldSystemFontOfSize:22];
    midLabel.text = @"动态";
    midLabel.textAlignment = NSTextAlignmentCenter;
    [navi addSubview:midLabel];
    UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(22.5, 36, 15, 3)];
    lineV.layer.cornerRadius = 1.5;
    lineV.backgroundColor = normalColors;
    [midLabel addSubview:lineV];
    
    
    addBtn = [UIButton buttonWithType:0];
    addBtn.frame = CGRectMake(_window_width-60, 22+statusbarHeight, 40, 40);
    [addBtn setImage:[UIImage imageNamed:@"trends发布"] forState:0];
    [addBtn addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:addBtn];
    
//    if ([[Config getIsUserauth]isEqual:@"1"]) {
//        addBtn.hidden = NO;
//    }else{
//        addBtn.hidden = YES;
//
//    }
}
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
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self creatNavi];
    [self addSegmentView];
    [self.view addSubview:self.zoneView];
    [_zoneView layoutTableWithFlag:@"动态"];
    _zoneView.fVC = self;
    [_zoneView pullData:@"Dynamic.getDynamicList"withliveId:@""];

}
-(void)addSegmentView{
    NSArray *titleArr = @[@"最新",@"关注"];

    for (int i = 0; i < titleArr.count; i ++) {
        UIButton * titleBtn = [UIButton buttonWithType:0];
        titleBtn.frame = CGRectMake(10+10*i+60*i, 64+statusbarHeight+10, 60, 26);
        [titleBtn setTitle:titleArr[i] forState:0];
        titleBtn.layer.cornerRadius = 13;
        titleBtn.layer.masksToBounds = YES;
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [titleBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [titleBtn addTarget:self action:@selector(titleSegmentClick:) forControlEvents:UIControlEventTouchUpInside];
        titleBtn.tag = 10000+i;
        [self.view addSubview:titleBtn];

        if (i == 0) {
            titleBtn.selected = YES;
            [titleBtn setBackgroundColor:normalColors];
            _newBtn = titleBtn;
        }else{
            titleBtn.selected = NO;
            [titleBtn setBackgroundColor:RGBA(245, 245, 245, 1)];
            _followBtn = titleBtn;
        }
    }
}
-(void)titleSegmentClick:(UIButton *)sender{
    if (sender == _newBtn) {
        [_newBtn setBackgroundColor:normalColors];
        _newBtn.selected = YES;
        [_followBtn setBackgroundColor:RGBA(245, 245, 245, 1)];
        _followBtn.selected =NO;
        [_zoneView pullData:@"Dynamic.getDynamicList" withliveId:@""];

    }else{
        [_newBtn setBackgroundColor:RGBA(245, 245, 245, 1) ];
        _newBtn.selected = NO;
        [_followBtn setBackgroundColor:normalColors];
        _followBtn.selected =YES;
        [_zoneView pullData:@"Dynamic.getAttentionDynamic" withliveId:@""];

    }
    
}
-(void)addClick{
    EditTrendsViewController *editTrends = [[EditTrendsViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:editTrends animated:YES];

}

- (ZoneView *)zoneView {
    if (!_zoneView) {
        _zoneView = [[ZoneView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight+50, _window_width, _window_height-64-statusbarHeight-50)];
        _zoneView.translatesAutoresizingMaskIntoConstraints = NO;
        _zoneView.delegate = self;
    }
    return _zoneView;
}
-(void)cellImgaeClick:(NSMutableArray *)imagearr atIndex:(NSInteger)index
{
    [ImageBrowserViewController show:self type:PhotoBroswerVCTypeModal hideDelete:YES index:index imagesBlock:^NSArray *{
        return imagearr;
        
    } retrunBack:^(NSMutableArray *imgearr) {
    }];

}
-(void)cellVideoClick:(NSString *)videourl
{
    ShowDetailVC *detail = [[ShowDetailVC alloc]init];
    detail.fromStr = @"trendlist";
    detail.videoPath =videourl;
    detail.backcolor = @"video";

    detail.deleteEvent = ^(NSString *type) {
    };
    [[MXBADelegate sharedAppDelegate]pushViewController:detail animated:YES];
}
@end
