//
//  TConversationCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/14.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TConversationCell.h"
#import "THeader.h"

@implementation TConversationCellData
@end

@interface TConversationCell ()
@property (nonatomic, strong) TConversationCellData *data;
@end

@implementation TConversationCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

+ (CGSize)getSize;
{
    return CGSizeMake(Screen_Width, TConversationCell_Height);
}

- (void)setData:(TConversationCellData *)data
{
    _data = data;
    if (_data.userHeader) {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:_data.userHeader]];
    }else{
        _headImageView.image = [UIImage imageNamed:_data.head];
    }
    if ([_data.isVIP isEqual:@"1"]) {
        _vipImageView.hidden = NO;
    }else{
        _vipImageView.hidden = YES;
    }
    _timeLabel.text = _data.time;
//    _titleLabel.text = _data.title;
    _titleLabel.text = _data.userName;
    _subTitleLabel.text = _data.subTitle;
    [_unReadView setNum:_data.unRead];
    [self defaultLayout];
}

- (void)setupViews
{
    self.backgroundColor = [UIColor whiteColor];
    
    _headImageView = [[UIImageView alloc] init];
    _headImageView.backgroundColor = self.backgroundColor;
    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = 25;
    [self addSubview:_headImageView];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor lightGrayColor];
    _timeLabel.backgroundColor = self.backgroundColor;
    _timeLabel.layer.masksToBounds = YES;
    [self addSubview:_timeLabel];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.backgroundColor = self.backgroundColor;
    _titleLabel.layer.masksToBounds = YES;
    [self addSubview:_titleLabel];
    
    
    _vipImageView = [[UIImageView alloc] init];
    _vipImageView.image = [UIImage imageNamed:@"vip"];
    [self addSubview:_vipImageView];

    _unReadView = [[TUnReadView alloc] init];
    [self addSubview:_unReadView];

    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.backgroundColor = self.backgroundColor;
    _subTitleLabel.layer.masksToBounds = YES;
    _subTitleLabel.font = [UIFont systemFontOfSize:14];
    _subTitleLabel.textColor = [UIColor lightGrayColor];
    [self addSubview:_subTitleLabel];
    _rightImageView = [[UIImageView alloc] init];
    _rightImageView.image = [UIImage imageNamed:@"right_arrow"];
    [self addSubview:_rightImageView];

    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, TConversationCell_Height-1, _window_width, 1) andColor:colorf5 andView:self];
    [self setSeparatorInset:UIEdgeInsetsMake(0, TConversationCell_Margin, 0, 0)];
}

- (void)defaultLayout
{
    CGSize size = [TConversationCell getSize];
    _headImageView.frame = CGRectMake(TConversationCell_Margin, TConversationCell_Margin, size.height - TConversationCell_Margin * 2, size.height - TConversationCell_Margin * 2);
    if ([_data.title isEqual:@"预约"]) {
        _rightImageView.frame = CGRectMake(size.width-25, 25, 20, 20);
    }else{
        _rightImageView.frame = CGRectZero;
    }
    [_timeLabel sizeToFit];
    _timeLabel.frame = CGRectMake(size.width - TConversationCell_Margin - _timeLabel.frame.size.width, TConversationCell_Margin_Text, _timeLabel.frame.size.width, _timeLabel.frame.size.height);

    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake(_headImageView.frame.origin.x + _headImageView.frame.size.width + TConversationCell_Margin, TConversationCell_Margin_Text, size.width - _timeLabel.frame.size.width - _headImageView.frame.size.width - 4 * TConversationCell_Margin, _titleLabel.frame.size.height);
    CGFloat wwwwwww = [[YBToolClass sharedInstance] widthOfString:_data.userName andFont:SYS_Font(16) andHeight:20];
    _vipImageView.frame = CGRectMake(_titleLabel.x + wwwwwww + 3, TConversationCell_Margin_Text + 2, 25, 15);

    _unReadView.frame = CGRectMake(size.width - TConversationCell_Margin - _unReadView.frame.size.width, size.height - TConversationCell_Margin_Text - _unReadView.frame.size.height, _unReadView.frame.size.width, _unReadView.frame.size.height);
    
    [_subTitleLabel sizeToFit];
    _subTitleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, size.height - TConversationCell_Margin_Text - _subTitleLabel.frame.size.height, size.width - _headImageView.frame.size.width - 4 * TConversationCell_Margin - _unReadView.frame.size.width, _subTitleLabel.frame.size.height);
}

@end
