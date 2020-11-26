//
//  play_linkMic.h
//  iphoneLive
//
//  Created by 王敏欣 on 2017/6/1.
//  Copyright © 2017年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TXLiteAVSDK_Professional/TXLivePlayListener.h>
#import <TXLiteAVSDK_Professional/TXLivePlayConfig.h>
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>
#import <TXLiteAVSDK_Professional/TXLivePush.h>
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import "V8HorizontalPickerView.h"


@protocol play_linkmic <NSObject>
-(void)startConnectRtmpForLink_mic;//开始连麦推流
-(void)stoppushlink;//停止推流
-(void)closeuserconnect:(NSString *)uid;//主播关闭某人的连麦
-(void)closeUserbyVideo:(NSDictionary *)subdic;//视频播放失败

@end

@interface play_linkMic : UIView<TXLivePlayListener,TXLivePushListener>
{
    TXLivePlayer *       _txLivePlayer;
    TXLivePlayConfig*    _config;
    CWStatusBarNotification *_notification;
    UIImageView *loadingImage;
    BOOL _ishost;//判断是不是主播
}
@property(nonatomic,strong)NSDictionary *subdic;
@property (nonatomic,strong) UIButton *returnCancle;
@property(nonatomic,assign)id<play_linkmic>delegate;
@property TXLivePushConfig* txLivePushonfig;
@property TXLivePush*       txLivePush;
@property(nonatomic,strong)NSString *playurl;
@property(nonatomic,strong)NSString *pushurl;
-(instancetype)initWithRTMPURL:(NSDictionary *)dic andFrame:(CGRect)frames andisHOST:(BOOL)ishost;

-(void)stopConnect;
-(void)stopPush;
//美颜
- (void)setBeautyStyle:(CGFloat)style beautyLevel:(CGFloat)bl whitenessLevel:(CGFloat)wl ruddinessLevel:(CGFloat)rl;
- (void)setEyeScaleLevel:(CGFloat)el;
- (void)setFaceScaleLevel:(CGFloat)fl;
- (void)setBGMVolume:(CGFloat)vol;
- (void)setMicVolume:(CGFloat)vol;

- (void)setFilter:(UIImage *)image;

- (void)adjustCenter;

@end
