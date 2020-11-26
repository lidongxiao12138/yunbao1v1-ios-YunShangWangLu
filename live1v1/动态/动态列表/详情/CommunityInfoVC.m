//
//  CommunityInfoVC.m
//  yunbaolive
//
//  Created by YB007 on 2019/7/19.
//  Copyright © 2019 cat. All rights reserved.
//

#import "CommunityInfoVC.h"

#import "commentModel.h"
#import <HPGrowingTextView/HPGrowingTextView.h>
//#import "twEmojiView.h"

#import "CommunityInfoCell.h"
#import "CommunityInfoHeader.h"
#import "ImageBrowserViewController.h"
//#import "LookPicVC.h"
#import "XHSoundRecorder.h"
#import <Qiniu/QiniuSDK.h>
#import "PersonMessageViewController.h"
#import "ReportViewController.h"
#import "ShowDetailVC.h"
@interface CommunityInfoVC()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,CommunityInfoCellDelegate,HPGrowingTextViewDelegate,TFaceViewDelegate,UIGestureRecognizerDelegate,CommunityHeaderDelegate>
{
    int count;//下拉次数
    MJRefreshBackNormalFooter *footer;
    
    BOOL isReply;//判断是否是回复
    UILabel *tableviewLine;
    UIView *tableheader;
    UIButton *finish;
    
    NSMutableArray *_atArray;                                        //@用户的uid和uname数组
    UILabel *nothingLabel;
    
    UIView *_shadowView;
    
    NSDictionary *_topInfoDic;
    
    UIButton *_recordBtn;  //录制语音左边按钮
    UIButton *_soundBtn; //录制语音按钮
    BOOL isrecording;
    
    int timeLong;  //录制时间
    NSTimer *recordTimer;
    BOOL iscancel;

}
//@property(nonatomic,strong)UILabel *allCommentLabels;//显示全部评论
@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)HPGrowingTextView *textField;//评论框
@property(nonatomic,strong)UIView *toolBar;//评论困底部view
@property(nonatomic,strong)NSMutableArray *itemsarray;//评论列表
@property(nonatomic,copy)NSString *parentid;//回复的评论ID
@property(nonatomic,copy)NSString *commentid;//回复的评论commentid
@property(nonatomic,copy)NSString *touid;//回复的评论UID
@property(nonatomic,copy)NSString *hostid;//发布视频的人的id

@property(nonatomic,strong)CommunityInfoHeader *tableTopHeader;
@property(nonatomic,strong)NSString *soundPath;//

@end

@implementation CommunityInfoVC
- (CommunityInfoHeader *)tableTopHeader {
    if (!_tableTopHeader) {
        _tableTopHeader = [[CommunityInfoHeader alloc]initWithFrame:CGRectMake(0, 0, _window_width, 0)];
        _tableTopHeader.backgroundColor = UIColor.whiteColor;
        _tableTopHeader.delegate = self;
    }
    return _tableTopHeader;
}
#pragma mark - header delegate start
-(void)onClickNJCommentsBtn {
    [_textField becomeFirstResponder];
}
-(void)updateTabHeader {
    nothingLabel.top = [_tableTopHeader getTableHeaderHeight] +30;
    _tableview.tableHeaderView.frame = CGRectMake(0, 0, _window_width, [_tableTopHeader getTableHeaderHeight]);
}

#pragma mark----------详情点击代理-----------
-(void)clickImgTap:(int)index {
    NSArray *imgArray = [NSArray arrayWithArray:[_topInfoDic valueForKey:@"thumbs"]];
    
    [ImageBrowserViewController show:self type:PhotoBroswerVCTypeModal hideDelete:YES index:index imagesBlock:^NSArray *{
        return imgArray;
        
    } retrunBack:^(NSMutableArray *imgearr) {
    }];
}
-(void)clickgoCenter:(NSString *)liveid
{
    if ([liveid isEqual:[Config getOwnID]]) {
        return;
    }
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":liveid} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 0) {
            NSDictionary *subDic = [info firstObject];
            PersonMessageViewController *person = [[PersonMessageViewController alloc]init];
            person.liveDic = subDic;
            [[MXBADelegate sharedAppDelegate] pushViewController:person animated:YES];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
//举报
-(void)clickReportORDelete:(NSString *)commitid
{
    ReportViewController *jubao = [[ReportViewController alloc]init];
    jubao.dongtaiId =commitid;
    [[MXBADelegate sharedAppDelegate]pushViewController:jubao animated:YES];
}
//视频详情
-(void)clickVideoTap:(NSString *)videoUrl
{
    ShowDetailVC *detail = [[ShowDetailVC alloc]init];
    detail.fromStr = @"trendlist";
    detail.videoPath =videoUrl;
    detail.backcolor = @"video";
    detail.deleteEvent = ^(NSString *type) {
    };
    [[MXBADelegate sharedAppDelegate]pushViewController:detail animated:YES];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:_emojiV]) {
        return NO;
    }
    return YES;
}

#pragma mark - header delegate end


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:REMOVEALLVIODEORVOICE object:nil];
//    if (_tableTopHeader.livePlayer) {
//        [_tableTopHeader.livePlayer stopPlay];
//        _tableTopHeader.livePlayer = nil;
//    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self pullInfo];
    [self reloaddata:@""];
}
-(void)pullInfo {
    _topInfoDic = self.communityInfoDic;
    [_tableTopHeader setHeaderData:self.communityInfoDic];
    [_tableview reloadData];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.titleL.text = @"详情";
    self.view.backgroundColor = colorf5;
    timeLong = 0;
    [self creatNavi];
    
    [self setUpUi];
    
}
-(void)dealloc{
    NSLog(@"dealloc");
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark -------请求数据------------
-(void)reloaddata:(NSString *)from{
    count+=1;
    _textField.text = @"";
    _textField.placeholder = @"说点什么...";
    NSDictionary *parameterDic = @{
                                   @"uid":[Config getOwnID],
                                   @"dynamicid":_communityID,
                                   @"p":@(count),
                                   };

    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Dynamic.getComments" andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if(code == 0) {
            NSArray *datainfo = info;
            if (datainfo.count >0) {
                NSDictionary *infos = [datainfo firstObject];
                NSArray *commentlist = [infos valueForKey:@"commentlist"];
                
                NSString *allcomments = [NSString stringWithFormat:@"%@",[infos valueForKey:@"comments"]];
                [_tableTopHeader updataComments:allcomments];
                //weakSelf.allCommentLabels.text = [NSString stringWithFormat:@"%d %@",allcomments,YZMsg(@"评论")];
                if (count == 1) {
                    [_itemsarray removeAllObjects];
                }
                for (NSDictionary *dic in commentlist) {
                    [_itemsarray addObject:[dic mutableCopy]];
                }
                if (_itemsarray.count == 0) {
                    nothingLabel.hidden = NO;
                }else{
                    nothingLabel.hidden = YES;
                }
                if (commentlist.count == 0) {
                    [weakSelf.tableview.mj_footer endRefreshingWithNoMoreData];
                }else{
                    [weakSelf.tableview.mj_footer endRefreshing];
                }
                [weakSelf.tableview.mj_header endRefreshing];

                [weakSelf.tableview reloadData];

            }else{
                if (count == 1) {
                    nothingLabel.hidden = NO;

                }else{
                    nothingLabel.hidden = YES;

                }
                [weakSelf.tableview.mj_header endRefreshing];
                [weakSelf.tableview.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [weakSelf.tableview.mj_footer endRefreshing];
    }];

}
-(void)setUpUi {
    _atArray = [NSMutableArray array];
    count = 0;//上拉加载次数
    _parentid = @"0";
    _commentid = @"0";
    isReply = NO;//判断回复
    
    _hostid = _communityUid;
    _touid = _hostid;
    
    _itemsarray = [NSMutableArray array];
    
    _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0,_window_height - 50-ShowDiff, _window_width, 50+ShowDiff)];
    _toolBar.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);//RGB(248, 248, 248);
    
    //_toolBar顶部横线 和 顶部 view分割开
    UILabel *lineso = [[UILabel alloc]initWithFrame:CGRectMake(0,0,_window_width,1)];
    lineso.backgroundColor = Line_Cor;//[UIColor groupTableViewBackgroundColor];
    [_toolBar addSubview:lineso];
    
    //设置输入框
    
    _recordBtn = [UIButton buttonWithType:0];
    _recordBtn.frame = CGRectMake(5, 5, 40, 40);
    [_recordBtn setImage:[UIImage imageNamed:@"语音评论1"] forState:UIControlStateNormal];
    [_recordBtn setImage:[UIImage imageNamed:@"语音评论2"] forState:UIControlStateSelected];
    [_recordBtn addTarget:self action:@selector(recordBtnClick) forControlEvents:UIControlEventTouchUpInside];

    //设置输入框
    UIView *vc  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    vc.backgroundColor = [UIColor clearColor];
    _textField = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(50,8, _window_width - 68-50, 34)];
    _textField.layer.masksToBounds = YES;
    _textField.layer.cornerRadius = 17;
    _textField.font = SYS_Font(16);
    _textField.placeholder = @"说点什么...";
    _textField.textColor = GrayText;
    _textField.placeholderColor = GrayText;
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeySend;
    _textField.enablesReturnKeyAutomatically = YES;
    
    _textField.internalTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingHead;
    _textField.internalTextView.textContainer.maximumNumberOfLines = 1;
    
    /**
     * 由于 _textField 设置了contentInset 后有色差，在_textField后添
     * 加一个背景view并把_textField设置clearColor
     */
    _textField.contentInset = UIEdgeInsetsMake(2, 10, 2, 10);
    _textField.backgroundColor = [UIColor clearColor];
    
    
    _soundBtn = [UIButton buttonWithType:0];
    _soundBtn.frame = CGRectMake(50,6, _window_width - 68-50, 38);
    _soundBtn.layer.cornerRadius = 19;
    _soundBtn.layer.masksToBounds = YES;
    _soundBtn.backgroundColor = normalColors;
    _soundBtn.hidden = YES;
    [_soundBtn setTitle:@"按住说话" forState:0];
    [_soundBtn setTitleColor:[UIColor whiteColor] forState:0];
    _soundBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_soundBtn addTarget:self action:@selector(TouchDown) forControlEvents:UIControlEventTouchDown];
    [_soundBtn addTarget:self action:@selector(talkUpInside) forControlEvents:UIControlEventTouchUpInside];

//    [_soundBtn addTarget:self action:@selector(TouchUp)forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [_soundBtn addTarget:self action:@selector(TouchUp) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [_soundBtn addTarget:self action:@selector(talkExit:) forControlEvents:UIControlEventTouchDragExit];
    [_soundBtn addTarget:self action:@selector(talkEnter:) forControlEvents:UIControlEventTouchDragEnter];

    UIView *tv_bg = [[UIView alloc]initWithFrame:_textField.frame];
    tv_bg.backgroundColor = [UIColor whiteColor];
    tv_bg.layer.masksToBounds = YES;
    tv_bg.layer.cornerRadius = _textField.layer.cornerRadius;
    [_toolBar addSubview:tv_bg];
    [_toolBar addSubview:_textField];
    [_toolBar addSubview:_recordBtn];
    [_toolBar addSubview:_soundBtn];

    //发送按钮
    finish = [UIButton buttonWithType:0];
    finish.frame = CGRectMake(_window_width - 44,8,34,34);
    [finish setImage:[UIImage imageNamed:@"chat_face.png"] forState:0];
    [finish addTarget:self action:@selector(atFrends) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:finish];
    
    
    CGRect tabFrame = CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-ShowDiff-50);
    _tableview = [[UITableView alloc]initWithFrame:tabFrame style:UITableViewStylePlain];
    _tableview.delegate   = self;
    _tableview.dataSource = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.backgroundColor = [UIColor whiteColor];//Black_Cor;//RGB(248, 248, 248);
    _tableview.layer.masksToBounds = YES;
    _tableview.showsVerticalScrollIndicator = NO;
    _tableview.estimatedRowHeight = 250.0;
    _tableview.estimatedSectionHeaderHeight = 0;
    _tableview.estimatedSectionFooterHeight = 0;
    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, _tableview.bottom-12, _window_width, 15)];
    spaceView.backgroundColor = _tableview.backgroundColor;
    [self.view addSubview:spaceView];
    [self.view addSubview:_tableview];
    
    
    _tableview.tableHeaderView = self.tableTopHeader;
    
    if (@available(iOS 11.0,*)) {
        _tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _shadowView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _shadowView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer *shadowTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickShadowTap)];
    shadowTap.delegate = self;
    [_shadowView addGestureRecognizer:shadowTap];
    [self.view addSubview:_shadowView];
    _shadowView.hidden = YES;
    [self.view addSubview:_toolBar];
    nothingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _tableview.height/2-10, _window_width, 20)];
    nothingLabel.font = [UIFont systemFontOfSize:13];
    nothingLabel.text = @"暂无评论，快来抢沙发吧";
    nothingLabel.textColor = RGB_COLOR(@"#969696", 1);
    nothingLabel.textAlignment = NSTextAlignmentCenter;
    nothingLabel.backgroundColor =[UIColor whiteColor];
    nothingLabel.hidden = YES;
    [_tableview addSubview:nothingLabel];
    //tableview顶部横线 和 顶部 view分割开
    tableviewLine = [[UILabel alloc]initWithFrame:CGRectMake(0, _window_height*0.3 + 49,_window_width,1)];
    tableviewLine.backgroundColor = Line_Cor;//[UIColor colorWithRed:198/255.0 green:198/255.0 blue:198/255.0 alpha:1];
    //[self addSubview:tableviewLine];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
//    [self reloaddata:@""];
//    footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(reloaddata:)];
//    [footer setTitle:@"评论加载中..." forState:MJRefreshStateRefreshing];
//    [footer setTitle:@"没有更多了哦~" forState:MJRefreshStateNoMoreData];
//    [footer setTitle:@"" forState:MJRefreshStateIdle];
//    footer.stateLabel.font = [UIFont systemFontOfSize:15.0f];
//    footer.automaticallyHidden = YES;
//    self.tableview.mj_footer = footer;
    WeakSelf;
    _tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        count = 0;
        [weakSelf reloaddata:@""];
    }];
    _tableview.mj_footer =[MJRefreshFooter footerWithRefreshingBlock:^{
        [weakSelf reloaddata:@""];

    }];
    //添加表情
    if(!_emojiV){
        _emojiV = [[TFaceView alloc] initWithFrame:CGRectMake(0, _window_height, _window_width, TFaceView_Height)];
        _emojiV.delegate = self;
        [_emojiV setData:[[TUIKit sharedInstance] getConfig].faceGroups];
        [self.view  addSubview:_emojiV];
        
    }
    UIButton *sendBtn= [UIButton buttonWithType:0];
    sendBtn.frame = CGRectMake(_emojiV.width-80, _emojiV.height-30, 60, 30);
    [sendBtn setBackgroundColor:normalColors];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:0];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    sendBtn.layer.cornerRadius = 15;
    sendBtn.layer.masksToBounds = YES;
    [sendBtn addTarget:self action:@selector(pushmessage) forControlEvents:UIControlEventTouchUpInside];
    [_emojiV addSubview:sendBtn];
}
-(void)TouchDown{
    
    if(!_record){
        _record = [[TRecordView alloc] init];
        _record.frame = [UIScreen mainScreen].bounds;
    }
    [self.view addSubview:_record];
//    _recordStartTime = [NSDate date];
    [_record setStatus:Record_Status_Recording];
//    _recordButton.backgroundColor = [UIColor lightGrayColor];
    [_soundBtn setTitle:@"松开结束" forState:UIControlStateNormal];
//    [self startRecord];

    if (recordTimer) {
        [recordTimer invalidate];
        recordTimer = nil;
        timeLong = 0;
    }
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerBegin) userInfo:nil repeats:YES];
    
    [[XHSoundRecorder sharedSoundRecorder] startRecorder:^(NSString *filePath) {
        
        if (recordTimer) {
            [recordTimer invalidate];
            recordTimer = nil;
        }
        NSLog(@"录音文件路径---:%@",filePath);
        NSLog(@"录音结束");
        if (timeLong <= 1) {
//            [MBProgressHUD showError:@"录音太短"];
            return;
        }
        [_record removeFromSuperview];
        _record = nil;
        if (iscancel) {
            [[XHSoundRecorder sharedSoundRecorder]removeSoundRecorder];
            iscancel = NO;
            return;
        }else{
            _soundPath = filePath;
            [self getQiNiuToken];
            [_soundBtn setTitle:@"按住说话" forState:UIControlStateNormal];

        }

    }];
    
}
-(void)TouchUp{
    [_record removeFromSuperview];
    [_soundBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [[XHSoundRecorder sharedSoundRecorder] stopRecorder];
}
- (void)talkExit:(UIButton *)sender
{
    [_record setStatus:Record_Status_Cancel];
    [_soundBtn setTitle:@"上拉取消" forState:UIControlStateNormal];
    iscancel = YES;
    [[XHSoundRecorder sharedSoundRecorder] stopRecorder];
    
}
- (void)talkEnter:(UIButton *)sender
{
    [_record setStatus:Record_Status_Recording];
    [_soundBtn setTitle:@"松开结束" forState:UIControlStateNormal];
}
-(void)talkUpInside{
    [_record removeFromSuperview];
    [_soundBtn setTitle:@"按住说话" forState:UIControlStateNormal];

    [[XHSoundRecorder sharedSoundRecorder] stopRecorder];

}
-(void)timerBegin{
    timeLong +=1;
    if (timeLong == 60) {
        [self TouchUp];
        return;
    }
}
#pragma make  ------上传七牛-----------
-(void)getQiNiuToken{
    
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Upload.GetQiniuToken" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *token = minstr([[info firstObject] valueForKey:@"token"]);
            [weakSelf starUplodToKen:token andAudioPath:_soundPath];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"提交失败"];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"提交失败"];
    }];
    
}
-(void)starUplodToKen:(NSString *)token andAudioPath:(NSString *)audioPath{
    WeakSelf;
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        
    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    
    NSString *videoName = [YBToolClass getNameBaseCurrentTime:@"_action_audio.mp3"];
    [upManager putFile:audioPath key:videoName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            [MBProgressHUD hideHUD];
            [weakSelf requstAPPServceAddVoice:key length:@""];
            
            //                [weakSelf uploadVideo:key andCover:@""];
        }else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"提交失败"];
        }
    } option:option];
    
}
-(void)requstAPPServceAddVoice:(NSString *)vodeoPath length:(NSString *)vodeoLenth{
    NSDictionary *parmeter = @{
                               @"uid":[Config getOwnID],
                               @"token":[Config getOwnToken],
                               @"dynamicid":_communityID,
                               @"touid":@"",
                               @"commentid":@"",
                               @"parentid":@"",
                               @"content":@"",
                               @"type":@"1",
                               @"voice":vodeoPath,
                               @"length":@(timeLong),
                               };
    [YBToolClass postNetworkWithUrl:@"Dynamic.setComment" andParameter:parmeter success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            timeLong = 0;
            [MBProgressHUD showError:msg];
        }else{
            timeLong = 0;

            [MBProgressHUD showError:msg];
        }
        
    } fail:^{
        timeLong = 0;

    }];
    
}



-(void)recordBtnClick{
    isrecording = !isrecording;
    if (isrecording) {
        _recordBtn.selected = YES;
        _soundBtn.hidden = NO;
    }else{
        _recordBtn.selected = NO;
        _soundBtn.hidden = YES;
        
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableview deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *subdic = _itemsarray[indexPath.row];
    NSDictionary *userinfo = [subdic valueForKey:@"userinfo"];
    
    _touid = [NSString stringWithFormat:@"%@",[userinfo valueForKey:@"id"]];
    if ([_touid isEqual:[Config getOwnID]]) {
        
        [MBProgressHUD showError:@"不能回复自己"];
        return;
    }
    
    [_textField becomeFirstResponder];
    NSString *path = [NSString stringWithFormat:@"%@给:%@",@"回复",[userinfo valueForKey:@"user_nickname"]];
    _textField.placeholder = path;
    _parentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];
    _commentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"commentid"]];
    isReply = YES;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.itemsarray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableview deselectRowAtIndexPath:indexPath animated:NO];
    CommunityInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommunityInfoCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CommunityInfoCell" owner:nil options:nil] lastObject];
    }
    cell.model = [[commentModel alloc]initWithDic:_itemsarray[indexPath.row]];
    cell.delegate = self;
    cell.curIndex = indexPath;
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;//self.tableTopHeader
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    return 0.01;;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
#pragma mark  评论
-(void)pushmessage{

    /*
     parentid  回复的评论ID
     commentid 回复的评论commentid
     touid     回复的评论UID
     如果只是评论 这三个传0
     */
    if (_textField.text.length == 0 || _textField.text == NULL || _textField.text == nil || [_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [MBProgressHUD showError:@"请添加内容后再尝试"];
        return;
    }
    NSString *sendtouid = [NSString stringWithFormat:@"%@",_touid];
    NSString *sendcommentid = [NSString stringWithFormat:@"%@",_commentid];
    NSString *sendparentid = [NSString stringWithFormat:@"%@",_parentid];
    NSString *path = [NSString stringWithFormat:@"%@",_textField.text];
    
    [self hideself];
    
    NSString *at_json = @"";
    //转json、去除空格、回车
    if (_atArray.count>0) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_atArray options:NSJSONWritingPrettyPrinted error:nil];
        at_json = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        at_json = [at_json stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        at_json = [at_json stringByReplacingOccurrencesOfString:@" " withString:@""];
        at_json = [at_json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    WeakSelf;
    
    NSDictionary *parmeter = @{
                               @"uid":[Config getOwnID],
                               @"token":[Config getOwnToken],
                               @"dynamicid":_communityID,
                               @"touid":sendtouid,
                               @"commentid":sendcommentid,
                               @"parentid":sendparentid,
                               @"content":path,
                               @"type":@"0",
                               @"voice":@"",
                               @"length":@(timeLong),
                               };

    [YBToolClass postNetworkWithUrl:@"Dynamic.setComment" andParameter:parmeter success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if(code == 0) {
            _textField.text = @"";
            _textField.placeholder = @"说点什么...";
            //论完后 把状态清零
            _touid = _hostid;
            _parentid = @"0";
            _commentid = @"0";
            
            [MBProgressHUD showSuccess:@"评论成功"];
            [_atArray removeAllObjects];
            NSDictionary *infos = info;
            //刷新评论数
            NSString * allcomments = [NSString stringWithFormat:@"%@",[infos valueForKey:@"comments"]];
            [_tableTopHeader updataComments:allcomments];
            // weakSelf.allCommentLabels.text = [NSString stringWithFormat:@"%d %@",allcomments,YZMsg(@"评论")];
            count = 0;
            [weakSelf reloaddata:@""];

        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
#pragma mark -- 获取键盘高度
- (void)keyboardWillShow:(NSNotification *)aNotification {
    _shadowView.hidden = NO;
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.origin.y;
    _toolBar.frame = CGRectMake(0, height - 50, _window_width, 50);
//    _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
    
}
- (void)keyboardWillHide:(NSNotification *)aNotification {
    _shadowView.hidden = YES;
    WeakSelf;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.toolBar.frame = CGRectMake(0, _window_height - 50-statusbarHeight, _window_width, 50+statusbarHeight);
//        _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
    }];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [_textField resignFirstResponder];
}
#pragma mark - 召唤好友
-(void)atFrends {
    _shadowView.hidden = NO;
    [_textField resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        _emojiV.frame = CGRectMake(0, _window_height - (EmojiHeight+ShowDiff), _window_width, EmojiHeight+ShowDiff);
        _toolBar.frame = CGRectMake(0, _emojiV.y - 50, _window_width, 50);
    }];
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self hideself];
}
-(void)hideself{
    _shadowView.hidden = YES;
    [self.view endEditing:YES];
    _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
    _toolBar.frame = CGRectMake(0, _emojiV.y - 50, _window_width, 50);
}

-(void)clickShadowTap {
    if (_emojiV) {
        _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
    }
    _toolBar.frame = CGRectMake(0, _emojiV.y - 50, _window_width, 50);
    [_textField resignFirstResponder];
    _shadowView.hidden = YES;
}
#pragma mark - 输入框代理事件
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    _textField.height = height;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    [_textField resignFirstResponder];
    [self pushmessage];
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        NSRange selectRange = growingTextView.selectedRange;
        if (selectRange.length > 0) {
            //用户长按选择文本时不处理
            return YES;
        }
        
        // 判断删除的是一个@中间的字符就整体删除
        NSMutableString *string = [NSMutableString stringWithString:growingTextView.text];
        NSArray *matches = [self findAllAt];
        
        BOOL inAt = NO;
        NSInteger index = range.location;
        for (NSTextCheckingResult *match in matches) {
            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
            if (NSLocationInRange(range.location, newRange)) {
                inAt = YES;
                index = match.range.location;
                [string replaceCharactersInRange:match.range withString:@""];
                break;
            }
        }
        
        if (inAt) {
            growingTextView.text = string;
            growingTextView.selectedRange = NSMakeRange(index, 0);
            return NO;
        }
    }
    
    //判断是回车键就发送出去
    if ([text isEqualToString:@"\n"]) {
        [self pushmessage];
        return NO;
    }
    
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    UITextRange *selectedRange = growingTextView.internalTextView.markedTextRange;
    NSString *newText = [growingTextView.internalTextView textInRange:selectedRange];
    
    if (newText.length < 1) {
        // 高亮输入框中的@
        UITextView *textView = _textField.internalTextView;
        NSRange range = textView.selectedRange;
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:textView.text              attributes:@{NSForegroundColorAttributeName:GrayText,NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        
        NSArray *matches = [self findAllAt];
        
        for (NSTextCheckingResult *match in matches) {
            [string addAttribute:NSForegroundColorAttributeName value:AtCol range:NSMakeRange(match.range.location, match.range.length - 1)];
        }
        
        textView.attributedText = string;
        textView.selectedRange = range;
    }
    
    if (growingTextView.text.length >0) {
        NSString *theLast = [growingTextView.text substringFromIndex:[growingTextView.text length]-1];
        if ([theLast isEqual:@"@"]) {
            //去掉手动输入的  @
            NSString *end_str = [growingTextView.text substringToIndex:growingTextView.text.length-1];
            _textField.text = end_str;
            [self atFrends];
        }
    }
    
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView {
    // 光标不能点落在@词中间
    NSRange range = growingTextView.selectedRange;
    if (range.length > 0) {
        // 选择文本时可以
        return;
    }
    
    NSArray *matches = [self findAllAt];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
        if (NSLocationInRange(range.location, newRange)) {
            growingTextView.internalTextView.selectedRange = NSMakeRange(match.range.location + match.range.length, 0);
            break;
        }
    }
}

#pragma mark - Private
- (NSArray<NSTextCheckingResult *> *)findAllAt {
    // 找到文本中所有的@
    NSString *string = _textField.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return matches;
}
#pragma mark - cell delegate start
- (void)reloadCurCell:(commentModel *)model andIndex:(NSIndexPath *)curIndex andReplist:(NSArray *)list needRefresh:(BOOL)needRefresh;{
    for (int i = 0; i < _itemsarray.count; i++) {
        NSMutableDictionary *muDic = _itemsarray[i];
        if ([minstr([muDic valueForKey:@"id"]) isEqual:model.parentid]) {
            [muDic setObject:list forKey:@"replylist"];
            break;
        }
    }
    if (needRefresh) {
        [_tableview reloadRowsAtIndexPaths:@[curIndex] withRowAnimation:UITableViewRowAnimationNone];
    }
}
//这个地方找到点赞的字典，在数组中删除再重新插入 处理点赞
-(void)makeLikeRloadList:(NSString *)commectid andLikes:(NSString *)likes islike:(NSString *)islike{
    
    int numbers = 0;
    for (int i=0; i<_itemsarray.count; i++) {
        NSMutableDictionary *subdic = _itemsarray[i];
        NSString *parentid = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"id"]];
        if ([parentid isEqual:commectid]) {
            [subdic setObject:likes forKey:@"likes"];
            [subdic setObject:islike forKey:@"islike"];
            numbers = i;
            break;
        }
    }
    //[self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numbers inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)pushDetails:(NSDictionary *)commentdic{
    NSDictionary *userinfo = [commentdic valueForKey:@"userinfo"];
    
    _touid = [NSString stringWithFormat:@"%@",[userinfo valueForKey:@"id"]];
    if ([_touid isEqual:[Config getOwnID]]) {
        return;
    }
    [_textField becomeFirstResponder];
    NSString *path = [NSString stringWithFormat:@"%@给:%@",@"回复",[userinfo valueForKey:@"user_nickname"]];
    _textField.placeholder = path;
    _parentid = [NSString stringWithFormat:@"%@",[commentdic valueForKey:@"id"]];
    _commentid = [NSString stringWithFormat:@"%@",[commentdic valueForKey:@"commentid"]];
    isReply = YES;
}
#pragma mark - cell delegate end
#pragma mark - Emoji 代理
-(void)sendimage:(NSString *)str {
    if ([str isEqual:@"msg_del"]) {
        [_textField.internalTextView deleteBackward];
    }else {
        [_textField.internalTextView insertText:str];
    }
}
-(void)clickSendEmojiBtn {
    [self pushmessage];
}
#pragma mark - 导航

-(void)returnBtnClick{
    [[MXBADelegate sharedAppDelegate] popViewController:YES];
    
}

-(void)creatNavi {
    
    UIView *navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navi];
    
    UIButton *retrunBtn = [UIButton buttonWithType:0];
    retrunBtn.frame = CGRectMake(10, 22+statusbarHeight, 40, 40);
    [retrunBtn setImage:[UIImage imageNamed:@"navi_backImg"] forState:0];
    [retrunBtn addTarget:self action:@selector(returnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:retrunBtn];
    
    //标题
    
    //    UILabel *midLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 22+statusbarHeight, 60, 42)];
    UILabel *midLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(retrunBtn.frame)+10, 22+statusbarHeight, _window_width-40*2, 42)];
    midLabel.textColor = RGB_COLOR(@"#333333", 1);
    midLabel.font = SYS_Font(15);
    midLabel.text = @"动态详情";
    midLabel.textAlignment = NSTextAlignmentCenter;
    [navi addSubview:midLabel];
    midLabel.centerX = navi.centerX;
    //私信
    
    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 63+statusbarHeight, _window_width, 1) andColor:colorf5 andView:navi];

}
- (void)faceViewDidBackDelete:(TFaceView *)faceView
{
    [_textField.internalTextView deleteBackward];
}



- (void)faceView:(TFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFaceGroup *group = [[TUIKit sharedInstance] getConfig].faceGroups[indexPath.section];
    TFaceCellData *face = group.faces[indexPath.row];
    //    if(indexPath.section == 0){
    //        [_textField addEmoji:face.name];
    //    }
    //    if ([str isEqual:@"msg_del"]) {
    //        [_textField.internalTextView deleteBackward];
    //    }else {
    [_textField.internalTextView insertText:face.name];
    //    }
    
    //    else{
    //        TFaceMessageCellData *data = [[TFaceMessageCellData alloc] init];
    //        data.groupIndex = group.groupIndex;
    //        data.head = TUIKitResource(@"default_head");
    //        data.path = face.path;
    //        data.faceName = face.name;
    //        data.isSelf = YES;
    //        if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
    //            [_delegate inputController:self didSendMessage:data];
    //        }
    //    }
}

@end
