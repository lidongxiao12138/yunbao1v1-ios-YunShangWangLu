//
//  recommendCell.m
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "recommendCell.h"

@implementation recommendCell{
    UIView *priceView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(recommendModel *)model{
    _model = model;
    NSArray *arr = @[@"离线",@"勿扰",@"在聊",@"在线"];
    _stateImgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"状态-%@",arr[[_model.online intValue]]]];
    [_levelImgV sd_setImageWithURL:[NSURL URLWithString:[common getAnchorLevelMessage:_model.level_anchor]]];
    [_thumbImgV sd_setImageWithURL:[NSURL URLWithString:_model.thumb]];
    _nameL.text = _model.user_nickname;
//    _uuView.direction = UUMarqueeViewDirectionUpward;
//    _uuView.delegate = self;
//    _uuView.timeIntervalPerScroll = 5.0f;
//    _uuView.timeDurationPerScroll = 0.5f;
//    _uuView.touchEnabled = NO;
//    [_uuView reloadData];
//    [_uuView start];
//    if (_model.typeArray.count == 0) {
//        _uuHeightC.constant = 0;
//    }else{
//        _uuHeightC.constant = 15;
//    }
    if (_model.typeArray.count > 0) {
        NSDictionary *dic =[_model.typeArray firstObject];
        _openTypeImgV.image = [UIImage imageNamed:minstr([dic valueForKey:@"icon"])];
        _openTypeL.text = minstr([dic valueForKey:@"content"]);
    }
    if (_model.isvideo) {
        _videoImgWidthC.constant = 12.0;
        _videoImgV.hidden = NO;
        if (_model.isvoice) {
            _audioImgV.hidden = NO;
        }else{
            _audioImgV.hidden = YES;
        }
    }else{
        _videoImgWidthC.constant = 0.0;
        _videoImgV.hidden = YES;
        if (_model.isvoice) {
            _audioImgV.hidden = NO;
        }else{
            _audioImgV.hidden = YES;
        }
    }
    if (_model.distance) {
        _distanceL.text = _model.distance;
    }else{
        _distanceL.text = @"";
    }
    
    //rk_1029
    _stateImgV.hidden = YES;
    
}

//#pragma mark - UUMarqueeViewDelegate
//- (NSUInteger)numberOfVisibleItemsForMarqueeView:(UUMarqueeView*)marqueeView {
//    return 1;
//}
//
//- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView*)marqueeView {
//    return _model.typeArray.count;
//}
//
//- (void)createItemView:(UIView*)itemView forMarqueeView:(UUMarqueeView*)marqueeView {
//    itemView.backgroundColor = [UIColor clearColor];
//    
//    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15.0f, 15.0f)];
//    icon.tag = 1003;
//    [itemView addSubview:icon];
//
//    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(3.0f + 15.0f, 0.0f, CGRectGetWidth(itemView.bounds) - 15.0f, CGRectGetHeight(itemView.bounds))];
//    content.font = [UIFont systemFontOfSize:10.0f];
//    content.tag = 1001;
//    content.textColor = [UIColor whiteColor];
//    [itemView addSubview:content];
//}
//
//- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
//        UILabel *content = [itemView viewWithTag:1001];
//        content.text = [_model.typeArray[index] objectForKey:@"content"];
//    
//        UIImageView *icon = [itemView viewWithTag:1003];
//        icon.image = [UIImage imageNamed:[_model.typeArray[index] objectForKey:@"icon"]];
//}
//
//- (CGFloat)itemViewHeightAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
//    return 15.0f;
//}
//
//- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
//    return _window_width-20;  // icon width + label width (it's perfect to cache them all)
//}
//
//- (void)didTouchItemViewAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
//}

@end
