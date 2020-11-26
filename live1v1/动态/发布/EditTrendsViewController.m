//
//  EditTrendsViewController.m
//  live1v1
//
//  Created by ybRRR on 2019/7/25.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "EditTrendsViewController.h"
#import "MyTextView.h"
#import "XLPhotoBrowser.h"
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>
#import <Qiniu/QiniuSDK.h>
#import "SoundRecordView.h"
#import "ShowDetailVC.h"
#import "XHSoundRecorder.h"
#import <YYWebImage/YYWebImage.h>
#import "ImageBrowserViewController.h"
#define photoWH  110
@interface EditTrendsViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,TZImagePickerControllerDelegate,TXLivePlayListener,UITextViewDelegate>{
    UIView *bottomView;
    UIView *addressView;
    UISwitch *addressSwitch;
    
    int _uploadType;    //0：纯文字；1：文字+图片；2：文字+视频 3.文字+音频
    int imageIndex;    //上传图片记录
    NSString *_uploadBackKey;//视频封面key
    UIImage *_videoCoverImage;//相册获取视频封面
    

    TXLivePlayer *_livePlayer;
    NSString *_oldVideoPath;
    UIImageView *_vioceImgNormal;
    UIButton *publishBtn;
    
    UILabel *_voiceTimeLb;
    NSTimer *voicetimer;
    int oldVoiceTime;
    
    BOOL islisten;
    BOOL voiceEnd;
    UILabel *addressLb;
    UILabel *_imageCountlb;
    


}
@property(nonatomic,strong)MyTextView *topTextField;
@property(nonatomic,strong)UIView *topTextView;

@property(nonatomic,strong)UIImageView *photoImgView;
@property(nonatomic,strong)UIView *selphotoView;
@property(nonatomic,strong)NSMutableArray *pohotArr;
@property(nonatomic,strong)NSMutableArray *newpohotArr;

@property(nonatomic,strong)UIImageView *videoImg;
@property(nonatomic,strong)UIImageView *audioImg;
@property(nonatomic,strong)UIButton *deleteAudioBtn;
@property(nonatomic,strong)SoundRecordView *soundView;
@property(nonatomic,strong)NSString *audioPath;//音频路径
@property(nonatomic,assign)int voicetime;//音频路径
@property (nonatomic,strong) AVPlayer *voicePlayer;
//监听播放起状态的监听者
@property (nonatomic ,strong) id playbackTimeObserver;

@property (strong, nonatomic)  YYAnimatedImageView *animationView;
@property(nonatomic,strong) UILabel *wordsNumL;                 //字符统计

@end

@implementation EditTrendsViewController

-(void)returnBtnClick{
    
    if (_topTextField.text.length > 0 || _selphotoView.hidden == NO) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"确认放弃当前编辑内容?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *suerA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[MXBADelegate sharedAppDelegate] popViewController:YES];
        }];
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 9.0) {
            [suerA setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
            [cancleA setValue:[UIColor redColor] forKey:@"_titleTextColor"];
        }
        [alertC addAction:suerA];
        [alertC addAction:cancleA];

        [self presentViewController:alertC animated:YES completion:nil];

    }else{
        [[MXBADelegate sharedAppDelegate] popViewController:YES];

    }
    
}
-(void)creatNavi {
    
    UIView *navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];
    
   
    UIButton *retrunBtn = [UIButton buttonWithType:0];
    retrunBtn.frame = CGRectMake(10, 22+statusbarHeight, 30, 30);
    [retrunBtn setImage:[UIImage imageNamed:@"returnback"] forState:0];
    [retrunBtn addTarget:self action:@selector(returnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:retrunBtn];
     //标题
    UILabel *midLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(retrunBtn.frame)+10, 22+statusbarHeight, 70, 30)];
    midLabel.backgroundColor = [UIColor clearColor];
    midLabel.font = [UIFont boldSystemFontOfSize:16];
    midLabel.text = @"发布动态";
    midLabel.textAlignment = NSTextAlignmentCenter;
    [navi addSubview:midLabel];
    midLabel.centerX = navi.centerX;
    
    
    publishBtn = [UIButton buttonWithType:0];
    publishBtn.frame = CGRectMake(_window_width-60, 22+statusbarHeight, 40, 30);
    [publishBtn setTitle:@"发布" forState:0];
    [publishBtn setTitleColor:normalColors forState:0];
    publishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [publishBtn addTarget:self action:@selector(publishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [publishBtn setEnabled:NO];
    [publishBtn setAlpha:0.4];
    [navi addSubview:publishBtn];
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 63+statusbarHeight, _window_width, 1) andColor:colorf5 andView:navi];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (_livePlayer) {
        [_livePlayer pause];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _uploadType = 0;
    imageIndex = 0;
    _pohotArr = [NSMutableArray array];
    _newpohotArr = [NSMutableArray array];
    voiceEnd = YES;
    [self creatNavi];
    [self.view addSubview:self.topTextView];
    [self addbottomView];
    [self addAddressView];
    
    [self.view addSubview:self.selphotoView];
    [self.view addSubview:self.videoImg];
    [self.view addSubview:self.audioImg];
    [self.view addSubview:self.deleteAudioBtn];
}
//输入框
- (UIView *)topTextView {
    if (!_topTextView) {
        _topTextView = [[UIView alloc]initWithFrame:CGRectMake(5, 70+statusbarHeight, _window_width-10, _window_width*0.32)];
        
        _topTextField = [[MyTextView alloc]initWithFrame:CGRectMake(0,0, _topTextView.width, _topTextView.height-15)];
        _topTextField.placeholder = @"此刻你想说些什么...";
        _topTextField.placeholderColor = RGB_COLOR(@"#cccccc", 1);
        _topTextField.delegate = self;
        _topTextField.font = SYS_Font(15);
        [_topTextView addSubview:_topTextField];
        
        
        _wordsNumL = [[UILabel alloc] initWithFrame:CGRectMake(_topTextView.width-50, _topTextView.height-15, 50, 12)];
//        _wordsNumL = [[UILabel alloc] initWithFrame:CGRectMake(0, _topTextView.height-15, _topTextView.width, 12)];
        _wordsNumL.text = @"0/200";
        _wordsNumL.textColor = RGB_COLOR(@"#969696", 1);
        _wordsNumL.font = [UIFont systemFontOfSize:12];
        _wordsNumL.backgroundColor =[UIColor whiteColor];
        _wordsNumL.textAlignment = NSTextAlignmentRight;
        [_topTextView addSubview:_wordsNumL];

    }
    return _topTextView;
}
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length < 1 && _selphotoView.hidden == YES &&_videoImg.hidden == YES &&_audioImg.hidden == YES) {
        [publishBtn setEnabled:NO];
        [publishBtn setAlpha:0.4];

    }else{
        [publishBtn setEnabled:YES];
        [publishBtn setAlpha:1];

        NSString *toBeString = textView.text;
        NSString *lang = [[[UITextInputMode activeInputModes]firstObject] primaryLanguage]; // 键盘输入模式
        if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange = [textView markedTextRange];//获取高亮部分
            UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
            //没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                if (toBeString.length > 200) {
                    textView.text = [toBeString substringToIndex:200];
                    _wordsNumL.text = [NSString stringWithFormat:@"%lu/200",textView.text.length];
                }else{
                    _wordsNumL.text = [NSString stringWithFormat:@"%lu/200",toBeString.length];
                }
            }else{
                //有高亮选择的字符串，则暂不对文字进行统计和限制
            }
        }else{
            // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            if (toBeString.length > 200) {
                textView.text = [toBeString substringToIndex:200];
                _wordsNumL.text = [NSString stringWithFormat:@"%lu/200",textView.text.length];
            }else{
                _wordsNumL.text = [NSString stringWithFormat:@"%lu/200",toBeString.length];
            }
        }

    }
}

//地址界面
-(void)addAddressView{
    addressView = [[UIView alloc]init];
    addressView.frame = CGRectMake(0, CGRectGetMaxY(bottomView.frame)+15, _window_width, 60);
    [self.view addSubview:addressView];
    //画了一条线（上面的）
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(10, 0, _window_width-20, 1) andColor:colorf5 andView:addressView];
    
    //定位前面的小图片
    UIImageView *addressImg = [[UIImageView alloc]init];
    addressImg.frame = CGRectMake(10, addressView.height/2-7, 12, 14);
    addressImg.image = [UIImage imageNamed:@"trends定位"];
    [addressView addSubview:addressImg];
    
    addressLb = [[UILabel alloc]init];
    addressLb.frame = CGRectMake(addressImg.right+5, addressView.height/2-10, 100, 22);
    addressLb.text = minstr([cityDefault getMyCity]).length > 0 ?minstr([cityDefault getMyCity]):@"好像在火星";
    addressLb.font = [UIFont systemFontOfSize:14];
    addressLb.textColor = [UIColor blackColor];
    [addressView addSubview:addressLb];

    
    //定位开关
    addressSwitch = [[UISwitch alloc]init];
    addressSwitch.frame = CGRectMake(_window_width-60, addressView.height/2-15, 30, 20);
    addressSwitch.on = YES;
    [addressSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:(UIControlEventValueChanged)];

    [addressView addSubview:addressSwitch];
    
    //又画了一条线(下面的)
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(10, addressView.height-1, _window_width-20, 1) andColor:colorf5 andView:addressView];

}
-(void)valueChanged:(UISwitch *)sender{
    if (sender.on) {
        addressLb.text =[cityDefault getMyCity];
    }else{
        addressLb.text =@"好像在火星";

    }
}
//功能按钮 图片、视频、语音、
-(void)addbottomView{
    
    CGFloat btnWH = 60;
    
    
    bottomView = [[UIView alloc]init];
    bottomView.frame = CGRectMake(0, CGRectGetMaxY(_topTextView.frame), _window_width, btnWH);
    [self.view addSubview:bottomView];
    
    NSArray *picArr  = @[@"trends图片",@"trends视频",@"trends录音"];
    NSArray *nameArr = @[@"图片",@"视频",@"录音"];
    for(int i = 0; i < picArr.count ;i ++){
        UIButton *picBtn = [UIButton buttonWithType:0];
        picBtn.frame = CGRectMake(20+10*i+btnWH*i, 0,btnWH, btnWH);
        [picBtn setImage:[UIImage imageNamed:picArr[i]] forState:0];
        [picBtn setTitle:nameArr[i] forState:0];
        picBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        picBtn.tag = 10000+i;
        [picBtn setTitleColor:[UIColor grayColor] forState:0];
        [picBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        picBtn = [YBToolClass setUpImgDownText:picBtn];
        picBtn.layer.cornerRadius = 5;
        picBtn.layer.masksToBounds = YES;
        [picBtn setBackgroundColor:RGBA(250, 250, 250, 1)];
        [bottomView addSubview:picBtn];
    }
    
}
-(void)bottomBtnClick:(UIButton *)sender{
    switch (sender.tag) {
        case 10000:
            NSLog(@"图片")
            [self photoBtnClick];
            break;
        case 10001:
            NSLog(@"视频")
            [self clickBotBtnisMovie:YES];

            break;
        case 10002:
            NSLog(@"语音")
            [self showAudioView];
            break;

        default:
            break;
    }
}

#pragma mark----- 录音功能界面------
-(void)showAudioView{
    WeakSelf;
    if (_soundView) {
        [_soundView removeFromSuperview];
        _soundView = nil;
    }
    _soundView = [[SoundRecordView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _soundView.backgroundColor = RGBA(29, 29, 29, 0.3);
    _soundView.hideBlock = ^{
        [weakSelf.soundView removeFromSuperview];
        weakSelf.soundView =nil;
    };
    _soundView.recordEvent = ^(NSString * _Nonnull audioPath, int voiceTime) {
        weakSelf.audioPath = audioPath;
        weakSelf.voicetime = voiceTime;
        oldVoiceTime = voiceTime;
        [weakSelf.soundView removeFromSuperview];
        weakSelf.soundView =nil;
        [weakSelf changeAudioFrame:YES];


    };
    [self.view addSubview:_soundView];
}
- (void)clickBotBtnisMovie:(BOOL)isMovie {
    
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *picAction = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self selectThumbWithType:UIImagePickerControllerSourceTypeCamera];
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
        NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
        ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
        [self presentViewController:ipc animated:YES completion:nil];
        ipc.videoMaximumDuration = 30.0f;//30秒
        ipc.delegate = self;//设置委托

    }];
    [picAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:picAction];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"本地视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
            imagePC.showSelectBtn = NO;
            imagePC.allowCrop = NO;
            imagePC.allowPickingOriginalPhoto = NO;
            imagePC.oKButtonTitleColorNormal = normalColors;
            imagePC.allowPickingImage = NO;
            imagePC.allowTakePicture = NO;
            imagePC.allowTakeVideo = NO;
            imagePC.allowPickingVideo = YES;
            imagePC.allowPickingMultipleVideo = NO;
            [self presentViewController:imagePC animated:YES completion:nil];

    }];
    [photoAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:photoAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:cancleAction];
    
    [self presentViewController:alertContro animated:YES completion:nil];
    
}

//显示选择照片界面
-(UIView *)selphotoView{
    
    if (!_selphotoView) {
        
        _selphotoView = [[UIView alloc]init];
        _selphotoView.frame = CGRectMake(0, CGRectGetMaxY(_topTextView.frame), _window_width, photoWH);
        _selphotoView.hidden = YES;

        _photoImgView = [[UIImageView alloc]init];
        _photoImgView.frame = CGRectMake(10, 0, photoWH, photoWH);
        _photoImgView.userInteractionEnabled = YES;
        _photoImgView.contentMode = UIViewContentModeScaleAspectFit;
        _photoImgView.userInteractionEnabled = YES;
        [_selphotoView addSubview:_photoImgView];
        
        UIImageView *backImg = [[UIImageView alloc]init];
        backImg.image = [UIImage imageNamed:@"editImgBack"];
        backImg.frame  = CGRectMake(0, 0, _photoImgView.width, _photoImgView.height);
        backImg.userInteractionEnabled = YES;
        [_photoImgView addSubview:backImg];
        
        _imageCountlb = [[UILabel alloc]init];
        _imageCountlb.font = [UIFont systemFontOfSize:10];
        _imageCountlb.textColor = [UIColor whiteColor];
        [backImg addSubview:_imageCountlb];
        [_imageCountlb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(backImg).offset(-5);
            make.bottom.equalTo(backImg).offset(-5);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage)];
        [backImg addGestureRecognizer:tap];
        
        UIButton *deleteBtn = [UIButton buttonWithType:0];
        deleteBtn.frame = CGRectMake(_photoImgView.width-16, 0, 16, 16);
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"删除相册"] forState:0];
        [deleteBtn addTarget:self action:@selector(deletePhotoClick) forControlEvents:UIControlEventTouchUpInside];
        [_photoImgView addSubview:deleteBtn];
        
        UIButton *addPhotoBtn = [UIButton buttonWithType:0];
        addPhotoBtn.frame = CGRectMake(CGRectGetMaxX(_photoImgView.frame)+10, 0,photoWH, photoWH);
        [addPhotoBtn setImage:[UIImage imageNamed:@"trends添加"] forState:0];
        [addPhotoBtn setBackgroundColor:RGBA(250, 250, 250, 1)];
        [addPhotoBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        addPhotoBtn.tag = 10000;
        [_selphotoView addSubview:addPhotoBtn];
        
    }
    return _selphotoView;
}


#pragma mark--------视频界面-----------
-(UIImageView *)videoImg{

    if (!_videoImg) {
        _videoImg = [[UIImageView alloc]init];
        _videoImg.frame =CGRectMake(10,CGRectGetMaxY(_topTextView.frame), _window_width/2.8, _window_width/2.8*16/9);
        _videoImg.userInteractionEnabled = YES;
        _videoImg.hidden = YES;
        
        UIButton *deleteBtn = [UIButton buttonWithType:0];
        deleteBtn.frame = CGRectMake(_videoImg.width-16, 0, 16, 16);
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"删除相册"] forState:0];
        [deleteBtn addTarget:self action:@selector(deleteVideoClick) forControlEvents:UIControlEventTouchUpInside];
        [_videoImg addSubview:deleteBtn];

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTap)];
        [_videoImg addGestureRecognizer:singleTap];
    }
    return _videoImg;
}
-(void)deleteVideoClick{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"是否删除视频?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (_livePlayer) {
            [_livePlayer stopPlay];
            [_livePlayer removeVideoWidget];
            _livePlayer = nil;
        }
        
        [self changeVideoFrame:NO];
    }];
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 9.0) {
        [suerA setValue:[UIColor redColor] forKey:@"_titleTextColor"];
        [cancleA setValue:RGB_COLOR(@"#969696", 1) forKey:@"_titleTextColor"];
    }
    [alertC addAction:cancleA];
    [alertC addAction:suerA];
    [self presentViewController:alertC animated:YES completion:nil];

}
#pragma mark--------音频界面-----------

-(UIImageView *)audioImg{
    if (!_audioImg) {
        _audioImg = [[UIImageView alloc]init];
        _audioImg.frame =CGRectMake(10,CGRectGetMaxY(_topTextView.frame), _window_width/2, 40);
        _audioImg.backgroundColor = normalColors;
        _audioImg.userInteractionEnabled = YES;
        _audioImg.layer.cornerRadius = 20;
        _audioImg.layer.masksToBounds = YES;
        _audioImg.hidden = YES;
        
        _animationView = [[YYAnimatedImageView alloc]init];
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"trendslistaudeo" withExtension:@"gif"];
        _animationView.yy_imageURL = url;
        _animationView.hidden = YES;
        [_audioImg addSubview:_animationView];
        [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_audioImg);
            make.left.equalTo(_audioImg).offset(20);
            make.width.equalTo(_audioImg).multipliedBy(0.6);
            make.height.mas_equalTo(30);
        }];

        
        _vioceImgNormal = [[UIImageView alloc]init];
        _vioceImgNormal.image =[UIImage imageNamed:@"icon_voice_play_1"];
        _vioceImgNormal.userInteractionEnabled = YES;
        [_audioImg addSubview:_vioceImgNormal];
        [_vioceImgNormal mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_audioImg);
            make.left.equalTo(_audioImg).offset(20);
            make.width.equalTo(_audioImg).multipliedBy(0.6);
            make.height.mas_equalTo(18);

        }];

        _voiceTimeLb = [[UILabel alloc]init];
        _voiceTimeLb.textColor =[UIColor whiteColor];
        _voiceTimeLb.font = [UIFont systemFontOfSize:14];
        [_audioImg addSubview:_voiceTimeLb];
        [_voiceTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_vioceImgNormal.mas_right).offset(8);
            make.centerY.equalTo(_audioImg.mas_centerY);
            make.right.equalTo(_audioImg.mas_right);
            make.height.mas_equalTo(16);
        }];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioImgClick)];
        [_audioImg addGestureRecognizer:singleTap];
    }
    return _audioImg;

}
-(void)audioImgClick{
    
    int floattotal = self.voicetime;
    
    islisten = !islisten;
    if (islisten) {
        voiceEnd = NO;
        if (_voicePlayer) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
            [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
            [_voicePlayer removeObserver:self forKeyPath:@"status"];
            [_voicePlayer pause];
            _voicePlayer = nil;
        }else{
        }
        NSURL * url  = [NSURL fileURLWithPath:self.audioPath isDirectory:NO];
        AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
        _voicePlayer = [[AVPlayer alloc]initWithPlayerItem:songItem];
        [_voicePlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        //        _voicePlayer.automaticallyWaitsToMinimizeStalling = NO;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
        WeakSelf;
        _playbackTimeObserver = [_voicePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            //当前播放的时间
            CGFloat floatcurrent = CMTimeGetSeconds(time);
            NSLog(@"floatcurrent = %.1f",floatcurrent);
            //总时间
            _voiceTimeLb.text =[NSString stringWithFormat:@"%.0fs",(floattotal-floatcurrent) > 0 ? (floattotal-floatcurrent) : 0];
            
        }];
        
        [_voicePlayer play];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
        
    }else{
        _vioceImgNormal.hidden = NO;
        
        _animationView.hidden = YES;
        if (_voicePlayer) {
            [_voicePlayer pause];
        }
    }

}


- (void)playFinished:(NSNotification *)not{
    
    voiceEnd = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
    [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
    [_voicePlayer removeObserver:self forKeyPath:@"status"];
    [_voicePlayer pause];
    _voicePlayer = nil;
    
    _animationView.hidden = YES;
    _voiceTimeLb.text = [NSString stringWithFormat:@"%ds",self.voicetime];
    _vioceImgNormal.hidden = NO;
    
}
- (void)appDidEnterBackground:(NSNotification *)not{
    if (_voicePlayer) {
        [_voicePlayer pause];
        [self playFinished:not];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                NSLog(@"----播放失败----------");
                [MBProgressHUD showError:@"播放失败"];
                voiceEnd = NO;
                //                if (self.mutedBlock) {
                //                    self.mutedBlock(@"0");
                //                }
                
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"----播放----------");
                
                //                [self creatJumpBtn];
                voiceEnd = YES;
                _vioceImgNormal.hidden = YES;
                _animationView.hidden = NO;
                
                
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                [MBProgressHUD showError:@"播放失败"];
                voiceEnd = NO;
                //                if (self.mutedBlock) {
                //                    self.mutedBlock(@"0");
                //                }
                
            }
                break;
        }
        
    }
    
}


-(void)voicedaojishi{
    oldVoiceTime--;
    _voiceTimeLb.text = [NSString stringWithFormat:@"%ds",oldVoiceTime];
}

-(void)timerPause{
    [voicetimer setFireDate:[NSDate distantFuture]];
}
-(void)timerBegin{
    [voicetimer setFireDate:[NSDate date]];
}
-(void)timerEnd{
    [voicetimer invalidate];
    
    
}

-(UIButton *)deleteAudioBtn{
    if (!_deleteAudioBtn) {
        _deleteAudioBtn = [UIButton buttonWithType:0];
        _deleteAudioBtn.frame = CGRectMake(CGRectGetMaxX(_audioImg.frame), _audioImg.origin.y, 20, 20);
        [_deleteAudioBtn setImage:[UIImage imageNamed:@"icon_voice_del"] forState:0];
        [_deleteAudioBtn addTarget:self action:@selector(deleteAudioClick) forControlEvents:UIControlEventTouchUpInside];
        _deleteAudioBtn.hidden  = YES;
    }
    return _deleteAudioBtn;

}
-(void)deleteAudioClick{
    
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:@"是否删除录音？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        voiceEnd = YES;
        [self changeAudioFrame:NO];
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    [cancleAction setValue:[UIColor blackColor] forKey:@"_titleTextColor"];

    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];

}
-(void)audioTap{

}
-(void)videoTap{
    ShowDetailVC *detail = [[ShowDetailVC alloc]init];
    detail.videoPath =_oldVideoPath;
    detail.backcolor = @"video";

    detail.deleteEvent = ^(NSString *type) {
        if ([type isEqual:@"视频"]) {
            if (_videoImg) {
                [_livePlayer stopPlay];
                _livePlayer = nil;
            }
            [self changeVideoFrame:NO];
        }
    };
    [[MXBADelegate sharedAppDelegate]pushViewController:detail animated:YES];
}
#pragma mark 图片点击
-(void)tapImage{
    [ImageBrowserViewController show:self type:PhotoBroswerVCTypeModal hideDelete:NO index:0 imagesBlock:^NSArray *{
        return _pohotArr;

    } retrunBack:^(NSMutableArray *imgearr) {
        if (imgearr.count > 0) {
            _pohotArr = imgearr;
        }else{
            [self changeFrame:NO];
        }
    }];
}

#pragma mark  ------------发布---------------
-(void)publishBtnClick{
    publishBtn.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        publishBtn.userInteractionEnabled = YES;
    });
    [MBProgressHUD showMessage:@""];
    //1  图片。 2视频。3音频。0文字
    if (_selphotoView.hidden == NO) {
        _uploadType = 1;
        [self getQiNiuToken];
    }else if (_videoImg.hidden == NO) {
        _uploadType = 2;
        [self getQiNiuToken];
    }else if(_audioImg.hidden == NO){
        _uploadType = 3;
        [self getQiNiuToken];
    }else{
        _uploadType = 0;
        [self requstAPPServceAndVideo:@"" andVideoImage:@"" addThumb:@"" addVoice:@"" length:@""];
    }
    
}
-(void)requstAPPServceAndVideo:(NSString *)video andVideoImage:(NSString *)video_thumb addThumb:(NSString *)thumb addVoice:(NSString *)voice length:(NSString *)length{
    
    NSDictionary *singDic = @{
                              @"uid":[Config getOwnID],
                              @"type":@(_uploadType)
                              };
    NSString *sign = [YBToolClass sortString:singDic];
    
    
    NSDictionary *parmeter = @{
                               @"uid":[Config getOwnID],
                               @"token":[Config getOwnToken],
                               @"title":_topTextField.text,
                               @"thumb":thumb,
                               @"video_thumb":video_thumb,
                               @"href":video,
                               @"lat":minstr([cityDefault getMylat]) ,
                               @"lng":minstr([cityDefault getMylat]),
                               @"city":minstr(addressLb.text) ,
                               @"type":@(_uploadType),
                               @"voice":voice,
                               @"length":length,
                               @"sign":sign
                               };
    [YBToolClass postNetworkWithUrl:@"Dynamic.setDynamic" andParameter:parmeter success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            imageIndex = 0;
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
        }
        
    } fail:^{
        
    }];

}
//删除照片
-(void)deletePhotoClick{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"是否删除照片?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _selphotoView.hidden = YES;
        _uploadType = 0;
        [self changeFrame:NO];
    }];
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 9.0) {
        [suerA setValue:[UIColor redColor] forKey:@"_titleTextColor"];
        [cancleA setValue:RGB_COLOR(@"#969696", 1) forKey:@"_titleTextColor"];
    }
    [alertC addAction:cancleA];
    [alertC addAction:suerA];
    [self presentViewController:alertC animated:YES completion:nil];

}


#pragma mark  ------ 改变坐标。---------
-(void)changeFrame:(BOOL)ischange{
    if (ischange) {
        [publishBtn setEnabled:YES];
        [publishBtn setAlpha:1];
        _imageCountlb.text = [NSString stringWithFormat:@"共%ld张",_pohotArr.count];
        _selphotoView.hidden =NO;
        bottomView.hidden = YES;
        addressView.frame = CGRectMake(0, CGRectGetMaxY(_selphotoView.frame)+15, _window_width, 60);
    }else{
        _selphotoView.hidden =YES;
        bottomView.hidden = NO;
        addressView.frame = CGRectMake(0, CGRectGetMaxY(bottomView.frame)+15, _window_width, 60);
        if (_topTextField.text.length < 1) {
            [publishBtn setEnabled:NO];
            [publishBtn setAlpha:0.4];

        }
    }
    
}

-(void)changeVideoFrame:(BOOL)ischange{
    if (ischange) {
        [publishBtn setEnabled:YES];
        [publishBtn setAlpha:1];

        _videoImg.hidden =NO;
        bottomView.hidden = YES;
        addressView.frame = CGRectMake(0, CGRectGetMaxY(_videoImg.frame)+15, _window_width, 60);
    }else{
        _videoImg.hidden =YES;
        bottomView.hidden = NO;
        addressView.frame = CGRectMake(0, CGRectGetMaxY(bottomView.frame)+15, _window_width, 60);
        if (_topTextField.text.length < 1) {
            [publishBtn setEnabled:NO];
            [publishBtn setAlpha:0.4];
            
        }

    }

}
-(void)changeAudioFrame:(BOOL)ischange{
    if (ischange) {
        [publishBtn setEnabled:YES];
        [publishBtn setAlpha:1];

        _audioImg.hidden =NO;
        _deleteAudioBtn.hidden = NO;
        bottomView.hidden = YES;
        addressView.frame = CGRectMake(0, CGRectGetMaxY(_audioImg.frame)+15, _window_width, 60);
        _voiceTimeLb.text = [NSString stringWithFormat:@"%ds",self.voicetime];
    }else{
        _audioImg.hidden =YES;
        _deleteAudioBtn.hidden = YES;
        
        bottomView.hidden = NO;
        addressView.frame = CGRectMake(0, CGRectGetMaxY(bottomView.frame)+15, _window_width, 60);
        if (_topTextField.text.length < 1) {
            [publishBtn setEnabled:NO];
            [publishBtn setAlpha:0.4];
            
        }

    }
    
}

#pragma mark **************选择图片begin************************
- (void)photoBtnClick
{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *picAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectThumbWithType:UIImagePickerControllerSourceTypeCamera];

    }];
    [picAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:picAction];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self selectThumbWithType:UIImagePickerControllerSourceTypePhotoLibrary];
        TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:9 delegate:self];
        imagePC.showSelectBtn = YES;
        imagePC.allowCrop = NO;
        imagePC.allowPickingOriginalPhoto = NO;
        imagePC.oKButtonTitleColorNormal = normalColors;
        imagePC.allowTakePicture = YES;
        imagePC.allowTakeVideo = NO;
        imagePC.allowPickingVideo = NO;
        imagePC.allowPickingMultipleVideo = NO;
        [self presentViewController:imagePC animated:YES completion:nil];

    }];
    [photoAction setValue:color32 forKey:@"_titleTextColor"];
    [alertContro addAction:photoAction];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancleAction setValue:color96 forKey:@"_titleTextColor"];
    [alertContro addAction:cancleAction];
    
    [self presentViewController:alertContro animated:YES completion:nil];
    
}
- (void)selectThumbWithType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = type;
    imagePickerController.allowsEditing = YES;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
- (UIImage*)getVideoFirstViewImage:(NSURL *)path {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
   
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        _photoImgView.image = image;
        [_pohotArr addObject:_photoImgView.image];
        NSLog(@"====sssssss====:%@",_pohotArr);
        [self changeFrame:YES];
    }else{
        NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"sssd00-----%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:sourceURL]]);
        NSLog(@"sssdsss-----%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[sourceURL path]]]);
        NSString *outputPath =[sourceURL path];
        UIImage *viodeimg =[self getVideoFirstViewImage:[NSURL fileURLWithPath:outputPath]];
        [self changeVideoFrame:YES];
        if (!_livePlayer) {
            _livePlayer  = [[TXLivePlayer alloc] init];
            _livePlayer.delegate = self;
        }
        
        [_livePlayer setupVideoWidget:CGRectZero containView:_videoImg insertIndex:0];
        [_livePlayer startPlay:outputPath type:PLAY_TYPE_LOCAL_VIDEO];
        _videoCoverImage = viodeimg;
        _oldVideoPath = outputPath;

        //以下是压缩视频 暂未用
//        NSURL *newVideoUrl ; //一般.mp4
//        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
//        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
//        newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]] ;//这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
//        [picker dismissViewControllerAnimated:YES completion:nil];
//        [self convertVideoQuailtyWithInputURL:sourceURL outputURL:newVideoUrl completeHandler:nil];

    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    

}
- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    //  NSLog(resultPath);
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 NSLog(@"%@",[NSString stringWithFormat:@"%f s", [self getVideoLength:outputURL]]);
                 NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [self getFileSize:[outputURL path]]]);
                 
                 //UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], self, nil, NULL);//这个是保存到手机相册
                 
//                 [self alertUploadVideo:outputURL];
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
         
     }];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}

#pragma mark **************选择图片end************************


#pragma mark------------选择视频------------------------
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    NSLog(@"-dsddddddddd--%@\n===%@",asset,coverImage);
    
    [MBProgressHUD showMessage:@""];
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetMediumQuality success:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        if (outputPath) {
            [MBProgressHUD hideHUD];

            [self changeVideoFrame:YES];
            if (!_livePlayer) {
                _livePlayer  = [[TXLivePlayer alloc] init];
                _livePlayer.delegate = self;
            }

            [_livePlayer setupVideoWidget:CGRectZero containView:_videoImg insertIndex:0];
            [_livePlayer startPlay:outputPath type:PLAY_TYPE_LOCAL_VIDEO];
            _videoCoverImage = coverImage;
            _oldVideoPath = outputPath;
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"请重新选择(iCloud视频请先在本地相册下载后上传)"];
        }

    } failure:^(NSString *errorMessage, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:errorMessage];
        NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
    }];
    
    
}
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    NSLog(@"------多选择图片--：%@",photos);
    [_pohotArr addObjectsFromArray:photos];
    [self changeFrame:YES];
    if (_pohotArr.count > 0) {
        _photoImgView.image = [_pohotArr firstObject];

    }

}

#pragma make  ------上传七牛-----------
-(void)getQiNiuToken{
    
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Upload.GetQiniuToken" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *token = minstr([[info firstObject] valueForKey:@"token"]);
            [weakSelf starUplodToKen:token andCover:_videoCoverImage andViderPath:_oldVideoPath];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"提交失败"];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"提交失败"];
    }];

}
//传视频和封面图
-(void)starUplodToKen:(NSString *)token andCover:(UIImage *)coverImg andViderPath:(NSString *)videoPath {
    _oldVideoPath = videoPath;
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        
    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    
    if(_uploadType == 2){
        NSData *imageData = UIImagePNGRepresentation(coverImg);
        if (!imageData) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"请重新选择"];
            return;
        }
        NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"_action_video_cover.png"];
        //传图片
        WeakSelf;
        [upManager putData:imageData key:imageName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if (info.ok) {
                //图片成功
                _uploadBackKey = key;
                //传视频
                NSString *videoName = [YBToolClass getNameBaseCurrentTime:@"_action_video.mp4"];
                [upManager putFile:videoPath key:videoName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                    if (info.ok) {
                        [MBProgressHUD hideHUD];
                        [weakSelf uploadVideo:key andCover:_uploadBackKey];
                    }else {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:@"提交失败"];
                    }
                } option:option];
            }
            else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"提交失败"];
            }
        } option:option];
    }else if(_uploadType == 1){
        
        [_newpohotArr removeAllObjects];
        for (int i = 0; i < _pohotArr.count ; i ++) {
            
            UIImage *image =_pohotArr[i];
            NSData *imageData = UIImagePNGRepresentation(image);
            if (!imageData) {
                [MBProgressHUD showError:@"图片错误"];
                return;
            }
            NSString *imageName = [YBToolClass getNameBaseCurrentTime:[NSString stringWithFormat:@"_action_image%d_cover.png", i]];

            [upManager putData:imageData key:imageName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                if (info.ok) {
                    //图片成功
                    [_newpohotArr addObject:key];
                    imageIndex +=1;
                    if (imageIndex == _pohotArr.count) {
                        NSString *allImg = @"";
                        for (NSString *imgStr in _newpohotArr) {
                            allImg =[allImg stringByAppendingString:[NSString stringWithFormat:@"%@;",imgStr]];
                        }
                        NSMutableString *uploadImg =[ NSMutableString stringWithString:[NSString stringWithFormat:@"%@"
                                                                                       ,allImg]];;

                        [uploadImg replaceCharactersInRange:NSMakeRange(uploadImg.length-1,1) withString:@""];
                        NSLog(@"sdasdjkasdjaktutututu:%@",uploadImg)
                        [self requstAPPServceAndVideo:@"" andVideoImage:@"" addThumb:uploadImg addVoice:@"" length:@""];
                        
                    }

                }else {
                    imageIndex = 0;
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"提交失败"];
                }
            } option:option];

        }
    }else if(_uploadType == 3){
        WeakSelf;
        NSString *videoName = [YBToolClass getNameBaseCurrentTime:@"_action_audio.m4a"];

        [upManager putFile:self.audioPath key:videoName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if (info.ok) {
                [MBProgressHUD hideHUD];
                [weakSelf requstAPPServceAndVideo:@"" andVideoImage:@"" addThumb:@"" addVoice:key length:[NSString stringWithFormat:@"%d",weakSelf.voicetime]];
            }else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"提交失败"];
            }
        } option:option];

    }
}
-(void)uploadVideo:(NSString *)videoKey andCover:(NSString *)coverKey {
    
    [self requstAPPServceAndVideo:videoKey andVideoImage:coverKey addThumb:@"" addVoice:@"" length:@""];

}

#pragma mark  视频
-(void)stopPlay{
    if (_livePlayer) {
        [_livePlayer stopPlay];
        _livePlayer = nil;
    }
}
-(void)playVideo:(NSDictionary *)subDic {
    NSString *videoUrl = [NSString stringWithFormat:@"%@/%@",[common qiniu_domain],[subDic valueForKey:@"videoUrl"]];
    if (!_livePlayer) {
        _livePlayer  = [[TXLivePlayer alloc] init];
        _livePlayer.delegate = self;
    }
    [_livePlayer setupVideoWidget:CGRectZero containView:_videoImg insertIndex:0];
    [_livePlayer startPlay:videoUrl type:PLAY_TYPE_LOCAL_VIDEO];
}
#pragma mark TXLivePlayListener
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_PLAY_END) {
            [_livePlayer resume];
            return;
        }
    });
    
}
-(void) onNetStatus:(NSDictionary*) param {
    
}
- (CGFloat) getFileSize:(NSString *)path
{
    NSLog(@"%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size/1024;
    }else{
        NSLog(@"找不到文件");
    }
    return filesize;
}//此方法可以获取文件的大小，返回的是单位是KB。
- (CGFloat) getVideoLength:(NSURL *)URL
{
    
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:URL];
    CMTime time = [avUrl duration];
    int second = ceil(time.value/time.timescale);
    return second;
}//此方法可以获取视频文件的时长。

@end
