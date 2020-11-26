//
//  CommunityInfoHeader.m
//  yunbaolive
//
//  Created by YB007 on 2019/7/20.
//  Copyright © 2019 cat. All rights reserved.
//

#import "CommunityInfoHeader.h"
#import "TTTAttributedLabel.h"



#define kPicDiv 4.0f
#define kNumberOfLines 5.0
@interface CommunityInfoHeader()<TTTAttributedLabelDelegate,TXLivePlayListener>
{
    BOOL isSounding;

}
@property (nonatomic,strong) AVPlayer *voicePlayer;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,strong) UILabel *voiceTime;
//监听播放起状态的监听者
@property (nonatomic ,strong) id playbackTimeObserver;

@end
@implementation CommunityInfoHeader
{
    CGFloat _allHeight;
    NSDictionary *_infoDic;
    UILabel *_footerAllComNum;
    
    NSString *_isLikeStr;
    NSString *_likesStr;
    NSString *_commentStr;
    
    UIButton *_pauseBtn;

}

-(void)setHeaderData:(NSDictionary *)infoDic {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseVideo) name:PAUSEVIODEINDETAIL object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resumeVideo) name:RESUMEVIODEINDETAIL object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAll) name:REMOVEALLVIODEORVOICE object:nil];

    _infoDic = infoDic;
    _allHeight = 0;
    
    _isLikeStr = minstr([infoDic valueForKey:@"islike"]);
    _likesStr = minstr([infoDic valueForKey:@"likes"]);
    _commentStr = minstr([infoDic valueForKey:@"comments"]);
    
    for(UIView *view in [self subviews])
    {
        [view removeFromSuperview];
    }
    [self setHeadView];
    [self setBodyView];
    [self setZanReplyBar];
    [self setFootView];
    
}
-(void)setHeadView {
    _headView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 40, 40)];
    [_headView sd_setImageWithURL:[NSURL URLWithString:minstr([[_infoDic valueForKey:@"userinfo"] valueForKey:@"avatar"])]];
    [self addSubview:_headView];
    
    CALayer *layer=[_headView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:40 / 2.0];
    [layer setBorderWidth:1];
    [layer setBorderColor:[[UIColor clearColor] CGColor]];
    
    //名称
    UILabel *titleL = [[UILabel alloc]init];
    titleL.font = SYS_Font(16);
    titleL.textColor = RGB_COLOR(@"#323232", 1);
    titleL.text = minstr([[_infoDic valueForKey:@"userinfo"] valueForKey:@"user_nickname"]);
    [self addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headView.mas_right).offset(8);
        //        make.centerY.equalTo(_headView);
        make.top.mas_equalTo(_headView.mas_top);
    }];
    
    UIImageView *sexImg = [[UIImageView alloc]init];
    NSString *sexStr =minstr([[_infoDic valueForKey:@"userinfo"] valueForKey:@"sex"]);
    if ([sexStr isEqual:@"2"]) {
        sexImg.image = [UIImage imageNamed:@"person_性别女"];
    }else if([sexStr isEqual:@"1"]){
        sexImg.image = [UIImage imageNamed:@"person_性别男"];
        
    }
    [self addSubview:sexImg];
    [sexImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleL.mas_right).offset(5);
        make.width.height.mas_equalTo(15);
        make.top.equalTo(titleL.mas_top);
    }];
    
    UIImageView *addressImg = [[UIImageView alloc]init];
    addressImg.image = [UIImage imageNamed:@"trends定位"];
    [self addSubview:addressImg];
    [addressImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headView.mas_right).offset(8);
        make.top.equalTo(titleL.mas_bottom).offset(8);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(14);
    }];
    
    UILabel *addressLb = [[UILabel alloc]init];
    addressLb.font = SYS_Font(12);
    addressLb.textColor = RGBA(150, 150, 150, 1);
    addressLb.text = minstr([_infoDic valueForKey:@"city"]);
    [self addSubview:addressLb];
    [addressLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(addressImg);
        make.left.equalTo(addressImg.mas_right).offset(5);
    }];
    
    UILabel *lineLb = [[UILabel alloc]init];
    lineLb.backgroundColor =RGBA(200, 200, 200, 1);
    [self addSubview:lineLb];
    [lineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addressLb.mas_right).offset(8);
        make.top.equalTo(addressImg.mas_top);
        make.bottom.equalTo(addressImg.mas_bottom);
        make.width.mas_equalTo(1.5);
    }];
    
    UILabel *sendTime = [[UILabel alloc]init];
    sendTime.text = minstr([_infoDic valueForKey:@"datetime"]);
    sendTime.textColor = RGBA(150, 150, 150, 1);
    sendTime.font = SYS_Font(12);
    [self  addSubview:sendTime];
    [sendTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(addressImg);
        make.left.equalTo(lineLb.mas_right).offset(8);
    }];
    
    
    UIButton *moreBtn = [UIButton buttonWithType:0];
    moreBtn.frame = CGRectMake(_window_width-50, _headView.origin.y, 30, 20);
    [moreBtn setImage:[UIImage imageNamed:@"trends三圆点"] forState:0];
    [moreBtn addTarget:self action:@selector(cellDelBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:moreBtn];
    
    //去往个人中心
    UIButton *goCenter = [UIButton buttonWithType:0];
    [goCenter addTarget:self action:@selector(centerClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:goCenter];
    [goCenter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headView.mas_left);
        make.right.equalTo(_headView.mas_right).offset(20);
        make.top.mas_equalTo(_headView.mas_top);
        make.bottom.equalTo(_headView.mas_bottom);
    }];

    
}
-(void)centerClick{
    if (_delegate && [_delegate respondsToSelector:@selector(clickgoCenter:)]) {
        [_delegate clickgoCenter:minstr([[_infoDic valueForKey:@"userinfo"] valueForKey:@"id"])];
    }
    
}
-(void)cellDelBtn{
    WeakSelf;
    NSString *userid = minstr([[_infoDic valueForKey:@"userinfo"] valueForKey:@"id"]);
    if ([userid isEqual:[Config getOwnID]]) {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *suerA = [UIAlertAction actionWithTitle:@"删除此条动态" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf showAlertCC];
        }];
        
        UIViewController *currentVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        [alertC addAction:cancelA];
        [alertC addAction:suerA];
        
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 9.0) {
            [suerA setValue:RGB_COLOR(@"#323232", 1) forKey:@"_titleTextColor"];
            [cancelA setValue:RGB_COLOR(@"#969696", 1) forKey:@"_titleTextColor"];
        }
        [currentVC presentViewController:alertC animated:YES completion:nil];
    }else{
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *suerA = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(clickReportORDelete:)]) {
                [weakSelf.delegate clickReportORDelete:minstr([_infoDic valueForKey:@"id"])];
            }
        }];
        
        UIViewController *currentVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        [alertC addAction:cancelA];
        [alertC addAction:suerA];
        
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 9.0) {
            [suerA setValue:RGB_COLOR(@"#323232", 1) forKey:@"_titleTextColor"];
            [cancelA setValue:RGB_COLOR(@"#969696", 1) forKey:@"_titleTextColor"];
        }
        [currentVC presentViewController:alertC animated:YES completion:nil];
        
    }

}
-(void)showAlertCC {
    WeakSelf;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"是否删除此条动态?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onClickNJDelBtn:)]) {
//            [weakSelf.delegate onClickNJDelBtn:_njIndex];
//        }
        NSDictionary *parameterDic = @{
                                       @"uid":[Config getOwnID],
                                       @"token":[Config getOwnToken],
                                       @"dynamicid":minstr([_infoDic valueForKey:@"id"]),
                                       };
        
        [MBProgressHUD showMessage:@""];
        [YBToolClass postNetworkWithUrl:@"Dynamic.delDynamic" andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
            if (code == 0) {
                if (_livePlayer) {
                    [_livePlayer stopPlay];
                    _livePlayer = nil;
                }

                [MBProgressHUD showError:msg];
                [[MXBADelegate sharedAppDelegate]popViewController:YES];
            }else{
                [MBProgressHUD showError:msg];

            }
        } fail:^{
            [MBProgressHUD hideHUD];
        }];

    }];
    
    UIViewController *currentVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    [alertC addAction:cancelA];
    [alertC addAction:suerA];
    
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 9.0) {
        [suerA setValue:[UIColor redColor] forKey:@"_titleTextColor"];
        [cancelA setValue:RGB_COLOR(@"#969696", 1) forKey:@"_titleTextColor"];
    }
    [currentVC presentViewController:alertC animated:YES completion:nil];
    
}

-(void)setBodyView {
    //0-文字  1-文字+图片  2-文字+视频
    NSString *communityType = [_infoDic valueForKey:@"type"];
    if ([communityType isEqual:@"2"]) {
        [self setVideoBody];
    }else if([communityType isEqual:@"1"]){
        [self setNewsBody];
    }else if([communityType isEqual:@"3"]){
        [self setAudioBody];
    }else {
        [self setTextBody];
    }
}
-(void)setAudioBody{
    CGFloat bodyViewWidth = _window_width - 30;
    CGFloat bodyViewAddHight = 0;
    BOOL showMoreBtn = NO;
    
    NSString *content = minstr([_infoDic valueForKey:@"title"]);
    
    TTTAttributedLabel * contentLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, bodyViewWidth, 0)];
    contentLabel.numberOfLines = kNumberOfLines;
    contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    contentLabel.delegate = self;
    if (content != nil && content.length > 0 ) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.maximumLineHeight = 18.0f;
        paragraphStyle.minimumLineHeight = 16.0f;
        paragraphStyle.firstLineHeadIndent = 0.0f;
        paragraphStyle.lineSpacing = 6.0f;
        paragraphStyle.firstLineHeadIndent = 0.0f;
        paragraphStyle.headIndent = 0.0f;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        //
        UIFont *font = [UIFont systemFontOfSize:14];
        NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:RGB_COLOR(@"#323232", 1)};
        contentLabel.attributedText = [[NSAttributedString alloc]initWithString:content attributes:attributes];
        CGSize size = CGSizeMake(bodyViewWidth, 1000.0f);
        CGSize finalSize = [contentLabel sizeThatFits:size];
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        
        //利用富文本实现URL的点击事件http://blog.csdn.net/liyunxiangrxm/article/details/53410919
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLabel.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:YES],
                                        (NSString*)kCTForegroundColorAttributeName : (id)[[UIColor blueColor] CGColor]};
        
        contentLabel.highlightedTextColor = [UIColor whiteColor];
        contentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        // end modify by huangyibiao
        
        // reasion: handle links in chat content, ananylizing each link
        // 提取出文本中的超链接
        NSError *error;
        NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray *arrayOfAllMatches = [regex matchesInString:content
                                                    options:0
                                                      range:NSMakeRange(0, [content length])];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:content];
        for (NSTextCheckingResult *match in arrayOfAllMatches) {
            NSString *substringForMatch = [content substringWithRange:match.range];
            [attribute addAttribute:(NSString *)kCTFontAttributeName value:(id)contentLabel.font range:match.range];
            [attribute addAttribute:(NSString*)kCTForegroundColorAttributeName
                              value:(id)[[UIColor blueColor] CGColor]
                              range:match.range];
            [contentLabel addLinkToURL:[NSURL URLWithString:substringForMatch] withRange:match.range];
        }
        
        //文本增加长按手势
        contentLabel.userInteractionEnabled = YES;
//        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressText:)];
//        [contentLabel addGestureRecognizer:longTap];
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        bodyViewAddHight = 0;
        
    }
    CGFloat fromY = contentLabel == nil?0:contentLabel.frame.size.height+10;
    if (showMoreBtn) {
        fromY += bodyViewAddHight;
    }
    UIImageView *videoImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, fromY, _window_width/2, 40)];
    videoImg.layer.cornerRadius = 20;
    videoImg.layer.masksToBounds = YES;
    videoImg.image = [UIImage imageNamed:@"recordBackimge"];
    videoImg.backgroundColor = normalColors;
    videoImg.userInteractionEnabled = YES;
    CGFloat bodyHight = videoImg.frame.size.height + videoImg.frame.origin.y;
    if (showMoreBtn) {
        bodyHight += bodyViewAddHight;
    }
    
    
    
    self.bodyView = nil;
    self.bodyView = [[UIView alloc]initWithFrame:CGRectMake(_headView.left, _headView.bottom + 10, bodyViewWidth, bodyHight)];
    [self addSubview:self.bodyView];
    [self.bodyView addSubview:videoImg];
    if(contentLabel != nil){
        [self.bodyView addSubview:contentLabel];
    }
    

    _audioBackImg = [[UIImageView alloc]init];
    _audioBackImg.image = [UIImage imageNamed:@"icon_voice_play_1"];
    [videoImg addSubview:_audioBackImg];
    [_audioBackImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(videoImg);
        make.left.equalTo(videoImg).offset(20);
        make.width.equalTo(videoImg).multipliedBy(0.6);
        make.height.mas_equalTo(18);
    }];

    _animationView = [[YYAnimatedImageView alloc]init];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"trendslistaudeo" withExtension:@"gif"];
    _animationView.yy_imageURL = url;
    _animationView.hidden = YES;
    [videoImg addSubview:_animationView];
    [_animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(videoImg);
        make.left.equalTo(videoImg).offset(20);
        make.width.equalTo(videoImg).multipliedBy(0.6);
        make.height.mas_equalTo(30);
    }];
    
    _voiceTime = [[UILabel alloc]init];
    _voiceTime.font = [UIFont systemFontOfSize:14];
    _voiceTime.textColor = [UIColor whiteColor];
    _voiceTime.text = [NSString stringWithFormat:@"%@s",minstr([_infoDic valueForKey:@"length"])];
    [videoImg addSubview:_voiceTime];
    [_voiceTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_audioBackImg.mas_right).offset(5);
        make.centerY.equalTo(videoImg);
        make.right.equalTo(videoImg.mas_right);
        
    }];
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(voiceClick)];
    [videoImg addGestureRecognizer:tapGesture];

}

-(void)setTextBody {
    CGFloat bodyViewWidth = _window_width - 30;
    CGFloat bodyViewAddHight = 0;
    
    NSString *content = minstr([_infoDic valueForKey:@"title"]);
    
    TTTAttributedLabel * contentLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, bodyViewWidth, 0)];
    contentLabel.numberOfLines = kNumberOfLines;
    contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    contentLabel.delegate = self;
    
    if (content != nil && content.length > 0 ) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.maximumLineHeight = 18.0f;
        paragraphStyle.minimumLineHeight = 16.0f;
        paragraphStyle.firstLineHeadIndent = 0.0f;
        paragraphStyle.lineSpacing = 6.0f;
        paragraphStyle.firstLineHeadIndent = 0.0f;
        paragraphStyle.headIndent = 0.0f;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        //
        UIFont *font = [UIFont systemFontOfSize:14];
        NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:RGB_COLOR(@"#323232", 1)};
        contentLabel.attributedText = [[NSAttributedString alloc]initWithString:content attributes:attributes];
        CGSize size = CGSizeMake(bodyViewWidth, 1000.0f);
        CGSize finalSize = [contentLabel sizeThatFits:size];
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        
        //利用富文本实现URL的点击事件http://blog.csdn.net/liyunxiangrxm/article/details/53410919
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLabel.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:YES],
                                        (NSString*)kCTForegroundColorAttributeName : (id)[[UIColor blueColor] CGColor]};
        
        contentLabel.highlightedTextColor = [UIColor whiteColor];
        contentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        // end modify by huangyibiao
        
        // reasion: handle links in chat content, ananylizing each link
        // 提取出文本中的超链接
        NSError *error;
        NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray *arrayOfAllMatches = [regex matchesInString:content
                                                    options:0
                                                      range:NSMakeRange(0, [content length])];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:content];
        for (NSTextCheckingResult *match in arrayOfAllMatches) {
            NSString *substringForMatch = [content substringWithRange:match.range];
            [attribute addAttribute:(NSString *)kCTFontAttributeName value:(id)contentLabel.font range:match.range];
            [attribute addAttribute:(NSString*)kCTForegroundColorAttributeName
                              value:(id)[[UIColor blueColor] CGColor]
                              range:match.range];
            [contentLabel addLinkToURL:[NSURL URLWithString:substringForMatch] withRange:match.range];
        }
        
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        bodyViewAddHight = 0;
    }
    
    //调整frame = 内容的frame高度
    CGFloat bodyHight = contentLabel.frame.size.height + bodyViewAddHight;
    self.bodyView = nil;
    self.bodyView = [[UIView alloc]initWithFrame:CGRectMake(_headView.frame.origin.x, _headView.bottom + 10, bodyViewWidth, bodyHight)];
    [self addSubview:self.bodyView];
    [self.bodyView addSubview:contentLabel];
    
    
}

-(void)setNewsBody {
    CGFloat bodyViewWidth = _window_width - 30;
    CGFloat bodyViewAddHight = 0;
    BOOL showMoreBtn = NO;
    
    NSString *content = minstr([_infoDic valueForKey:@"title"]);
    
    TTTAttributedLabel * contentLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, bodyViewWidth, 0)];
    contentLabel.numberOfLines = kNumberOfLines;
    contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    contentLabel.delegate = self;
    
    if (content != nil && content.length > 0 ) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.maximumLineHeight = 18.0f;
        paragraphStyle.minimumLineHeight = 16.0f;
        paragraphStyle.firstLineHeadIndent = 0.0f;
        paragraphStyle.lineSpacing = 6.0f;
        paragraphStyle.firstLineHeadIndent = 0.0f;
        paragraphStyle.headIndent = 0.0f;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        //
        UIFont *font = [UIFont systemFontOfSize:14];
        NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:RGB_COLOR(@"#323232", 1)};
        contentLabel.attributedText = [[NSAttributedString alloc]initWithString:content attributes:attributes];
        CGSize size = CGSizeMake(bodyViewWidth, 1000.0f);
        CGSize finalSize = [contentLabel sizeThatFits:size];
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        
        //利用富文本实现URL的点击事件http://blog.csdn.net/liyunxiangrxm/article/details/53410919
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLabel.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:YES],
                                        (NSString*)kCTForegroundColorAttributeName : (id)[[UIColor blueColor] CGColor]};
        
        contentLabel.highlightedTextColor = [UIColor whiteColor];
        contentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        // end modify by huangyibiao
        
        // reasion: handle links in chat content, ananylizing each link
        // 提取出文本中的超链接
        NSError *error;
        NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray *arrayOfAllMatches = [regex matchesInString:content
                                                    options:0
                                                      range:NSMakeRange(0, [content length])];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:content];
        for (NSTextCheckingResult *match in arrayOfAllMatches) {
            NSString *substringForMatch = [content substringWithRange:match.range];
            [attribute addAttribute:(NSString *)kCTFontAttributeName value:(id)contentLabel.font range:match.range];
            [attribute addAttribute:(NSString*)kCTForegroundColorAttributeName
                              value:(id)[[UIColor blueColor] CGColor]
                              range:match.range];
            [contentLabel addLinkToURL:[NSURL URLWithString:substringForMatch] withRange:match.range];
        }
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        bodyViewAddHight = 0;
        
    }
    
    if (_imgArray == nil) {
        _imgArray = [[NSMutableArray alloc]init];
    }
    [_imgArray removeAllObjects];
    [_imgArray addObjectsFromArray:[_infoDic valueForKey:@"thumbs"]];
    
    if (_imgViewArray == nil) {
        _imgViewArray = [[NSMutableArray alloc]init];
    }
    [_imgViewArray removeAllObjects];
    
    CGFloat fromY = contentLabel == nil?0:contentLabel.frame.size.height+10;
    if (showMoreBtn) {
        fromY += bodyViewAddHight;
    }
    if ([_imgArray count] == 1) {
        
        //CGFloat picW = bodyViewWidth/7*3;
        CGFloat picW = (bodyViewWidth - 2 * kPicDiv)/3;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, fromY, picW, picW)];
        imageView.tag = 0;
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:_imgArray[0]]];
        
        [_imgViewArray addObject:imageView];
        
         UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPressImage:)];
         [imageView addGestureRecognizer:tapGesture];
//         UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
//         [imageView addGestureRecognizer:longTap];
        
        
    }else if([_imgArray count] == 2){
        CGFloat imgWidth = (bodyViewWidth - 2 * kPicDiv)/3;
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, fromY, imgWidth, imgWidth)];
        
        [imageView1 sd_setImageWithURL:[NSURL URLWithString:_imgArray[0]]];
        
        //[imageView1 sd_setImageWithURL:[NSURL URLWithString:item[@"FileUrl"]]];
        imageView1.tag = 0;
        imageView1.userInteractionEnabled = YES;
        
         UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPressImage:)];
         [imageView1 addGestureRecognizer:tapGesture];
//         UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
//         [imageView1 addGestureRecognizer:longTap];
        
        [_imgViewArray addObject:imageView1];
        
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(imgWidth+kPicDiv,fromY, imgWidth, imgWidth)];
        [imageView2 sd_setImageWithURL:[NSURL URLWithString:_imgArray[1]]];
        
        //[imageView2 sd_setImageWithURL:[NSURL URLWithString:item[@"FileUrl"]]];
        [_imgViewArray addObject:imageView2];
        imageView2.userInteractionEnabled = YES;
        
         UITapGestureRecognizer*tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPressImage:)];
         [imageView2 addGestureRecognizer:tapGesture2];
//         UILongPressGestureRecognizer *longTap2 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
//         [imageView2 addGestureRecognizer:longTap2];
        
        imageView2.tag = 1;
    }else if([_imgArray count] == 4){
        CGFloat imgWidth = (bodyViewWidth - 2 * kPicDiv)/3;
        for (int i=0; i<[_imgArray count]; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((i%2)*(imgWidth+kPicDiv), (i/2)*(imgWidth+kPicDiv) + fromY, imgWidth, imgWidth)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:_imgArray[i]]];
            imageView.backgroundColor = [UIColor redColor];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            [_imgViewArray addObject:imageView];
            
             UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPressImage:)];
             [imageView addGestureRecognizer:tapGesture];
//             UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
//             [imageView addGestureRecognizer:longTap];
            
        }
    }
    else{
        CGFloat imgWidth = (bodyViewWidth - 2 * kPicDiv)/3;
        for (int i=0; i<[_imgArray count]; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((i%3)*(imgWidth+kPicDiv), (i/3)*(imgWidth+kPicDiv) + fromY, imgWidth, imgWidth)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:_imgArray[i]]];
            
            //[imageView sd_setImageWithURL:[NSURL URLWithString:item[@"FileUrl"]]];
            imageView.tag = i;
            [_imgViewArray addObject:imageView];
            imageView.userInteractionEnabled = YES;
            
             UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPressImage:)];
             [imageView addGestureRecognizer:tapGesture];
//             UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
//             [imageView addGestureRecognizer:longTap];
            
        }
    }
    
    UIImageView *lastView = [_imgViewArray objectAtIndex:([_imgViewArray count]-1) ];
    CGFloat bodyHight = lastView.frame.size.height + lastView.frame.origin.y;
    if (showMoreBtn) {
        bodyHight += bodyViewAddHight;
    }
    
    self.bodyView = nil;
    self.bodyView = [[UIView alloc]initWithFrame:CGRectMake(_headView.left, _headView.bottom + 10, bodyViewWidth, bodyHight)];
    [self addSubview:self.bodyView];
    if(contentLabel != nil){
        [self.bodyView addSubview:contentLabel];
    }
    for (UIImageView *iv in _imgViewArray) {
        [self.bodyView addSubview:iv];
    }
    
}
- (void)onPressImage:(UITapGestureRecognizer *)sender{
    
    UIImageView *imageview = (UIImageView *)sender.view;
    if (_delegate && [_delegate respondsToSelector:@selector(clickImgTap:)]) {
        [_delegate clickImgTap:(int)imageview.tag];
    }
    
}



-(void)setVideoBody {
    CGFloat bodyViewWidth = _window_width - 30;
    CGFloat bodyViewAddHight = 0;
    BOOL showMoreBtn = NO;
    
    NSString *content = minstr([_infoDic valueForKey:@"title"]);
    
    TTTAttributedLabel * contentLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, bodyViewWidth, 0)];
    contentLabel.numberOfLines = kNumberOfLines;
    contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    contentLabel.delegate = self;
    
    if (content != nil && content.length > 0 ) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.maximumLineHeight = 18.0f;
        paragraphStyle.minimumLineHeight = 16.0f;
        paragraphStyle.firstLineHeadIndent = 0.0f;
        paragraphStyle.lineSpacing = 6.0f;
        paragraphStyle.firstLineHeadIndent = 0.0f;
        paragraphStyle.headIndent = 0.0f;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        //
        UIFont *font = [UIFont systemFontOfSize:14];
        NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:RGB_COLOR(@"#323232", 1)};
        contentLabel.attributedText = [[NSAttributedString alloc]initWithString:content attributes:attributes];
        CGSize size = CGSizeMake(bodyViewWidth, 1000.0f);
        CGSize finalSize = [contentLabel sizeThatFits:size];
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        
        //利用富文本实现URL的点击事件http://blog.csdn.net/liyunxiangrxm/article/details/53410919
        contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        contentLabel.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:YES],
                                        (NSString*)kCTForegroundColorAttributeName : (id)[[UIColor blueColor] CGColor]};
        
        contentLabel.highlightedTextColor = [UIColor whiteColor];
        contentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        // end modify by huangyibiao
        
        // reasion: handle links in chat content, ananylizing each link
        // 提取出文本中的超链接
        NSError *error;
        NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray *arrayOfAllMatches = [regex matchesInString:content
                                                    options:0
                                                      range:NSMakeRange(0, [content length])];
        NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:content];
        for (NSTextCheckingResult *match in arrayOfAllMatches) {
            NSString *substringForMatch = [content substringWithRange:match.range];
            [attribute addAttribute:(NSString *)kCTFontAttributeName value:(id)contentLabel.font range:match.range];
            [attribute addAttribute:(NSString*)kCTForegroundColorAttributeName
                              value:(id)[[UIColor blueColor] CGColor]
                              range:match.range];
            [contentLabel addLinkToURL:[NSURL URLWithString:substringForMatch] withRange:match.range];
        }
        
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        bodyViewAddHight = 0;
        
    }
    
    CGFloat fromY = contentLabel == nil?0:contentLabel.frame.size.height+10;
    if (showMoreBtn) {
        fromY += bodyViewAddHight;
    }
    
    
    
    UIImageView *videoImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, fromY, _window_width/2.8, _window_width/2.8*16/9)];
    videoImg.contentMode = UIViewContentModeScaleAspectFill;
    videoImg.clipsToBounds = YES;
    [videoImg sd_setImageWithURL:[NSURL URLWithString:minstr([_infoDic valueForKey:@"video_thumb"])]];
    videoImg.userInteractionEnabled = YES;
    videoImg.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *videoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clcikVideoTap)];
    [videoImg addGestureRecognizer:videoTap];
    
    _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_pauseBtn addTarget:self action:@selector(clcikVideoTap) forControlEvents:UIControlEventTouchUpInside];
    [_pauseBtn setImage:[UIImage imageNamed:@"icon_video_play"] forState:0];
    [videoImg addSubview:_pauseBtn];
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.centerX.centerY.equalTo(videoImg);
    }];
    
    CGFloat bodyHight = videoImg.frame.size.height + videoImg.frame.origin.y;
    if (showMoreBtn) {
        bodyHight += bodyViewAddHight;
    }
    
    self.bodyView = nil;
    self.bodyView = [[UIView alloc]initWithFrame:CGRectMake(_headView.left, _headView.bottom + 10, bodyViewWidth, bodyHight)];
    [self addSubview:self.bodyView];
    [self.bodyView addSubview:videoImg];
//    [backview addSubview:videoImg];
    if(contentLabel != nil){
        [self.bodyView addSubview:contentLabel];
    }
    
    
    [self layoutIfNeeded];
    [self playVideo:videoImg];
    
    
}
-(void)playVideo:(UIImageView *)containView{
    NSString *videoUrl = minstr([_infoDic valueForKey:@"href"]);
    if (!_livePlayer) {
        _livePlayer  = [[TXLivePlayer alloc] init];
        _livePlayer.delegate = self;
    }
    [_livePlayer setupVideoWidget:CGRectZero containView:containView insertIndex:0];
    [_livePlayer startPlay:videoUrl type:PLAY_TYPE_LOCAL_VIDEO];
//    [_livePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
//    [_livePlayer setRenderRotation:HOME_ORIENTATION_DOWN];

    _pauseBtn.hidden = YES;
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
-(void)clcikVideoTap {
    if (_delegate && [_delegate respondsToSelector:@selector(clickVideoTap:)]) {
        [_livePlayer pause];
        [_delegate clickVideoTap:minstr([_infoDic valueForKey:@"href"])];
    }
    //rank 点击暂停
//    if (_livePlayer.isPlaying) {
//        [_livePlayer pause];
//        _pauseBtn.hidden = NO;
//
//    }else {
//        [_livePlayer resume];
//        _pauseBtn.hidden = YES;
//    }
}

-(void)voiceClick{
    NSLog(@"--------------音频-----");
    NSLog(@"--------:::%@",minstr([_infoDic valueForKey:@"voice"]));
    NSString *timeStr=minstr([_infoDic valueForKey:@"length"]);
    
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
            //        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:model.voiceUrl]];
            //        [_voicePlayer replaceCurrentItemWithPlayerItem:item];
        }else{
            
        }
        
        
        NSURL * url  = [NSURL URLWithString:minstr([_infoDic valueForKey:@"voice"])];
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
            weakSelf.voiceTime.text =[NSString stringWithFormat:@"%.0f\"",(floattotal-floatcurrent) > 0 ? (floattotal-floatcurrent) : 0];
            
        }];
        
        [_voicePlayer play];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
        
    }else{
        if (_voicePlayer) {
            [_voicePlayer pause];
            _audioBackImg.hidden = NO;
            _animationView.hidden = YES;

        }
    }

    
}

- (void)playFinished:(NSNotification *)not{
    
    _isPlaying = NO;
    _audioBackImg.hidden = NO;
    _animationView.hidden = YES;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
    [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
    [_voicePlayer removeObserver:self forKeyPath:@"status"];
    [_voicePlayer pause];
    _voicePlayer = nil;
    
    _voiceTime.text = [NSString stringWithFormat:@"%@\"",minstr([_infoDic valueForKey:@"length"])];
    
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
                _audioBackImg.hidden = NO;
                _animationView.hidden = YES;
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"----播放----------");
                _isPlaying = YES;
                isSounding = YES;
                _audioBackImg.hidden = YES;
                _animationView.hidden = NO;
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                [MBProgressHUD showError:@"播放失败"];
                _isPlaying = NO;
                _audioBackImg.hidden = NO;
                _animationView.hidden = YES;
            }
                break;
        }
        
    }
    
}

-(void)stopVideoPlay{
    if (_livePlayer) {
        [_livePlayer stopPlay];
        _livePlayer = nil;
    }
}


-(void)setZanReplyBar {
    _zanBarView =  [[UIView alloc]initWithFrame:CGRectMake(15, _bodyView.bottom+10, _window_width-30, 50)];
    [self addSubview:_zanBarView];
    
    //赞
    _njZanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_njZanBtn setImage:[UIImage imageNamed:@"trends点赞灰"] forState:0];
    if ([[_infoDic valueForKey:@"islike"] isEqual:@"1"]) {
        [_njZanBtn setImage:[UIImage imageNamed:@"trends点赞亮"] forState:0];
    }
    [_njZanBtn addTarget:self action:@selector(cellZanBtn) forControlEvents:UIControlEventTouchUpInside];
    [_njZanBtn setTitle:minstr([_infoDic valueForKey:@"islike"]) forState:0];
    _njZanBtn.titleLabel.font = SYS_Font(13);
    [_njZanBtn setTitleColor:[UIColor lightGrayColor] forState:0];
    _njZanBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [_zanBarView addSubview:_njZanBtn];
    [_njZanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_zanBarView.mas_left);
        make.top.equalTo(_zanBarView.mas_top).offset(3);
        make.height.equalTo(@40);
        //make.width.greaterThanOrEqualTo(@50);
    }];
    
    //评论
    _njCommentBnt = [UIButton buttonWithType:UIButtonTypeCustom];
    [_njCommentBnt setImage:[UIImage imageNamed:@"trends评论"] forState:0];
    [_njCommentBnt addTarget:self action:@selector(cellCommentsBtn) forControlEvents:UIControlEventTouchUpInside];
    [_njCommentBnt setTitle:minstr([_infoDic valueForKey:@"comments"]) forState:0];
    _njCommentBnt.titleLabel.font = _njZanBtn.titleLabel.font;
    [_njCommentBnt setTitleColor:[UIColor lightGrayColor] forState:0];
    _njCommentBnt.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [_zanBarView addSubview:_njCommentBnt];
    [_njCommentBnt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_njZanBtn.mas_right).offset(20);
        make.centerY.equalTo(_njZanBtn);
        make.height.equalTo(_njZanBtn);
    }];
}

-(void)setFootView {
    _footView = [[UIView alloc]initWithFrame:CGRectMake(0, _zanBarView.bottom, _window_width, 40)];
    _footView.backgroundColor = RGB_COLOR(@"#ffffff", 1);
    [self addSubview:_footView];
    
    [[YBToolClass sharedInstance]lineViewWithFrame:CGRectMake(0, 0, _window_width, 1) andColor:RGB_COLOR(@"#f5f5f5", 1) andView:_footView];
    
    _footerAllComNum = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, _window_width, 20)];
    _footerAllComNum.text = [NSString stringWithFormat:@"全部评论"];
    _footerAllComNum.textColor = RGB_COLOR(@"#323232", 1);
    _footerAllComNum.font = SYS_Font(15);
    [_footView addSubview:_footerAllComNum];
    
    _allHeight = CGRectGetMaxY(_footView.frame);
    
    if (_delegate && [_delegate respondsToSelector:@selector(updateTabHeader)]) {
        [_delegate updateTabHeader];
    }
}

-(void)cellCommentsBtn {
    if (_delegate && [_delegate respondsToSelector:@selector(onClickNJCommentsBtn)]) {
        [_delegate onClickNJCommentsBtn];
    }
}
-(void)cellZanBtn {
    //动态点赞

    NSDictionary *singDic = @{
                              @"uid":[Config getOwnID],
                              @"dynamicid":[_infoDic valueForKey:@"id"]
                              };
    NSString *sign = [YBToolClass sortString:singDic];
    
    NSDictionary *parameterDic = @{
                                   @"uid":[Config getOwnID],
                                   @"token":[Config getOwnToken],
                                   @"dynamicid":[_infoDic valueForKey:@"id"],
                                   @"sign":sign
                                   };

    [YBToolClass postNetworkWithUrl:@"Dynamic.addLike" andParameter:parameterDic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:msg];
        if (code == 0) {
            NSDictionary *zanInfoDic = [info firstObject];
            _isLikeStr = minstr([zanInfoDic valueForKey:@"islike"]);
            _likesStr = minstr([zanInfoDic valueForKey:@"nums"]);
            [_njZanBtn setTitle:_likesStr forState:0];
            if ([_isLikeStr isEqual:@"1"]) {
                [_njZanBtn setImage:[UIImage imageNamed:@"trends点赞亮"] forState:0];
            }else {
                [_njZanBtn setImage:[UIImage imageNamed:@"trends点赞灰"] forState:0];
            }
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

-(CGFloat)getTableHeaderHeight {
    
    return _allHeight;
}
-(NSString *)getIsLikeState {
    return _isLikeStr;
}
-(NSString *)getLikesNum {
    return _likesStr;
}
-(void)updataComments:(NSString *)comments {
    _commentStr = comments;
    _footerAllComNum.text = [NSString stringWithFormat:@"全部评论"];
    [_njCommentBnt setTitle:_commentStr forState:0];
}

-(NSString *)getCommentsNum {
    
    return _commentStr;
}
-(void)pauseVideo{
    if (_livePlayer) {
//        [_livePlayer pause];
        [_livePlayer setMute:YES];
    }
    if (_voicePlayer) {
        [_voicePlayer pause];
        _audioBackImg.hidden = NO;
        _animationView.hidden = YES;
    }

}
-(void)resumeVideo{
    if (_livePlayer) {
//        [_livePlayer resume];
        [_livePlayer setMute:NO];

    }
}

-(void)removeAll{
    if (_livePlayer) {
        [_livePlayer stopPlay];
        _livePlayer = nil;
    }
    if (_voicePlayer) {
        _isPlaying = NO;
        _audioBackImg.hidden = NO;
        _animationView.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
        [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
        [_voicePlayer removeObserver:self forKeyPath:@"status"];
        [_voicePlayer pause];
        _voicePlayer = nil;
    }

}
@end
