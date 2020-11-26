
//#import <TXLiteAVSDK_UGC/TXUGCPublish.h>
//#import <TXRTMPSDK/TXUGCRecord.h>
//#import <TXRTMPSDK/TXUGCPublish.h>
//#import <TXRTMPSDK/TXLivePlayer.h>

#import "TCVideoPublishController.h"
#import "UIView+CustomAutoLayout.h"
#import "TCVideoRecordViewController.h"

//#import <TXLiteAVSDK_UGC/TXUGCRecord.h>
//#import <TXLiteAVSDK_UGC/TXLivePlayer.h>
#import <TXLiteAVSDK_Professional/TXUGCRecord.h>
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <Qiniu/QiniuSDK.h>
#import <AVFoundation/AVFoundation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
//#import <COSClient.h>
#import "QCloudCore.h"
#import <QCloudCOSXML/QCloudCOSXML.h>

#import "YBTabBarController.h"
#import "MyTextView.h"
#import "instructionCell.h"
#import "MIneVideoViewController.h"

@interface TCVideoPublishController()<TXLivePlayListener,QCloudSignatureProvider,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource>
@property BOOL isNetWorkErr;
@property UIImageView      *imgPublishState;

@property (nonatomic,strong) NSString *imagekey;
@property (nonatomic,strong) NSString *videokey;
//分享的视频id 和 截图
@property (nonatomic,strong) NSString *videoid;
@property (nonatomic,strong) NSString *image_thumb;

/** 顶部组合：视频预览、视频描述 */
@property(nonatomic,strong)UIView   *topMix;

@property(nonatomic,strong)UIView  *videoPreview;               //视频预览
@property(nonatomic,strong)MyTextView  *videoDesTV;             //视频描述
@property(nonatomic,strong) UILabel *wordsNumL;                 //字符统计

/** 定位组合：图标、位置 */
@property(nonatomic,strong)UIView *locationV;

/** 分享平台组合 */
//@property(nonatomic,strong)PublishShareV *platformV;

/** 发布按钮 */
@property(nonatomic,strong)UIButton *publishBtn;

/**
 *  tx上传
 */
@property(nonatomic,strong)NSDictionary *TXSignDic;

@property (nonatomic,strong) UISwitch *coastSwitch;

@property (nonatomic,strong) UIButton *coastPriceBtn;

@property (nonatomic,strong) UILabel *tipsLable;

@end
@implementation TCVideoPublishController
{
    int sharetype;           //分享类型
    NSString *mytitle;
    
    //TXUGCPublish   *_videoPublish;
    TXLivePlayer     *_livePlayer;
    
    //TXPublishParam   *_videoPublishParams;
    TXRecordResult   *_recordResult;
    
    BOOL            _isPublished;
    BOOL            _playEnable;
    id              _videoRecorder;
    BOOL            _isNetWorkErr;
    NSString *qntoken;                       //七牛token
    
    NSString *filePathhh;                    //图片保存路径
   
    NSString *tengxunID;
    NSString *bucketName;
    NSString *regionName;
    
    
    UIView *pickBackView;
    UIView *wihteView;
    UIView *instructionView;
    UIPickerView *coinPicker;
    NSArray *videoArray;
    int videoMaxSelectIndex;
    int curVideoIndex;
    UITableView *instructionTable;
    NSArray *instructionArray;
    NSString *coastCoinStr;
}
#define TXYappId @"1255500835"
- (instancetype)initWithPath:(NSString *)videoPath videoMsg:(UIImage *) videoMsg {
    TXRecordResult *recordResult = [TXRecordResult new];
//    recordResult.coverImage = videoMsg.coverImage;
    recordResult.coverImage = videoMsg;

    recordResult.videoPath = videoPath;
    
    return [self init:nil recordType:0
         RecordResult:recordResult
           TCLiveInfo:nil];
    
}

- (instancetype)init:(id)videoRecorder recordType:(NSInteger)recordType RecordResult:(TXRecordResult *)recordResult  TCLiveInfo:(NSDictionary *)liveInfo {
    self = [super init];
    if (self) {

        sharetype = 0;
        //_videoPublishParams = [[TXPublishParam alloc] init];
        
        _recordResult = recordResult;
        _videoRecorder = videoRecorder;
        
        _isPublished = NO;
        _playEnable  = YES;
        _isNetWorkErr = NO;
        
        //_videoPublish = [[TXUGCPublish alloc] initWithUserID:[Config getOwnID]];
        //_videoPublish.delegate = self;
        _livePlayer  = [[TXLivePlayer alloc] init];
        _livePlayer.delegate = self;
        coastCoinStr = @"0";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
    }
    return self;
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getVideoCoastList];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _playEnable = YES;
    if (_isPublished == NO) {
        [_livePlayer startPlay:_recordResult.videoPath type:PLAY_TYPE_LOCAL_VIDEO];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _playEnable = NO;
    [_livePlayer stopPlay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"发布";
//    [UIApplication sharedApplication].statusBarHidden = NO;
//    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = colorf5;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
    
    
    //顶部视图：预览、描述
    [self.view addSubview:self.topMix];
    
    //定位
    [self.view addSubview:self.locationV];
    
    //发布
    [self.view addSubview:self.publishBtn];
    
    [self.view addSubview:self.tipsLable];
    [_tipsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_locationV.mas_bottom).offset(3);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    [_livePlayer setupVideoWidget:CGRectZero containView:_videoPreview insertIndex:0];
    
//    [BGSetting getBgSettingUpdate:NO maintain:NO eventBack:nil];
    
}

- (void)closeKeyboard:(UITapGestureRecognizer *)gestureRecognizer {
    [_videoDesTV resignFirstResponder];
}

#pragma mark - 发布
- (void)clickPublishBtn {

   _publishBtn.enabled = NO;
   [self.view endEditing:YES];
   [MBProgressHUD showMessage:@"发布中，请稍后"];
   mytitle = [NSString stringWithFormat:@"%@",_videoDesTV.text];//标题
    __weak TCVideoPublishController *weakself = self;
    if ([[common cloudtype] isEqualToString:@"2"]) {


        NSString *imgName = [YBToolClass getNameBaseCurrentTime:@".png"];
        NSString *videoName = [YBToolClass getNameBaseCurrentTime:@".mp4"];
        NSDictionary *parameters = @{@"imgname":imgName,
                                     @"videoname":videoName,
                                     @"folderimg":[common getTximgfolder],
                                     @"foldervideo":[common getTxvideofolder],
                                     };
        [YBToolClass postNetworkWithUrl:@"Video.getCreateNonreusableSignature" andParameter:parameters success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSDictionary *infoDic =  [info firstObject];
                bucketName = minstr([infoDic valueForKey:@"bucketname"]);
                tengxunID = minstr([infoDic valueForKey:@"appid"]);
                regionName = minstr([infoDic valueForKey:@"region"]);
                
//                if ([PublicObj checkNull:bucketName] || [PublicObj checkNull:tengxunID] || [PublicObj checkNull:regionName]) {
//                    NSLog(@"未配置腾讯云");
//                    [MBProgressHUD hideHUD];
//                    [MBProgressHUD showError:@"未配置腾讯云"];
//                    weakself.publishBtn.enabled = YES;
//                }else{
                    //初始化上传参数
                    [self txUplode];
                    [weakself uploadTCWithImgsign:[infoDic valueForKey:@"imgsign"] andVideosign:[infoDic valueForKey:@"videosign"] andImageName:imgName andVideoName:videoName];
//                }
            }else{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:msg];
                weakself.publishBtn.enabled = YES;
            }

        } fail:^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"网络连接断开，视频上传失败"];
            weakself.publishBtn.enabled = YES;

        }];

        [self networkState];

    }else{
//        NSString *url = [purl stringByAppendingFormat:@"?service=Video.getQiniuToken"];
        [YBToolClass postNetworkWithUrl:@"Upload.GetQiniuToken" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                NSDictionary *infoDic =  [info firstObject];
                qntoken = [NSString stringWithFormat:@"%@",[infoDic valueForKey:@"token"]];
                [weakself uploadqn];
            }else{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:msg];
                weakself.publishBtn.enabled = YES;
            }

        } fail:^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"网络连接断开，视频上传失败"];
            weakself.publishBtn.enabled = YES;
        }];
        
        [self networkState];
    }

}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView*)textView {

    NSString *toBeString = textView.text;
    NSString *lang = [[[UITextInputMode activeInputModes]firstObject] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];//获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 20) {
                textView.text = [toBeString substringToIndex:20];
                _wordsNumL.text = [NSString stringWithFormat:@"%lu/20",textView.text.length];
            }else{
                _wordsNumL.text = [NSString stringWithFormat:@"%lu/20",toBeString.length];
            }
        }else{
            //有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }else{
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > 20) {
            textView.text = [toBeString substringToIndex:20];
            _wordsNumL.text = [NSString stringWithFormat:@"%lu/20",textView.text.length];
        }else{
            _wordsNumL.text = [NSString stringWithFormat:@"%lu/20",toBeString.length];
        }
    }
    
}


- (void)applicationWillEnterForeground:(NSNotification *)noti {
    //temporary fix bug
    if ([self.navigationItem.title isEqualToString:@"发布中"])
        return;
    
    if (_isPublished == NO) {

        [_livePlayer startPlay:_recordResult.videoPath type:PLAY_TYPE_LOCAL_VIDEO];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)noti {
    [_livePlayer stopPlay];
    
}
#pragma mark TXLivePlayListener
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_PLAY_END && _playEnable) {
            [_livePlayer startPlay:_recordResult.videoPath type:PLAY_TYPE_LOCAL_VIDEO];
            return;
        }
    });

}
-(void) onNetStatus:(NSDictionary*) param {
    return;
}


#pragma mark - 上传七牛start
-(void)uploadqn{
    __weak TCVideoPublishController *weakself = self;
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        
    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    //获取视频和图片
    NSString *filePath =_recordResult.videoPath;
    NSData *imageData = UIImagePNGRepresentation(_recordResult.coverImage);
    NSString *imageName = [YBToolClass getNameBaseCurrentTime:@".png"];
    //传图片
    [upManager putData:imageData key:[NSString stringWithFormat:@"image_%@",imageName] token:qntoken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        if (info.ok) {
            //图片成功
            [weakself uploadimagesuccess:key];
            //传视频
            NSString *videoName = [YBToolClass getNameBaseCurrentTime:@".mp4"];
            [upManager putFile:filePath key:[NSString stringWithFormat:@"video_%@",videoName] token:qntoken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                if (info.ok) {
                    //成功
                    NSLog(@"qn_upload_suc:%@",key);
                    //请求app业务服务器给标题
                    [weakself uploadvideosuccess:key andTitle:mytitle];
                }else {
                    //失败
                    [MBProgressHUD showError:@"上传失败"];
                    _publishBtn.enabled = YES;
                }
                NSLog(@"info ===== %@", info);
                NSLog(@"resp ===== %@", resp);
            } option:option];
        }
        else {
            [MBProgressHUD hideHUD];
            //图片失败
            NSLog(@"%@",info.error);
            [MBProgressHUD showError:@"上传失败"];
            _publishBtn.enabled = YES;
        }
    } option:option];
}
-(void)uploadimagesuccess:(NSString *)key {
    _imagekey = key;
    
}
-(void)uploadvideosuccess:(NSString *)key andTitle:(NSString *)myTitle {
    _videokey = key;
    [self requstAPPServceTitle:myTitle andVideo:_videokey andImage:_imagekey];
}
#pragma mark - 上传七牛end
#pragma mark -
#pragma mark - 腾讯云上传start
-(void)txUplode {
    
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    configuration.appID = tengxunID;//@"1258210369";
    configuration.signatureProvider = self;
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = regionName;//@"ap-shanghai";
    configuration.endpoint = endpoint;
    
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
    
    self.TXSignDic = [NSDictionary dictionary];
    
}

- (void)signatureWithFields:(QCloudSignatureFields*)fileds request:(QCloudBizHTTPRequest*)request urlRequest:(NSMutableURLRequest*)urlRequst compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock {
    
    NSString *url = [h5url stringByAppendingFormat:@":8088/cam"];
    [YBToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            _TXSignDic = [info valueForKey:@"credentials"];
            QCloudCredential* credential = [QCloudCredential new];
            credential.secretID  = [NSString stringWithFormat:@"%@",[_TXSignDic valueForKey:@"tmpSecretId"]];
            credential.secretKey = [NSString stringWithFormat:@"%@",[_TXSignDic valueForKey:@"tmpSecretKey"]];
            credential.token = [NSString stringWithFormat:@"%@",[_TXSignDic valueForKey:@"sessionToken"]];
            QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);
        }else{
            [MBProgressHUD showError:msg];
        }

    } Fail:^{
        
    }];
    
    
}
-(void)uploadTCWithImgsign:(NSString *)imgSign andVideosign:(NSString *)videoSign andImageName:(NSString *)imgName andVideoName:(NSString *)videoName{
    UIImage *saveImg = _recordResult.coverImage;
    if (!_recordResult.coverImage) {
        saveImg = [TXVideoInfoReader getSampleImage:0.0 videoPath:_recordResult.videoPath];
    }
    NSData *imageData = UIImagePNGRepresentation(saveImg);
    if (saveImg) {
        __weak TCVideoPublishController *weakself = self;
        QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
        put.object = imgName;//[NSString stringWithFormat:@"dspdemo/%@",imgName];
        put.bucket = bucketName;
        put.body =  imageData;
        [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            NSLog(@"rk;;upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
        }];
        [put setFinishBlock:^(id outputObject, NSError* error) {
            QCloudUploadObjectResult *rst = outputObject;
            NSLog(@"rk;;111111:\nlocation:%@\n%@",rst.location,rst.key);

            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"上传失败"];
                    _publishBtn.enabled = YES;
                });
            }else{
                [weakself uploadVideowithImgurl:rst.location andVideosign:videoSign andvideoName:videoName];
            }

        }];
        [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    }else{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"上传失败"];
        _publishBtn.enabled = YES;
    }
    
}
- (void)uploadVideowithImgurl:(NSString *)imgurl andVideosign:(NSString *)videoSign andvideoName:(NSString *)videoName {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* sssssurl = [NSURL fileURLWithPath:_recordResult.videoPath];
    put.object = videoName;
    put.bucket = bucketName;//@"rk-1258210369";
    put.body =  sssssurl;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"rk;;upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    }];
//    WeakSelf;
//    [put setFinishBlock:^(id outputObject, NSError* error) {
//        QCloudUploadObjectResult *rst = outputObject;
//        NSLog(@"rk;;111111:\nlocation:%@\n%@",rst.location,rst.key);
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [MBProgressHUD hideHUD];
//                [MBProgressHUD showError:@"上传失败"];
//                _publishBtn.enabled = YES;
//            });
//        }else{
//            [weakSelf requstAPPServceTitle:mytitle andVideo:rst.location andImage:imgurl];
//        }
//
//    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
}
#pragma mark - 腾讯云上传end
#pragma mark -
#pragma mark - 上传七牛或者腾讯云存储成功后把视频地址、封面地址反馈给自己的服务器
-(void)requstAPPServceTitle:(NSString *)myTile andVideo:(NSString *)video andImage:(NSString *)image {
    
    __weak TCVideoPublishController *weakself = self;
    NSMutableDictionary *pullDic = @{
                              @"uid":[Config getOwnID],
                              @"href":minstr(video),
                              @"thumb":minstr(image),
                              @"isprivate":@(_coastSwitch.on),
                              }.mutableCopy;
    NSString *sign = [YBToolClass sortString:pullDic];
    [pullDic setObject:sign forKey:@"sign"];
    [pullDic setObject:_musicID ? _musicID : @"0" forKey:@"musicid"];
    [pullDic setObject:minstr(myTile) forKey:@"title"];
    [pullDic setObject:coastCoinStr forKey:@"coin"];

    [YBToolClass postNetworkWithUrl:@"Video.setVideo" andParameter:pullDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"上传成功，请等待审核"];
            
            BOOL isOk = [[NSFileManager defaultManager] removeItemAtPath:_recordResult.videoPath error:nil];
            NSLog(@"%d shanchushanchushanchu",isOk);
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:filePathhh error:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //发布成功后刷新首页
                [self root];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"popRootVC" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadlist" object:nil];
                weakself.publishBtn.enabled = NO;
            });
        }else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
            weakself.publishBtn.enabled = YES;
        }

    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络连接断开，视频上传失败"];
        weakself.publishBtn.enabled = YES;

    }];
    
}
#pragma mark - f发布成功返回
-(void)root {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_livePlayer) {
            [_livePlayer stopPlay];
            _livePlayer = nil;
        }
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[MIneVideoViewController class]])
                {
                    MIneVideoViewController *vc = (MIneVideoViewController *)controller;
                    [self.navigationController popToViewController:vc animated:YES];
                }
        }
        
    });
}



#pragma mark - set/get
-(UIView *)topMix {
    if (!_topMix) {
        _topMix = [[UIView alloc] initWithFrame:CGRectMake(0, 64+statusbarHeight+5, _window_width, 180)];
        _topMix.backgroundColor = [UIColor whiteColor];
        _topMix.layer.cornerRadius = 5.0;
        _topMix.layer.masksToBounds = YES;
        //视频预览
        _videoPreview = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 100, 150)];
        _videoPreview.layer.cornerRadius = 5.0;
        _videoPreview.layer.masksToBounds = YES;

        
        //视频描述
        _videoDesTV = [[MyTextView alloc] initWithFrame:CGRectMake(_videoPreview.right+10, 15, _topMix.width-_videoPreview.width - 35, _videoPreview.height)];
        _videoDesTV.backgroundColor = [UIColor clearColor];//RGB(242, 242, 242);
        _videoDesTV.delegate = self;
        _videoDesTV.layer.borderColor = _topMix.backgroundColor.CGColor;
        _videoDesTV.font = SYS_Font(14);
        _videoDesTV.textColor = RGB_COLOR(@"#969696", 1);
        _videoDesTV.placeholder = @"添加视频描述~";
        _videoDesTV.placeholderColor = RGB_COLOR(@"#969696", 1);
        
        _wordsNumL = [[UILabel alloc] initWithFrame:CGRectMake(_videoDesTV.right-50, _videoDesTV.bottom-12, 50, 12)];
        _wordsNumL.text = @"0/20";
        _wordsNumL.textColor = RGB_COLOR(@"#969696", 1);
        _wordsNumL.font = [UIFont systemFontOfSize:12];
        _wordsNumL.backgroundColor =[UIColor clearColor];
        _wordsNumL.textAlignment = NSTextAlignmentRight;
        
        [_topMix addSubview:_videoPreview];
        [_topMix addSubview:_videoDesTV];
        [_topMix addSubview:_wordsNumL];
        
    }
    return _topMix;
}

-(UIView *)locationV {
    if (!_locationV) {
        //显示定位
        _locationV = [[UIView alloc]initWithFrame:CGRectMake(0, _topMix.bottom+5, _window_width, 50)];
        _locationV.backgroundColor = [UIColor whiteColor];;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 65, 50)];
        label.font = SYS_Font(15);
        label.textColor = color32;
        label.text = @"私密设置";
        [_locationV addSubview:label];
        
        _coastSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(label.right+5, 10, 100, 30)];
        _coastSwitch.on = NO;
        _coastSwitch.transform = CGAffineTransformMakeScale(0.65, 0.65);
        [_coastSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:(UIControlEventValueChanged)];
        [_locationV addSubview:_coastSwitch];
        
        _coastPriceBtn = [UIButton buttonWithType:0];
        [_coastPriceBtn setTitleColor:color96 forState:0];
        _coastPriceBtn.titleLabel.font = SYS_Font(15);
        [_coastPriceBtn addTarget:self action:@selector(coastPriceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_locationV addSubview:_coastPriceBtn];
        [_coastPriceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.height.equalTo(_locationV);
            make.right.equalTo(_locationV).offset(-10);
        }];
        [_coastPriceBtn setTitle:[NSString stringWithFormat:@"%@%@",coastCoinStr,[common name_coin]] forState:0];
    }
    return _locationV;
}
- (void)valueChanged:(UISwitch*)swt{
//    if (_coastSwitch.on) {
//        [self coastPriceBtnClick];
//    }
}
- (void)getVideoCoastList{
    [YBToolClass postNetworkWithUrl:@"Video.GetFee" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            _tipsLable.text = minstr([[info firstObject] valueForKey:@"tips"]);
            curVideoIndex = 0;
            videoArray = [[info firstObject] valueForKey:@"list"];
            videoMaxSelectIndex = (int)[videoArray count] - 1;
            for (int i = 0; i < videoArray.count; i++) {
                NSDictionary *dic = videoArray[i];
//                if ([minstr([dic valueForKey:@"coin"]) isEqual:curVideoValue]) {
//                    curVideoIndex = i;
//                }
                if(i == 0 ){
                    coastCoinStr = minstr([dic valueForKey:@"coin"]);
                    [_coastPriceBtn setTitle:[NSString stringWithFormat:@"%@%@",coastCoinStr,[common name_coin]] forState:0];
                }
                if ([minstr([dic valueForKey:@"canselect"]) isEqual:@"0"]) {
                    videoMaxSelectIndex = i-1;
                    if (videoMaxSelectIndex<0) {
                        videoMaxSelectIndex = 0;
                    }
                    break;
                }
            }

        }
    } fail:^{
        
    }];
}
- (void)coastPriceBtnClick{
    pickBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    pickBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [[UIApplication sharedApplication].keyWindow addSubview:pickBackView];
    wihteView = [[UIView alloc]initWithFrame:CGRectMake(30, _window_height, _window_width-60, 200)];
    wihteView.backgroundColor = [UIColor whiteColor];
    wihteView.layer.cornerRadius = 10;
    wihteView.layer.masksToBounds  = YES;
    [pickBackView addSubview:wihteView];
    
    UIButton *messageBtn = [UIButton buttonWithType:0];
    messageBtn.frame = CGRectMake(15, 7, 85, 30);
    [messageBtn setImage:[UIImage imageNamed:@"mine_message"] forState:0];
    [messageBtn setTitle:@"收费标准说明" forState:0];
    [messageBtn setTitleColor:color96 forState:0];
    messageBtn.titleLabel.font = SYS_Font(10);
    [messageBtn addTarget:self action:@selector(messageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [wihteView addSubview:messageBtn];
    UIButton *closeBtn = [UIButton buttonWithType:0];
    closeBtn.frame = CGRectMake(wihteView.width-41, 0, 41, 41);
    [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [closeBtn addTarget:self action:@selector(closebtnClick) forControlEvents:UIControlEventTouchUpInside];
    [wihteView addSubview:closeBtn];
    
    coinPicker = [[UIPickerView alloc]initWithFrame:CGRectMake((wihteView.width-80)/2, 40, 80, 120)];
    coinPicker.backgroundColor = [UIColor whiteColor];
    coinPicker.delegate = self;
    coinPicker.dataSource = self;
    coinPicker.showsSelectionIndicator = YES;
    [wihteView addSubview:coinPicker];
    
    UILabel *leftL = [[UILabel alloc]initWithFrame:CGRectMake(20, 90, (wihteView.width-80)/2-20, 20)];
    leftL.font = SYS_Font(14);
    leftL.textColor = RGB_COLOR(@"#646464", 1);
    leftL.text = @"向TA收费";
    leftL.textAlignment = NSTextAlignmentCenter;
    [wihteView addSubview:leftL];
    
    UILabel *rightL = [[UILabel alloc]initWithFrame:CGRectMake(coinPicker.right, 90, (wihteView.width-80)/2-20, 20)];
    rightL.font = SYS_Font(14);
    rightL.textColor = RGB_COLOR(@"#646464", 1);
    rightL.text = [common name_coin];
    rightL.textAlignment = NSTextAlignmentCenter;
    [wihteView addSubview:rightL];
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 160, wihteView.width, 1) andColor:RGB_COLOR(@"#DCDCDC", 1) andView:wihteView];
    
    UIButton *sureBtn = [UIButton buttonWithType:0];
    sureBtn.frame = CGRectMake(0, 160, wihteView.width, 40);
    [sureBtn setTitleColor:normalColors forState:0];
    [sureBtn setTitle:@"确定" forState:0];
    sureBtn.titleLabel.font = SYS_Font(14);
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [wihteView addSubview:sureBtn];
    [self showCoinPicker];

}
- (void)showCoinPicker{
    [coinPicker selectRow:curVideoIndex inComponent:0 animated:YES];
    [coinPicker reloadAllComponents];
    pickBackView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        wihteView.center = pickBackView.center;
    }];
}
- (void)messageBtnClick{

    [YBToolClass postNetworkWithUrl:@"Video.getFeeInfo" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            instructionArray = info;
            if (!instructionView) {
                instructionView = [[UIView alloc]initWithFrame:CGRectMake(30, _window_height, _window_width-60, 330)];
                instructionView.backgroundColor = [UIColor whiteColor];
                instructionView.layer.cornerRadius = 10;
                instructionView.layer.masksToBounds  = YES;
                [pickBackView addSubview:instructionView];
                UIButton *closeBtn = [UIButton buttonWithType:0];
                closeBtn.frame = CGRectMake(wihteView.width-41, 0, 41, 41);
                [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
                closeBtn.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
                [closeBtn addTarget:self action:@selector(closeInstructionViewClick) forControlEvents:UIControlEventTouchUpInside];
                [instructionView addSubview:closeBtn];
                UILabel *labelll = [[UILabel alloc]initWithFrame:CGRectMake(instructionView.width/2-40, 13, 80, 47)];
                labelll.textAlignment = NSTextAlignmentCenter;
                labelll.font = SYS_Font(14);
                labelll.text =@"收费说明";
                [instructionView addSubview:labelll];
                
                instructionTable = [[UITableView alloc]initWithFrame:CGRectMake(35, 60, instructionView.width-70, 244) style:0];
                instructionTable.delegate = self;
                instructionTable.dataSource = self;
                instructionTable.separatorStyle = 0;
                [instructionView addSubview:instructionTable];
                
            }
            [self showInstructionTable];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        
    }];
    
}
- (void)showInstructionTable{
    [instructionTable reloadData];
    instructionView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        instructionView.center = pickBackView.center;
    }];
}
- (void)closeInstructionViewClick{
    [UIView animateWithDuration:0.3 animations:^{
        instructionView.y = _window_height;
    }completion:^(BOOL finished) {
        instructionView.hidden = YES;
    }];
    
}
- (void)closebtnClick{
    if ([coastCoinStr isEqual:@"0"]) {
        _coastSwitch.on = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        wihteView.y = _window_height;
    }completion:^(BOOL finished) {
        pickBackView.hidden = YES;
    }];
    
}
- (void)sureBtnClick{
//    NSString *url;
//    NSDictionary *dic;
    NSInteger index = [coinPicker selectedRowInComponent: 0];
    coastCoinStr = minstr([videoArray[index] valueForKey:@"coin"]);
    [_coastPriceBtn setTitle:[NSString stringWithFormat:@"%@%@",coastCoinStr,[common name_coin]] forState:0];
    [self closebtnClick];
    if ([coastCoinStr isEqual:@"0"]) {
        _coastSwitch.on = NO;
    }

//        url = @"User.SetVideoValue";
//        dic = @{@"value":minstr([videoArray[index] valueForKey:@"coin"])};
//    [YBToolClass postNetworkWithUrl:url andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        if (code == 0) {
////            [self requestData];
//            [self closebtnClick];
//        }
//        [MBProgressHUD showError:msg];
//    } fail:^{
//
//    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return instructionArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    instructionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"instructionCELL"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"instructionCell" owner:nil options:nil] lastObject];
    }
    NSDictionary *dic = instructionArray[indexPath.row];
    [cell.levelImgV sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"thumb"])]];
    cell.coinL.text = [NSString stringWithFormat:@"≤ %@",minstr([dic valueForKey:@"coin"])];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == instructionTable) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, instructionTable.width, 40)];
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.width/2, 40)];
        label1.font = SYS_Font(12);
        label1.textColor = RGB_COLOR(@"#646464", 1);
        label1.text = @"主播星级";
        label1.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label1];
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(view.width/2, 0, view.width/2, 40)];
        label2.font = SYS_Font(12);
        label2.textColor = RGB_COLOR(@"#646464", 1);
        label2.text = @"收费价格";
        label2.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label2];
        [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, view.width, 1) andColor:RGB_COLOR(@"#dcdcdc", 1) andView:view];
        return view;
    }
    return nil;
}

#pragma mark- Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [videoArray count];
    
}


#pragma mark- Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return minstr([[videoArray objectAtIndex: row] valueForKey:@"coin"]);
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (row > videoMaxSelectIndex) {
        [pickerView selectRow:videoMaxSelectIndex inComponent:0 animated:YES];
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 80;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 40)];
    myView.textAlignment = NSTextAlignmentCenter;
    myView.text = minstr([[videoArray objectAtIndex: row] valueForKey:@"coin"]);
    myView.font = [UIFont systemFontOfSize:16];
    myView.backgroundColor = [UIColor clearColor];
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, 80, 1) andColor:RGB_COLOR(@"#DCDCDC", 1) andView:myView];
    return myView;
}
-(UILabel *)tipsLable {
    if (!_tipsLable) {
        _tipsLable = [[UILabel alloc]init];
        _tipsLable.font = SYS_Font(10);
        _tipsLable.textColor = color96;
        _tipsLable.numberOfLines = 0;
    }
    return _tipsLable;
}

-(UIButton *)publishBtn {
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _publishBtn.frame = CGRectMake(40,_window_height-120-ShowDiff, _window_width-80, 40);
        [_publishBtn setTitle:@"确认发布" forState:0];
        [_publishBtn setTitleColor:[UIColor whiteColor] forState:0];
        _publishBtn.backgroundColor = normalColors;
        _publishBtn.layer.masksToBounds = YES;
        _publishBtn.layer.cornerRadius = 20;
        [_publishBtn addTarget:self action:@selector(clickPublishBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishBtn;
}

//#pragma mark - 导航
//-(void)creatNavi {
//    YBNavi *navi = [[YBNavi alloc]init];
//    navi.leftHidden = NO;
//    navi.rightHidden = YES;
////    navi.imgTitleSameR = YES;
//    [navi ybNaviLeft:^(id btnBack) {
//        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:YZMsg(@"提示") message:YZMsg(@"是否放弃发布此条视频") preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        }];
//        [alertContro addAction:cancleAction];
//        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"放弃") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//            [self fangqi];
//        }];
//        [alertContro addAction:sureAction];
//        [self presentViewController:alertContro animated:YES completion:nil];
//
//    } andRightName:@"" andRight:^(id btnBack) {
//
//    } andMidTitle:YZMsg(@"发布视频")];
//    [self.view addSubview:navi];
//}
- (void)fangqi{
    BOOL isOk = [[NSFileManager defaultManager] removeItemAtPath:_recordResult.videoPath error:nil];
    NSLog(@"%d shanchushanchushanchu",isOk);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePathhh error:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"popRootVC" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadlist" object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];

}
-(void)networkState{
    __weak typeof(self) wkSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                [MBProgressHUD showError:@"网络连接断开，视频上传失败"];
                wkSelf.imgPublishState.hidden = YES;
                wkSelf.isNetWorkErr = YES;
                break;
            default:
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring]; //开启网络监控
}

- (void)dealloc {
    [_livePlayer removeVideoWidget];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
