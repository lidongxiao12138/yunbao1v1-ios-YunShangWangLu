//
//  TCallCell.m
//  live1v1
//
//  Created by IOS1 on 2019/4/22.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "TCallCell.h"
#import "TFaceView.h"
#import "TFaceCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"

@implementation TCallCellData
@end

@implementation TCallCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (CGSize)getContainerSize:(TCallCellData *)data
{
//    _content.attributedText = [self formatMessageString:data.content];
    _content.text = data.content;
    CGSize contentSize = [_content sizeThatFits:CGSizeMake(TTextMessageCell_Text_Width_Max-30, MAXFLOAT)];
    return CGSizeMake(contentSize.width + 2 * TTextMessageCell_Margin+30, contentSize.height + 2 * TTextMessageCell_Margin);
}

- (void)setupViews
{
    [super setupViews];
    _bubble = [[UIImageView alloc] init];
    [super.container addSubview:_bubble];
    
    _TypeImgV = [[UIImageView alloc] init];
    [_bubble addSubview:_TypeImgV];

    _content = [[UILabel alloc] init];
    _content.font = [UIFont systemFontOfSize:15];
    _content.numberOfLines = 0;
    [_bubble addSubview:_content];
}


- (void)setData:(TCallCellData *)data;
{
    //set data
    [super setData:data];
    _content.text = data.content;
    //update layout
    _bubble.frame = super.container.bounds;
    
    if(data.isSelf){
        if ([data.type isEqual:@"1"]) {
            _TypeImgV.image = [UIImage imageNamed:@"己方视频"];
        }else{
            _TypeImgV.image = [UIImage imageNamed:@"己方语音"];
        }
        _content.frame = CGRectMake(TTextMessageCell_Margin, TTextMessageCell_Margin, _bubble.frame.size.width - 2 * TTextMessageCell_Margin-30, _bubble.frame.size.height - 2 * TTextMessageCell_Margin);
        _TypeImgV.frame = CGRectMake(_content.right+10, TTextMessageCell_Margin, 20, 20);
        _bubble.image = [[[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"sender_text_normal")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{30,20,30,20}") resizingMode:UIImageResizingModeStretch];
        _bubble.highlightedImage = [[[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"sender_text_pressed")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{30,20,30,20}") resizingMode:UIImageResizingModeStretch];
        _content.textColor = [UIColor whiteColor];
    }
    else{
        if ([data.type isEqual:@"1"]) {
            _TypeImgV.image = [UIImage imageNamed:@"对方视频"];
        }else{
            _TypeImgV.image = [UIImage imageNamed:@"对方语音"];
        }
        _content.frame = CGRectMake(TTextMessageCell_Margin+30, TTextMessageCell_Margin, _bubble.frame.size.width - 2 * TTextMessageCell_Margin-30, _bubble.frame.size.height - 2 * TTextMessageCell_Margin);
        _TypeImgV.frame = CGRectMake(TTextMessageCell_Margin, TTextMessageCell_Margin, 20, 20);
        _bubble.image = [[[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"receiver_text_normal")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{30,20,30,20}") resizingMode:UIImageResizingModeStretch];
        _bubble.highlightedImage = [[[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"receiver_text_pressed")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{30,20,30,20}") resizingMode:UIImageResizingModeStretch];
        _content.textColor = [UIColor blackColor];
    }
}


@end
