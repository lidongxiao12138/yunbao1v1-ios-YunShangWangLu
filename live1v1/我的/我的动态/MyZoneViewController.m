//
//  MyZoneViewController.m
//  live1v1
//
//  Created by ybRRR on 2019/8/3.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MyZoneViewController.h"
#import "ZoneView.h"
#import "ImageBrowserViewController.h"
#import "ShowDetailVC.h"
#import "EditTrendsViewController.h"
@interface MyZoneViewController ()<ZoneViewDelegate>
@property(nonatomic,strong)ZoneView *zoneView;

@end

@implementation MyZoneViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [_zoneView pullData:@"Dynamic.getHomeDynamic"withliveId:[Config getOwnID]];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleL.text = @"我的动态";
    self.rightBtn.hidden = NO;
    [self.rightBtn setImage:[UIImage imageNamed:@"trends发布"] forState:0];
    [self.rightBtn addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.zoneView];

    [_zoneView layoutTableWithFlag:@"动态"];
    _zoneView.fVC = self;

}
-(void)addClick{
    EditTrendsViewController *editTrends = [[EditTrendsViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:editTrends animated:YES];
    
}

- (ZoneView *)zoneView {
    if (!_zoneView) {
        _zoneView = [[ZoneView alloc]initWithFrame:CGRectMake(0,64+statusbarHeight, _window_width, _window_height-64-statusbarHeight)];
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
    [[MXBADelegate sharedAppDelegate]pushViewController:detail animated:NO];
}

@end
