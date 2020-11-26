//
//  TiUICell.h
//  TiLive
//
//  Created by Cat66 on 2018/5/8.
//  Copyright © 2018年 Tillurosy Tech. All rights reserved.
//

#import "TiUICell.h"

@interface TiUICell ()

@end

@implementation TiUICell

- (UIImageView *)bgView {
    if (!_bgView) {
        
        _bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_bgView setImage:nil];
    }
    return _bgView;
    
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        _label.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:_label];
    }
    return _label;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = self.bgView;
        self.label.frame = CGRectMake(1, 1, CGRectGetWidth(self.frame) - 2 + 10, CGRectGetWidth(self.frame) - 5);
    }
    return self;
}

- (void)setRockUICellByIndex:(NSInteger)index {
//    NSArray *rockNameCN = [[NSArray alloc] initWithObjects:@"无", @"炫彩抖动",@"灵魂出窍", @"头晕目眩",@"闪动分屏", @"酷炫转屏",@"四分镜头", @"黑白电影",@"自由抖动", @"瞬间石化", @"魔法镜面", nil];
    NSArray *rockNameCN = [[NSArray alloc] initWithObjects:@"无",@"炫彩抖动",@"轻彩抖动", @"头晕目眩", @"灵魂出窍",@"暗黑魔法", @"虚拟镜像",@"动感分屏", @"黑白电影", @"瞬间石化", @"魔法镜面", nil];
    self.label.text = [rockNameCN objectAtIndex:index];
}

- (void)setFilterUICellByIndex:(NSInteger)index {
    NSArray *filterNameCN = [[NSArray alloc] initWithObjects:@"无", @"素描",@"黑边", @"卡通",@"浮雕", @"胶片",@"马赛克", @"半色调",@"交叉线", @"那舍尔", @"咖啡", @"巧克力", @"可可", @"美味", @"初恋", @"森林", @"光泽", @"禾草", @"假日", @"初吻", @"洛丽塔", @"回忆", @"慕斯", @"标准", @"氧气", @"桔梗", @"赤红", @"冷日", @"扭曲", @"油画", @"分色", @"漩涡", @"光晕", @"眩晕", @"圆点", @"极坐标", @"水晶球", @"曝光", @"水墨", nil];
    self.label.text = [filterNameCN objectAtIndex:index];
}

- (void)setDistortionUICellByIndex:(NSInteger)index {
    NSArray *distortionNameCN = [[NSArray alloc] initWithObjects:@"无", @"外星人", @"梨梨脸", @"瘦瘦脸", @"方方脸", nil];
    self.label.text = [distortionNameCN objectAtIndex:index];
}

- (void)setGreenScreenUICellByIndex:(NSInteger)index {
    NSArray *greenScreenNameCN = [[NSArray alloc] initWithObjects:@"无", @"星空", @"黑板", nil];
    self.label.text = [greenScreenNameCN objectAtIndex:index];
}

- (void)changeCellEffect:(BOOL)isChange {
    if (isChange) {
        [self.label setTextColor:TiRGBA(255, 255, 255, 1)];
    } else {
        [self.label setTextColor:normalColors];
    }
}
@end
