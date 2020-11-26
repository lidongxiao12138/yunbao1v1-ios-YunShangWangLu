//
//  TGiftMessageCell.m
//  live1v1
//
//  Created by IOS1 on 2019/4/12.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "TGiftMessageCell.h"
@implementation TGiftMessageCellData
@end

@implementation TGiftMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (CGSize)getContainerSize:(TMessageCellData *)data
{
   
    return CGSizeMake(_window_width/2, 70);
}

- (void)setData:(TGiftMessageCellData *)data
{
    //set data
    [super setData:data];
    _numL.text = [NSString stringWithFormat:@"x %@",data.giftNum];
    [_heade sd_setImageWithURL:[NSURL URLWithString:data.giftIcon]];
    _nameL.text = data.giftName;
    CGFloat width = ([[YBToolClass sharedInstance]widthOfString:_numL.text andFont:[UIFont boldSystemFontOfSize:25] andHeight:30]+10);
    
    if (data.isSelf) {
        _numL.frame = CGRectMake(super.container.width-width, 20, width, 30);
        _heade.frame = CGRectMake(_numL.left-60, 7.5, 45, 45);
        _nameL.frame = CGRectMake(_heade.left-7.5, _heade.bottom, 60, 15);
    }else{
        _numL.frame = CGRectMake(0, 20, width, 30);
        _heade.frame = CGRectMake(_numL.right+7.5, 7.5, 45, 45);
        _nameL.frame = CGRectMake(_heade.left-7.5, _heade.bottom, 60, 15);
    }
}
- (void)setupViews
{
    [super setupViews];
    CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(-8 * (CGFloat)M_PI / 180), 1, 0, 0);

    _numL = [[CFGradientLabel alloc] init];
    _numL.labelTextColor = RGB_COLOR(@"#FFDD00", 1);
    _numL.font = [UIFont boldSystemFontOfSize:25];
    _numL.transform = matrix;
    _numL.textAlignment = NSTextAlignmentCenter;
    [super.container addSubview:_numL];

    _heade = [[UIImageView alloc] init];

    [super.container addSubview:_heade];
    
    
    _nameL = [[UILabel alloc] init];
    _nameL.font = SYS_Font(11);
    _nameL.textAlignment = NSTextAlignmentCenter;
    [super.container addSubview:_nameL];
    
}

@end
