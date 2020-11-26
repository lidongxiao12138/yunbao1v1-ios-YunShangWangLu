//
//  CommunityCell.m
//  CircleOfFriendsDisplay
//
//  Created by 李云祥 on 16/9/22.
//  Copyright © 2016年 李云祥. All rights reserved.
//

#import "CommunityCell.h"
#import "TTTAttributedLabel.h"
#import "Masonry.h"
#import "PicSelView.h"
#import "ImageBrowserViewController.h"
#import "XHSoundRecorder.h"
#import "FSAudioStream.h"
#define kPicDiv 4.0f
#define kNumberOfLines 5.0

@interface CommunityCell()<TTTAttributedLabelDelegate,TXLivePlayListener>{
    
    BOOL voiceIsPlaying;
}
@property (strong,nonatomic) UIButton * moreBtn;
@property (strong,nonatomic)FSAudioStream *audioStream;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,strong) UILabel *audioTimelb;
//监听播放起状态的监听者
@property (nonatomic ,strong) id playbackTimeObserver;

@end
@implementation CommunityCell

-(void)setData:(CommunityItem *)data {
    _data = data;
    for(UIView *view in [self.contentView subviews])
    {
        [view removeFromSuperview];
    }
    [self setHeadView];
    [self setBodyView];
    [self setZanReplyBar];
    [self setFootView];

}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.bounds = [UIScreen mainScreen].bounds;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopVideoAndVoice) name:@"stopAllSound" object:nil];
    }
    return self;
}
-(void)setHeadView {
    _headView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 40, 40)];
    [_headView sd_setImageWithURL:[NSURL URLWithString:minstr([_data.userInfoDic valueForKey:@"avatar"])]];
    [self.contentView addSubview:_headView];
    
    CALayer *layer=[_headView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:40 / 2.0];
    [layer setBorderWidth:1];
    [layer setBorderColor:[[UIColor clearColor] CGColor]];
    
    //名称
    UILabel *titleL = [[UILabel alloc]init];
    titleL.font = SYS_Font(16);
    titleL.textColor = RGB_COLOR(@"#323232", 1);
    titleL.text = minstr([_data.userInfoDic valueForKey:@"user_nickname"]);
    [self.contentView addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headView.mas_right).offset(8);
//        make.centerY.equalTo(_headView);
        make.top.mas_equalTo(_headView.mas_top);
    }];
    
    
    
    UIImageView *sexImg = [[UIImageView alloc]init];
    NSString *sexStr =minstr([_data.userInfoDic valueForKey:@"sex"]);
    if ([sexStr isEqual:@"2"]) {
        sexImg.image = [UIImage imageNamed:@"person_性别女"];
    }else if([sexStr isEqual:@"1"]){
        sexImg.image = [UIImage imageNamed:@"person_性别男"];

    }
    [self.contentView addSubview:sexImg];
    [sexImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleL.mas_right).offset(5);
        make.width.height.mas_equalTo(15);
        make.top.equalTo(titleL.mas_top);
    }];
    
    UIImageView *addressImg = [[UIImageView alloc]init];
    addressImg.image = [UIImage imageNamed:@"trends定位"];
    [self.contentView addSubview:addressImg];
    [addressImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headView.mas_right).offset(8);
        make.top.equalTo(titleL.mas_bottom).offset(8);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(14);
    }];
    
    UILabel *addressLb = [[UILabel alloc]init];
    addressLb.font = SYS_Font(12);
    addressLb.textColor = RGBA(150, 150, 150, 1);
    addressLb.text = minstr(_data.city);
    [self.contentView addSubview:addressLb];
    [addressLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(addressImg);
        make.left.equalTo(addressImg.mas_right).offset(5);
    }];
    
    UILabel *lineLb = [[UILabel alloc]init];
    lineLb.backgroundColor =RGBA(200, 200, 200, 1);
    [self.contentView addSubview:lineLb];
    [lineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addressLb.mas_right).offset(8);
        make.top.equalTo(addressImg.mas_top);
        make.bottom.equalTo(addressImg.mas_bottom);
        make.width.mas_equalTo(1.5);
    }];
    
    UILabel *sendTime = [[UILabel alloc]init];
    sendTime.text = _data.timeStr;
    sendTime.textColor = RGBA(150, 150, 150, 1);
    sendTime.font = SYS_Font(12);
    [self.contentView  addSubview:sendTime];
    [sendTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(addressImg);
        make.left.equalTo(lineLb.mas_right).offset(8);
    }];

    
    UIButton *moreBtn = [UIButton buttonWithType:0];
    moreBtn.frame = CGRectMake(_window_width-50, _headView.origin.y, 30, 20);
    [moreBtn setImage:[UIImage imageNamed:@"trends三圆点"] forState:0];
    [moreBtn addTarget:self action:@selector(cellDelBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:moreBtn];
    
    //去往个人中心
    UIButton *goCenter = [UIButton buttonWithType:0];
    [goCenter addTarget:self action:@selector(centerClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:goCenter];
    [goCenter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_headView.mas_left);
        make.right.equalTo(_headView.mas_right).offset(20);
        make.top.mas_equalTo(_headView.mas_top);
        make.bottom.equalTo(_headView.mas_bottom);
    }];

}

-(void)setBodyView {
    //0-文字  1-文字+图片  2-文字+视频
    NSString *communityType = _data.communityType;
    if ([communityType isEqual:@"2"]) {
        [self setVideoBody];
    }else if([communityType isEqual:@"1"]){
        [self setNewsBody];
    }else if([communityType isEqual:@"3"]){
        [self setAudioBody];
    }else{
        [self setTextBody];
    }
    /*
    NSArray *img_a = _data.imgs;
    if (img_a.count<=0) {
        [self setTextBody];
    }else {
        [self setNewsBody];
    }
     */
}

-(void)setAudioBody{
    CGFloat bodyViewWidth = _window_width - 30;
    CGFloat bodyViewAddHight = 0;
    BOOL showMoreBtn = NO;
    
    NSString *content = _data.titleStr;
    
    TTTAttributedLabel * contentLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(0, 5, bodyViewWidth, 0)];
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
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressText:)];
        [contentLabel addGestureRecognizer:longTap];
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
    videoImg.backgroundColor = normalColors;
    videoImg.image = [UIImage imageNamed:@"recordBackimge"];
    videoImg.userInteractionEnabled = YES;
    CGFloat bodyHight = videoImg.frame.size.height + videoImg.frame.origin.y;
    if (showMoreBtn) {
        bodyHight += bodyViewAddHight;
    }
    
    self.bodyView = nil;
    self.bodyView = [[UIView alloc]initWithFrame:CGRectMake(_headView.left, _headView.bottom + 10, bodyViewWidth, bodyHight)];
    [self.contentView addSubview:self.bodyView];
    [self.bodyView addSubview:videoImg];
    if(contentLabel != nil){
        [self.bodyView addSubview:contentLabel];
        if (showMoreBtn) {
            [self.bodyView addSubview:_moreBtn];
        }
    }
    UIButton *audioBtn = [UIButton buttonWithType:0];
    audioBtn.frame = CGRectMake(0, 0, videoImg.width, videoImg.height);
    [audioBtn addTarget:self action:@selector(audioBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [videoImg addSubview:audioBtn];
    
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

    _audioTimelb = [[UILabel alloc]init];
    _audioTimelb.font = [UIFont systemFontOfSize:12];
    _audioTimelb.textColor = [UIColor whiteColor];
    _audioTimelb.text =[NSString stringWithFormat:@"%@s",_data.length];
    [videoImg addSubview:_audioTimelb];
    [_audioTimelb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(videoImg);
        make.height.mas_equalTo(20);
        make.right.equalTo(audioBtn.mas_right);
        make.width.equalTo(videoImg).multipliedBy(0.2);
    }];
}
-(void)setTextBody {
    CGFloat bodyViewWidth = _window_width - 30;
    CGFloat bodyViewAddHight = 0;
    BOOL showMoreBtn = NO;
    
    NSString *content = _data.titleStr;
    
    TTTAttributedLabel * contentLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(0,5, bodyViewWidth, 0)];
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
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressText:)];
        [contentLabel addGestureRecognizer:longTap];
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        bodyViewAddHight = 0;
    }
    
    //调整frame = 内容的frame高度
    CGFloat bodyHight = contentLabel.frame.size.height + bodyViewAddHight;
    self.bodyView = nil;
    self.bodyView = [[UIView alloc]initWithFrame:CGRectMake(_headView.frame.origin.x, _headView.bottom + 10, bodyViewWidth, bodyHight)];
    [self.contentView addSubview:self.bodyView];
    [self.bodyView addSubview:contentLabel];
    if (showMoreBtn) {
        [self.bodyView addSubview:_moreBtn];
    }

}

-(void)setNewsBody {
    CGFloat bodyViewWidth = _window_width - 30;
    CGFloat bodyViewAddHight = 0;
    BOOL showMoreBtn = NO;
    
    NSString *content = _data.titleStr;
    
    TTTAttributedLabel * contentLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(0, 5, bodyViewWidth, 0)];
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
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressText:)];
        [contentLabel addGestureRecognizer:longTap];
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        bodyViewAddHight = 0;
        
    }
    
    if (_imgArray == nil) {
        _imgArray = [[NSMutableArray alloc]init];
    }
    [_imgArray removeAllObjects];
    [_imgArray addObjectsFromArray:_data.imgs];
    
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
        /*
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
        [imageView addGestureRecognizer:longTap];
         */
        
    }else if([_imgArray count] == 2){
//        CGFloat imgWidth = (bodyViewWidth - 2 * kPicDiv)/3;
        CGFloat picW = (bodyViewWidth - 2 * kPicDiv)/3;

        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, fromY, picW, picW)];
        [imageView1 sd_setImageWithURL:[NSURL URLWithString:_imgArray[0]]];
        imageView1.tag = 0;
        imageView1.userInteractionEnabled = YES;
        imageView1.contentMode = UIViewContentModeScaleAspectFill;
        imageView1.clipsToBounds = YES;
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPressImage:)];
        [imageView1 addGestureRecognizer:tapGesture];
        /*
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
        [imageView1 addGestureRecognizer:longTap];
        */
        [_imgViewArray addObject:imageView1];
        
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(picW+kPicDiv,fromY, picW, picW)];
        [imageView2 sd_setImageWithURL:[NSURL URLWithString:_imgArray[1]]];
        imageView2.contentMode = UIViewContentModeScaleAspectFill;
        imageView2.clipsToBounds = YES;

        [_imgViewArray addObject:imageView2];
        imageView2.userInteractionEnabled = YES;
        imageView2.tag = 1;

        UITapGestureRecognizer*tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPressImage:)];
        [imageView2 addGestureRecognizer:tapGesture2];
        /*
        UILongPressGestureRecognizer *longTap2 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
        [imageView2 addGestureRecognizer:longTap2];
        */
    }else if([_imgArray count] == 4){
//        CGFloat imgWidth = (bodyViewWidth - 2 * kPicDiv)/3;
        CGFloat picW = (bodyViewWidth - 2 * kPicDiv)/3;

        for (int i=0; i<[_imgArray count]; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((i%2)*(picW+kPicDiv), (i/2)*(picW+kPicDiv) + fromY, picW, picW)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:_imgArray[i]]];
            imageView.backgroundColor = [UIColor redColor];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            [_imgViewArray addObject:imageView];
           
            UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPressImage:)];
            [imageView addGestureRecognizer:tapGesture];
             /*
            UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
            [imageView addGestureRecognizer:longTap];
            */
        }
    }
    else{
//        CGFloat imgWidth = (bodyViewWidth - 2 * kPicDiv)/3;
        CGFloat picW = (bodyViewWidth - 2 * kPicDiv)/3;

        for (int i=0; i<[_imgArray count]; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((i%3)*(picW+kPicDiv), (i/3)*(picW+kPicDiv) + fromY, picW, picW)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:_imgArray[i]]];
            
            //[imageView sd_setImageWithURL:[NSURL URLWithString:item[@"FileUrl"]]];
            imageView.tag = i;
            [_imgViewArray addObject:imageView];
            imageView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onPressImage:)];
            [imageView addGestureRecognizer:tapGesture];
            /*
            UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImage:)];
            [imageView addGestureRecognizer:longTap];
            */
        }
    }
    
    UIImageView *lastView = [_imgViewArray objectAtIndex:([_imgViewArray count]-1) ];
    CGFloat bodyHight = lastView.frame.size.height + lastView.frame.origin.y;
    if (showMoreBtn) {
        bodyHight += bodyViewAddHight;
    }
    
    self.bodyView = nil;
    self.bodyView = [[UIView alloc]initWithFrame:CGRectMake(_headView.left, _headView.bottom + 10, bodyViewWidth, bodyHight)];
    [self.contentView addSubview:self.bodyView];
    if(contentLabel != nil){
        [self.bodyView addSubview:contentLabel];
        if (showMoreBtn) {
            [self.bodyView addSubview:_moreBtn];
        }
    }
    for (UIImageView *iv in _imgViewArray) {
        [self.bodyView addSubview:iv];
    }
    
}
-(void)setVideoBody {
    CGFloat bodyViewWidth = _window_width - 30;
    CGFloat bodyViewAddHight = 0;
    BOOL showMoreBtn = NO;
    
    NSString *content = _data.titleStr;
    
    TTTAttributedLabel * contentLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectMake(0, 5, bodyViewWidth, 0)];
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
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressText:)];
        [contentLabel addGestureRecognizer:longTap];
        contentLabel.frame = CGRectMake(0, 0, finalSize.width, finalSize.height);
        bodyViewAddHight = 0;
        
    }
    
    CGFloat fromY = contentLabel == nil?0:contentLabel.frame.size.height+10;
    if (showMoreBtn) {
        fromY += bodyViewAddHight;
    }
    if (_data.width == 0) {
        UIImage *videoThumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_data.video_thumb]]];
        _data.width = videoThumbImage.size.width;
        _data.height = videoThumbImage.size.height;
    }
    CGFloat imgWidth = _window_width/2.8;
    if (_data.width > _data.height) {
        imgWidth = (_window_width-30);
    }
    if (_data.width == 0) {
        _data.width = imgWidth;
        _data.height = imgWidth * 1.5;
    }
    UIImageView *videoImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, fromY, imgWidth, imgWidth/_data.width * _data.height)];

//    UIImageView *videoImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, fromY, _window_width/2.8, _window_width/2.8*16/9)];
    [videoImg sd_setImageWithURL:[NSURL URLWithString:minstr(_data.video_thumb)]];
    videoImg.userInteractionEnabled = YES;
    
    _pauseIV = [[UIImageView alloc]init];
    _pauseIV.image = [UIImage imageNamed:@"icon_video_play"];
    [videoImg addSubview:_pauseIV];
    [_pauseIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.centerX.centerY.equalTo(videoImg);
    }];
    
    UIButton *viodeBtn = [UIButton buttonWithType:0];
    viodeBtn.frame = CGRectMake(0, 0, videoImg.width, videoImg.height);
    [viodeBtn addTarget:self action:@selector(videoClick) forControlEvents:UIControlEventTouchUpInside];
    [videoImg addSubview:viodeBtn];
    CGFloat bodyHight = videoImg.frame.size.height + videoImg.frame.origin.y;
    if (showMoreBtn) {
        bodyHight += bodyViewAddHight;
    }
    
    self.bodyView = nil;
    self.bodyView = [[UIView alloc]initWithFrame:CGRectMake(_headView.left, _headView.bottom + 10, bodyViewWidth, bodyHight)];
    [self.contentView addSubview:self.bodyView];
    [self.bodyView addSubview:videoImg];
    if(contentLabel != nil){
        [self.bodyView addSubview:contentLabel];
        if (showMoreBtn) {
            [self.bodyView addSubview:_moreBtn];
        }
    }
    
    [self playVideo:videoImg];
}
-(void)playVideo:(UIImageView *)containView{
    if (!_txLivePlayer) {
        _txLivePlayer  = [[TXLivePlayer alloc] init];
        _txLivePlayer.delegate = self;
    }
    [_txLivePlayer setupVideoWidget:CGRectZero containView:containView insertIndex:0];
//    [_txLivePlayer setRenderMode:RENDER_MODE_FILL_EDGE];

}

- (void)showMore{
    if ([_moreBtn.titleLabel.text isEqualToString:@"全文"]) {
        if (_delegate && [_delegate respondsToSelector:@selector(onPressMoreBtnOnDynamicCell:)]) {
            //[_moreBtn setTitle:@"收起" forState:UIControlStateNormal];
            //_data.textOpenFlag = YES;
            [_delegate onPressMoreBtnOnDynamicCell:self];
        }
    }else if ([_moreBtn.titleLabel.text isEqualToString:@"收起"]){
        if (_delegate && [_delegate respondsToSelector:@selector(onPressMoreBtnOnDynamicCell:)]) {
            //[_moreBtn setTitle:@"更多" forState:UIControlStateNormal];
            //_data.textOpenFlag = NO;
            [_delegate onPressMoreBtnOnDynamicCell:self];
        }
    }
}

#pragma mark - TTTAttributedLabelDelegate 点击聊天内容中的超链接
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    //NSLog([NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil]);
    if (_delegate && [_delegate respondsToSelector:@selector(onPressShareUrlOnUrl:)]) {
        [_delegate onPressShareUrlOnUrl:url];
    }

}
- (void)longPressText:(UILongPressGestureRecognizer *)sender{
    NSLog(@"长按");
    if (sender.state == UIGestureRecognizerStateBegan){
        if (_delegate && [_delegate respondsToSelector:@selector(onLongPressText:onDynamicCell:)]) {
            TTTAttributedLabel *label = (TTTAttributedLabel *)sender.view;
            [_delegate onLongPressText:label.text onDynamicCell:self];
        }
    }
}
-(void)setZanReplyBar {
    _zanBarView =  [[UIView alloc]initWithFrame:CGRectMake(15, _bodyView.bottom+5, _window_width-30, 50)];
    [self.contentView addSubview:_zanBarView];
   
    
    //赞
    _njZanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([_data.isLikeStr isEqual:@"1"]) {
        [_njZanBtn setImage:[UIImage imageNamed:@"trends点赞亮"] forState:0];
    }else{
        [_njZanBtn setImage:[UIImage imageNamed:@"trends点赞灰"] forState:0];
    }
    [_njZanBtn addTarget:self action:@selector(cellZanBtn) forControlEvents:UIControlEventTouchUpInside];
    [_njZanBtn setTitle:_data.likesStr forState:0];
    _njZanBtn.titleLabel.font = SYS_Font(13);
    [_njZanBtn setTitleColor:[UIColor lightGrayColor] forState:0];
    _njZanBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [_zanBarView addSubview:_njZanBtn];
    [_njZanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_zanBarView.mas_left);
//        make.top.equalTo(sendTime.mas_bottom).offset(0);
        make.top.equalTo(_zanBarView.mas_top).offset(3);

        make.height.equalTo(@40);
        //make.width.greaterThanOrEqualTo(@50);
    }];
    
    //评论
    _njCommentBnt = [UIButton buttonWithType:UIButtonTypeCustom];
    [_njCommentBnt setImage:[UIImage imageNamed:@"trends评论"] forState:0];
    [_njCommentBnt addTarget:self action:@selector(cellCommentsBtn) forControlEvents:UIControlEventTouchUpInside];
    [_njCommentBnt setTitle:_data.commentStr forState:0];
    _njCommentBnt.titleLabel.font = _njZanBtn.titleLabel.font;
    [_njCommentBnt setTitleColor:[UIColor lightGrayColor] forState:0];
    _njCommentBnt.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [_zanBarView addSubview:_njCommentBnt];
    [_njCommentBnt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_njZanBtn.mas_right).offset(20);
        make.centerY.equalTo(_njZanBtn);
        make.height.equalTo(_njZanBtn);
    }];
    
    //删除
    _njDelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_njDelBtn setImage:[UIImage imageNamed:@"社区-删除"] forState:0];
    [_njDelBtn addTarget:self action:@selector(cellDelBtn) forControlEvents:UIControlEventTouchUpInside];
    [_zanBarView addSubview:_njDelBtn];
    [_njDelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_zanBarView.mas_right);
        make.centerY.equalTo(_njZanBtn);
        make.height.equalTo(_njZanBtn);
    }];
    _njDelBtn.hidden = YES;
    if ([_data.uidStr isEqual:[Config getOwnID]]) {
         _njDelBtn.hidden = NO;
    }
    
}
-(void)cellDelBtn {
    //删除
    WeakSelf;
    if ([_data.uidStr isEqual:[Config getOwnID]]) {

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
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onClickReportBtn:)]) {
                [weakSelf.delegate onClickReportBtn:_njIndex];
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
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onClickNJDelBtn:)]) {
            [weakSelf.delegate onClickNJDelBtn:_njIndex];
        }
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



-(void)cellHitsBtn {
    //
}

-(void)cellCommentsBtn {
    if (_delegate && [_delegate respondsToSelector:@selector(onClickNJCommentsBtn:)]) {
        [_delegate onClickNJCommentsBtn:_njIndex];
    }
}
-(void)cellZanBtn {
    if (_delegate && [_delegate respondsToSelector:@selector(onClickNJZanBtn:)]) {
        [_delegate onClickNJZanBtn:_njIndex];
    }
}

-(void)setFootView {
    _footView = [[UIView alloc]initWithFrame:CGRectMake(0, _zanBarView.bottom, _window_width, 1)];
    _footView.backgroundColor = RGB_COLOR(@"#f5f5f5", 1);
    [self.contentView addSubview:_footView];
}
- (void)onPressZan:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(onPressZanBtnOnDynamicCell:)]) {
        [_delegate onPressZanBtnOnDynamicCell:self];
    }
}
- (void)onPressDelete:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(onPressDeleteBtnOnDynamicCell:)]) {
        [_delegate onPressDeleteBtnOnDynamicCell:self];
    }
}
- (void)onPressReply:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(onPressReplyBtnOnDynamicCell:)]) {
        [_delegate onPressReplyBtnOnDynamicCell:self];
    }
}
- (void)onPressImage:(UITapGestureRecognizer *)sender{

    UIImageView *imageview = (UIImageView *)sender.view;
    NSInteger index = imageview.tag;

    if (_delegate && [_delegate respondsToSelector:@selector(onTapImage:AtIndex:)]) {
        
//        [_delegate onPressImageView:imageview onDynamicCell:self];
        [self.delegate onTapImage:_imgArray AtIndex:index];
    }
    
}

-(void)centerClick{
    if (_delegate && [_delegate respondsToSelector:@selector(onCenterClick:)]) {
        [self.delegate onCenterClick:minstr(_data.uidStr)];
    }

}
-(void)audioBtnClick{
    NSLog(@"--------------音频-----");
    NSLog(@"--------:::%@",_data.voice);
    
    if (_delegate && [_delegate respondsToSelector:@selector(onClickVoiceOnDynamicCell:)]) {
        [self.delegate onClickVoiceOnDynamicCell:self];
    }

    NSString *timeStr=_data.length;;

    int floattotal = [timeStr intValue];

    _isSounding = !_isSounding;
    if (_isSounding) {
        _isPlaying = NO;
        if (_voicePlayer) {

            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
            [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
            [_voicePlayer removeObserver:self forKeyPath:@"status"];
            [_voicePlayer pause];
            _voicePlayer = nil;
        }else{
            
        }
        NSURL * url  = [NSURL URLWithString:_data.voice];
        
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
            weakSelf.audioTimelb.text =[NSString stringWithFormat:@"%.0fs",(floattotal-floatcurrent) > 0 ? (floattotal-floatcurrent) : 0];
            
        }];

        [_voicePlayer play];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];

    }else{
        _audioBackImg.hidden = NO;
        _animationView.hidden = YES;
        if (_voicePlayer) {
            [_voicePlayer pause];
        }
    }

}
- (void)playFinished:(NSNotification *)not{
    
    _isPlaying = NO;
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_voicePlayer.currentItem];
//    [_voicePlayer removeTimeObserver:self.playbackTimeObserver];
//    [_voicePlayer removeObserver:self forKeyPath:@"status"];
//    [_voicePlayer pause];
//    _voicePlayer = nil;
    
    _animationView.hidden = YES;
    _audioTimelb.text = [NSString stringWithFormat:@"%@s",_data.length];
    _audioBackImg.hidden = NO;

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
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"----播放----------");
                _isPlaying = YES;
                _audioBackImg.hidden = YES;
                _animationView.hidden = NO;
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                [MBProgressHUD showError:@"播放失败"];
                _isPlaying = NO;
            }
                break;
        }
    }
}
#pragma mark ------点击视频----------
-(void)videoClick{
    if (_delegate && [_delegate respondsToSelector:@selector(onVideoClickWithUrl:)]) {
        [self.delegate onVideoClickWithUrl:minstr(_data.hrefStr)];
    }
}
- (void)longPressImage:(UILongPressGestureRecognizer *)sender{
    UIImageView *imageView = (UIImageView *)sender.view;
    if (sender.state == UIGestureRecognizerStateBegan){
        if (_delegate && [_delegate respondsToSelector:@selector(onLongPressImageView:onDynamicCell:)]) {
            [_delegate onLongPressImageView:imageView onDynamicCell:self];
        }
    }
}
- (CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(_window_width, _footView.bottom);
}

#pragma mark TXLivePlayListener
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_PLAY_END) {
            [_txLivePlayer resume];
            _isPlayingVideo= NO;
            return;
        }else if (EvtID == PLAY_EVT_PLAY_BEGIN){
            _isPlayingVideo= YES;
        }

    });
    
}
-(void) onNetStatus:(NSDictionary*) param {
    
}
-(void)playVideoPath{
    [_txLivePlayer startPlay: minstr(_data.hrefStr) type:PLAY_TYPE_LOCAL_VIDEO];
}
-(void)pauseVideo{

    [_txLivePlayer pause];
    if (_voicePlayer) {
        [_voicePlayer pause];
        _audioBackImg.hidden = NO;
        _animationView.hidden = YES;

    }
}
-(void)resumeVide{
   [_txLivePlayer resume];
}
-(void)stopVideoAndVoice{
    if (_txLivePlayer) {
        [_txLivePlayer pause];
//        _txLivePlayer = nil;
    }
    if (_voicePlayer) {
        [_voicePlayer pause];
//        _voicePlayer = nil;
        _audioBackImg.hidden = NO;
        _animationView.hidden = YES;
        

    }
}

-(void)playVoice:(BOOL)isVioce{
    if (isVioce) {
        if (_txLivePlayer) {
            [_txLivePlayer pause];
        }
    }else{
        if (_voicePlayer) {
            [_voicePlayer pause];
            _voicePlayer = nil;
            _audioBackImg.hidden = NO;
            _animationView.hidden = YES;
        }
    }
    
}
@end
