//
//  play_linkMic.m
//  iphoneLive
//
//  Created by 王敏欣 on 2017/6/1.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "play_linkMic.h"

#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150

@implementation play_linkMic

-(instancetype)initWithRTMPURL:(NSDictionary *)dic andFrame:(CGRect)frames andisHOST:(BOOL)ishost{
    self = [super initWithFrame:frames];
    _subdic = [NSDictionary dictionaryWithDictionary:dic];
    _playurl = [NSString stringWithFormat:@"%@",[dic valueForKey:@"playurl"]];
    _pushurl = [NSString stringWithFormat:@"%@",[dic valueForKey:@"pushurl"]];
    if (self) {
        _ishost = ishost;
        _notification = [CWStatusBarNotification new];
        _notification.notificationLabelBackgroundColor = [UIColor redColor];
        _notification.notificationLabelTextColor = [UIColor whiteColor];
        if ([_pushurl isEqual:@"0"]) {
            [self RTMPPlay:frames];
        }
        else{
            [self RTMPPUSH:frames];
        }
        loadingImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - VIDEO_VIEW_WIDTH) / 2  , (self.height - VIDEO_VIEW_HEIGHT) / 2, VIDEO_VIEW_WIDTH, VIDEO_VIEW_HEIGHT)];
        loadingImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:loadingImage];
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"loading_image0.png"],
                                 [UIImage imageNamed:@"loading_image1.png"],
                                 [UIImage imageNamed:@"loading_image2.png"],
                                 [UIImage imageNamed:@"loading_image3.png"],
                                 [UIImage imageNamed:@"loading_image4.png"],
                                 [UIImage imageNamed:@"loading_image5.png"],
                                 [UIImage imageNamed:@"loading_image6.png"],
                                 [UIImage imageNamed:@"loading_image7.png"],
                                 [UIImage imageNamed:@"loading_image8.png"],
                                 [UIImage imageNamed:@"loading_image9.png"],
                                 [UIImage imageNamed:@"loading_image10.png"],
                                 [UIImage imageNamed:@"loading_image11.png"],
                                 [UIImage imageNamed:@"loading_image12.png"],
                                 [UIImage imageNamed:@"loading_image13.png"],
                                 [UIImage imageNamed:@"loading_image14.png"],
                                 nil];
        //要展示的动画
        loadingImage.animationImages=array;
        //一次动画的时间
        loadingImage.animationDuration= [array count]*0.1;
        //只执行一次动画
        loadingImage.animationRepeatCount = MAXFLOAT;
        //开始动画
        [loadingImage startAnimating];
        //直播间观众—关闭
        _returnCancle = [UIButton buttonWithType:UIButtonTypeCustom];
        _returnCancle.tintColor = [UIColor whiteColor];
        [_returnCancle setImage:[UIImage imageNamed:@"直播间观众—关闭"] forState:UIControlStateNormal];
        _returnCancle.backgroundColor = [UIColor clearColor];
        [_returnCancle setTitle:[dic valueForKey:@"userid"] forState:UIControlStateNormal];
        [_returnCancle setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_returnCancle addTarget:self action:@selector(returnCancles:) forControlEvents:UIControlEventTouchUpInside];
        _returnCancle.frame = CGRectMake(frames.size.width/3*2, 3, frames.size.width/3, frames.size.width/3);
        _returnCancle.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_returnCancle];
        if (_ishost) {
            _returnCancle.hidden = NO;
        }else{
            _returnCancle.hidden = YES;
        }
        NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
        [dc addObserver:self
               selector:@selector(appactive)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
        [dc addObserver:self
               selector:@selector(appnoactive)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
    }
    return self;
}
- (void)adjustCenter{
    loadingImage.frame = CGRectMake((self.width - VIDEO_VIEW_WIDTH) / 2  , (self.height - VIDEO_VIEW_HEIGHT) / 2, VIDEO_VIEW_WIDTH, VIDEO_VIEW_HEIGHT);
    
}
- (void)appactive{
    [_txLivePush resumePush];
}
- (void)appnoactive{
    [_txLivePush pausePush];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}
-(void)returnCancles:(UIButton *)sender{
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(sender){
            sender.userInteractionEnabled = YES;
        }
    });
    [self.delegate closeuserconnect:sender.titleLabel.text];
    [self removeFromSuperview];
}
-(void)RTMPPUSH:(CGRect)frames{
    if (!_txLivePushonfig) {
        _txLivePushonfig = [[TXLivePushConfig alloc] init];
        _txLivePushonfig.frontCamera = YES;
        _txLivePushonfig.enableAutoBitrate = YES;
        _txLivePushonfig.pauseFps = 10;
        _txLivePushonfig.pauseTime = 300;
        _txLivePushonfig.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
    }
    if (!_txLivePush) {
        _txLivePush = [[TXLivePush alloc] initWithConfig:_txLivePushonfig];
        _txLivePush.delegate = self;
    }
    [_txLivePush startPreview:self];
    CGFloat beauty_level = [minstr([_subdic valueForKey:@"beauty_level"]) floatValue];
    CGFloat whitening_level = [minstr([_subdic valueForKey:@"whitening_level"]) floatValue];
    [_txLivePush setBeautyStyle:0 beautyLevel:beauty_level whitenessLevel:whitening_level ruddinessLevel:0];
    [_txLivePush startPush:_pushurl];
}
-(void)RTMPPlay:(CGRect)frames{
    if (!_config) {
        _config = [[TXLivePlayConfig alloc] init];
        //自动模式
        _config.bAutoAdjustCacheTime   = YES;
        _config.minAutoAdjustCacheTime = 1;
        _config.maxAutoAdjustCacheTime = 5;
        _txLivePlayer =[[TXLivePlayer alloc] init];
        _txLivePlayer.enableHWAcceleration = YES;
        [_txLivePlayer setupVideoWidget:frames containView:self insertIndex:0];
        [_txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
        [_txLivePlayer setConfig:_config];
    }
    if(_txLivePlayer != nil)
    {
        _txLivePlayer.delegate = self;
        NSString *playUrl = _playurl;
        NSInteger _playType = 0;
        if ([playUrl hasPrefix:@"rtmp:"]) {
            _playType = PLAY_TYPE_LIVE_RTMP;
        } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && [playUrl rangeOfString:@".flv"].length > 0) {
            _playType = PLAY_TYPE_LIVE_FLV;
        } else{
            [_notification displayNotificationWithMessage:@"播放地址不合法，直播目前仅支持rtmp,flv播放方式!" forDuration:5];
        }
        int result = [_txLivePlayer startPlay:playUrl type:PLAY_TYPE_LIVE_RTMP_ACC];//RTMP直播加速播放
        NSLog(@"play_linkMicwangminxin%d",result);
        if (result == -1)
        {
        }
        if(result != 0)
        {
            [_notification displayNotificationWithMessage:@"视频流播放失败" forDuration:5];
        }
        if(result == 0){
        }
    }
}
//播放监听事件
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_CONNECT_SUCC) {
            NSLog(@"play_linkMic已经连接服务器");
        }
        else if (EvtID == PLAY_EVT_RTMP_STREAM_BEGIN){
            NSLog(@"play_linkMic已经连接服务器，开始拉流");
        }
        else if (EvtID == PLAY_EVT_PLAY_BEGIN){
            NSLog(@"play_linkMic视频播放开始");
            [loadingImage removeFromSuperview];
            loadingImage = nil;
        }
        else if (EvtID== PLAY_WARNING_VIDEO_PLAY_LAG){
            NSLog(@"play_linkMic当前视频播放出现卡顿（用户直观感受）");
        }
        else if (EvtID == PLAY_EVT_PLAY_END){
            NSLog(@"play_linkMic视频播放结束");
        }
        else if (EvtID == PLAY_ERR_NET_DISCONNECT) {
            NSLog(@"play_linkMic网络断连,且经多次重连抢救无效,可以放弃治疗,更多重试请自行重启播放");
              //  [self.delegate closeUserbyVideo:_subdic];
        }
    });
}
//推流监听
-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID >= 0) {
            if (EvtID == PUSH_WARNING_HW_ACCELERATION_FAIL)
            {
                _txLivePush.config.enableHWAcceleration = false;
                NSLog(@"play_linkmic连麦推流硬编码启动失败，采用软编码");
            }
            else if (EvtID == PUSH_EVT_CONNECT_SUCC)
            {
                // 已经连接推流服务器
                NSLog(@"play_linkmic连麦推流已经连接推流服务器");
            }
            else if (EvtID == PUSH_EVT_PUSH_BEGIN)
            {
                // 已经与服务器握手完毕,开始推流
                NSLog(@"play_linkmic连麦推流已经与服务器握手完毕,开始推流");
                [self.delegate startConnectRtmpForLink_mic];//开始连麦推流
                [loadingImage removeFromSuperview];
                loadingImage = nil;
                //3.拉取其它正在和大主播连麦的小主播的视频流
            }
            else if (EvtID == PUSH_WARNING_RECONNECT){
                // 网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)
                NSLog(@"movieplay连麦推流网络断连, 已启动自动重连 (自动重连连续失败超过三次会放弃)");
            }
            else if (EvtID == PUSH_WARNING_NET_BUSY) {
                [_notification displayNotificationWithMessage:@"您当前的网络环境不佳，请尽快更换网络保证正常连麦" forDuration:5];
            }
        }
        else{
            if (EvtID == PUSH_ERR_NET_DISCONNECT) {
                NSLog(@"movieplay连麦推流 推流失败，结束连麦");
                [_notification displayNotificationWithMessage:@"推流失败，结束连麦" forDuration:5];
                [self.delegate stoppushlink];
            }
        }
    });
}
- (void)stopConnect{
    if(_txLivePlayer != nil)
    {
        _txLivePlayer.delegate = nil;
        [_txLivePlayer stopPlay];
        [_txLivePlayer removeVideoWidget];
    }
}
-(void)stopPush{
    [_txLivePush stopPreview];
    [_txLivePush stopPush];
}
-(void)onNetStatus:(NSDictionary *)param{
}
//新添加美颜方法
- (void)setBeautyStyle:(CGFloat)style beautyLevel:(CGFloat)bl whitenessLevel:(CGFloat)wl ruddinessLevel:(CGFloat)rl{
    if (_txLivePush) {
        [_txLivePush setBeautyStyle:style beautyLevel:bl whitenessLevel:wl ruddinessLevel:rl];
    }
}
- (void)setEyeScaleLevel:(CGFloat)el{
    if (_txLivePush) {
        [_txLivePush setEyeScaleLevel:el];
    }
}
- (void)setFaceScaleLevel:(CGFloat)fl{
    if (_txLivePush) {
        [_txLivePush setFaceScaleLevel:fl];
    }
}
- (void)setBGMVolume:(CGFloat)vol{
    if (_txLivePush) {
        [_txLivePush setBGMVolume:vol];
    }
}
- (void)setMicVolume:(CGFloat)vol{
    if (_txLivePush) {
        [_txLivePush setMicVolume:vol];
    }
}
- (void)setFilter:(UIImage *)image{
    if (_txLivePush && image) {
        [_txLivePush setFilter:image];
    }
    else{
        [_txLivePush setFilter:nil];
    }
}
@end
