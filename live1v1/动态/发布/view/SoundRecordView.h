//
//  SoundRecordView.h
//  live1v1
//
//  Created by ybRRR on 2019/7/27.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YBProgreseView.h"
#import <YYWebImage/YYWebImage.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^hideself)(void);
typedef void(^recordSoundSure)(NSString *audioPath, int voiceTime);
@interface SoundRecordView : UIView{
    
    UIView *_backView;//白色背景
    
    UIImageView *_recordNormalImg;//录制状态
    
    UIButton *auditionBtn;//试听按钮
    UIButton *recordBtn;//录音按钮
    UIButton *deleteBtn;//删除按钮
    
    BOOL isAudition;
    BOOL isRecording; //正在录音
    float minValue;
    float _oldtime; //记录上次录音时间
    float _oldlistenetime; //记录上次试听时间

    NSTimer *audioTimer;
    
    UILabel *tipsLb;  //录制状态
    UILabel *recordTimeLb;//录制时间
    UIButton *sureBtn;
    
    int recordCount;
}
@property (nonatomic,copy) hideself hideBlock;
@property (nonatomic,copy) recordSoundSure recordEvent;
@property (nonatomic,strong) YBProgreseView *loopProgressView; //进度条
@property (strong, nonatomic)  YYAnimatedImageView *animationView;
@property (strong, nonatomic) NSString *filePath;//音频路径
@property (nonatomic, copy) NSURL *destURL;
@property (strong, nonatomic) NSString *oldPath;

@property (nonatomic, strong) AVAudioRecorder *recoder;


@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong)   AVAssetExportSession* assetExport;

/// 目标路径
//@property (nonatomic, copy) NSURL *destURL;

@end

NS_ASSUME_NONNULL_END
