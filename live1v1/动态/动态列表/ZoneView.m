//
//  ZoneView.m
//  live1v1
//
//  Created by ybRRR on 2019/7/26.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "ZoneView.h"
#import <HPGrowingTextView/HPGrowingTextView.h>
#import "CommunityCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ReportViewController.h"
#import "CommunityInfoVC.h"
#import "ImageBrowserViewController.h"
#import "XHSoundRecorder.h"
#import <Qiniu/QiniuSDK.h>
#import "UITableView+WebVideoCache.h"
#import "PersonMessageViewController.h"
#define Tag_MyReplySheetShow 0x01
#define Tag_LongPressTextSheetShow 0x02
#define Tag_LongPressPicSheetShow 0x03
#define Tag_CoverViewSheetShow 0x04
#define Tag_LongPressShareUrlShow 0x05
#define Tag_CopyMyReplySheetShow 0x06

@interface ZoneView()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,HPGrowingTextViewDelegate,UIGestureRecognizerDelegate,CommunityCellDelegate,TFaceViewDelegate,UIScrollViewDelegate>
{
    int _paging;
    NSDictionary *_currentDic;
    NSIndexPath *_currentIndex;
    
    UIView *_toolBar;
    UIView *_wBgView;
    
    CGFloat _zoneHeight;
    CGFloat _zomeWidth;
    
    NSString *_pubUrl;
    
    UIButton *_recordBtn;  //录制语音左边按钮
    UIButton *_soundBtn; //录制语音按钮
    BOOL isrecording;
    
    
}
@property(nonatomic,strong)HPGrowingTextView *textField;
@property(nonatomic,strong)UIButton *finishbtn;

@property(nonatomic,strong)UITableView *zoneTableView;
@property(nonatomic,strong)NSArray *models;
@property(nonatomic,strong)NSString *soundPath;//
@property(nonatomic,strong)NSString *liveUid;//

@end

@implementation ZoneView
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _liveUid = @"";
        _cellUid = @"";
        [self creatNothingView];
        _zoneHeight = frame.size.height;
        _zomeWidth = frame.size.width;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
        
        _paging = 1;
        isrecording =NO;
        _zoneInfo = [NSMutableArray array];
        
        _zoneTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _zoneTableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_zoneTableView];
        
        if (@available(iOS 11.0,*)) {
            _zoneTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else {
            self.fVC.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        _zoneTableView.delegate = self;
        _zoneTableView.dataSource = self;
        _zoneTableView.estimatedRowHeight = 0;
        _zoneTableView.estimatedSectionHeaderHeight = 0;
        _zoneTableView.estimatedSectionFooterHeight = 0;
        _zoneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _zoneTableView.backgroundColor = [UIColor whiteColor];
        [_zoneTableView setNeedsLayout];
        [_zoneTableView setNeedsDisplay];
        [_zoneTableView registerClass:[CommunityCell class]forCellReuseIdentifier:@"zoneCell"];
        [self setExtraCellLineHidden:_zoneTableView];
        
        //首页动态的下拉与上拉
        _zoneTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _paging = 1;
            [self pullData:_pubUrl withliveId:_liveUid];
        }];
        _zoneTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            _paging +=1;
            [self pullData:_pubUrl withliveId:_liveUid];
        }];
        
        _zoneTableView.fd_debugLogEnabled = YES;
        
        [self showtextfield];

    }
    return self;
}
-(void)showtextfield{
    
    UIWindow *currentW = [UIApplication sharedApplication].delegate.window;
    _wBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _wBgView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTapGes)];
    bgTap.delegate = self;
    [_wBgView addGestureRecognizer:bgTap];
    [currentW addSubview:_wBgView];
    _wBgView.hidden = YES;
    if (!_toolBar) {

        
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0,_window_height - 50-ShowDiff, _window_width, 50+ShowDiff)];
        _toolBar.backgroundColor = [RGBA(32, 28, 54,1) colorWithAlphaComponent:0.2];//RGB(27, 25, 41);;//RGB(248, 248, 248);
        [_wBgView addSubview:_toolBar];
        
        //设置输入框
        
        _recordBtn = [UIButton buttonWithType:0];
        _recordBtn.frame = CGRectMake(5, 5, 40, 40);
        [_recordBtn setImage:[UIImage imageNamed:@"语音评论1"] forState:UIControlStateNormal];
        [_recordBtn setImage:[UIImage imageNamed:@"语音评论2"] forState:UIControlStateSelected];
        [_recordBtn addTarget:self action:@selector(recordBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *vc  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        vc.backgroundColor = [UIColor clearColor];
        _textField = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(50,8, _zomeWidth - 68-50, 34)];
        _textField.layer.masksToBounds = YES;
        _textField.layer.cornerRadius = 17;
        _textField.font = SYS_Font(16);
        _textField.placeholder = @"说点什么...";
        _textField.textColor = [UIColor blackColor];
        _textField.placeholderColor = RGBA(150, 150, 150,1);
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
        UIView *tv_bg = [[UIView alloc]initWithFrame:_textField.frame];
        tv_bg.backgroundColor = RGBA(44, 40, 64, 0.2);
        tv_bg.layer.masksToBounds = YES;
        tv_bg.layer.cornerRadius = _textField.layer.cornerRadius;
        
        
        _soundBtn = [UIButton buttonWithType:0];
        _soundBtn.frame = CGRectMake(50,6, _zomeWidth - 68-50, 38);
        _soundBtn.layer.cornerRadius = 19;
        _soundBtn.layer.masksToBounds = YES;
        _soundBtn.backgroundColor = normalColors;
        _soundBtn.hidden = YES;
        [_soundBtn setTitle:@"按住说话" forState:0];
        [_soundBtn setTitleColor:[UIColor whiteColor] forState:0];
        _soundBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_soundBtn addTarget:self action:@selector(TouchDown) forControlEvents:UIControlEventTouchDown];
        [_soundBtn addTarget:self action:@selector(TouchUp)forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

        
        [_toolBar addSubview:tv_bg];
        [_toolBar addSubview:_textField];
        [_toolBar addSubview:_recordBtn];
        [_toolBar addSubview:_soundBtn];
        
        
        _finishbtn = [UIButton buttonWithType:0];
        _finishbtn.frame = CGRectMake(_zomeWidth - 44,8,34,34);
        [_finishbtn setImage:[UIImage imageNamed:@"chat_face.png"] forState:0];
        [_finishbtn addTarget:self action:@selector(atFrends) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_finishbtn];
        
    }
    
    //添加表情
    if(!_emojiV){
        _emojiV = [[TFaceView alloc] initWithFrame:CGRectMake(0, _window_height, _window_width, TFaceView_Height)];
        _emojiV.delegate = self;
        [_emojiV setData:[[TUIKit sharedInstance] getConfig].faceGroups];
        [_wBgView addSubview:_emojiV];

    }

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:_emojiV]) {
        return NO;
    }
    return YES;
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
-(void)TouchDown{
    
    [_soundBtn setTitle:@"松开 结束" forState:0];
    [[XHSoundRecorder sharedSoundRecorder] startRecorder:^(NSString *filePath) {
        
        NSLog(@"录音文件路径---:%@",filePath);
        NSLog(@"录音结束");
        _soundPath = filePath;
        [self getQiNiuToken];
    }];

}
-(void)TouchUp{
    [_soundBtn setTitle:@"按住说话" forState:0];
    [[XHSoundRecorder sharedSoundRecorder] stopRecorder];

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
                               @"dynamicid":[_currentDic valueForKey:@"id"],
                               @"touid":@"",
                               @"commentid":@"",
                               @"parentid":@"",
                               @"content":@"",
                               @"type":@"1",
                               @"voice":vodeoPath,
                               @"length":@"",
                               };
    [YBToolClass postNetworkWithUrl:@"Dynamic.setComment" andParameter:parmeter success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [MBProgressHUD showError:msg];
        }else{
            [MBProgressHUD showError:msg];
        }
        
    } fail:^{
        
    }];

}
#pragma mark - 添加表情
-(void)atFrends {
    [_textField resignFirstResponder];
    _wBgView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _emojiV.frame = CGRectMake(0, _window_height - (EmojiHeight+ShowDiff), _window_width, EmojiHeight+ShowDiff);
        _toolBar.frame = CGRectMake(0, _emojiV.y - 50, _window_width, 50);
        _toolBar.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
        _textField.backgroundColor = [UIColor whiteColor];
    }];
}

-(void)clickTapGes {
    if (_emojiV) {
        _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
    }
    [_textField resignFirstResponder];
    _wBgView.hidden = YES;
}

-(void)layoutTableWithFlag:(NSString *)flag {
    if ([flag isEqual:@"动态"]) {
        _zoneTableView.contentInset = UIEdgeInsetsMake(0, 0, 49+ShowDiff, 0);
    }else if ([flag isEqual:@"个中"]){
        _zoneTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }else {
        _zoneTableView.contentInset = UIEdgeInsetsMake(0, 0, ShowDiff, 0);
    }
}

#pragma  mark - 分享、评论、赞 end

- (void)setExtraCellLineHidden: (UITableView *)tableView {
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
#pragma mark -- 获取键盘高度
- (void)keyboardWillShow:(NSNotification *)aNotification {
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.origin.y;
    _toolBar.frame = CGRectMake(0, height - 50, _window_width, 50);
    _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
    _toolBar.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
    _textField.backgroundColor = [UIColor whiteColor];
    
}
- (void)keyboardWillHide:(NSNotification *)aNotification {
    
    [UIView animateWithDuration:0.1 animations:^{
        _toolBar.frame = CGRectMake(0, _window_height - 50-statusbarHeight, _window_width, 50+statusbarHeight);
        _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
        _toolBar.backgroundColor = [RGBA(32, 28, 54, 1) colorWithAlphaComponent:0.2];
        _textField.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark === pull
-(void)pullData:(NSString *)url withliveId:(NSString *)liveid{
    _pubUrl = url;
    _liveUid = liveid;
    //@"Community.getCommunityList"
    NSDictionary *parameterDic;
    if ([url isEqual:@"Dynamic.getDynamicList"]) {
        parameterDic = @{@"p":@(_paging),
                         @"uid":[Config getOwnID]
                         };
    }else{
        parameterDic = @{@"p":@(_paging),
                         @"uid":[Config getOwnID],
                         @"token":[Config getOwnToken],
                         @"liveuid":liveid
                         };

    }
    [YBToolClass postNetworkWithUrl:_pubUrl andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [_zoneTableView.mj_header endRefreshing];
        [_zoneTableView.mj_footer endRefreshing];
        if (code == 0) {
#warning zl_
            NSArray *infoA = [NSArray arrayWithArray:info];
//            NSArray *infoA = [NSArray arrayWithObject:info[0]];
            if (_paging == 1) {
                [_zoneInfo removeAllObjects];
            }
            if (infoA.count <=0) {
                [_zoneTableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [_zoneInfo addObjectsFromArray:infoA];
            }
            if (_zoneInfo.count <=0) {
                self.nothingView.hidden = NO;
                self.nothingImgV.image = [UIImage imageNamed:@"follow_无数据"];
                self.nothingMsgL.text = @"还没有动态哦～";
                self.nothingBtn.hidden = YES;
                _zoneTableView.hidden = YES;

//                [PublicView showTextNoData:_zoneTableView text1:@"" text2:@"暂无数据"];
            }else{
                self.nothingView.hidden = YES;
                _zoneTableView.hidden = NO;

                [PublicView hiddenTextNoData:_zoneTableView];
            }
            [_zoneTableView reloadData];
            
        }else{
            [MBProgressHUD showMessage:msg];
        }
    } fail:^{
        
    }];
    
}
- (NSArray *)models {
    NSMutableArray *m_array = [NSMutableArray array];
    for (NSDictionary *dic in _zoneInfo) {
        CommunityItem *item = [CommunityItem dynamicWithDict:dic];
        [m_array addObject:item];
    }
    _models = m_array;
    return _models;
}

#pragma mark - tableviewdelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommunityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zoneCell" forIndexPath:indexPath];
    CommunityItem *item = _models[indexPath.row];
    cell.delegate = self;
    cell.data = item;
    cell.njIndex = indexPath;
    cell.fd_enforceFrameLayout = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommunityItem *item = [_models objectAtIndex:indexPath.row];
    CGFloat height ;
    @try {
        height = [tableView fd_heightForCellWithIdentifier:@"zoneCell" cacheByIndexPath:indexPath configuration:^(CommunityCell *cell) {
            cell.fd_enforceFrameLayout = YES;
            cell.data = item;
        }];
    } @catch (NSException *exception) {
        //NSLog(@"%@",exception.description);
        height = 150;
    } @finally {
        
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _currentDic = _zoneInfo[indexPath.row];
    WeakSelf;
    CommunityInfoVC *infoVC = [[CommunityInfoVC alloc]init];
    NSDictionary *subDic = _zoneInfo[indexPath.row];
    infoVC.communityInfoDic = subDic;
    infoVC.communityID = minstr([subDic valueForKey:@"id"]);
    infoVC.communityUid = minstr([subDic valueForKey:@"uid"]);
    
    infoVC.infoEvent = ^(int eventCode, NSDictionary *eventDic) {
//        [weakSelf updateData:indexPath andNewData:eventDic];
    };
    [[MXBADelegate sharedAppDelegate]pushViewController:infoVC animated:YES];
    
}

#pragma mark 评论
-(void)onClickNJCommentsBtn:(NSIndexPath *)index {
//    _currentDic = _zoneInfo[index.row];
//    _currentIndex = index;
//    _wBgView.hidden = NO;
//    [_textField becomeFirstResponder];
    _currentDic = _zoneInfo[index.row];
    WeakSelf;
    CommunityInfoVC *infoVC = [[CommunityInfoVC alloc]init];
    NSDictionary *subDic = _zoneInfo[index.row];
    infoVC.communityInfoDic = subDic;
    infoVC.communityID = minstr([subDic valueForKey:@"id"]);
    infoVC.communityUid = minstr([subDic valueForKey:@"uid"]);
    infoVC.infoEvent = ^(int eventCode, NSDictionary *eventDic) {
        //        [weakSelf updateData:indexPath andNewData:eventDic];
    };
    [[MXBADelegate sharedAppDelegate]pushViewController:infoVC animated:YES];

}

#pragma mark - 点赞

-(void)onClickNJZanBtn:(NSIndexPath *)index {
    _currentDic = _zoneInfo[index.row];
    _currentIndex = index;
    [self dolike];
}

-(void)dolike{
    if ([[Config getOwnID] intValue]<0) {
//        [PublicObj warnLogin];
        return;
    }
    
    NSDictionary *singDic = @{
                                  @"uid":[Config getOwnID],
                                  @"dynamicid":[_currentDic valueForKey:@"id"]
                                 };
    NSString *sign = [YBToolClass sortString:singDic];

    NSDictionary *parameterDic = @{
                                   @"uid":[Config getOwnID],
                                   @"token":[Config getOwnToken],
                                   @"dynamicid":[_currentDic valueForKey:@"id"],
                                   @"sign":sign
                                   };
    
    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"Dynamic.addLike" andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if(code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_currentDic];
            [m_dic setObject:[infoDic valueForKey:@"nums"] forKey:@"likes"];
            [m_dic setObject:[infoDic valueForKey:@"islike"] forKey:@"islike"];
            [_zoneInfo replaceObjectAtIndex:_currentIndex.row withObject:m_dic];
            [_zoneTableView reloadRowsAtIndexPaths:@[_currentIndex] withRowAnimation:UITableViewRowAnimationNone];
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
    
    
}

#pragma mark - 点赞 end
#pragma mark 举报
-(void)onClickReportBtn:(NSIndexPath *)index
{
    _currentDic = _zoneInfo[index.row];
    _currentIndex = index;
    ReportViewController *jubao = [[ReportViewController alloc]init];
    jubao.dongtaiId =[_currentDic valueForKey:@"id"];
//    [self.navigationController pushViewController:jubao animated:YES];
    [[MXBADelegate sharedAppDelegate]pushViewController:jubao animated:YES];

}
#pragma mark 删除
- (void)onClickNJDelBtn:(NSIndexPath *)index {
    _currentDic = _zoneInfo[index.row];
    _currentIndex = index;
    NSDictionary *parameterDic = @{
                                   @"uid":[Config getOwnID],
                                   @"token":[Config getOwnToken],
                                   @"dynamicid":[_currentDic valueForKey:@"id"],
                                   };

    [MBProgressHUD showMessage:@""];
    [YBToolClass postNetworkWithUrl:@"Dynamic.delDynamic" andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:msg];
        if (code == 0) {
            [_zoneInfo removeObject:_currentDic];
            [_zoneTableView reloadData];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
    
}

- (void)onPressImageView:(UIImageView *)imageView onDynamicCell:(CommunityCell *)cell{
    NSIndexPath *path = [_zoneTableView indexPathForCell:cell];
    NSLog(@"-------zone-----点击了：%@",path);
}
-(void)onClickVoiceOnDynamicCell:(CommunityCell *)cell
{
    [self stopVideo];
    NSIndexPath *path = [_zoneTableView indexPathForCell:cell];
    if (self.cellUid.length < 1) {
        _cellUid = cell.data.uidStr;
        _cellIndex = path;
    }
    if (![_cellIndex isEqual:path]) {
        CommunityCell *oldcell =[_zoneTableView cellForRowAtIndexPath:_cellIndex];
        if (oldcell.voicePlayer) {
            [oldcell.voicePlayer pause];
            oldcell.animationView.hidden = YES;
            oldcell.audioBackImg.hidden = NO;
            _cellIndex = path;
            oldcell.isSounding = NO;

        }
    }
    
    
    NSLog(@"---------->path:%@  \n uid:%@",path, cell.data.uidStr);
}
-(void)onTapImage:(NSMutableArray *)imageArr AtIndex:(NSInteger)tapIndex{
    if (_delegate && [_delegate respondsToSelector:@selector(cellImgaeClick:atIndex:)])
    [self.delegate cellImgaeClick:imageArr atIndex:tapIndex];

}
-(void)onVideoClickWithUrl:(NSString *)videoUrl
{
    if (_delegate && [_delegate respondsToSelector:@selector(cellVideoClick:)]){
        [self.delegate cellVideoClick:videoUrl];

    }

}
- (void)creatNothingView{
    _nothingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height-64-statusbarHeight)];
    _nothingView.backgroundColor= [UIColor whiteColor];//RGB_COLOR(@"#f5f5f5", 1);
    _nothingView.hidden = YES;
    [self addSubview:_nothingView];
    _nothingImgV = [[UIImageView alloc]initWithFrame:CGRectMake(_nothingView.width/2-40, 120, 80, 80)];
    [_nothingView addSubview:_nothingImgV];
    _nothingTitleL = [[UILabel alloc]initWithFrame:CGRectMake(0, _nothingImgV.bottom+10, _window_width, 15)];
    _nothingTitleL.font = [UIFont systemFontOfSize:13];
    _nothingTitleL.textAlignment = NSTextAlignmentCenter;
    [_nothingView addSubview:_nothingTitleL];
    
    _nothingMsgL = [[UILabel alloc]initWithFrame:CGRectMake(0, _nothingTitleL.bottom+5, _window_width, 15)];
    _nothingMsgL.textColor = RGB_COLOR(@"#969696", 1);
    _nothingMsgL.font = [UIFont systemFontOfSize:10];
    _nothingMsgL.textAlignment = NSTextAlignmentCenter;
    [_nothingView addSubview:_nothingMsgL];
    
    _nothingBtn = [UIButton buttonWithType:0];
    _nothingBtn.frame = CGRectMake(_window_width/2-35, _nothingMsgL.bottom+10, 70, 28);
    _nothingBtn.backgroundColor = normalColors;
    _nothingBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_nothingBtn addTarget:self action:@selector(nothingBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _nothingBtn.hidden = YES;
    _nothingBtn.layer.cornerRadius = 15;
    _nothingBtn.layer.masksToBounds  = YES;
    [_nothingView addSubview:_nothingBtn];
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

#pragma mark  表情代理方法
- (void)faceViewDidBackDelete:(TFaceView *)faceView
{
    [_textField.internalTextView deleteBackward];
}



- (void)faceView:(TFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFaceGroup *group = [[TUIKit sharedInstance] getConfig].faceGroups[indexPath.section];
    TFaceCellData *face = group.faces[indexPath.row];
}
-(void)pushmessage {
    if (_textField.text.length<=0) {
        [MBProgressHUD showError:@"请添加内容后再尝试"];
        return;
    }
    NSDictionary *postDic = @{@"uid":[Config getOwnID],
                              @"token":[Config getOwnToken],
                              @"communityid":minstr([_currentDic valueForKey:@"id"]),
                              @"parentid":@"0",
                              @"commentid":@"0",
                              @"content":_textField.text,
                              @"at_info":@"",
                              @"type":@"0",
                              @"voice":@"",
                              @"length":@""
                              };
    [MBProgressHUD showMessage:@""];
    WeakSelf;
    [YBToolClass postNetworkWithUrl:@"Dynamic.setComment" andParameter:postDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:msg];
        if (code == 0) {
            NSString *comments = minstr([[info firstObject] valueForKey:@"comments"]);
            _textField.text = @"";
            [weakSelf clickTapGes];
            
            NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_currentDic];
            [m_dic setObject:comments forKey:@"comments"];
            [_zoneInfo replaceObjectAtIndex:_currentIndex.row withObject:m_dic];
            [_zoneTableView reloadRowsAtIndexPaths:@[_currentIndex] withRowAnimation:UITableViewRowAnimationNone];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
    
}

-(void)onCenterClick:(NSString *)liveId
{
    if ([liveId isEqual:[Config getOwnID]]) {
        return;
    }
    [YBToolClass postNetworkWithUrl:@"User.GetUserHome" andParameter:@{@"liveuid":liveId} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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

#pragma mark 滑动监听
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        NSArray *aaa = [_zoneTableView indexPathsForVisibleRows];
        NSLog(@"aaaaaaa=%@",aaa);
        if (aaa.count == 0) {
            return;
        }
        NSIndexPath *idexxx;
        if (aaa.count == 3) {
            idexxx = aaa[1];
        }else{
            int yyyyy = (int)scrollView.contentOffset.y - (130 + _window_width / 6);
            NSLog(@"YYYY=%d\nscrollView.contentOffset.y=%.2f",yyyyy,scrollView.contentOffset.y);
            if (scrollView.contentOffset.y < 130 + _window_width / 6+(_window_width+60)/2) {
                if (aaa.count >= 1) {
                    idexxx = aaa[0];
                }
            }else{
                if (yyyyy % (int)(_window_width+60) > (_window_width+60)/2) {
                    if (aaa.count >= 2) {
                        idexxx = aaa[1];
                    }
                }else{
                    if (aaa.count >= 1) {
                        idexxx = aaa[0];
                    }
                }
            }
        }
        for (CommunityCell *ce in [self cellsForTableView:_zoneTableView]) {
            NSIndexPath *indexp = [_zoneTableView indexPathForCell:ce];
            if (![indexp isEqual:idexxx]) {
                NSLog(@"1111---%@停止",indexp);
                if ([ce.data.communityType isEqual:@"2"]) {
                    [ce playVoice:NO];
                    NSLog(@"----------有视频-----");
                    if (ce.isPlayingVideo) {
//                        [ce.txLivePlayer pause];
                        [ce pauseVideo];

                        ce.pauseIV.hidden = YES;
                        ce.isPlayingVideo = NO;

                    }else{
//                        [ce.txLivePlayer resume];
                        [ce pauseVideo];

                        ce.pauseIV.hidden = YES;
                        ce.isPlayingVideo = YES;

                    }

                }else{
                    [ce pauseVideo];

                }

            }
            else{
                //            [ce playCurrentRoom];
                NSLog(@"1111---%@播放",indexp);
                if ([ce.data.communityType isEqual:@"2"]) {
                    NSLog(@"----------有视频-----");
                    if (!ce.isPlayingVideo) {
//                        [ce.txLivePlayer resume];
                        [ce pauseVideo];
                        ce.pauseIV.hidden = YES;
                        ce.isPlayingVideo = NO;
                    }
                    else{
//                        [ce.txLivePlayer resume];
                        [ce playVideoPath];
                        ce.pauseIV.hidden = YES;
                        ce.isPlayingVideo = YES;

                    }

                }
            }

        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSArray *aaa = [_zoneTableView indexPathsForVisibleRows];
    NSLog(@"aaaaaaa=%@",aaa);
    if (aaa.count == 0) {
        return;
    }
    NSIndexPath *idexxx;
    if (aaa.count == 3) {
        idexxx = aaa[1];
    }else{
        int yyyyy = (int)scrollView.contentOffset.y - (130 + _window_width / 6);
        NSLog(@"YYYY=%d\nscrollView.contentOffset.y=%.2f",yyyyy,scrollView.contentOffset.y);
        if (scrollView.contentOffset.y < 130 + _window_width / 6+(_window_width+60)/2) {
            if (aaa.count >= 1) {
                idexxx = aaa[0];
            }
        }else{
            if (yyyyy % (int)(_window_width+60) > (_window_width+60)/2) {
                if (aaa.count >= 2) {
                    idexxx = aaa[1];
                }
            }else{
                if (aaa.count >= 1) {
                    idexxx = aaa[0];
                }
            }
        }
    }
    for (CommunityCell *ce in [self cellsForTableView:_zoneTableView]) {
        NSIndexPath *indexp = [_zoneTableView indexPathForCell:ce];
        if (![indexp isEqual:idexxx]) {
            NSLog(@"1111---%@停止",indexp);
            if ([ce.data.communityType isEqual:@"2"]) {
                [ce playVoice:NO];

                NSLog(@"----------有视频-----");
                    [ce pauseVideo];
                    ce.pauseIV.hidden = YES;
                    ce.isPlayingVideo = YES;
            }else{
                [ce pauseVideo];
            }
        }else{
//            [ce playCurrentRoom];
            NSLog(@"1111---%@播放",indexp);
            if ([ce.data.communityType isEqual:@"2"]) {
                NSLog(@"----------有视频-----");
                if (!ce.isPlayingVideo) {
                    [ce pauseVideo];
                    ce.pauseIV.hidden = YES;
                    ce.isPlayingVideo = NO;
                }
                else{
                    [ce playVideoPath];
                    ce.pauseIV.hidden = YES;
                    ce.isPlayingVideo = YES;
                }
                
            }else{
                [ce pauseVideo];

            }
        }
    }
}

-(void)stopVideo{
    for (CommunityCell *ce in [self cellsForTableView:_zoneTableView]) {
        [ce playVoice:YES];

    }
}
- (NSArray *)cellsForTableView:(UITableView *)tableView
{
    NSInteger sections = tableView.numberOfSections;
    NSMutableArray *cells = [[NSMutableArray alloc]init];
    for (int section = 0; section < sections; section++) {
        NSInteger rows =[tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            if ([tableView cellForRowAtIndexPath:indexPath]) {
                [cells addObject:[tableView cellForRowAtIndexPath:indexPath]];
            }
          }
        }
    return cells;

}

@end
