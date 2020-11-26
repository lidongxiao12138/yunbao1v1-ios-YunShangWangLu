//
//  personSelectActionView.m
//  live1v1
//
//  Created by IOS1 on 2019/4/17.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "personSelectActionView.h"

@implementation personSelectActionView{
    NSArray *imgArray;
    NSArray *itemArray;
    UIView *whiteView;
}

- (instancetype)initWithImageArray:(NSArray *)array andItemArray:(NSArray *)iArray{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = RGB_COLOR(@"#000000", 0.2);
        imgArray = array;
        itemArray = iArray;
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, ShowDiff+50*(itemArray.count+1))];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    UIButton *cancleBtn = [UIButton buttonWithType:0];
    cancleBtn.frame = CGRectMake(0, whiteView.height-ShowDiff-50, _window_width, 50);
    [cancleBtn setTitle:@"取消" forState:0];
    [cancleBtn setTitleColor:color96 forState:0];
    cancleBtn.titleLabel.font = SYS_Font(13);
    [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:cancleBtn];
    for (int i = 0; i < itemArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(0, cancleBtn.top-(i+1)*50, _window_width, 50);
        [btn addTarget:self action:@selector(itemBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000+i;
        [btn setTitle:itemArray[i] forState:0];
        [btn setTitleColor:color32 forState:0];
        btn.titleLabel.font = SYS_Font(13);
        [btn setImage:[UIImage imageNamed:imgArray[i]] forState:0];
        [whiteView addSubview:btn];
        [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 49, _window_width, 1) andColor:RGB_COLOR(@"#f0f0f0", 1) andView:btn];
//        UILabel *label = [[UILabel alloc]init];
//        label.text = itemArray[i];
//        label.font = SYS_Font(13);
//        label.textColor = color32;
//        [btn addSubview:label];
//        [label mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(btn);
//        }];
//        UIImageView *imgV = [UIImageView alloc]init
    }
}
- (void)show{
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        whiteView.y = _window_height-whiteView.height;
    }];
}
- (void)cancleBtnClick{
    [UIView animateWithDuration:0.2 animations:^{
        whiteView.y = _window_height;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];

}
- (void)itemBtnClick:(UIButton *)sender{
    if (self.block) {
        self.block((int)sender.tag-1000);
    }
    [self cancleBtnClick];
}
@end
