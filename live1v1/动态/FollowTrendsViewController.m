//
//  FollowTrendsViewController.m
//  live1v1
//
//  Created by ybRRR on 2019/8/5.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "FollowTrendsViewController.h"
#import "ZoneView.h"
#import "ImageBrowserViewController.h"
#import "ShowDetailVC.h"

@interface FollowTrendsViewController ()<ZoneViewDelegate>
@property(nonatomic,strong)ZoneView *zoneView;

@end

@implementation FollowTrendsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [_zoneView pullData:@"Dynamic.getAttentionDynamic"withliveId:@""];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.zoneView];
    [_zoneView layoutTableWithFlag:@"动态"];
    _zoneView.fVC = self;
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
    [[MXBADelegate sharedAppDelegate]pushViewController:detail animated:YES];
}

@end
