//
//  YSFiterView.m
//  live1v1
//
//  Created by YB007 on 2019/10/24.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "YSFiterView.h"

@implementation YSFiterView{
    UIView *whiteView;
    NSMutableArray *sexBtnarray;
//    NSMutableArray *typeBtnarray;
    NSString *_sexStr;
//    NSString *_typeStr;
    CGFloat _delElementHeith;
}

- (instancetype)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = RGB_COLOR(@"#000000", 0.2);
        _sexStr = @"0";
//        _typeStr = @"0";
        sexBtnarray = [NSMutableArray array];
//        typeBtnarray = [NSMutableArray array];
        _delElementHeith = 18+11+26;
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, 270+ShowDiff-_delElementHeith)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    whiteView.layer.mask = [[YBToolClass sharedInstance] setViewLeftTop:20 andRightTop:20 andView:whiteView];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(28, 17, 100, 18)];
    label.text = @"想要看的用户";
    label.font = SYS_Font(12);
    label.textColor = color32;
    [whiteView addSubview:label];
    
    UIButton *closeBtn = [UIButton buttonWithType:0];
    closeBtn.frame = CGRectMake(whiteView.width-52, 0, 52, 52);
    [closeBtn setImage:[UIImage imageNamed:@"screen_close"] forState:0];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    [closeBtn addTarget:self action:@selector(closebtnClick) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:closeBtn];
    NSArray *titleArray = @[@"全部",@"女",@"男"];
    CGFloat speace = (_window_width-210)/4;
    for (int i = 0; i < titleArray.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(speace+i*(60+speace), label.bottom+13, 70, 70);
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"screen_%@_nor",titleArray[i]]] forState:0];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"screen_%@_sel",titleArray[i]]] forState:UIControlStateSelected];
        [btn setTitle:titleArray[i] forState:0];
        btn.titleLabel.font = SYS_Font(11);
        [btn setTitleColor:color96 forState:0];
        [btn setTitleColor:normalColors forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(sexBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
        btn.tag = 1000+i;
        [whiteView addSubview:btn];
        btn = [YBToolClass setUpImgDownText:btn space:11];
        [sexBtnarray addObject:btn];
    }
    /*
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(28, label.bottom+83+9, 100, 18)];
    label2.text = @"通话类型";
    label2.font = SYS_Font(12);
    label2.textColor = color32;
    [whiteView addSubview:label2];
    NSArray *titleArray2 = @[@"全部",@"视频",@"语音"];
    CGFloat speace2 = (_window_width-180)/4;
    for (int i = 0; i < titleArray2.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(speace2+i*(60+speace2), label2.bottom+11, 60, 26);
        btn.layer.cornerRadius = 13;
        btn.layer.masksToBounds = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"筛选-未选中"] forState:0];
        [btn setBackgroundImage:[UIImage imageNamed:@"screen_sel"] forState:UIControlStateSelected];
        [btn setTitle:titleArray2[i] forState:0];
        [btn setTitle:titleArray2[i] forState:UIControlStateSelected];
        btn.clipsToBounds = YES;
        btn.titleLabel.font = SYS_Font(11);
        [btn setTitleColor:color96 forState:0];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
        btn.tag = 2000+i;
        [whiteView addSubview:btn];
        [typeBtnarray addObject:btn];
    }
     */
    UIButton *screenBtn = [UIButton buttonWithType:0];
    screenBtn.frame = CGRectMake(38,  label.bottom+83+9+20, _window_width-38*2, 40);
    screenBtn.layer.cornerRadius = 20;
    screenBtn.layer.masksToBounds = YES;
    [screenBtn setBackgroundColor:normalColors];
    [screenBtn setTitle:@"确定" forState:0];
    screenBtn.titleLabel.font = SYS_Font(15);
    [screenBtn addTarget:self action:@selector(screenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:screenBtn];
}
- (void)show{
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        whiteView.y = _window_height-270-ShowDiff+_delElementHeith;
    }];
    
}
- (void)closebtnClick{
    [UIView animateWithDuration:0.2 animations:^{
        whiteView.y = _window_height;
    }completion:^(BOOL finished) {
        self.hidden = YES;
    }];
    
}
- (void)sexBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    for (UIButton *btn in sexBtnarray) {
        if (btn == sender) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    switch (sender.tag) {
        case 1000:
            _sexStr = @"0";
            break;
        case 1001:
            _sexStr = @"2";
            break;
        case 1002:
            _sexStr = @"1";
            break;
            
        default:
            break;
    }
    
}
/*
- (void)typeBtnClick:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    for (UIButton *btn in typeBtnarray) {
        if (btn == sender) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    _typeStr = [NSString stringWithFormat:@"%ld",sender.tag - 2000];
}
 */
- (void)screenBtnClick{
    [self closebtnClick];
    if (self.block) {
        NSDictionary *dic = @{
                              @"sex":_sexStr,
//                              @"type":_typeStr
                              };
        self.block(dic);
    }
}

@end
