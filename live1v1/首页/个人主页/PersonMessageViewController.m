//
//  PersonMessageViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/1.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "PersonMessageViewController.h"
#import "YBPageControl.h"
#import "messageTableView.h"
#import "personWordCell.h"
#import "personImpressCell.h"
#import "personLiveCell.h"
#import "personUserCell.h"
#import "liwuview.h"
#import "AnchorViewController.h"
#import "TChatController.h"
#import "TConversationCell.h"
#import "InvitationViewController.h"
#import "TIMComm.h"
#import "TIMManager.h"
#import "TIMMessage.h"
#import "TIMConversation.h"
#import "GiftCabinetCell.h"
#import "continueGift.h"
#import "expensiveGiftV.h"//礼物
#import "MineImpressViewController.h"
#import "personSelectActionView.h"
#import "RechargeViewController.h"
#import "GiftCabinetViewController.h"
#import "videoShowCell.h"
#import "picShowCell.h"
#import "LookVideoViewController.h"
#import "liansongBackView.h"
#import "YBImageView.h"
#import "JPVideoPlayerKit.h"
#import "VIPViewController.h"
#import "ZoneView.h"
@interface PersonMessageViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,sendGiftDelegate,haohuadelegate,UICollectionViewDelegate,UICollectionViewDataSource,ZoneViewDelegate>{
    UIImageView *firstBottomV;
    UIScrollView *topScroll;
    UIView *lastView;
    CGFloat btnHeight;
    //视频语音通话发起按钮
    UIButton *callBtn;
    //礼物
    UIButton *giftBtn;
    UIButton *secondGiftBtn;
    //关注
    UIButton *followBtn;
    UIButton *secondFollowBtn;

    //消息
    UIButton *messageBtn;
    UIButton *secondMessageBtn;

    //上啦按钮
    UIButton *upSwipBtn;
    //
    YBPageControl *pageControl;
    
    int page;
    NSArray *sectionArray;
    liwuview *giftView;
    UIButton *giftZheZhao;
    int callType;
    
    expensiveGiftV *haohualiwuV;//豪华礼物
    continueGift *continueGifts;//连送礼物
    liansongBackView *liansongliwubottomview;

    personSelectActionView *actionView;
    UIView *moveLine;
    
    
    UIScrollView *bottomScrollV;
    NSMutableArray *segmentBtnArray;
    int videoPage;
    int picPage;

    
    YBAlertView *alert;
    NSArray *topImgArr;
    UIImageView *playerImgview;
    
    UIView *videoNothingView;
    UIView *picNothingView;

    NSString *blackActionTitle;
    
    BOOL isVideoAuthor;
}
@property (nonatomic,strong) UIScrollView *backScroll;
@property (nonatomic,strong) UITableView *messageTable;
@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,strong) UICollectionView *videoCollectionV;
@property (nonatomic,strong) NSMutableArray *videoArray;
@property (nonatomic,strong) UICollectionView *picCollectionV;
@property (nonatomic,strong) NSMutableArray *picArray;
@property (nonatomic,strong) ZoneView *zoneView;

@end

@implementation PersonMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.naviView.hidden = YES;
    if ([minstr([_liveDic valueForKey:@"isblack"]) isEqual:@"1"]) {
        blackActionTitle = @"解除拉黑";
    }else{
        blackActionTitle = @"拉黑";
    }
    topImgArr = [_liveDic valueForKey:@"photos_list"];
    sectionArray = @[@"个人介绍",@"个性签名",@"主播形象",@"用户印象",@"个人资料",@"礼物柜",@"用户评价"];

//    self.naviView.backgroundColor = [UIColor clearColor];
//    [self.returnBtn setImage:[UIImage imageNamed:@"white_backImg"] forState:0];
    self.view.backgroundColor = [UIColor whiteColor];
    [self creatScrollView:@{}];
}
- (void)creatScrollView:(NSDictionary *)dic{
    _backScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _backScroll.backgroundColor = [UIColor whiteColor];
    _backScroll.pagingEnabled = YES;
    _backScroll.bounces = NO;
    _backScroll.delegate = self;
    [self.view addSubview:_backScroll];
    if (@available(iOS 11.0, *)) {
        _backScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([minstr([_liveDic valueForKey:@"isvideo"]) isEqual:@"1"] && [minstr([_liveDic valueForKey:@"isvoice"]) isEqual:@"1"]) {
        callType = 1;
    }else if ([minstr([_liveDic valueForKey:@"isvideo"]) isEqual:@"1"] && [minstr([_liveDic valueForKey:@"isvoice"]) isEqual:@"0"]){
        callType = 2;
    }else if ([minstr([_liveDic valueForKey:@"isvideo"]) isEqual:@"0"] && [minstr([_liveDic valueForKey:@"isvoice"]) isEqual:@"1"]){
        callType = 3;
    }else{
        callType = 0;
    }
    topScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    topScroll.delegate = self;
    topScroll.pagingEnabled = YES;
    [_backScroll addSubview:topScroll];
    topScroll.contentSize = CGSizeMake(_window_width*topImgArr.count, 0);
    for (int i = 0; i < topImgArr.count; i++) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width*i, 0, _window_width, _window_height)];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        [imgV sd_setImageWithURL:[NSURL URLWithString:[topImgArr[i] valueForKey:@"thumb"]]];
        [topScroll addSubview:imgV];
        if (i == 0 && [minstr([topImgArr[i] valueForKey:@"type"]) isEqual:@"1"]){
            playerImgview = imgV;
        }
    }
    _backScroll.contentSize = CGSizeMake(0, _window_height*2);
    
    UIImageView* mask_top = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100+statusbarHeight)];
    [mask_top setImage:[UIImage imageNamed:@"video_record_mask_top"]];
    [_backScroll addSubview:mask_top];

    UIButton *rBtn = [UIButton buttonWithType:0];
    rBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
    //    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [rBtn setImage:[UIImage imageNamed:@"white_backImg"] forState:0];
    [rBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [_backScroll addSubview:rBtn];

    UIButton *rightBtn = [UIButton buttonWithType:0];
    rightBtn.frame = CGRectMake(_window_width-40, 24+statusbarHeight, 40, 40);

    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setImage:[UIImage imageNamed:@"三点白"] forState:0];
    [rightBtn setTintColor:[UIColor whiteColor]];
    
    [_backScroll addSubview:rightBtn];

    firstBottomV = [[UIImageView alloc]initWithFrame:CGRectMake(0, _window_height-200-ShowDiff, _window_width, 200+ShowDiff)];
    firstBottomV.image = [UIImage imageNamed:@"home_封面阴影@2x"];
    firstBottomV.contentMode = UIViewContentModeScaleAspectFill;
    firstBottomV.clipsToBounds = YES;
    firstBottomV.userInteractionEnabled = YES;
    [_backScroll addSubview:firstBottomV];
    
    if (IS_IPHONE_5) {
        btnHeight = 30.0;
    }else{
        btnHeight = 36.0;
    }
    lastView = [[UIView alloc]initWithFrame:CGRectMake(0, firstBottomV.height-60-ShowDiff, _window_width, 60+ShowDiff)];
    [firstBottomV addSubview:lastView];
    
    callBtn = [UIButton buttonWithType:0];
    callBtn.frame = CGRectMake(_window_width-(btnHeight+1)*3.33-10, (60-btnHeight)/2, btnHeight*3.33, btnHeight);
    [callBtn addTarget:self action:@selector(callBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [lastView addSubview:callBtn];
    NSArray *arr = @[@"person_礼物1",@"person_未关注1",@"person_私信1"];
    for (int i = 0; i < arr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(callBtn.left-(i+1)*(10+btnHeight), callBtn.top, btnHeight, btnHeight);
        [btn setImage:[UIImage imageNamed:arr[i]] forState:0];
        [btn addTarget:self action:@selector(lastBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [lastView addSubview:btn];
        switch (i) {
            case 0:
                giftBtn = btn;
                break;
            case 1:
                followBtn = btn;
                [followBtn setImage:[UIImage imageNamed:@"已关注1"] forState:UIControlStateSelected];
                if ([minstr([_liveDic valueForKey:@"isattent"]) isEqual:@"1"]) {
                    followBtn.selected = YES;
                }else{
                    followBtn.selected = NO;
                }
                break;
            case 2:
                messageBtn = btn;
                break;

            default:
                break;
        }
        
    }
    upSwipBtn = [UIButton buttonWithType:0];
    upSwipBtn.frame = CGRectMake(10, callBtn.top, 80, btnHeight);
    [upSwipBtn setImage:[UIImage imageNamed:@"person_上拉"] forState:0];
    [upSwipBtn setTitle:@"  上拉查看详情" forState:0];
    upSwipBtn.titleLabel.font = SYS_Font(10);
    [lastView addSubview:upSwipBtn];
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, firstBottomV.height-60-ShowDiff, _window_width, 1) andColor:RGB_COLOR(@"#fafafa", 1) andView:firstBottomV];
    UILabel *priceL = [[UILabel alloc]initWithFrame:CGRectMake(15, firstBottomV.height-61-ShowDiff-28, _window_width-30, 28)];
    priceL.font = SYS_Font(12);
    priceL.textColor = [UIColor whiteColor];
    [firstBottomV addSubview:priceL];
    if (callType == 1) {
        [callBtn setImage:[UIImage imageNamed:@"person_按钮-视频语音"] forState:0];
        priceL.text = [NSString stringWithFormat:@"视频：%@%@/分钟   语音：%@%@/分钟",minstr([_liveDic valueForKey:@"video_value"]),[common name_coin],minstr([_liveDic valueForKey:@"voice_value"]),[common name_coin]];
    }else if (callType == 2){
        [callBtn setImage:[UIImage imageNamed:@"person_按钮-视频"] forState:0];
        priceL.text = [NSString stringWithFormat:@"视频：%@%@/分钟",minstr([_liveDic valueForKey:@"video_value"]),[common name_coin]];
    }else if (callType == 3){
        [callBtn setImage:[UIImage imageNamed:@"person_按钮-语音"] forState:0];
        priceL.text = [NSString stringWithFormat:@"语音：%@%@/分钟",minstr([_liveDic valueForKey:@"voice_value"]),[common name_coin]];
    }else{
        [callBtn setImage:[UIImage imageNamed:@"person_按钮-视频语音"] forState:0];
        priceL.text = [NSString stringWithFormat:@"视频：未开启   语音：未开启"];
    }
    pageControl = [[YBPageControl alloc]initWithFrame:CGRectMake(_window_width-10-10*5, priceL.top+11.5, 10*5, 5)];
    pageControl.numberOfPages = topImgArr.count;
    pageControl.currentPageIndicatorTintColor = RGB_COLOR(@"#E014E2", 1);
    pageControl.pageIndicatorTintColor = RGB_COLOR(@"#b8b4b2", 1);
    pageControl.hidesForSinglePage = YES;
    pageControl.currentPage = 0;
    [firstBottomV addSubview:pageControl];
    
    UIImageView *sexImgV = [[UIImageView alloc]initWithFrame:CGRectMake(priceL.left, priceL.top-18, 15, 15)];
    if ([minstr([_liveDic valueForKey:@"sex"]) isEqual:@"1"]) {
        sexImgV.image = [UIImage imageNamed:@"person_性别男"];
    }else{
        sexImgV.image = [UIImage imageNamed:@"person_性别女"];
    }
    [firstBottomV addSubview:sexImgV];
    
    UIImageView *locationImgV = [[UIImageView alloc]initWithFrame:CGRectMake(sexImgV.right+10, priceL.top-18, 15, 15)];
    locationImgV.image = [UIImage imageNamed:@"person_位置"];
    [firstBottomV addSubview:locationImgV];
    NSString *city = minstr([_liveDic valueForKey:@"city"]);
    CGFloat locationWidth = [[YBToolClass sharedInstance] widthOfString:city andFont:SYS_Font(12) andHeight:15];
    UILabel *locationL = [[UILabel alloc]initWithFrame:CGRectMake(locationImgV.right+5, sexImgV.top, locationWidth, sexImgV.height)];
    locationL.font = SYS_Font(12);
    locationL.text = city;
    locationL.textColor = [UIColor whiteColor];
    [firstBottomV addSubview:locationL];

    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(locationL.right+10, sexImgV.top+2.5, 1, 10) andColor:RGB_COLOR(@"#fafafa", 1) andView:lastView];
    
    UILabel *idLabel = [[UILabel alloc]initWithFrame:CGRectMake(locationL.right+21, sexImgV.top, 100, sexImgV.height)];
    idLabel.font = SYS_Font(13);
    idLabel.text = [NSString stringWithFormat:@"ID:%@",minstr([_liveDic valueForKey:@"id"])];
    idLabel.textColor = [UIColor whiteColor];
    [firstBottomV addSubview:idLabel];
    
    NSString *name = minstr([_liveDic valueForKey:@"user_nickname"]);

    CGFloat nameWidth = [[YBToolClass sharedInstance] widthOfString:name andFont:SYS_Font(17) andHeight:24];

    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(priceL.left, sexImgV.top-34, nameWidth, 24)];
    nameLabel.font = SYS_Font(17);
    nameLabel.text = name;
    nameLabel.textColor = [UIColor whiteColor];
    [firstBottomV addSubview:nameLabel];
    
    UIImageView *starImgV = [[UIImageView alloc]initWithFrame:CGRectMake(nameLabel.right+8, nameLabel.top+4.5, 25, 15)];
    [starImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:minstr([_liveDic valueForKey:@"level_anchor"])]]];
    [firstBottomV addSubview:starImgV];

    UIImageView *stateImgV = [[UIImageView alloc]initWithFrame:CGRectMake(starImgV.right+8, nameLabel.top+4.5, 36, 15)];
    NSArray *onlineArr = @[@"离线",@"勿扰",@"在聊",@"在线"];
    stateImgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"主页状态-%@",onlineArr[[minstr([_liveDic valueForKey:@"online"]) intValue]]]];

    [firstBottomV addSubview:stateImgV];
    //rk_1029
    stateImgV.hidden = YES;
    
    if ([minstr([_liveDic valueForKey:@"isvip"]) isEqual:@"1"]) {
        UIImageView *vipImgV = [[UIImageView alloc]initWithFrame:CGRectMake(starImgV.right+8, nameLabel.top+4.5, 25, 15)];
        vipImgV.image = [UIImage imageNamed:@"vip"];
        [firstBottomV addSubview:vipImgV];
        stateImgV.x = vipImgV.right + 8;
    }

    UILabel *fansL = [[UILabel alloc]initWithFrame:CGRectMake(_window_width-60, nameLabel.top, 50, 40)];
    fansL.font = SYS_Font(13);
    fansL.numberOfLines = 2;
    fansL.text = [NSString stringWithFormat:@"%@\n粉丝",minstr([_liveDic valueForKey:@"fans"])];
    fansL.textColor = [UIColor whiteColor];
    fansL.textAlignment = NSTextAlignmentCenter;
    [firstBottomV addSubview:fansL];
    [self creatSecondPageView];
    
    liansongliwubottomview = [[liansongBackView alloc]init];
    [self.view addSubview:liansongliwubottomview];
    liansongliwubottomview.frame = CGRectMake(0, statusbarHeight + 140,300,140);

}
- (void)creatSecondPageView{
    UIView *secondView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, _window_height)];
    secondView.backgroundColor = [UIColor whiteColor];
    [_backScroll addSubview:secondView];
    
    UIView *secondNavi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    [secondView addSubview:secondNavi];
    UIButton *rBtn = [UIButton buttonWithType:0];
    rBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
    //    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [rBtn setImage:[UIImage imageNamed:@"navi_backImg"] forState:0];
    [rBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [secondNavi addSubview:rBtn];
    
    UILabel *titleL2 = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2-80, 34+statusbarHeight, 160, 20)];
    titleL2.font = SYS_Font(16);
    titleL2.textColor = color32;
    titleL2.text = minstr([_liveDic valueForKey:@"user_nickname"]);
    titleL2.textAlignment = NSTextAlignmentCenter;
    [secondNavi addSubview:titleL2];
    
    UIButton *rightBtn = [UIButton buttonWithType:0];
    rightBtn.frame = CGRectMake(_window_width-40, 24+statusbarHeight, 40, 40);
    
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setImage:[UIImage imageNamed:@"三点"] forState:0];
    [secondNavi addSubview:rightBtn];

    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, secondNavi.height-1, _window_width, 1) andColor:RGB_COLOR(@"#fafafa", 1) andView:secondNavi];
    
    UIView *secondTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, 40)];
    secondTopView.backgroundColor = [UIColor whiteColor];
    [secondView addSubview:secondTopView];
    segmentBtnArray = [NSMutableArray array];
    NSArray *array = @[@"资料",@"视频",@"相册",@"动态"];

    for (int i = 0; i < array.count; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake((_window_width-240)/5+i*((_window_width-240)/5 + 60), 0, 60, 35);
        [btn setTitle:array[i] forState:0];
        [btn setTitleColor:color32 forState:UIControlStateSelected];
        [btn setTitleColor:color96 forState:0];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [secondTopView addSubview:btn];
        if (i == 0) {
            btn.selected = YES;
            moveLine = [[UIView alloc]initWithFrame:CGRectMake(btn.centerX-7.5, 33, 15, 3)];
            moveLine.backgroundColor = normalColors;
            moveLine.layer.cornerRadius = 1.5;
            moveLine.layer.masksToBounds = YES;
            [secondTopView addSubview:moveLine];
        }
        btn.tag = 1957+i;
        [segmentBtnArray addObject:btn];
    }
    bottomScrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight+40, _window_width, _window_height-64-60-statusbarHeight-ShowDiff-40)];
    bottomScrollV.backgroundColor = [UIColor whiteColor];
    bottomScrollV.contentSize = CGSizeMake(_window_width*4, 0);
    bottomScrollV.pagingEnabled = YES;
    bottomScrollV.bounces = NO;
    bottomScrollV.delegate = self;
    [secondView addSubview:bottomScrollV];

    _messageTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height-64-60-statusbarHeight-ShowDiff-40) style:0];
    _messageTable.delegate = self;
    _messageTable.dataSource = self;
    _messageTable.separatorStyle = 0;
    _messageTable.backgroundColor = [UIColor whiteColor];
    [bottomScrollV addSubview:_messageTable];
    [_messageTable registerClass:[messageTableView class] forHeaderFooterViewReuseIdentifier:@"messageHeaderView"];
    
    _videoArray = [NSMutableArray array];
    videoPage = 1;

    [bottomScrollV addSubview:self.videoCollectionV];
    [bottomScrollV addSubview:self.picCollectionV];

    [bottomScrollV addSubview:self.zoneView];

    [_zoneView layoutTableWithFlag:@"个中"];
    _zoneView.fVC = self;
    [_zoneView pullData:@"Dynamic.getHomeDynamic" withliveId:minstr([_liveDic valueForKey:@"id"])];

    
    
    
    
    UIView *secondLastView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-60-ShowDiff, _window_width, 60+ShowDiff)];
    [secondView addSubview:secondLastView];
    
    UIButton *secondCallBtn = [UIButton buttonWithType:0];
    
    secondCallBtn.frame = CGRectMake(_window_width-(btnHeight+1)*3.33-10, (60-btnHeight)/2, btnHeight*3.33, btnHeight);
    [secondCallBtn addTarget:self action:@selector(callBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [secondLastView addSubview:secondCallBtn];
    if (callType == 1) {
        [secondCallBtn setImage:[UIImage imageNamed:@"person_按钮-视频语音"] forState:0];
    }else if (callType == 2){
        [secondCallBtn setImage:[UIImage imageNamed:@"person_按钮-视频"] forState:0];
    }else if (callType == 3){
        [secondCallBtn setImage:[UIImage imageNamed:@"person_按钮-语音"] forState:0];
    }else{
        [secondCallBtn setImage:[UIImage imageNamed:@"person_按钮-视频语音"] forState:0];
        secondCallBtn.userInteractionEnabled = NO;
    }

    NSArray *arr = @[@"person_礼物2",@"person_未关注2",@"person_私信2"];
    for (int i = 0; i < arr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(callBtn.left-(i+1)*(5+50), 5, 50, 50);
        [btn setImage:[UIImage imageNamed:arr[i]] forState:0];
        [btn addTarget:self action:@selector(lastBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [secondLastView addSubview:btn];
        switch (i) {
            case 0:
                secondGiftBtn = btn;
                break;
            case 1:
                secondFollowBtn = btn;
                [secondFollowBtn setImage:[UIImage imageNamed:@"person_已关注2"] forState:UIControlStateSelected];
                if ([minstr([_liveDic valueForKey:@"isattent"]) isEqual:@"1"]) {
                    secondFollowBtn.selected = YES;
                }else{
                    secondFollowBtn.selected = NO;
                }

                break;
            case 2:
                secondMessageBtn = btn;
                break;
                
            default:
                break;
        }
        
    }

    
    
    _listArray = [NSMutableArray array];
    page = 1;
    _messageTable.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        page ++;
        [self pullInternet];
    }];
    [self pullInternet];
    [self pullPicList];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self pullVideoList];
    });



}

- (ZoneView *)zoneView {
    if (!_zoneView) {
        _zoneView = [[ZoneView alloc]initWithFrame:CGRectMake(_window_width*3,0, _window_width, _window_height-64-60-statusbarHeight-ShowDiff-40)];
        _zoneView.translatesAutoresizingMaskIntoConstraints = NO;
        _zoneView.delegate = self;
    }
    return _zoneView;
}

- (void)pullInternet{
    
    [YBToolClass postNetworkWithUrl:@"Label.GetEvaluateList" andParameter:@{@"liveuid":minstr([_liveDic valueForKey:@"id"]),@"p":@(page)} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_messageTable.mj_footer endRefreshing];

        if (code == 0) {
            if (page == 1) {
                [_listArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                [_listArray addObject:[[personUserModel alloc] initWithDic:dic]];
            }
            [_messageTable reloadData];
            if ([info count] == 0) {
                [_messageTable.mj_footer endRefreshingWithNoMoreData];
            }
        }
    } fail:^{
        [_messageTable.mj_footer endRefreshing];
    }];

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sectionArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 6) {
        return _listArray.count;
    }
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    messageTableView *headerView = (messageTableView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"messageHeaderView"];
    if (headerView == nil) {
        headerView = [[messageTableView alloc] initWithReuseIdentifier:@"messageHeaderView"];
    }
    UITapGestureRecognizer *tapppp = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doliwugui)];

    headerView.titleL.text = sectionArray[section];
    headerView.giftL.hidden = YES;
    headerView.rightImgV.hidden = YES;
    headerView.giftNumL.hidden = YES;
    headerView.badL.hidden = YES;
    headerView.badImgV.hidden = YES;
    headerView.goodL.hidden = YES;
    headerView.goodImgV.hidden = YES;
    [headerView removeGestureRecognizer:tapppp];
    if (section == 5) {
        headerView.rightImgV.hidden = NO;
        headerView.giftNumL.hidden = NO;
        headerView.giftL.hidden = NO;

        headerView.giftNumL.text = minstr([_liveDic valueForKey:@"gift_total"]);
        headerView.giftL.text = @"礼物总数";
        [headerView addGestureRecognizer:tapppp];
    }else if(section == 6){
        headerView.badL.hidden = NO;
        headerView.badL.text = minstr([_liveDic valueForKey:@"badnums"]);
        headerView.badImgV.hidden = NO;
        headerView.goodL.hidden = NO;
        headerView.goodL.text = minstr([_liveDic valueForKey:@"goodnums"]);
        headerView.goodImgV.hidden = NO;
        
    }
    return headerView;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 || indexPath.section == 1) {
        personWordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personWordCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"personWordCell" owner:nil options:nil] lastObject];
        }
        if (indexPath.section == 0) {
            cell.contentL.text = minstr([_liveDic valueForKey:@"intr"]);
        }else{
            cell.contentL.text = minstr([_liveDic valueForKey:@"signature"]);
        }
        return cell;

    }else if (indexPath.section == 2 || indexPath.section == 3){
        personImpressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personImpressCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"personImpressCell" owner:nil options:nil] lastObject];
        }
        if (indexPath.section == 2) {
            cell.nothingL.hidden = YES;
            cell.rightJiantou.hidden = YES;
            NSArray *labels = [_liveDic valueForKey:@"label_list"];
            for (int i = 0; i < labels.count; i ++) {
                NSDictionary *dic = labels[i];
                if (i == 0) {
                    cell.view1.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                    cell.label1.text = minstr([dic valueForKey:@"name"]);
                }
                if (i == 1) {
                    cell.view2.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                    cell.lable2.text = minstr([dic valueForKey:@"name"]);
                }
                if (i == 2) {
                    cell.view3.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                    cell.label3.text = minstr([dic valueForKey:@"name"]);
                }
                
            }

        }else{
            NSArray *labels = [_liveDic valueForKey:@"evaluate_list"];
            cell.rightJiantou.hidden = NO;

            if (labels.count == 0) {
                cell.nothingL.hidden = NO;
            }else{
                cell.nothingL.hidden = YES;
                for (int i = 0; i < labels.count; i ++) {
                    NSDictionary *dic = labels[i];
                    if (i == 0) {
                        cell.view1.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                        cell.label1.text = minstr([dic valueForKey:@"name"]);
                    }
                    if (i == 1) {
                        cell.view2.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                        cell.lable2.text = minstr([dic valueForKey:@"name"]);
                    }
                    if (i == 2) {
                        cell.view3.backgroundColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                        cell.label3.text = minstr([dic valueForKey:@"name"]);
                    }
                    
                }

            }
        }
        return cell;

    }else if (indexPath.section == 4){
        personLiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personLiveCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"personLiveCell" owner:nil options:nil] lastObject];
        }
        cell.label1.text = minstr([_liveDic valueForKey:@"last_online_time"]);
        cell.label2.text = minstr([_liveDic valueForKey:@"answer_rate"]);
        cell.label3.text = [NSString stringWithFormat:@"%@cm",minstr([_liveDic valueForKey:@"height"])];
        cell.label4.text = [NSString stringWithFormat:@"%@kg",minstr([_liveDic valueForKey:@"weight"])];
        cell.label5.text = minstr([_liveDic valueForKey:@"city"]);
        cell.label6.text = minstr([_liveDic valueForKey:@"constellation"]);

        return cell;

    }else if (indexPath.section == 5){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"celllll"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"celllll"];
            cell.selectionStyle = 0;
            NSArray *gift_list = [_liveDic valueForKey:@"gift_list"];
            if (gift_list.count == 0) {
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, cell.contentView.width, 50)];
                label.text = @"TA还没有收到礼物";
                label.font = SYS_Font(12);
                label.textColor = color96;
                [cell.contentView addSubview:label];
            }else{
                for (int i = 0; i < gift_list.count; i++) {
                    NSDictionary *dic = gift_list[i];
                    GiftCabinetCell *view = [[[NSBundle mainBundle] loadNibNamed:@"GiftCabinetCell" owner:nil options:nil] lastObject];
                    view.frame = CGRectMake(_window_width/5*i, 0, _window_width/5, _window_width/5+40);
                    [cell.contentView addSubview:view];
                    [view.thumbImgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])]];
                    view.nameL.text = minstr([dic valueForKey:@"name"]);
                    view.giftNumL.text = minstr([dic valueForKey:@"total_nums"]);
                }
            }
        }
        return cell;
    }else{
        personUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personUserCELL"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"personUserCell" owner:nil options:nil] lastObject];
        }
        cell.model = _listArray[indexPath.row];
        return cell;

    }
}
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [[YBToolClass sharedInstance] heightOfString:minstr([_liveDic valueForKey:@"signature"]) andFont:SYS_Font(12) andWidth:_window_width-30]+25;
    }else if (indexPath.section == 1) {
        return [[YBToolClass sharedInstance] heightOfString:minstr([_liveDic valueForKey:@"intr"]) andFont:SYS_Font(12) andWidth:_window_width-30]+25;
    }else if (indexPath.section == 2 || indexPath.section == 3){
        return 50;
    }else if (indexPath.section == 4){
        return 135;
    }else if (indexPath.section == 5){
        NSArray *gift_list = [_liveDic valueForKey:@"gift_list"];
        if (gift_list.count == 0) {
            return  50;
        }
        return _window_width/5+40;
    }else{
        return 50;
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3) {
        MineImpressViewController *impress = [[MineImpressViewController alloc]init];
        impress.touid = minstr([_liveDic valueForKey:@"id"]);
        [self.navigationController pushViewController:impress animated:YES];
    }
}
#pragma mark ============底部按钮点击事件=============
- (void)callBtnClick{
    if (callType == 1) {

        if (!actionView) {
            NSArray *imgArray = @[@"person_选择语音",@"person_选择视频"];
            NSArray *itemArray = @[[NSString stringWithFormat:@"语音通话（%@%@/分钟）",minstr([_liveDic valueForKey:@"voice_value"]),[common name_coin]],[NSString stringWithFormat:@"视频通话（%@%@/分钟）",minstr([_liveDic valueForKey:@"video_value"]),[common name_coin]]];

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
            [self.view addSubview:actionView];
        }
        [actionView show];
    }else if (callType == 2){
        [self sendCallwithType:@"1"];
    }else if (callType == 3){
        [self sendCallwithType:@"2"];
    }else{
        [MBProgressHUD showError:@"对方已关闭接听"];
    }
}
- (void)lastBtnClick:(UIButton *)sender{
    if (sender == giftBtn || sender == secondGiftBtn) {
        //礼物
        if (!giftView) {
            giftView = [[liwuview alloc]initWithDic:@{@"uid":minstr([_liveDic valueForKey:@"id"]),@"showid":@"0"} andMyDic:nil];
            giftView.giftDelegate = self;
            giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
            [self.view addSubview:giftView];
            giftZheZhao = [UIButton buttonWithType:0];
            giftZheZhao.frame = CGRectMake(0, 0, _window_width, _window_height-(_window_width/2+100+ShowDiff));
            [giftZheZhao addTarget:self action:@selector(giftZheZhaoClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:giftZheZhao];
            giftZheZhao.hidden = YES;
        }
        [UIView animateWithDuration:0.2 animations:^{
            giftView.frame = CGRectMake(0,_window_height-(_window_width/2+100+ShowDiff), _window_width, _window_width/2+100+ShowDiff);
        } completion:^(BOOL finished) {
            giftZheZhao.hidden = NO;
        }];
    }
    if (sender == followBtn || sender == secondFollowBtn) {
        //关注
        [YBToolClass postNetworkWithUrl:@"User.SetAttent" andParameter:@{@"touid":minstr([_liveDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSDictionary *infoDic = [info firstObject];
                if ([minstr([infoDic valueForKey:@"isattent"]) isEqual:@"1"]) {
                    followBtn.selected = YES;
                    secondFollowBtn.selected = followBtn.selected;
                }else{
                    followBtn.selected = NO;
                    secondFollowBtn.selected = followBtn.selected;
                }
            }
            [MBProgressHUD showError:msg];

        } fail:^{
            
        }];
    }
    if (sender == messageBtn || sender == secondMessageBtn) {
        //消息
        TConversationCellData *data = [[TConversationCellData alloc] init];
        data.convId = minstr([_liveDic valueForKey:@"id"]);
        data.convType = TConv_Type_C2C;
        data.title = minstr([_liveDic valueForKey:@"user_nickname"]);
        data.userHeader = minstr([_liveDic valueForKey:@"avatar"]);
        data.userName = minstr([_liveDic valueForKey:@"user_nickname"]);
        data.level_anchor = minstr([_liveDic valueForKey:@"level_anchor"]);
        data.isauth = minstr([_liveDic valueForKey:@"isauth"]);
        data.isAtt = [NSString stringWithFormat:@"%d",followBtn.selected];
        data.isVIP = minstr([_liveDic valueForKey:@"isvip"]);
        data.isblack = minstr([_liveDic valueForKey:@"isblack"]);

        TChatController *chat = [[TChatController alloc] init];
        chat.conversation = data;
        [self.navigationController pushViewController:chat animated:YES];
    }

}
#pragma mark ============礼物=============

-(void)sendGiftSuccess:(NSMutableDictionary *)playDic{
    NSString *type = minstr([playDic valueForKey:@"type"]);
    
    if (!continueGifts) {
        continueGifts = [[continueGift alloc]initWithFrame:CGRectMake(0, 0, liansongliwubottomview.width, liansongliwubottomview.height)];
        [liansongliwubottomview addSubview:continueGifts];
        //初始化礼物空位
        [continueGifts initGift];
    }
    if ([type isEqual:@"1"]) {
        [self expensiveGift:playDic];
    }
    else{
        [continueGifts GiftPopView:playDic andLianSong:@"Y"];
    }
    
}
- (void)pushCoinV{
    RechargeViewController *recharge = [[RechargeViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:recharge animated:YES];

}
/************ 礼物弹出及队列显示开始 *************/
-(void)expensiveGiftdelegate:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        [self.view addSubview:haohualiwuV];
    }
    if (giftData == nil) {
        
        
    }
    else
    {
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }
}
-(void)expensiveGift:(NSDictionary *)giftData{
    if (!haohualiwuV) {
        haohualiwuV = [[expensiveGiftV alloc]init];
        haohualiwuV.delegate = self;
        //         [backScrollView insertSubview:haohualiwuV atIndex:8];
        [self.view addSubview:haohualiwuV];
    }
    if (giftData == nil) {
        
        
        
    }
    else
    {
        [haohualiwuV addArrayCount:giftData];
    }
    if(haohualiwuV.haohuaCount == 0){
        [haohualiwuV enGiftEspensive];
    }
}

- (void)giftZheZhaoClick{
    giftZheZhao.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
    } completion:^(BOOL finished) {
    }];

}
#pragma mark ============scrolldelegate=============
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    if (playerImgview) {
//
//    }
//}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == topScroll) {
        pageControl.currentPage = scrollView.contentOffset.x/_window_width;
        if (playerImgview) {
            if (pageControl.currentPage == 0) {
                [self playerPlay];
            }else{
                [self playerStop];
            }
        }
    }
    if (scrollView == bottomScrollV) {
        int i = scrollView.contentOffset.x/_window_width;
        UIButton *btn = segmentBtnArray[i];
        moveLine.centerX = btn.centerX;
        for (UIButton *bttnn in segmentBtnArray) {
            if (bttnn == btn) {
                bttnn.selected = YES;
            }else{
                bttnn.selected = NO;
            }
        }
    }
    if (scrollView == _backScroll) {
        if (_backScroll.contentOffset.y == 0 && pageControl.currentPage == 0) {
            [self playerPlay];
        }else{
            [self playerStop];
        }
    }
}


#pragma mark ============发起通话=============
- (void)sendCallwithType:(NSString *)type{
    if ([type isEqual:@"2"]) {
        //语音
        if ([YBToolClass checkAudioAuthorization] == 2) {
            //弹出麦克风权限
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self callllllllllType:type];
                    }else{
                        [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                    }
                });
            }];
        }else{
            if ([YBToolClass checkAudioAuthorization] == 1) {
                [self callllllllllType:type];
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
                    [self callllllllllType:type];
                }else{
                    [MBProgressHUD showError:@"未允许麦克风权限，不能语音通话"];
                }
            });
        }];
    }else{
        if ([YBToolClass checkAudioAuthorization] == 1) {
            [self callllllllllType:type];
        }else{
            [MBProgressHUD showError:@"请前往设置中打开麦克风权限"];
            return;
        }
    }
}
- (void)callllllllllType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_liveDic valueForKey:@"id"]),[Config getOwnToken],type,[Config getOwnID]]];
    NSDictionary *dic = @{
                          @"liveuid":minstr([_liveDic valueForKey:@"id"]),
                          @"type":type,
                          @"sign":sign
                          };
    [YBToolClass postNetworkWithUrl:@"Live.Checklive" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            TIMConversation *conversation = [[TIMManager sharedInstance]
                                             getConversation:TIM_C2C
                                             receiver:minstr([_liveDic valueForKey:@"id"])];
            NSDictionary *dic = @{
                                  @"method":@"call",
                                  @"action":@"0",
                                  @"user_nickname":[Config getOwnNicename],
                                  @"avatar":[Config getavatar],
                                  @"type":type,
                                  @"showid":minstr([infoDic valueForKey:@"showid"]),
                                  @"id":[Config getOwnID],
                                  @"content":@"邀请你通话"
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
            
            
        }else if(code == 800){
            [self showYuyue:type andMessage:msg];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];

}
- (void)showWaitView:(NSDictionary *)infoDic andType:(NSString *)type{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:minstr([_liveDic valueForKey:@"id"]) forKey:@"id"];
    [muDic setObject:minstr([_liveDic valueForKey:@"avatar"]) forKey:@"avatar"];
    [muDic setObject:minstr([_liveDic valueForKey:@"user_nickname"]) forKey:@"user_nickname"];
    [muDic setObject:minstr([_liveDic valueForKey:@"level_anchor"]) forKey:@"level_anchor"];
    [muDic setObject:minstr([_liveDic valueForKey:@"video_value"]) forKey:@"video_value"];
    [muDic setObject:minstr([_liveDic valueForKey:@"voice_value"]) forKey:@"voice_value"];

    [muDic addEntriesFromDictionary:infoDic];
    InvitationViewController *vc = [[InvitationViewController alloc]initWithType:[type intValue] andMessage:muDic];
    vc.showid = minstr([infoDic valueForKey:@"showid"]);
    vc.total = minstr([infoDic valueForKey:@"total"]);
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:nil];

}
- (void)sendMessageFaild:(NSDictionary *)infoDic andType:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_liveDic valueForKey:@"id"]),minstr([infoDic valueForKey:@"showid"]),[Config getOwnToken],[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Live.UserHang" andParameter:@{@"liveuid":minstr([_liveDic valueForKey:@"id"]),@"showid":minstr([infoDic valueForKey:@"showid"]),@"sign":sign,@"hangtype":@"0"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
    } fail:^{
    }];

}
- (void)showYuyue:(NSString *)type andMessage:(NSString *)msg{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"预约" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self SetSubscribe:type];
    }];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];

}
- (void)SetSubscribe:(NSString *)type{
    NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&token=%@&type=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_liveDic valueForKey:@"id"]),[Config getOwnToken],type,[Config getOwnID]]];
    [YBToolClass postNetworkWithUrl:@"Subscribe.SetSubscribe" andParameter:@{@"liveuid":minstr([_liveDic valueForKey:@"id"]),@"type":type,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
    } fail:^{
    }];
    
}
- (void)doliwugui{
    GiftCabinetViewController *vc = [[GiftCabinetViewController alloc]init];
    vc.userID = minstr([_liveDic valueForKey:@"id"]);
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
}
- (void)rightBtnClick{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:blackActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setBlack];
    }];
    [sureAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:cancleAction];

    [self presentViewController:alertContro animated:YES completion:nil];

}




- (void)topBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    for (UIButton *btn in segmentBtnArray) {
        if (btn == sender) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        moveLine.centerX = sender.centerX;
    }];
    [bottomScrollV setContentOffset:CGPointMake(_window_width*(sender.tag-1957), 0)];
}
- (void)pullVideoList{
    [YBToolClass postNetworkWithUrl:@"Video.GetHomeVideo" andParameter:@{@"p":@(videoPage),@"liveuid":minstr([_liveDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_videoCollectionV.mj_footer endRefreshing];
        [_videoCollectionV.mj_header endRefreshing];
        if (code == 0) {
            if (videoPage == 1) {
                [_videoArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                videoModel *model = [[videoModel alloc]initWithDic:dic];
                [_videoArray addObject:model];
            }
            [_videoCollectionV reloadData];
            if (_videoArray.count == 0) {
                videoNothingView.hidden = NO;
            }else{
                videoNothingView.hidden = YES;
            }

        }
    } fail:^{
        [_videoCollectionV.mj_footer endRefreshing];
        [_videoCollectionV.mj_header endRefreshing];
        
    }];
}
- (void)pullPicList{
    [YBToolClass postNetworkWithUrl:@"Photo.getHomePhoto" andParameter:@{@"p":@(picPage),@"liveuid":minstr([_liveDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_picCollectionV.mj_footer endRefreshing];
        [_picCollectionV.mj_header endRefreshing];
        if (code == 0) {
            if (picPage == 1) {
                [_videoArray removeAllObjects];
            }
            for (NSDictionary *dic in info) {
                picModel *model = [[picModel alloc]initWithDic:dic];
                [_picArray addObject:model];
            }
            [_picCollectionV reloadData];
            if (_picArray.count == 0) {
                picNothingView.hidden = NO;
            }else{
                picNothingView.hidden = YES;
            }
        }
    } fail:^{
        [_picCollectionV.mj_footer endRefreshing];
        [_picCollectionV.mj_header endRefreshing];
        
    }];


}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _videoCollectionV) {
        return _videoArray.count;
    }else{
        return _picArray.count;
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (collectionView == _picCollectionV) {
        picModel *model = _picArray[indexPath.row];
        picShowCell *cell = (picShowCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if ([model.isprivate isEqual:@"1"] && [model.cansee isEqual:@"0"]) {
            [self showAlertView:[NSString stringWithFormat:@"该照片为私密照片，需支付%@%@观看，开通VIP后可免费观看",model.coin,[common name_coin]] andIsVideo:NO andModel:model andPicCell:cell];
            return;
        }
        [self showBigPhoto:cell andModel:model];
    }else{
        videoModel *model = _videoArray[indexPath.row];
        if ([model.isprivate isEqual:@"1"] && [model.cansee isEqual:@"0"]) {
            [self showAlertView:[NSString stringWithFormat:@"该视频为私密视频，需支付%@%@观看，开通VIP后可免费观看",model.coin,[common name_coin]] andIsVideo:YES andModel:model andPicCell:nil];
            return;
        }
        [self goLookVideo:model];
    }
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _videoCollectionV) {
        videoShowCell *cell = (videoShowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"videoShowCELL" forIndexPath:indexPath];
        videoModel *model = _videoArray[indexPath.row];
        cell.model = model;
        return cell;


    }else{
        picShowCell *cell = (picShowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"picShowCELL" forIndexPath:indexPath];
        picModel *model = _picArray[indexPath.row];
        cell.model = model;
        return cell;

    }
}
- (UICollectionView *)videoCollectionV{
    if (!_videoCollectionV) {

        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
        flow.scrollDirection = UICollectionViewScrollDirectionVertical;
        flow.itemSize = CGSizeMake((_window_width-4)/3, (_window_width-4)/3*1.33);
        flow.minimumLineSpacing = 2;
        flow.minimumInteritemSpacing = 2;
        flow.sectionInset = UIEdgeInsetsMake(2, 0,2, 0);
        
        _videoCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(_window_width, 0, _window_width, _window_height-64-60-statusbarHeight-ShowDiff-40) collectionViewLayout:flow];
        _videoCollectionV.backgroundColor = [UIColor whiteColor];
        _videoCollectionV.delegate   = self;
        _videoCollectionV.dataSource = self;
        [_videoCollectionV registerNib:[UINib nibWithNibName:@"videoShowCell" bundle:nil] forCellWithReuseIdentifier:@"videoShowCELL"];
        
        _videoCollectionV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            videoPage ++;
            [self pullVideoList];
        }];
        videoNothingView = [[UIView alloc]initWithFrame:CGRectMake(0, _videoCollectionV.height/2-100, _videoCollectionV.width, 100)];
        videoNothingView.hidden = YES;
        [_videoCollectionV addSubview:videoNothingView];
        UIImageView *nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(videoNothingView.width/2-40, 0, 80, 80)];
        nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
        [videoNothingView addSubview:nothingImgV];
        UILabel *nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, nothingImgV.bottom, _window_width, 20)];
        nothingTitleL.font = [UIFont systemFontOfSize:11];
        nothingTitleL.textColor = color96;
        nothingTitleL.textAlignment = NSTextAlignmentCenter;
        nothingTitleL.text = @"TA还没有上传过视频";
        [videoNothingView addSubview:nothingTitleL];

    }
    return _videoCollectionV;
}
- (UICollectionView *)picCollectionV{
    if (!_picCollectionV) {
        _picArray = [NSMutableArray array];
        picPage = 1;

        UICollectionViewFlowLayout *flowwwww = [[UICollectionViewFlowLayout alloc]init];
        flowwwww.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowwwww.itemSize = CGSizeMake((_window_width-4)/3, (_window_width-4)/3*1.33);
        flowwwww.minimumLineSpacing = 2;
        flowwwww.minimumInteritemSpacing = 2;
        flowwwww.sectionInset = UIEdgeInsetsMake(2, 0,2, 0);
        
        _picCollectionV = [[UICollectionView alloc]initWithFrame:CGRectMake(_window_width*2, 0, _window_width, _window_height-64-60-statusbarHeight-ShowDiff-40) collectionViewLayout:flowwwww];
        _picCollectionV.backgroundColor = [UIColor whiteColor];
        _picCollectionV.delegate   = self;
        _picCollectionV.dataSource = self;
        [_picCollectionV registerNib:[UINib nibWithNibName:@"picShowCell" bundle:nil] forCellWithReuseIdentifier:@"picShowCELL"];
        _picCollectionV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            picPage ++;
            [self pullPicList];
        }];
        picNothingView = [[UIView alloc]initWithFrame:CGRectMake(0, _videoCollectionV.height/2-100, _videoCollectionV.width, 100)];
        picNothingView.hidden = YES;
        [_picCollectionV addSubview:picNothingView];
        UIImageView *nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(videoNothingView.width/2-40, 0, 80, 80)];
        nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
        [picNothingView addSubview:nothingImgV];
        UILabel *nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, nothingImgV.bottom, _window_width, 20)];
        nothingTitleL.font = [UIFont systemFontOfSize:11];
        nothingTitleL.textColor = color96;
        nothingTitleL.textAlignment = NSTextAlignmentCenter;
        nothingTitleL.text = @"TA还没有上传过照片";
        [picNothingView addSubview:nothingTitleL];


    }
    return _picCollectionV;
}

- (void)showAlertView:(NSString *)message andIsVideo:(BOOL)isvideo andModel:(id)model andPicCell:(picShowCell *)cell{
    WeakSelf;
    alert = [[YBAlertView alloc]initWithTitle:@"提示" andMessage:message andButtonArrays:@[@"开通会员",@"付费观看"] andButtonClick:^(int type) {
        if (type == 2) {
            [weakSelf doPayWithIsVideo:isvideo andModel:model andPicCell:cell];
        }else if (type == 1) {
            [weakSelf doVIP];
        }
        
        [weakSelf removeAlertView];
        
    }];
    [self.view addSubview:alert];
}
- (void)removeAlertView{
    if (alert) {
        [alert removeFromSuperview];
        alert = nil;
    }
    
}
- (void)doVIP{
    VIPViewController *vip = [[VIPViewController alloc]init];
    [[MXBADelegate sharedAppDelegate] pushViewController:vip animated:YES];
}

- (void)addLookPicViews:(picModel *)model{
    NSString *sign = [YBToolClass sortString:@{@"uid":[Config getOwnID],@"photoid":model.picID}];

    [YBToolClass postNetworkWithUrl:@"Photo.addView" andParameter:@{@"photoid":model.picID,@"sign":sign} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *dic = [info firstObject];
            model.views = minstr([dic valueForKey:@"nums"]);
            [_picCollectionV reloadData];
        }
    } fail:^{
        
    }];

}
- (void)doPayWithIsVideo:(BOOL)isvideo andModel:(id)model andPicCell:(picShowCell *)cell{
    NSString *url;
    videoModel *vModel;
    picModel *pModel;
    if (isvideo) {
        vModel = model;
        url = [NSString stringWithFormat:@"Video.BuyVideo&videoid=%@",vModel.videoID];
    }else{
        pModel = model;
        url = [NSString stringWithFormat:@"Photo.buyPhoto&photoid=%@",pModel.picID];
    }
    [YBToolClass postNetworkWithUrl:url andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            if (isvideo) {
                vModel.cansee = @"1";
                NSDictionary *infoDic = [info firstObject];
                vModel.href = minstr([infoDic valueForKey:@"href"]);
                [self goLookVideo:vModel];
            }else{
                pModel.cansee = @"1";
                [self showBigPhoto:cell andModel:pModel];
            }
        }else if (code == 1005){
            [self pushCoinV];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];

}
- (void)showBigPhoto:(picShowCell *)cell andModel:(picModel *)model{
    dispatch_async(dispatch_get_main_queue(), ^{
        YBImageView *sss = [[YBImageView alloc]initWithImgView:cell.thumbImgV];
        [[UIApplication sharedApplication].delegate.window addSubview:sss];
    });
    [self addLookPicViews:model];
}
- (void)goLookVideo:(videoModel *)model{
    LookVideoViewController *look = [[LookVideoViewController alloc]init];
    look.model = model;
    look.userDic = _liveDic;
    [self.navigationController pushViewController:look animated:YES];
}
- (void)setBlack{
    [YBToolClass postNetworkWithUrl:@"User.SetBlack" andParameter:@{@"touid":minstr([_liveDic valueForKey:@"id"])} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            if ([minstr([infoDic valueForKey:@"isblack"]) isEqual:@"1"]) {
                blackActionTitle = @"解除拉黑";
            }else{
                blackActionTitle = @"拉黑";
            }
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}

- (void)playerPlay{
    [playerImgview jp_resumePlayWithURL:[NSURL URLWithString:[[topImgArr firstObject] valueForKey:@"href"]]
                     bufferingIndicator:[UIView new]
                            controlView:[UIView new]
                           progressView:[UIView new]
                          configuration:^(UIView * _Nonnull view, JPVideoPlayerModel * _Nonnull playerModel) {
                          }];
}
-(void)playerStop {
    [[JPVideoPlayerManager sharedManager] stopPlay];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self playerStop];
}
- (void)viewWillAppear:(BOOL)animated{
    if (playerImgview) {
        if (_backScroll.contentOffset.y == 0 && pageControl.currentPage == 0) {
            [self playerPlay];
        }else{
            [self playerStop];
        }
    }

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
