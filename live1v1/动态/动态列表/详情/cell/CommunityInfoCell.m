//
//  CommunityInfoCell.m
//  yunbaolive
//
//  Created by Boom on 2018/12/17.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "CommunityInfoCell.h"
#import "commDetailCell.h"
#import "detailmodel.h"
#import "TUIKit.h"
@implementation CommunityInfoCell{
    int page;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (@available(iOS 11.0,*)) {
        _replyTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (NSURL *)anImgUrl{
    if (!_anImgUrl) {
        _anImgUrl = [[NSBundle mainBundle] URLForResource:@"trendslistaudeo" withExtension:@"gif"];
    }
    return _anImgUrl;
}

- (void)setModel:(commentModel *)model{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAll) name:REMOVEALLVIODEORVOICE object:nil];
    _model = model;
    if ([_model.isvoice isEqual:@"1"]) {
        _voiceBtn.layer.borderColor = normalColors.CGColor;
        _audioBack.hidden =NO;
        _animationView.yy_imageURL = self.anImgUrl;
        _voiceTimeL.text = [NSString stringWithFormat:@"%@s",model.voiceTime];
//        [_replyTable mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_voiceBtn.mas_bottom);
//        }];

    }else{
        _audioBack.hidden = YES;
//        [_replyTable mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_contentL.mas_bottom);
//            make.bottom.equalTo(self);
//        }];

    }
    [self layoutIfNeeded];
    NSLog(@"_replyArray=%@",_model.replyList);
    _replyArray = [_model.replyList mutableCopy];
    [_iconImgView sd_setImageWithURL:[NSURL URLWithString:_model.avatar_thumb]];
    _nameL.text = _model.user_nicename;
//    _contentL.text = _model.content;
    _zanNumL.text = _model.likes;
    if ([_model.islike isEqual:@"1"]) {
        [_zanBtn setImage:[UIImage imageNamed:@"trends点赞亮"] forState:0];
        _zanNumL.textColor = RGB_COLOR(@"#fa561f", 1);
    }else{
        [_zanBtn setImage:[UIImage imageNamed:@"trends点赞灰"] forState:0];
//        _zanNumL.textColor = RGB(130, 130, 130);
        _zanNumL.textColor = RGBA(130, 130, 130, 1);
    }
    //匹配表情文字
    NSArray *resultArr  = [[YBToolClass sharedInstance] machesWithPattern:emojiPattern andStr:_model.content];
    if (!resultArr) return;
    NSUInteger lengthDetail = 0;
    NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc]initWithString:_model.content];
    //遍历所有的result 取出range
    for (NSTextCheckingResult *result in resultArr) {
        //取出图片名
        NSString *imageName =   [_model.content substringWithRange:NSMakeRange(result.range.location, result.range.length)];
        NSLog(@"--------%@",imageName);
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        
        //取出图片
        NSString *path = [NSString stringWithFormat:@"emoji/%@", imageName];
        NSString *emojiPath = TUIKitFace(path);
        UIImage *emojiImage = [[[TUIKit sharedInstance] getConfig] getFaceFromCache:emojiPath];
        NSAttributedString *imageString;
        if (emojiImage) {
            attach.image = emojiImage;
            attach.bounds = CGRectMake(0, -2, 15, 15);
            imageString =   [NSAttributedString attributedStringWithAttachment:attach];
        }else{
            imageString =   [[NSMutableAttributedString alloc]initWithString:imageName];
        }
        //图片附件的文本长度是1
        NSLog(@"emoj===%zd===size-w:%f==size-h:%f",imageString.length,imageString.size.width,imageString.size.height);
        NSUInteger length = attstr.length;
        NSRange newRange = NSMakeRange(result.range.location - lengthDetail, result.range.length);
        [attstr replaceCharactersInRange:newRange withAttributedString:imageString];
        
        lengthDetail += length - attstr.length;
    }
    NSAttributedString *dateStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@",_model.datetime] attributes:@{NSForegroundColorAttributeName:RGB_COLOR(@"#959697", 1),NSFontAttributeName:[UIFont systemFontOfSize:11]}];
    [attstr appendAttributedString:dateStr];
    //更新到label上
    [_replyTable reloadData];

    _contentL.attributedText = attstr;

    if ([_model.replys intValue] > 0) {

        CGFloat HHHH = 0.0;
        for (NSDictionary *dic in _replyArray) {
            detailmodel *model = [[detailmodel alloc]initWithDic:dic];
            HHHH += model.rowH;
        }
        if ([_model.replys intValue] == 1) {
            _tableHeight.constant = HHHH;
        }else{
            if (!_replyBottomView) {
                _replyBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
                _replyBottomView.backgroundColor = [UIColor whiteColor];
                //回复
                _Reply_Button = [UIButton buttonWithType:0];
                _Reply_Button.backgroundColor = [UIColor clearColor];
                _Reply_Button.titleLabel.textAlignment = NSTextAlignmentLeft;
                _Reply_Button.titleLabel.font = [UIFont systemFontOfSize:12];
                [_Reply_Button addTarget:self action:@selector(makeReply) forControlEvents:UIControlEventTouchUpInside];
                NSMutableAttributedString *attstr = [[NSMutableAttributedString alloc]initWithString:@"展开更多回复"];
                [attstr addAttribute:NSForegroundColorAttributeName value:RGBA(200, 200, 200, 1) range:NSMakeRange(0, 6)];
                NSTextAttachment *attach = [[NSTextAttachment alloc] init];
                UIImage *image = [UIImage imageNamed:@"relpay_三角下.png"];
                NSAttributedString *imageString;
                if (image) {
                    attach.image = image;
                    attach.bounds = CGRectMake(0, -4, 15, 15);
                    imageString =   [NSAttributedString attributedStringWithAttachment:attach];
                    [attstr appendAttributedString:imageString];
                }
                [_Reply_Button setAttributedTitle:attstr forState:0];
                
                NSMutableAttributedString *attstr2 = [[NSMutableAttributedString alloc]initWithString:@"收起"];
                [attstr2 addAttribute:NSForegroundColorAttributeName value:RGBA(200, 200, 200, 1) range:NSMakeRange(0, 2)];
                NSTextAttachment *attach2 = [[NSTextAttachment alloc] init];
                UIImage *image2 = [UIImage imageNamed:@"relpay_三角上.png"];
                NSAttributedString *imageString2;
                if (image2) {
                    attach2.image = image2;
                    attach2.bounds = CGRectMake(0, -4, 15, 15);
                    imageString2 =   [NSAttributedString attributedStringWithAttachment:attach2];
                    [attstr2 appendAttributedString:imageString2];
                }
                [_Reply_Button setAttributedTitle:attstr2 forState:UIControlStateSelected];
                [_replyBottomView addSubview:_Reply_Button];
                
                [_Reply_Button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.bottom.equalTo(_replyBottomView);
                }];
                
            }
            _replyTable.tableFooterView = _replyBottomView;
            if (_model.replyList.count % 20 != 0 && _model.replyList.count != 1) {
                _Reply_Button.selected = YES;
            }else{
                _Reply_Button.selected = NO;
            }
            _tableHeight.constant = HHHH+50;
        }
    }else{
        _tableHeight.constant = 0;
        _replyTable.tableFooterView = nil;
    }
}
- (IBAction)audioBtnClick:(id)sender {
    NSLog(@"--------------音频-----");
    NSLog(@"--------:::%@",_model.voiceUrl);
    NSString *timeStr=_model.voiceTime;;
    
    int floattotal = [timeStr intValue];
    
    isSounding = !isSounding;
    if (isSounding) {
        _isPlaying = NO;
        if (_voicePlayer) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
            [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
            [_voicePlayer removeObserver:self forKeyPath:@"status"];
            [_voicePlayer pause];
            _voicePlayer = nil;
        }else{}
        NSURL * url  = [NSURL URLWithString:_model.voiceUrl];
        AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
        _voicePlayer = [[AVPlayer alloc]initWithPlayerItem:songItem];
        [_voicePlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
        WeakSelf;
        _playbackTimeObserver = [_voicePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            //当前播放的时间
            CGFloat floatcurrent = CMTimeGetSeconds(time);
            NSLog(@"floatcurrent = %.1f",floatcurrent);
            //总时间
            weakSelf.voiceTimeL.text =[NSString stringWithFormat:@"%.0fs",(floattotal-floatcurrent) > 0 ? (floattotal-floatcurrent) : 0];
            
        }];
        
        [_voicePlayer play];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
        [[NSNotificationCenter defaultCenter]postNotificationName:PAUSEVIODEINDETAIL object:nil];
        
    }else{
        if (_voicePlayer) {
            [_voicePlayer pause];
            _pauseImage.image = [UIImage imageNamed:@"icon_video_replayvice.png"];
        }
    }
}
- (void)playFinished:(NSNotification *)not{
    
    _isPlaying = NO;
    _pauseImage.image = [UIImage imageNamed:@"icon_video_replayvice.png"];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
    [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
    [_voicePlayer removeObserver:self forKeyPath:@"status"];
    [_voicePlayer pause];
    _voicePlayer = nil;
    
    _voiceTimeL.text = [NSString stringWithFormat:@"%@s",_model.voiceTime];
    [[NSNotificationCenter defaultCenter]postNotificationName:RESUMEVIODEINDETAIL object:nil];
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
            case AVPlayerStatusUnknown:
            {
                NSLog(@"----播放失败----------");
                [MBProgressHUD showError:@"播放失败"];
                _isPlaying = NO;
                _pauseImage.image = [UIImage imageNamed:@"icon_video_replayvice.png"];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"----播放----------");
                _isPlaying = YES;
                isSounding = YES;
                _pauseImage.image = [UIImage imageNamed:@"icon_video_replayvice_1"];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                [MBProgressHUD showError:@"播放失败"];
                _isPlaying = NO;
                _pauseImage.image = [UIImage imageNamed:@"icon_video_replayvice.png"];
            }
                break;
        }
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _replyArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    commDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commDetailCELL"];
    if (!cell) {
        cell = [[commDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commDetailCell"];
    }

    detailmodel *model = [[detailmodel alloc]initWithDic:_replyArray[indexPath.row]];
    cell.model = model;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    detailmodel *model = [[detailmodel alloc]initWithDic:_replyArray[indexPath.row]];
    return model.rowH;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *subdic = _replyArray[indexPath.row];
    
    [self.delegate pushDetails:subdic];
}

- (void)makeReply{
    if (_Reply_Button.selected) {
        NSDictionary *dic = [_replyArray firstObject];
        [_replyArray removeAllObjects];
        [_replyArray addObject:dic];
        _model.replyList = _replyArray;
        [_replyTable reloadData];
        _Reply_Button.selected = NO;
        [self.delegate reloadCurCell:_model andIndex:_curIndex andReplist:_replyArray needRefresh:YES];

    }else{
        if (_replyArray.count == 1) {
            page = 1;
        }else{
            page ++;
        }
        [self requestData:NO];
    }
}
- (void)requestData:(BOOL)flag{
    NSString *last_replyid = @"0";
    NSDictionary *dic = [_replyArray lastObject];
    if ([dic isKindOfClass:[NSDictionary class]] && flag == NO) {
        last_replyid = [NSString stringWithFormat:@"%@",[dic valueForKey:@"id"]];
    }
    if (flag) {
        //有新回复，pag重置
        page = 1;
    }

    NSDictionary *parameterDic = @{
                                   @"uid":[Config getOwnID],
                                   @"last_replyid":last_replyid,
                                   @"commentid":_model.parentid,//minstr([dic valueForKey:@"parentid"])
                                   @"p":@(page),
                                   @"token":[Config getOwnToken]
                                   };

    [YBToolClass postNetworkWithUrl:@"Dynamic.getReplys" andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if(code == 0) {
            NSDictionary *infoDic = [info firstObject];
            NSMutableArray *infos = [infoDic valueForKey:@"lists"];
//            if (page == 1 && infos.count>0) {
//                [_replyArray removeObjectAtIndex:0];
//            }
//            if (page == 1 && flag == YES) {
//                [_replyArray removeAllObjects];
//            }
            for (NSDictionary *dic in infos) {
                [_replyArray addObject:[dic mutableCopy]];
            }

//            [_replyArray addObjectsFromArray:info];
            _model.replyList = _replyArray;
            //            [_replyTable reloadData];
            [self.delegate reloadCurCell:_model andIndex:_curIndex andReplist:_replyArray needRefresh:YES];
            if (infos.count < 20) {
                _Reply_Button.selected = YES;
            }
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];

}
- (IBAction)zanBtnClick:(id)sender {

    if ([_model.ID isEqual:[Config getOwnID]]) {
        [MBProgressHUD showError:@"不能给自己的评论点赞"];
        
        return;
    }
    if ([[Config getOwnID] intValue] < 0) {
        //[self.delegate youkedianzan];
        return;
    }
    //_bigbtn.userInteractionEnabled = NO;
    NSDictionary *singDic = @{
                              @"uid":[Config getOwnID],
                              @"commentid":_model.parentid
                              };
    NSString *sign = [YBToolClass sortString:singDic];

    NSDictionary *parameterDic = @{
                                   @"uid":[Config getOwnID],
                                   @"token":[Config getOwnToken],
                                   @"commentid":_model.parentid,
                                   @"sign":sign
                                   };

    [YBToolClass postNetworkWithUrl:@"Dynamic.addCommentLike" andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if(code == 0) {
            //动画
            dispatch_async(dispatch_get_main_queue(), ^{
                [_zanBtn.imageView.layer addAnimation:[YBToolClass bigToSmallRecovery] forKey:nil];
            });
            
            NSDictionary *infos = [info firstObject];
            NSString *islike = [NSString stringWithFormat:@"%@",[infos valueForKey:@"islike"]];
            NSString *likes = [NSString stringWithFormat:@"%@",[infos valueForKey:@"nums"]];
            
            _zanNumL.text = likes;
            if ([islike isEqual:@"1"]) {
                [_zanBtn setImage:[UIImage imageNamed:@"trends点赞亮"] forState:0];
                _zanNumL.textColor = RGB_COLOR(@"#fa561f", 1);;
            }else{
                [_zanBtn setImage:[UIImage imageNamed:@"trends点赞灰"] forState:0];
                _zanNumL.textColor =RGBA(130, 130, 130, 1);// RGB(130, 130, 130);
            }
            
            [self.delegate makeLikeRloadList:_model.parentid andLikes:likes islike:islike];

        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
    
}
-(void)removeAll{
    if (_voicePlayer) {
        _isPlaying = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
        [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
        [_voicePlayer removeObserver:self forKeyPath:@"status"];
        [_voicePlayer pause];
        _voicePlayer = nil;
    }
    
}

@end
