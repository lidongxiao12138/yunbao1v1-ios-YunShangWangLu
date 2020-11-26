//
//  SoundRecordView.m
//  live1v1
//
//  Created by ybRRR on 2019/7/27.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SoundRecordView.h"
#import "XHSoundRecorder.h"
#import "HMAudioComposition.h"
@implementation SoundRecordView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        minValue = 0;
        _oldtime = 0;
        _oldPath = @"";
        recordCount = 0;
//        _oldlistenetime = 0;
        [self initUI];
    }
    return self;
}
-(void)hideself{
    self.hideBlock();
}

-(void)initUI{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height- _window_height*0.35, _window_width, _window_height *0.35)];
    _backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_backView];
    
    UIButton *closeBtn = [UIButton buttonWithType:0];
    [closeBtn setImage:[UIImage imageNamed:@"returnback"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideself) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backView).offset(10);
        make.width.height.mas_equalTo(30);
        make.top.equalTo(_backView).offset(8);
    }];
    
    UILabel*titlelb = [[UILabel alloc]init];
    titlelb.font = [UIFont systemFontOfSize:16];
    titlelb.textColor = [UIColor blackColor];
    titlelb.text = @"录音";
    [_backView addSubview:titlelb];
    [titlelb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backView);
        make.top.equalTo(_backView).offset(10);
    }];
    
    sureBtn = [UIButton buttonWithType:0];
    [sureBtn setImage:[UIImage imageNamed:@"录音确定"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(soundSureClick) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.hidden = YES;
    [_backView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_backView).offset(-10);
        make.width.height.mas_equalTo(30);
        make.top.equalTo(_backView).offset(8);
    }];

    UILabel *line = [[UILabel alloc]init];
    line.backgroundColor = RGBA(239, 236, 239, 1);
    [_backView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(closeBtn.mas_bottom).offset(8);
        make.width.equalTo(_backView);
        make.height.mas_equalTo(1);
    }];
    
    auditionBtn = [UIButton buttonWithType:0];
    [auditionBtn setImage:[UIImage imageNamed:@"audio试听"] forState:0];
    [auditionBtn addTarget:self action:@selector(auditionClick) forControlEvents:UIControlEventTouchUpInside];
    auditionBtn.hidden = YES;
    [_backView addSubview:auditionBtn];
    [auditionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line).offset(15);
        make.centerX.equalTo(_backView);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(20);
    }];
    
    self.loopProgressView.frame =CGRectMake(20, _backView.height/2, _backView.width-40, 15);
    [self.loopProgressView initLayers];
    [_backView addSubview:self.loopProgressView];
    
    recordTimeLb = [[UILabel alloc]init];
    recordTimeLb.font = [UIFont systemFontOfSize:10];
    recordTimeLb.textColor = RGBA(150, 150, 150, 1);
    [_backView addSubview:recordTimeLb];
    recordTimeLb.text = [NSString stringWithFormat:@"%ds",(int)minValue];
    [recordTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.loopProgressView.mas_top).offset(-5);
        make.left.equalTo(self.loopProgressView.mas_left);
    }];
    UILabel *allTime = [[UILabel alloc]init];
    allTime.font = [UIFont systemFontOfSize:10];
    allTime.textColor = RGBA(150, 150, 150, 1);
    allTime.text = RECOEDTIME;
    [_backView addSubview:allTime];
    [allTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.loopProgressView.mas_right);
        make.bottom.equalTo(self.loopProgressView.mas_top).offset(-5);
    }];
    
    recordBtn =[UIButton buttonWithType:0];
    [recordBtn setBackgroundImage:[UIImage imageNamed:@"recordBtnBack"] forState:0];
    [recordBtn addTarget:self action:@selector(recordClick) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:recordBtn];
    [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_backView);
        make.top.equalTo(self.loopProgressView.mas_top).offset(20);
        make.width.height.mas_equalTo(60);
    }];
    _animationView = [[YYAnimatedImageView alloc]init];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"recording" withExtension:@"gif"];
    _animationView.yy_imageURL = url;
    _animationView.hidden = YES;
    [recordBtn addSubview:_animationView];
    [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(recordBtn);
        make.width.height.mas_equalTo(50);
    }];
    
    _recordNormalImg = [[UIImageView alloc]init];
    _recordNormalImg.image = [UIImage imageNamed:@"recordNoraml"];
    _recordNormalImg.hidden = NO;
    [recordBtn addSubview:_recordNormalImg];
    [_recordNormalImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(recordBtn);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(25);

    }];
    
    tipsLb = [[UILabel alloc]init];
    tipsLb.textColor = RGBA(150, 150, 150, 1);
    tipsLb.font = [UIFont systemFontOfSize:13];
    tipsLb.text = @"点击可录音";
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [_backView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(recordBtn.mas_bottom).offset(5);
        make.centerX.equalTo(_backView);
    }];
    
    deleteBtn = [UIButton buttonWithType:0];
    [deleteBtn setImage:[UIImage imageNamed:@"录音删除"] forState:0];
    deleteBtn.hidden = YES;
    [deleteBtn addTarget:self action:@selector(deleteSound) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(recordBtn.mas_centerY);
        make.left.equalTo(recordBtn.mas_right).offset(20);
        make.width.height.mas_equalTo(50);
    }];

}
//删除录音
-(void)deleteSound{
    if (audioTimer) {
        [audioTimer invalidate];
        audioTimer= nil;
    }
    tipsLb.hidden = NO;
    recordBtn.hidden = NO;

    _oldtime= 0;
    self.filePath = @"";
    [[XHSoundRecorder sharedSoundRecorder]removeSoundRecorder];
    minValue = 0;
    sureBtn.hidden = YES;
    self.loopProgressView.persentage = minValue;
    recordTimeLb.text = [NSString stringWithFormat:@"%ds",(int)minValue];
    auditionBtn.hidden = YES;
    [auditionBtn setImage:[UIImage imageNamed:@"audio试听"] forState:0];

}
-(void)soundSureClick{
    if (self.recordEvent) {
        self.recordEvent(self.filePath, minValue);
    }
}
- (NSString *)composeDir {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSString *compseDir = [NSString stringWithFormat:@"%@/AudioCompose/", cacheDir];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:compseDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:compseDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return compseDir;
}
#define kCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

#define MUSIC                    [kCachesPath stringByAppendingPathComponent:@"Music"]
#define COMBINPATH         [MUSIC stringByAppendingPathComponent:@"combine.mp3"]

#pragma mark  开始录音
-(void)recordClick{
    isRecording = !isRecording;
    if (isRecording) {
        sureBtn.hidden = YES;
        [self hideLisenAddDelete:YES];
        //开始录音
//        _oldlistenetime = 0;//开始录音试听归零
        _animationView.hidden = NO;
        _recordNormalImg.hidden = YES;
        tipsLb.text = @"点击可暂停";
        WeakSelf;
        if ((int)_oldtime != 0) {
            minValue = _oldtime;
        }
        if (!audioTimer) {
            audioTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(audiodaojishi) userInfo:nil repeats:YES];
        }else{
            [self timerBegin];
        }
//        if (_oldPath && _oldPath.length > 0) {
//            [[XHSoundRecorder sharedSoundRecorder]setNewPath:_oldPath];
//        }
        //  准备录音
        [self prepareToRecord];
        //  录音记录
        BOOL isSuccess = [self.recoder record];
        if (isSuccess) {
            NSLog(@"开始录音成功");
        }else{
            NSLog(@"开始录音失败");
        }

        [[XHSoundRecorder sharedSoundRecorder] startRecorder:^(NSString *filePath) {

            NSLog(@"录音文件路径---:%@",filePath);
            NSLog(@"录音结束");
            if (weakSelf.filePath && weakSelf.filePath.length > 0) {
                recordCount++;
                NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                NSString *destPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ddest.m4a",recordCount]];
                

                NSError *error = nil;
                //  如果目标文件已经存在删除目标文件
                if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {

                    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];
                    if (!success) {
                        NSLog(@"删除文件失败:%@",error);
                    }else{
                        NSLog(@"删除文件:%@成功",destPath);
                    }
                }
                //  目录文件URL
                self.destURL = [NSURL fileURLWithPath:destPath];
//                self.destURL = [NSURL fileURLWithPath:destPath];

                NSURL *oldUrl = [NSURL fileURLWithPath:weakSelf.filePath];
                NSURL *newUrl = [NSURL fileURLWithPath:filePath];
                NSArray * sourceURLs = @[oldUrl,newUrl];
                [HMAudioComposition sourceURLs:sourceURLs composeToURL:self.destURL completed:^(NSError *error) {
                    if (error) {
                        NSLog(@"合并音频文件失败:%@",error);
                    }else{
                        NSLog(@"合并音频文件成功");
                        _filePath =destPath;

                    }
                }];

            }else{
                weakSelf.filePath = filePath;

            }

//            minValue = 0;
            if (minValue == 60) {
                recordBtn.hidden = YES;
                tipsLb.hidden = YES;
            }else{
                recordBtn.hidden = NO;
                tipsLb.hidden = NO;
            }
            sureBtn.hidden = NO;

            _animationView.hidden = YES;
            _recordNormalImg.hidden = NO;
            auditionBtn.hidden = NO;
            deleteBtn.hidden= NO;


        }];

    }else{
        sureBtn.hidden = NO;
//        auditionBtn.hidden = NO;
        [self hideLisenAddDelete:NO];
        //记录上次录制时间
        _oldtime = minValue;
        [[XHSoundRecorder sharedSoundRecorder] stopRecorder];

        tipsLb.text = @"点击可录音";
        _animationView.hidden = YES;
        _recordNormalImg.hidden = NO;
        auditionBtn.hidden = NO;
        deleteBtn.hidden= NO;
        [self timerPause];
    }
}

-(void)hideLisenAddDelete:(BOOL)ishide{
    auditionBtn.hidden = ishide;
    deleteBtn.hidden = ishide;
}
-(NSString*)getDocumentPath
{
    // @expandTilde 是否覆盖
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
    
}


#pragma mark  试听
-(void)auditionClick{
    
    isAudition = !isAudition;
    if (isAudition) {
        [auditionBtn setImage:[UIImage imageNamed:@"audio暂停"] forState:0];
        recordBtn.hidden = YES;
        tipsLb.hidden = YES;
        deleteBtn.hidden = YES;
        [[XHSoundRecorder sharedSoundRecorder] playsound:self.filePath withFinishPlaying:^{
            NSLog(@"播放结束");
            if (minValue == 60) {
                recordBtn.hidden = YES;
                tipsLb.hidden = YES;
            }else{
                recordBtn.hidden = NO;
                tipsLb.hidden = NO;
            }
            sureBtn.hidden = NO;

            deleteBtn.hidden = NO;
            isAudition = NO;
            [auditionBtn setImage:[UIImage imageNamed:@"audio试听"] forState:0];
            [self timerPause];

        }];

        
    }else{
        [[XHSoundRecorder sharedSoundRecorder] pausePlaysound];
        if (minValue == 60) {
            recordBtn.hidden = YES;
            tipsLb.hidden = YES;
        }else{
            recordBtn.hidden = NO;
            tipsLb.hidden = NO;
        }
        deleteBtn.hidden = NO;
        [auditionBtn setImage:[UIImage imageNamed:@"audio试听"] forState:0];

    }
}
#pragma mark 录音倒计时
-(void)audiodaojishi{
    if (minValue == 60) {
        if (audioTimer) {
            [audioTimer invalidate];
            audioTimer = nil;
        }
        [[XHSoundRecorder sharedSoundRecorder] stopRecorder];
        return;
    }
    minValue+=1;
    recordTimeLb.text = [NSString stringWithFormat:@"%ds",(int)minValue];

    self.loopProgressView.persentage = minValue/60;

}

-(void)timerPause{
    [audioTimer setFireDate:[NSDate distantFuture]];
}
-(void)timerBegin{
    [audioTimer setFireDate:[NSDate date]];
}
-(void)timerEnd{
    [audioTimer invalidate];
    

}
#pragma mark ---G
-(YBProgreseView*)loopProgressView{
    if(!_loopProgressView){
        _loopProgressView = [[YBProgreseView alloc] init];
        
    }
    return _loopProgressView;
}

#pragma mark  录音合成

//初始化录音
- (void) prepareToRecord {
    
    // 真机环境仅仅是这样还不能录音
    NSError *error = nil;
    //  单例对象,用于设置当前的应用的音频环境
    //  设置音频的类别
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord  error:&error];
    if (error) {
        NSLog(@"设置录音模式出错");
        return;
    }
    static int count = 0;
    count++;
    //    NSString *fileName = [NSString stringWithFormat:@"recoder_%d.AAC",count];
    NSString *fileName = [NSString stringWithFormat:@"recoder_%d.AAC",count];
    
    //  把录音文件保存在沙盒中
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    //  路径转换为URL
    NSURL *url = [NSURL fileURLWithPath:path];
    //    NSLog(@"%@",url);
    //  录音设置: 了解,涉及到音频很专业的东西,
    //录音: 音频文件最小
    //settings  设置参数  录音相关参数  声道  速率  采样率
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    //2.够着  录音参数
    // 音频格式
    setting[AVFormatIDKey] = @(kAudioFormatMPEG4AAC);
    //    文件后缀必须是: AAC,必须是大写
    // 音频采样率
    setting[AVSampleRateKey] = @(16000.0);
    // 音频通道数
    setting[AVNumberOfChannelsKey] = @(1);
    // 线性音频的位深度
    setting[AVLinearPCMBitDepthKey] = @(8);
    // 音频编码质量
    setting[AVEncoderAudioQualityKey] = @(AVAudioQualityMin);
    
    //  1 .创建录音器
    /// URL: 录音文件保存的地址
    /// settings: 录音的设置
    /// error: 创建录音器的错误信息
    //    NSError *error = nil;
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:url settings:@{} error:&error];
    
    if (error) {
        NSLog(@"创建录音器失败:%@",error);
        return;
    }
    
    //  2. 准备录音
    [recorder prepareToRecord];
    //  3. 开启音频的分贝的更新
    recorder.meteringEnabled = YES;
    
    //  记录录音器
    self.recoder = recorder;
    
}
-(void)compose{
    //  文档路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //  文件路径
    NSArray *fileNames = [[NSFileManager defaultManager] subpathsAtPath:docPath];
    //  获取文档目录保存所有 .AAC 格式的音频文件URL
    NSMutableArray *sourceURLs = [NSMutableArray array];
    
    //  遍历
    for (NSString *fileName in fileNames) {
        NSLog(@"源文件:%@",fileName);
        
        if (![fileName.pathExtension isEqualToString:@"AAC"]) {
            continue;
        }
        
        //      文件路径
        NSString *filePath = [docPath stringByAppendingPathComponent:fileName];
        //      文件的URL
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        //      源文件数组
        [sourceURLs addObject:fileURL];
    }
    
    //  目标文件路径
    
    
    
    NSString *destPath = [docPath stringByAppendingPathComponent:@"dest.m4a"];
    NSError *error = nil;
    //  如果目标文件已经存在删除目标文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];
        if (!success) {
            NSLog(@"删除文件失败:%@",error);
        }else{
            NSLog(@"删除文件:%@成功",destPath);
        }
    }
    //  目录文件URL
    self.destURL = [NSURL fileURLWithPath:destPath];
    //  导出音频
    [HMAudioComposition sourceURLs:sourceURLs composeToURL:self.destURL completed:^(NSError *error) {
        if (error) {
            NSLog(@"合并音频文件失败:%@",error);
        }else{
            NSLog(@"合并音频文件成功");
            _filePath =minstr(self.destURL) ;
        }
    }];

}

@end
