//
//  AnchorViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "AnchorViewController.h"
#import <TXLiteAVSDK_Professional/TXLivePush.h>
#import <TXLiteAVSDK_Professional/TXLiveBase.h>
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import <TXLiteAVSDK_Professional/TXLivePlayListener.h>
#import <TXLiteAVSDK_Professional/TXLivePlayConfig.h>
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>
#import <YYWebImage/YYWebImage.h>

#import "V8HorizontalPickerView.h"
/********************  TiFaceSDK添加 开始 ********************/
#include "TiUIView.h"
#include "TiSDKInterface.h"
/********************  TiFaceSDK添加 结束 ********************/
#import "liwuview.h"
#import "roomPayView.h"
#import "EndingEvaluationView.h"
#import "continueGift.h"
#import "expensiveGiftV.h"//礼物
#import "play_linkMic.h"
#import "TIMComm.h"
#import "TIMManager.h"
#import "TIMMessage.h"
#import "TIMConversation.h"


typedef NS_ENUM(NSInteger,TCLVFilterType) {
    FilterType_None         = 0,
    FilterType_white        ,   //美白滤镜
    FilterType_langman         ,   //浪漫滤镜
    FilterType_qingxin         ,   //清新滤镜
    FilterType_weimei         ,   //唯美滤镜
    FilterType_fennen         ,   //粉嫩滤镜
    FilterType_huaijiu         ,   //怀旧滤镜
    FilterType_landiao         ,   //蓝调滤镜
    FilterType_qingliang     ,   //清凉滤镜
    FilterType_rixi         ,   //日系滤镜
};

@interface AnchorViewController ()<TXVideoCustomProcessDelegate,V8HorizontalPickerViewDataSource,sendGiftDelegate,haohuadelegate,V8HorizontalPickerViewDelegate,TXVideoCustomProcessDelegate,play_linkmic,TXLivePlayListener,TXLivePushListener>{
    CWStatusBarNotification *_notification;
    AFNetworkReachabilityManager *managerAFH;//判断网络状态
    BOOL isclosenetwork;//判断断网回后台
    
    
    UILabel *timeL;
    NSTimer *linkTimer;
    int linkCount;
    NSTimer *backGroundTimer;//检测后台时间（超过60秒执行断流操作）
    int backTime;//
    
    liwuview *giftView;
    UIButton *giftZheZhao;
    expensiveGiftV *haohualiwuV;//豪华礼物
    continueGift *continueGifts;//连送礼物
    UIView *liansongliwubottomview;

    roomPayView *payView;
    
    EndingEvaluationView *endView;
    
    
    /***********************  腾讯SDK start **********************/
    float  _tx_beauty_level;
    float  _tx_whitening_level;
    float  _tx_eye_level;
    float  _tx_face_level;
    UIButton              *_beautyBtn;
    UIButton              *_filterBtn;
    UILabel               *_beautyLabel;
    UILabel               *_whiteLabel;
    UILabel               *_bigEyeLabel;
    UILabel               *_slimFaceLabel;
    UISlider              *_sdBeauty;
    UISlider              *_sdWhitening;
    UISlider              *_sdBigEye;
    UISlider              *_sdSlimFace;
    V8HorizontalPickerView  *_filterPickerView;
    NSInteger    _filterType;
    
    /***********************  腾讯SDK end **********************/
    play_linkMic *smallLink;
    TXLivePlayer *       _txLivePlayer;
    TXLivePlayConfig*    _config;
    UIView *playBackView;
    
    NSTimer *chargeTimer;
    
    UIAlertController *chargeAlert;
    
    
    UIView *playerMask;
    
    UIView *previewMask;

    BOOL isTXfiter;
}
@property TXLivePushConfig* txLivePushonfig;
@property TXLivePush*       txLivePublisher;
@property (nonatomic,strong) UIView *previewView;

/********************  TiFaceSDK添加 开始 ********************/
@property(nonatomic, strong) TiUIView *tiUIView; // TiFaceSDK UI
@property(nonatomic, strong) TiSDKManager *tiSDKManager;
/******************** TiFaceSDK添加 结束 ********************/
@property(nonatomic,strong)NSMutableArray *filterArray;//美颜数组
@property (nonatomic,strong)UIView     *vBeauty;

@end

@implementation AnchorViewController

- (void)viewWillAppear:(BOOL)animated{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.hidden = YES;
    __block CWStatusBarNotification *notifications = _notification;
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"islive"];
    WeakSelf;
    managerAFH = [AFNetworkReachabilityManager sharedManager];
    [managerAFH setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                [weakSelf backGround];
                [notifications displayNotificationWithMessage:@"网络断开连接" forDuration:8];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                [weakSelf backGround];
                [notifications displayNotificationWithMessage:@"网络断开连接" forDuration:8];
                break;
            case  AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"4GGGGGGGG");
                [weakSelf forwardGround];
                [notifications dismissNotification];
                break;
            case  AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                [weakSelf forwardGround];
                [notifications dismissNotification];
                break;
            default:
                break;
        }
    }];
    [managerAFH startMonitoring];

    [self creatUI];

    [self RTMPush];
    if ([_liveType intValue] == 2) {
        [self changeFrame];
    }
    NSLog(@"SDK Version = %@", [TXLiveBase getSDKVersionStr]);
#pragma mark 回到后台+来电话
    //注册进入后台的处理
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(forwardGround)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(backGround)
               name:UIApplicationWillResignActiveNotification
             object:nil];
    [dc addObserver:self selector:@selector(shajincheng) name:@"shajincheng" object:nil];
    [dc addObserver:self selector:@selector(callStateChange:) name:@"callStateChange" object:nil];

}
- (void)playBackViewClick{
    if (_vBeauty && _vBeauty.hidden == NO) {
        _vBeauty.hidden = YES;
    }

    if (playBackView.width == _window_width) {
        return;
    }else{
        [self.view insertSubview:_previewView aboveSubview:playBackView];
        [UIView animateWithDuration:0.2 animations:^{
            playBackView.frame = CGRectMake(0, 0, _window_width, _window_height);
            _previewView.frame = CGRectMake(_window_width*0.65, 40+statusbarHeight, _window_width*0.32, _window_width*0.32*1.33);
        }];
    }
}
- (void)previewViewClick{
    if (_vBeauty && _vBeauty.hidden == NO) {
        _vBeauty.hidden = YES;
    }

    if (_previewView.width == _window_width) {
        return;
    }else{
        [self.view insertSubview:playBackView aboveSubview:_previewView];
        [UIView animateWithDuration:0.2 animations:^{
            _previewView.frame = CGRectMake(0, 0, _window_width, _window_height);
            playBackView.frame = CGRectMake(_window_width*0.65, 40+statusbarHeight, _window_width*0.32, _window_width*0.32*1.33);
        }];
    }

}
- (void)creatUI{

    UIImageView *backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    backImgV.contentMode = UIViewContentModeScaleToFill;
    backImgV.clipsToBounds = YES;
    backImgV.image = [UIImage imageNamed:@"通话背景"];
    [self.view addSubview:backImgV];
    playBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    playBackView.backgroundColor = [UIColor clearColor];
    playBackView.clipsToBounds = YES;
    [self.view addSubview:playBackView];
    playerMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    playerMask.hidden = YES;
    playerMask.backgroundColor = [UIColor blackColor];
    [playBackView addSubview:playerMask];
    UITapGestureRecognizer *tapPlayer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playBackViewClick)];
    [playBackView addGestureRecognizer:tapPlayer];
    
    
    _previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _previewView.backgroundColor = [UIColor clearColor];
    _previewView.clipsToBounds = YES;
    [self.view addSubview:_previewView];
    previewMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    previewMask.hidden = YES;
    previewMask.backgroundColor = [UIColor blackColor];
    [_previewView addSubview:previewMask];

    UITapGestureRecognizer *tapPreview = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewViewClick)];
    [_previewView addGestureRecognizer:tapPreview];

    
    
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    headerView.layer.cornerRadius = 18;
    headerView.layer.masksToBounds = YES;
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(34+statusbarHeight);
        make.left.equalTo(self.view).offset(10);
        make.height.mas_equalTo(36);
    }];
    
    UIImageView *selfIconV = [[UIImageView alloc]init];
    [selfIconV sd_setImageWithURL:[NSURL URLWithString:minstr([_anchorMsg valueForKey:@"avatar"])]];
    selfIconV.contentMode = UIViewContentModeScaleToFill;
    selfIconV.layer.cornerRadius = 15;
    selfIconV.layer.masksToBounds = YES;
    selfIconV.clipsToBounds = YES;
    selfIconV.backgroundColor = normalColors;
    [headerView addSubview:selfIconV];
    [selfIconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(headerView).offset(3);
        make.width.height.mas_equalTo(30);
    }];
    UILabel *nameL = [[UILabel alloc]init];
    nameL.font = [UIFont systemFontOfSize:12];
    nameL.textColor = [UIColor whiteColor];
    nameL.text = minstr([_anchorMsg valueForKey:@"user_nickname"]);
    [headerView addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(selfIconV.mas_right).offset(8);
        make.centerY.equalTo(selfIconV).multipliedBy(0.7);
        make.right.equalTo(headerView).offset(-30);
    }];
    timeL = [[UILabel alloc]init];
    timeL.font = [UIFont systemFontOfSize:10];
    timeL.textColor = [UIColor whiteColor];
    timeL.text = @"00:00:00";
    [headerView addSubview:timeL];
    [timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(selfIconV.mas_right).offset(8);
        make.centerY.equalTo(selfIconV).multipliedBy(1.4);
        make.right.equalTo(headerView).offset(-30);
    }];
    
    NSArray *array;
    if ([_liveType isEqual:@"2"] || [_liveType isEqual:@"1"]) {
        if ([_liveType isEqual:@"1"]) {
            array = @[@"美颜",@"静音",@"挂断",@"切换镜头"];
        }else if ([_liveType isEqual:@"2"]) {
            array = @[@"美颜",@"静音",@"挂断",@"切换镜头",@"关闭摄像头"];
        }
        CGFloat speace = (_window_width - array.count*60)/(array.count+1);
        for (int i = 0; i < array.count; i ++) {
            UIButton *button = [UIButton buttonWithType:0];
            button.frame = CGRectMake(speace+i*(60+speace), _window_height-85-ShowDiff, 60, 60);
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"通话-%@",array[i]]] forState:0];
            if (i == 1) {
                [button setImage:[UIImage imageNamed:@"通话-静音开"] forState:UIControlStateSelected];
                
            }
            if (i == 4) {
                [button setImage:[UIImage imageNamed:@"通话-镜头开"] forState:UIControlStateSelected];
            }
            button.tag = i + 10086;
            [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
        }

    }else{
        array = @[@"静音",@"挂断"];
    }
    if ([_liveType isEqual:@"1"]) {
        array = @[@"美颜",@"静音",@"挂断",@"切换镜头"];
    }else if ([_liveType isEqual:@"2"]) {
        array = @[@"美颜",@"静音",@"挂断",@"切换镜头",@"关闭摄像头"];
    }else {
        array = @[@"静音",@"挂断"];
        CGFloat speace = (_window_width - 5*60)/6;

        for (int i = 0; i < array.count; i ++) {
            UIButton *button = [UIButton buttonWithType:0];
            button.frame = CGRectMake(_window_width/2-90-speace + i *(60+speace), _window_height-85-ShowDiff, 60, 60);
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"通话-%@",array[i]]] forState:0];
            if (i == 0) {
                [button setImage:[UIImage imageNamed:@"通话-静音开"] forState:UIControlStateSelected];
                
            }
            button.tag = i + 10087;
            [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
        }

    }
//    CGFloat speace = (_window_width - array.count*60)/(array.count+1);
//    for (int i = 0; i < array.count; i ++) {
//        UIButton *button = [UIButton buttonWithType:0];
//        button.frame = CGRectMake(speace+i*(60+speace), _window_height-85-ShowDiff, 60, 60);
//        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"通话-%@",array[i]]] forState:0];
//        if (i == 1) {
//            [button setImage:[UIImage imageNamed:@"通话-静音开"] forState:UIControlStateSelected];
//
//        }
//        if (i == 4) {
//            [button setImage:[UIImage imageNamed:@"通话-镜头开"] forState:UIControlStateSelected];
//        }
//        button.tag = i + 10086;
//        [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:button];
//    }
    if ([_liveType isEqual:@"2"] || [_liveType isEqual:@"4"]) {
        NSArray *array2 = @[@"通话-送礼物",@"通话-充值"];
        for (int i = 0; i < array2.count; i ++) {
            UIButton *button = [UIButton buttonWithType:0];
            button.frame = CGRectMake(_window_width-80, _window_height-85-ShowDiff-(i + 1)*46, 80, 36);
            [button setImage:[UIImage imageNamed:array2[i]] forState:0];
            button.tag = 1000+i;
            [button addTarget:self action:@selector(userBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            
        }
        [self timeCharge];
        if (!chargeTimer) {
            chargeTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeCharge) userInfo:nil repeats:YES];
        }
    }
    if (!linkTimer) {
        linkCount = 0;
        linkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(userLinkTimeAdd) userInfo:nil repeats:YES];
    }
    if ([_liveType isEqual:@"3"] || [_liveType isEqual:@"4"]) {
        UIImageView *gifImageV = [YYAnimatedImageView new];
        gifImageV.size = CGSizeMake(_window_width*0.4, _window_width*0.4);
        gifImageV.center = CGPointMake(self.view.centerX, self.view.centerY*0.7);
        NSURL *path = [[NSBundle mainBundle]URLForResource:@"room_audio" withExtension:@"gif"];
        gifImageV.yy_imageURL = path;
        [self.view addSubview:gifImageV];
    }
    liansongliwubottomview = [[UIView alloc]init];
    [self.view addSubview:liansongliwubottomview];
    liansongliwubottomview.frame = CGRectMake(0, statusbarHeight + 140,300,140);

}
- (void)playLink:(NSString *)pull{
    
    _config = [[TXLivePlayConfig alloc] init];
    //_config.enableAEC = YES;
    //自动模式
    _config.bAutoAdjustCacheTime   = YES;
    _config.minAutoAdjustCacheTime = 1;
    _config.maxAutoAdjustCacheTime = 5;
    _txLivePlayer =[[TXLivePlayer alloc] init];
    _txLivePlayer.enableHWAcceleration = YES;
    [_txLivePlayer setupVideoWidget:playBackView.bounds containView:playBackView insertIndex:0];
    [_txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
    [_txLivePlayer setConfig:_config];
    if(_txLivePlayer != nil)
    {
        _txLivePlayer.delegate = self;
        NSString *playUrl = pull;
        NSInteger _playType = 0;
        if ([playUrl hasPrefix:@"rtmp:"]) {
            _playType = PLAY_TYPE_LIVE_RTMP;
        } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && [playUrl rangeOfString:@".flv"].length > 0) {
            _playType = PLAY_TYPE_LIVE_FLV;
        }
        else{
            
        }
        if ([playUrl rangeOfString:@".mp4"].length > 0) {
            _playType = PLAY_TYPE_VOD_MP4;
        }
        int result = [_txLivePlayer startPlay:playUrl type:_playType];
        NSLog(@"wangminxin%d",result);
        if (result == -1)
        {
            
        }
        if( result != 0)
        {
            [_notification displayNotificationWithMessage:@"视频流播放失败" forDuration:5];
            
        }
        if( result == 0){
            NSLog(@"播放视频");
        }
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }

}
#pragma mark ============设置推流参数，开始推流=============

- (void)RTMPush{
    //配置推流参数
    _txLivePushonfig = [[TXLivePushConfig alloc] init];
    _txLivePushonfig.frontCamera = YES;
    _txLivePushonfig.enableAutoBitrate = YES;
    _txLivePushonfig.videoResolution = VIDEO_RESOLUTION_TYPE_720_1280 ;
    //background push
    _txLivePushonfig.pauseFps = 5;
    _txLivePushonfig.pauseTime = 300;
    [_txLivePushonfig setTouchFocus:NO];
    //耳返
    _txLivePushonfig.enableAudioPreview = NO;
    _txLivePushonfig.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
    _txLivePublisher = [[TXLivePush alloc] initWithConfig:_txLivePushonfig];
    _txLivePublisher.videoProcessDelegate = self;
    _txLivePublisher.delegate = self;

//    if (isTXfiter) {
    if ([YBToolClass checkNull:[common getTISDKKey]]) {
        isTXfiter = YES;
        //9.19更新美颜
        [_txLivePublisher setBeautyStyle:0 beautyLevel:9 whitenessLevel:3 ruddinessLevel:0];
        
    }else{
        isTXfiter = NO;
        [_txLivePublisher setBeautyStyle:0 beautyLevel:0 whitenessLevel:0 ruddinessLevel:0];
        [_txLivePublisher setMirror:YES];
        _txLivePublisher.videoProcessDelegate = self;
//        [TiSDK init:TIlicense];
        [TiSDK init:[YBToolClass decrypt:[common getTISDKKey]]];
        self.tiSDKManager = [[TiSDKManager alloc]init];
        self.tiUIView = [[TiUIView alloc]initTiUIViewWith:self.tiSDKManager delegate:nil superView:self.view];
        self.tiUIView.isClearOldUI = NO;
    }
    if ([_liveType intValue]> 2) {
        _txLivePushonfig.enablePureAudioPush = YES;   // true 为启动纯音频推流，而默认值是 false；
        [_txLivePublisher setConfig:_txLivePushonfig];
        
        
    }else{
        [_txLivePublisher startPreview:_previewView];
    }
    [_txLivePublisher startPush:_hostUrl];
}



#pragma mark ============连麦时长增加=============
- (void)userLinkTimeAdd{
    linkCount ++;
    timeL.text = [self secondsForDay:linkCount];
}
- (NSString *)secondsForDay:(int)count{
    NSString *str;
    str = [NSString stringWithFormat:@"%02d:%02d:%02d",count/3600,count%3600/60,count%3600%60];
    return str;
}
#pragma mark ============底部按钮点击=============

- (void)bottomButtonClick:(UIButton *)sender{
    if (sender.tag == 10086) {
        //美颜
        if (!isTXfiter) {
            [self.tiUIView createTiUIView];
        }else{
            [self userTXBase];
        }

    }else if (sender.tag == 10087) {
        //静音
        sender.selected = !sender.selected;
        [_txLivePublisher setMute:sender.selected];
    }else if (sender.tag == 10088) {
        //挂断
        [self doCloseVideo];
    }else if (sender.tag == 10089) {
        //切换镜头
        [_txLivePublisher switchCamera];
        [_txLivePublisher setMirror:_txLivePublisher.config.frontCamera];
    }else if (sender.tag == 10090) {
        //关闭镜头
        NSDictionary *dic = @{
                              @"method":@"livehandle",
                              @"action":[NSString stringWithFormat:@"%d",sender.selected+1]
                              };
        [self sendMessage:dic];
        sender.selected = !sender.selected;
    }

}
#pragma mark ============用户礼物充值按钮=============

- (void)userBtnClick:(UIButton *)sender{
    if (sender.tag == 1000) {
        //礼物
        if (!giftView) {
            giftView = [[liwuview alloc]initWithDic:@{@"uid":minstr([_anchorMsg valueForKey:@"id"]),@"showid":minstr([_anchorMsg valueForKey:@"showid"])} andMyDic:nil];
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

    }else{
        //充值
        [self requestPayList];
    }
}
- (void)requestPayList{
    if (!payView) {
        [YBToolClass postNetworkWithUrl:@"Charge.GetBalance" andParameter:@{@"type":@"ios"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSDictionary *infoDic = [info firstObject];
                if (!payView) {
                    payView = [[roomPayView alloc]initWithMsg:infoDic andFrome:1];
                    [self.view addSubview:payView];
                }
                [payView show];
                [self.view bringSubviewToFront:payView];
            }
        } fail:^{
            
        }];
    }else{
        [payView show];
        [self.view bringSubviewToFront:payView];

    }
    
}
- (void)giftZheZhaoClick{
    giftZheZhao.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        giftView.frame = CGRectMake(0,_window_height, _window_width, _window_width/2+100+ShowDiff);
    } completion:^(BOOL finished) {
    }];
    
}
- (void)pushCoinV{
    [self requestPayList];
}
#pragma mark ============送礼物成功=============

-(void)sendGiftSuccess:(NSMutableDictionary *)playDic{
    
//    NSString *type = minstr([playDic valueForKey:@"type"]);
//    
//    if (!continueGifts) {
//        continueGifts = [[continueGift alloc]initWithFrame:CGRectMake(0, 0, liansongliwubottomview.width, liansongliwubottomview.height)];
//        [liansongliwubottomview addSubview:continueGifts];
//        //初始化礼物空位
//        [continueGifts initGift];
//    }
//    if ([type isEqual:@"1"]) {
//        [self expensiveGift:playDic];
//    }
//    else{
//        [continueGifts GiftPopView:playDic andLianSong:@"Y"];
//    }
    
}
- (void)giffffffff:(NSDictionary *)playDic{
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

#pragma mark ============腾讯美颜=============
-(void)userTXBase {
    if (!_vBeauty) {
        [self txBaseBeauty];
    }
    _vBeauty.hidden = NO;
    [self.view bringSubviewToFront:_vBeauty];
}
-(void)txBaseBeauty {
    _filterArray = [NSMutableArray new];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"原图";
        v.face = [UIImage imageNamed:@"orginal"];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"美白";
        v.face = [UIImage imageNamed:@"fwhite"];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"浪漫";
        v.face = [UIImage imageNamed:@"langman"];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"清新";
        v.face = [UIImage imageNamed:@"qingxin"];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"唯美";
        v.face = [UIImage imageNamed:@"weimei"];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"粉嫩";
        v.face = [UIImage imageNamed:@"fennen"];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"怀旧";
        v.face = [UIImage imageNamed:@"huaijiu"];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"蓝调";
        v.face = [UIImage imageNamed:@"landiao"];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"清凉";
        v.face = [UIImage imageNamed:@"qingliang"];
        v;
    })];
    [_filterArray addObject:({
        V8LabelNode *v = [V8LabelNode new];
        v.title = @"日系";
        v.face = [UIImage imageNamed:@"rixi"];
        v;
    })];
    
    
    
    //美颜拉杆浮层
    float   beauty_btn_width  = 65;
    float   beauty_btn_height = 30;//19;
    
    float   beauty_btn_count  = 2;
    
    float   beauty_center_interval = (self.view.width - 30 - beauty_btn_width)/(beauty_btn_count - 1);
    float   first_beauty_center_x  = 15 + beauty_btn_width/2;
    int ib = 0;
    _vBeauty = [[UIView  alloc] init];
    _vBeauty.frame = CGRectMake(0, self.view.height-185-statusbarHeight, self.view.width, 185+statusbarHeight);
    [_vBeauty setBackgroundColor:[UIColor whiteColor]];
    float   beauty_center_y = _vBeauty.height - 30;//35;
    _beautyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _beautyBtn.center = CGPointMake(first_beauty_center_x, beauty_center_y);
    _beautyBtn.bounds = CGRectMake(0, 0, beauty_btn_width, beauty_btn_height);
    [_beautyBtn setImage:[UIImage imageNamed:@"white_beauty"] forState:UIControlStateNormal];
    [_beautyBtn setImage:[UIImage imageNamed:@"white_beauty_press"] forState:UIControlStateSelected];
    [_beautyBtn setTitle:@"美颜" forState:UIControlStateNormal];
    [_beautyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_beautyBtn setTitleColor:normalColors forState:UIControlStateSelected];
    _beautyBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    _beautyBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _beautyBtn.tag = 0;
    _beautyBtn.selected = YES;
    [_beautyBtn addTarget:self action:@selector(selectBeauty:) forControlEvents:UIControlEventTouchUpInside];
    ib++;
    _filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterBtn.center = CGPointMake(first_beauty_center_x + ib*beauty_center_interval, beauty_center_y);
    _filterBtn.bounds = CGRectMake(0, 0, beauty_btn_width, beauty_btn_height);
    [_filterBtn setImage:[UIImage imageNamed:@"beautiful"] forState:UIControlStateNormal];
    [_filterBtn setImage:[UIImage imageNamed:@"beautiful_press"] forState:UIControlStateSelected];
    [_filterBtn setTitle:@"滤镜" forState:UIControlStateNormal];
    [_filterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_filterBtn setTitleColor:normalColors forState:UIControlStateSelected];
    _filterBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    _filterBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _filterBtn.tag = 1;
    [_filterBtn addTarget:self action:@selector(selectBeauty:) forControlEvents:UIControlEventTouchUpInside];
    ib++;
    _beautyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,  _beautyBtn.top - 95, 40, 20)];
    _beautyLabel.text = @"美白";
    _beautyLabel.font = [UIFont systemFontOfSize:12];
    _sdBeauty = [[UISlider alloc] init];
    _sdBeauty.frame = CGRectMake(_beautyLabel.right, _beautyBtn.top - 95, self.view.width - _beautyLabel.right - 10, 20);
    _sdBeauty.minimumValue = 0;
    _sdBeauty.maximumValue = 9;
    _sdBeauty.value = 6.3;
    [_sdBeauty setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sdBeauty setMinimumTrackImage:[YBToolClass getImgWithColor:normalColors] forState:UIControlStateNormal];
    [_sdBeauty setMaximumTrackImage:[UIImage imageNamed:@"gray"] forState:UIControlStateNormal];
    [_sdBeauty addTarget:self action:@selector(txsliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _sdBeauty.tag = 0;
    
    
    _whiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _beautyBtn.top - 55, 40, 20)];
    
    _whiteLabel.text = @"美颜";
    _whiteLabel.font = [UIFont systemFontOfSize:12];
    _sdWhitening = [[UISlider alloc] init];
    
    _sdWhitening.frame =  CGRectMake(_whiteLabel.right, _beautyBtn.top - 55, self.view.width - _whiteLabel.right - 10, 20);
    
    _sdWhitening.minimumValue = 0;
    _sdWhitening.maximumValue = 9;
    _sdWhitening.value = 2.7;
    [_sdWhitening setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [_sdWhitening setMinimumTrackImage:[YBToolClass getImgWithColor:normalColors] forState:UIControlStateNormal];//[UIImage imageNamed:@"green"]
    [_sdWhitening setMaximumTrackImage:[UIImage imageNamed:@"gray"] forState:UIControlStateNormal];
    [_sdWhitening addTarget:self action:@selector(txsliderValueChange:) forControlEvents:UIControlEventValueChanged];
    _sdWhitening.tag = 1;
    
    _filterPickerView = [[V8HorizontalPickerView alloc] initWithFrame:CGRectMake(0, 10, self.view.width, 115)];
    _filterPickerView.textColor = [UIColor grayColor];
    _filterPickerView.elementFont = [UIFont fontWithName:@"" size:14];
    _filterPickerView.delegate = self;
    _filterPickerView.dataSource = self;
    _filterPickerView.hidden = YES;
    
    UIImageView *sel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_selected"]];
    
    _filterPickerView.selectedMaskView = sel;
    _filterType = 0;
    
    [_vBeauty addSubview:_beautyLabel];
    [_vBeauty addSubview:_whiteLabel];
    [_vBeauty addSubview:_sdWhitening];
    [_vBeauty addSubview:_sdBeauty];
    [_vBeauty addSubview:_beautyBtn];
    [_vBeauty addSubview:_bigEyeLabel];
    [_vBeauty addSubview:_sdBigEye];
    [_vBeauty addSubview:_slimFaceLabel];
    [_vBeauty addSubview:_sdSlimFace];
    [_vBeauty addSubview:_filterPickerView];
    [_vBeauty addSubview:_filterBtn];
    _vBeauty.hidden = YES;
    [self.view addSubview: _vBeauty];
}
#pragma tx_play_linkmic 代理
-(void)tx_closeUserbyVideo:(NSDictionary *)subdic{
    [MBProgressHUD showError:@"播放失败"];
}
-(void) onNetStatus:(NSDictionary*) param{
    
}
-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID >= 0) {
            if (EvtID == PUSH_WARNING_HW_ACCELERATION_FAIL) {
                _txLivePublisher.config.enableHWAcceleration = false;
                NSLog(@"PUSH_EVT_PUSH_BEGIN硬编码启动失败，采用软编码");
            }else if (EvtID == PUSH_EVT_CONNECT_SUCC) {
                // 已经连接推流服务器
                NSLog(@" PUSH_EVT_PUSH_BEGIN已经连接推流服务器");
            }else if (EvtID == PUSH_EVT_PUSH_BEGIN) {
                // 已经与服务器握手完毕,开始推流
                [self changePlayState];
                NSLog(@"liveshow已经与服务器握手完毕,开始推流");
            }else if (EvtID == PUSH_WARNING_RECONNECT){
                // 网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)
                NSLog(@"网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)");
            }else if (EvtID == PUSH_WARNING_NET_BUSY) {
                [_notification displayNotificationWithMessage:@"您当前的网络环境不佳，请尽快更换网络保证正常直播" forDuration:5];
            }
        }else {
            if (EvtID == PUSH_ERR_NET_DISCONNECT) {
                NSLog(@"PUSH_EVT_PUSH_BEGIN网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启推流");
                [_notification displayNotificationWithMessage:@"网络断连" forDuration:5];
                [self gainRevenueFromCalls];
            }
        }
    });
}
//播放监听事件
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_CONNECT_SUCC) {
            NSLog(@"moviplay不连麦已经连接服务器");
        }
        else if (EvtID == PLAY_EVT_RTMP_STREAM_BEGIN){
            NSLog(@"moviplay不连麦已经连接服务器，开始拉流");
        }
        else if (EvtID == PLAY_EVT_PLAY_BEGIN){
            NSLog(@"moviplay不连麦视频播放开始");
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }
        else if (EvtID== PLAY_WARNING_VIDEO_PLAY_LAG){
            NSLog(@"moviplay不连麦当前视频播放出现卡顿（用户直观感受）");
        }
        else if (EvtID == PLAY_EVT_PLAY_END){
            NSLog(@"moviplay不连麦视频播放结束");
            [_txLivePlayer resume];
        }
        else if (EvtID == PLAY_ERR_NET_DISCONNECT) {
            //视频播放结束
            NSLog(@"moviplay不连麦网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放");
        }
    });
}

-(void) txsliderValueChange:(UISlider*) obj {
    // todo
    if (obj.tag == 1) { //美颜
        _tx_beauty_level = obj.value;
        [_txLivePublisher setBeautyStyle:0 beautyLevel:_tx_beauty_level whitenessLevel:_tx_whitening_level ruddinessLevel:0];
        // [_txLivePublisher setBeautyFilterDepth:_beauty_level setWhiteningFilterDepth:_whitening_level];
    } else if (obj.tag == 0) { //美白
        _tx_whitening_level = obj.value;
        [_txLivePublisher setBeautyStyle:0 beautyLevel:_tx_beauty_level whitenessLevel:_tx_whitening_level ruddinessLevel:0];
        // [_txLivePublisher setBeautyFilterDepth:_beauty_level setWhiteningFilterDepth:_whitening_level];
    } else if (obj.tag == 2) { //大眼
        _tx_eye_level = obj.value;
        [_txLivePublisher setEyeScaleLevel:_tx_eye_level];
    } else if (obj.tag == 3) { //瘦脸
        _tx_face_level = obj.value;
        [_txLivePublisher setFaceScaleLevel:_tx_face_level];
    } else if (obj.tag == 4) {// 背景音乐音量
        [_txLivePublisher setBGMVolume:(obj.value/obj.maximumValue)];
    } else if (obj.tag == 5) { // 麦克风音量
        [_txLivePublisher setMicVolume:(obj.value/obj.maximumValue)];
    }
}

-(void)selectBeauty:(UIButton *)button{
    switch (button.tag) {
        case 0: {
            _sdWhitening.hidden = NO;
            _sdBeauty.hidden    = NO;
            _beautyLabel.hidden = NO;
            _whiteLabel.hidden  = NO;
            _bigEyeLabel.hidden = NO;
            _sdBigEye.hidden    = NO;
            _slimFaceLabel.hidden = NO;
            _sdSlimFace.hidden    = NO;
            _beautyBtn.selected  = YES;
            _filterBtn.selected = NO;
            _filterPickerView.hidden = YES;
            _vBeauty.frame = CGRectMake(0, self.view.height-185-statusbarHeight, self.view.width, 185+statusbarHeight);
        }break;
        case 1: {
            _sdWhitening.hidden = YES;
            _sdBeauty.hidden    = YES;
            _beautyLabel.hidden = YES;
            _whiteLabel.hidden  = YES;
            _bigEyeLabel.hidden = YES;
            _sdBigEye.hidden    = YES;
            _slimFaceLabel.hidden = YES;
            _sdSlimFace.hidden    = YES;
            _beautyBtn.selected  = NO;
            _filterBtn.selected = YES;
            _filterPickerView.hidden = NO;
            [_filterPickerView scrollToElement:_filterType animated:NO];
        }
            _beautyBtn.center = CGPointMake(_beautyBtn.center.x, _vBeauty.frame.size.height - 35-statusbarHeight);
            _filterBtn.center = CGPointMake(_filterBtn.center.x, _vBeauty.frame.size.height - 35-statusbarHeight);
    }
}
//设置美颜滤镜
#pragma mark - HorizontalPickerView DataSource Methods/Users/annidy/Work/RTMPDemo_PituMerge/RTMPSDK/webrtc
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return [_filterArray count];
}
#pragma mark - HorizontalPickerView Delegate Methods
- (UIView *)horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index {
    
    V8LabelNode *v = [_filterArray objectAtIndex:index];
    return [[UIImageView alloc] initWithImage:v.face];
    
}
- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    
    return 90;
}
- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    _filterType = index;
    [self filterSelected:index];
}
- (void)filterSelected:(NSInteger)index {
    NSString* lookupFileName = @"";
    switch (index) {
        case FilterType_None:
            break;
        case FilterType_white:
            lookupFileName = @"filter_white";
            break;
        case FilterType_langman:
            lookupFileName = @"filter_langman";
            break;
        case FilterType_qingxin:
            lookupFileName = @"filter_qingxin";
            break;
        case FilterType_weimei:
            lookupFileName = @"filter_weimei";
            break;
        case FilterType_fennen:
            lookupFileName = @"filter_fennen";
            break;
        case FilterType_huaijiu:
            lookupFileName = @"filter_huaijiu";
            break;
        case FilterType_landiao:
            lookupFileName = @"filter_landiao";
            break;
        case FilterType_qingliang:
            lookupFileName = @"filter_qingliang";
            break;
        case FilterType_rixi:
            lookupFileName = @"filter_rixi";
            break;
        default:
            break;
    }
    NSString * path = [[NSBundle mainBundle] pathForResource:lookupFileName ofType:@"png"];
    if (path != nil && index != FilterType_None && _txLivePublisher != nil) {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [_txLivePublisher setFilter:image];
    }
    else if(_txLivePublisher != nil) {
        [_txLivePublisher setFilter:nil];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
//    CGPoint origin = [[touches anyObject] locationInView:self.view];
//    CGPoint location;
//    location.x = origin.x/self.view.frame.size.width;
//    location.y = origin.y/self.view.frame.size.height;
//    [self onSwitchRtcView:location];
    
    //腾讯基础美颜
    if (_vBeauty && _vBeauty.hidden == NO) {
        _vBeauty.hidden = YES;
    }
}

#pragma mark ================ TXVideoProcessDelegate ===============
- (GLuint)onPreProcessTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height{
    
    /******************** TiFaceSDK添加 开始 ********************/
    if (!self.tiSDKManager) {
        return texture;
    }
    return [self.tiSDKManager renderTexture2D:texture Width:width Height:height Rotation:CLOCKWISE_0 Mirror:NO];
    /******************** TiFaceSDK添加 结束 ********************/
}
- (void)onTextureDestoryed{
    if (self.tiSDKManager) {
        [self.tiSDKManager destroy];
    }
}
#pragma mark ===========================   腾讯推流end   =======================================
- (void)callStateChange:(NSNotification *)not{
    NSDictionary *dic = [not object];
    if ([minstr([dic valueForKey:@"method"]) isEqual:@"call"]) {
        //用户推流成功
        if ([minstr([dic valueForKey:@"action"]) isEqual:@"10"] || [minstr([dic valueForKey:@"action"]) isEqual:@"11"]) {
            //播放对方的b流
            [self playLink:minstr([dic valueForKey:@"pull"])];
            //使用小窗口推流，大窗口播放对方的流
            [self changeFrame];
        }
        if ([minstr([dic valueForKey:@"action"]) isEqual:@"8"]){
            [self liveOver];//停止计时器
            [self rmObservers];//释放通知
            [self showUserEvaluatelastView];
            
        }
        if ([minstr([dic valueForKey:@"action"]) isEqual:@"9"]){
            [self liveOver];//停止计时器
            [self rmObservers];//释放通知
            NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"showid=%@&token=%@&touid=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_anchorMsg valueForKey:@"showid"]),[Config getOwnToken],minstr([_anchorMsg valueForKey:@"id"]),[Config getOwnID]]];
            
            NSDictionary *subDic = @{@"touid":minstr([_anchorMsg valueForKey:@"id"]),@"showid":minstr([_anchorMsg valueForKey:@"showid"]),@"sign":sign};
            [YBToolClass postNetworkWithUrl:@"Live.AnchorHang" andParameter:subDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                if (code == 0) {
                    [self showLastView:[info firstObject]];
                }else{
                    [self showLastView:@{@"answertotal":@"--",@"gifttotal":@"--"}];
                }
                
            } fail:^{
                [self showLastView:@{@"answertotal":@"--",@"gifttotal":@"--"}];
            }];
            
        }
        if ([minstr([dic valueForKey:@"action"]) isEqual:@"1"] || [minstr([dic valueForKey:@"action"]) isEqual:@"3"]) {
            [self liveOver];//停止计时器
            [self rmObservers];//释放通知
            [self doReturn];
        }
    }
    if ([minstr([dic valueForKey:@"method"]) isEqual:@"livehandle"]) {
        if ([minstr([dic valueForKey:@"action"]) isEqual:@"1"]){
            playerMask.hidden = NO;
        }
        if ([minstr([dic valueForKey:@"action"]) isEqual:@"2"]){
            playerMask.hidden = YES;
        }

    }
    if ([minstr([dic valueForKey:@"method"]) isEqual:@"sendgift"]) {
        if ([minstr([dic valueForKey:@"action"]) isEqual:@"1"]) {
            [self giffffffff:dic];
            NSLog(@"收到送礼物信息===%@",dic);
        }
    }
}
- (void)changePlayState{
//    1:视频主播 2:视频观众 3:语音主播 4:语音观众
    NSDictionary *dic;
    NSString *type;
    if ([_liveType intValue] == 1 || [_liveType intValue] == 2) {
        type = @"1";
    }else{
        type = @"2";
    }

    if ([_liveType intValue] == 1 || [_liveType intValue] == 3) {
        dic = @{
                @"method":@"call",
                @"action":@"11",
                @"pull":minstr([_anchorMsg valueForKey:@"pull"]),
                @"type":type
                };
    }else{
        dic = @{
                @"method":@"call",
                @"action":@"10",
                @"pull":minstr([_anchorMsg valueForKey:@"pull"]),
                @"type":type
                };
    }
    NSLog(@"--------------------%@",dic);
    [self sendMessage:dic];
}
- (void)sendMessage:(NSDictionary *)dic{
    TIMConversation *conversation = [[TIMManager sharedInstance]
                                     getConversation:TIM_C2C
                                     receiver:minstr([_anchorMsg valueForKey:@"id"])];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    TIMCustomElem * custom_elem = [[TIMCustomElem alloc] init];
    [custom_elem setData:data];
    TIMMessage * msg = [[TIMMessage alloc] init];
    [msg addElem:custom_elem];

    [conversation sendMessage:msg succ:^(){
        NSLog(@"SendMsg Succ");
        if ([minstr([dic valueForKey:@"method"]) isEqual:@"livehandle"]) {
            if ([minstr([dic valueForKey:@"action"]) isEqual:@"1"]) {
                previewMask.hidden = NO;
            }else{
                previewMask.hidden = YES;
            }
        }
    }fail:^(int code, NSString * err) {
        NSLog(@"SendMsg Failed:%d->%@", code, err);
        [MBProgressHUD showError:@"消息发送失败"];
    }];

}
- (void)changeFrame{
    [UIView animateWithDuration:0.2 animations:^{
        _previewView.frame = CGRectMake(_window_width*0.65, 40+statusbarHeight, _window_width*0.32, _window_width*0.32*1.33);
    }];
}
#pragma mark ============扣费=============
- (void)timeCharge{
    NSDictionary *subDic = @{@"liveuid":minstr([_anchorMsg valueForKey:@"id"]),@"showid":minstr([_anchorMsg valueForKey:@"showid"])};

    [YBToolClass postNetworkWithUrl:@"Live.TimeCharge" andParameter:subDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSString *coin = [infoDic valueForKey:@"coin"];
            LiveUser *liveUser = [Config myProfile];
            liveUser.coin  =  [NSString stringWithFormat:@"%@",coin];
            [Config updateProfile:liveUser];
            if (giftView) {
                [giftView chongzhiV:coin];
            }
            if ([minstr([infoDic valueForKey:@"istips"]) isEqual:@"1"]) {
                chargeAlert = [UIAlertController alertControllerWithTitle:@"余额不足" message:minstr([infoDic valueForKey:@"tips"]) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [chargeAlert addAction:cancleAction];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self requestPayList];
                }];
                [sureAction setValue:normalColors forKey:@"_titleTextColor"];
                [chargeAlert addAction:sureAction];
                [self presentViewController:chargeAlert animated:YES completion:nil];
            }
            
        }else{
            [MBProgressHUD showError:msg];
            [chargeAlert dismissViewControllerAnimated:YES completion:nil];
            [self gainRevenueFromCalls];
        }
    } fail:^{
        [chargeAlert dismissViewControllerAnimated:YES completion:nil];
        [self gainRevenueFromCalls];
    }];
}

#pragma mark ============关闭通话=============

//
- (void)doCloseVideo{
    NSString *message;
    if ([_liveType isEqual:@"1"] || [_liveType isEqual:@"2"]) {
        message = @"确认关闭视频通话";
    }else{
        message = @"确认关闭语音通话";
    }
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self gainRevenueFromCalls];
    }];
    [sureAction setValue:normalColors forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];
    
}
- (void)gainRevenueFromCalls{
    
    [self liveOver];//停止计时器
    [self rmObservers];//释放通知
    NSDictionary *dic;
    NSString *url;
    NSDictionary *subDic;
    NSString *type;
    if ([_liveType intValue] == 1 || [_liveType intValue] == 2) {
        type = @"1";
    }else{
        type = @"2";
    }
    if ([_liveType intValue] == 1 || [_liveType intValue] == 3) {
        NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"showid=%@&token=%@&touid=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_anchorMsg valueForKey:@"showid"]),[Config getOwnToken],minstr([_anchorMsg valueForKey:@"id"]),[Config getOwnID]]];
        
        dic = @{
                @"method":@"call",
                @"action":@"8",
                @"content":[self timeFormatted:linkCount],
                @"type":type
                };
        url = @"Live.AnchorHang";
        subDic = @{@"touid":minstr([_anchorMsg valueForKey:@"id"]),@"showid":minstr([_anchorMsg valueForKey:@"showid"]),@"sign":sign};
    }else{
        NSString *sign = [[YBToolClass sharedInstance] md5:[NSString stringWithFormat:@"liveuid=%@&showid=%@&token=%@&uid=%@&400d069a791d51ada8af3e6c2979bcd7",minstr([_anchorMsg valueForKey:@"id"]),minstr([_anchorMsg valueForKey:@"showid"]),[Config getOwnToken],[Config getOwnID]]];
        
        dic = @{
                @"method":@"call",
                @"action":@"9",
                @"content":[self timeFormatted:linkCount],
                @"type":type
                };
        url = @"Live.UserHang";
        subDic = @{@"liveuid":minstr([_anchorMsg valueForKey:@"id"]),@"showid":minstr([_anchorMsg valueForKey:@"showid"]),@"sign":sign,@"hangtype":@"2"};
    }
    [YBToolClass postNetworkWithUrl:url andParameter:subDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            if ([_liveType intValue] == 1 || [_liveType intValue] == 3) {
                [self showLastView:[info firstObject]];
            }else{
                [self showUserEvaluatelastView];
            }
        }else{
            [self doReturn];
        }
        
    } fail:^{
        [self doReturn];
    }];
    
    [self sendMessage:dic];
}
- (NSString *)timeFormatted:(int)totalSeconds{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (hours == 0) {
        return [NSString stringWithFormat:@"通话时长 %02d:%02d",minutes,seconds];
    }else{
        return [NSString stringWithFormat:@"通话时长 %02d:%02d:%02d",hours, minutes, seconds];
    }
}

//直播结束时 停止所有计时器
-(void)liveOver{
    if (backGroundTimer) {
        [backGroundTimer invalidate];
        backGroundTimer  = nil;
    }
    if (linkTimer) {
        [linkTimer invalidate];
        linkTimer = nil;
    }
    if (chargeTimer) {
        [chargeTimer invalidate];
        chargeTimer = nil;
    }
    if(_txLivePlayer != nil)
    {
        _txLivePlayer.delegate = nil;
        [_txLivePlayer stopPlay];
        [_txLivePlayer removeVideoWidget];
        _txLivePlayer = nil;
    }
    if(_txLivePublisher != nil)
    {
        _txLivePublisher.delegate = nil;
        [_txLivePublisher stopPreview];
        [_txLivePublisher stopPush];
        _txLivePublisher.config.pauseImg = nil;
        _txLivePublisher = nil;
    }
    if (haohualiwuV) {
        [haohualiwuV stopHaoHUaLiwu];
        [haohualiwuV removeFromSuperview];
        haohualiwuV = nil;
    }
}
- (void)rmObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"callStateChange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"shajincheng" object:nil];

    
}
- (void)showUserEvaluatelastView{
    endView = [[EndingEvaluationView alloc]initWithFrame:CGRectMake(_window_width, 0, _window_width, _window_height) andUserID:minstr([_anchorMsg valueForKey:@"id"]) andTime:[NSString stringWithFormat:@"本次通话时长  %d小时%d分%d秒",linkCount/3600,linkCount%3600/60,linkCount%3600%60]];
    WeakSelf;
    endView.block = ^{
        [weakSelf doReturn];
    };
    [self.view addSubview:endView];
    [UIView animateWithDuration:0.2 animations:^{
        endView.x = 0;
    }];
    
}
//展示结束页面
- (void)showLastView:(NSDictionary *)dic{
    UIView *lastView = [[UIView alloc]initWithFrame:CGRectMake(_window_width, 0, _window_width, _window_height)];
    lastView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lastView];
    UIView *grayView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*0.1, _window_height/2-75, _window_width*0.8, 150)];
    grayView.backgroundColor = RGB_COLOR(@"#fafafa", 1);
    grayView.layer.cornerRadius = 10;
    grayView.layer.masksToBounds = YES;
    [lastView addSubview:grayView];
    NSArray *array = @[@"通话时长",@"通话收入",@"礼物收入"];
    for (int i = 0; i < array.count; i ++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, i*50, grayView.width, 50)];
        [grayView addSubview:view];
        UILabel *leftL = [[UILabel alloc]init];
        leftL.text = array[i];
        leftL.font = SYS_Font(12);
        [view addSubview:leftL];
        [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(30);
            make.centerY.equalTo(view);
        }];
        
        UILabel *rightL = [[UILabel alloc]init];
        rightL.font = SYS_Font(12);
        [view addSubview:rightL];
        if (i == 0) {
            [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(view).offset(-20);
                make.centerY.equalTo(view);
            }];
            rightL.text = [NSString stringWithFormat:@"%d小时%d分%d秒",linkCount/3600,linkCount%3600/60,linkCount%3600%60];
        }else{
            [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(view).offset(-35);
                make.centerY.equalTo(view);
            }];
            UIImageView *coinImgV = [[UIImageView alloc]init];
            coinImgV.image = [UIImage imageNamed:@"coin_Icon"];
            [view addSubview:coinImgV];
            [coinImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(view).offset(-20);
                make.centerY.equalTo(view);
                make.width.height.mas_equalTo(12);
            }];
            if (i == 1) {
                rightL.text = minstr([dic valueForKey:@"answertotal"]);
            }else{
                rightL.text = minstr([dic valueForKey:@"gifttotal"]);
            }
        }
        if (i < array.count - 1) {
            UIView *lineV = [[UIView alloc]init];
            lineV.backgroundColor = RGB_COLOR(@"#f0f0f0", 1);
            [view addSubview:lineV];
            [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(view).offset(15);
                make.right.equalTo(view).offset(-15);
                make.bottom.equalTo(view);
                make.height.mas_equalTo(1);
            }];
        }
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, grayView.top - 80, _window_width, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"通话结束";;
    [lastView addSubview:label];
    
    UIButton *returnBtn = [UIButton buttonWithType:0];
    [returnBtn setBackgroundColor:normalColors];
    returnBtn.layer.cornerRadius = 20;
    returnBtn.layer.masksToBounds = YES;
    returnBtn.frame = CGRectMake(_window_width*0.2, _window_height-ShowDiff-140, _window_width*0.6, 40);
    [returnBtn setTitle:@"确认" forState:0];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [lastView addSubview:returnBtn];
    [UIView animateWithDuration:0.2 animations:^{
        lastView.x = 0;
    }];
}

- (void)doReturn{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"islive"];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark ============回到后台进入前台=============

//回到后台
- (void)backGround{
    [_txLivePublisher pausePush];
    if (!backGroundTimer) {
        backTime = 60;
        backGroundTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(backGroundTime) userInfo:nil repeats:YES];
    }

}
//进入前台
- (void)forwardGround{
    [_txLivePublisher resumePush];
    if (backGroundTimer) {
        [backGroundTimer invalidate];
        backGroundTimer = nil;
        NSLog(@"回到前台，取消计时器");
    }
}
- (void)backGroundTime{
    backTime -- ;
    NSLog(@"进入后台%dS",backTime);
    if (backTime <= 0) {
        [self gainRevenueFromCalls];
        [backGroundTimer invalidate];
        backGroundTimer = nil;
    }
    
}
- (void)shajincheng{
    NSLog(@"杀进程");
    [self gainRevenueFromCalls];
}
- (void)dealloc{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"islive"];
    [self liveOver];
    [self rmObservers];
    NSLog(@"dealloc");
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
