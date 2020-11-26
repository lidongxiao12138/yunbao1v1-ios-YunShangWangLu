//
//  EndingEvaluationView.m
//  live1v1
//
//  Created by IOS1 on 2019/4/12.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "EndingEvaluationView.h"

@implementation EndingEvaluationView{
    NSString *liveUid;
    UIScrollView *middleScroll;
    NSString *_timeSTR;
    UIButton *evaluationBtn;
    NSMutableArray *goodSelectArray;
    NSMutableArray *poolSelectArray;
    NSArray *goodArray;
    NSArray *poolArray;
}

- (instancetype)initWithFrame:(CGRect)frame andUserID:(NSString *)uid andTime:(NSString *)timeStr{
    if (self = [super initWithFrame:frame]) {
        liveUid = uid;
        _timeSTR = timeStr;
        goodSelectArray = [NSMutableArray array];
        poolSelectArray = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
        [self creatUI];
        [self requestData];
    }
    return self;
}
- (void)creatUI{
    middleScroll = [[UIScrollView alloc]initWithFrame:CGRectMake((_window_width-270)/2, _window_height*0.25, 270, _window_height/2)];
    [self addSubview:middleScroll];
    
    UILabel *label1 = [[UILabel alloc]init];
    label1.font = SYS_Font(12);
    label1.textColor = color32;
    label1.text = @"为主播的本次通话进行评价";
    [self addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(middleScroll.mas_top);
    }];
    UILabel *label2 = [[UILabel alloc]init];
    label2.font = SYS_Font(12);
    label2.textColor = RGB_COLOR(@"#c7c7c7", 1);
    label2.text = _timeSTR;
    [self addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(label1.mas_top).offset(-20);
    }];

    UILabel *label3 = [[UILabel alloc]init];
    label3.font = SYS_Font(20);
    label3.textColor = color32;
    label3.text = @"通话结束";
    [self addSubview:label3];
    [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(label2.mas_top).offset(-17);
    }];

    UILabel *label4 = [[UILabel alloc]init];
    label4.font = SYS_Font(12);
    label4.textColor = color96;
    label4.text = @"温馨提示：给主播评价时，只可选择同一类型的标签，且最多只能选择三个。";
    label4.numberOfLines = 0;
    [self addSubview:label4];
    [label4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(middleScroll.mas_bottom);
        make.width.mas_equalTo(270);
    }];
    evaluationBtn = [UIButton buttonWithType:0];
    [evaluationBtn setBackgroundColor:normalColors];
    [evaluationBtn setTitle:@"确认" forState:0];
    evaluationBtn.titleLabel.font = SYS_Font(15);
    evaluationBtn.layer.cornerRadius = 20;
    evaluationBtn.layer.masksToBounds = YES;
    [evaluationBtn addTarget:self action:@selector(evaluationBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:evaluationBtn];
    [evaluationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(label4.mas_bottom).offset(40);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(40);
    }];
    
}
- (void)requestData{
    [YBToolClass postNetworkWithUrl:@"Label.GetEvaluate" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSDictionary *infoDic = [info firstObject];
            goodArray = [infoDic valueForKey:@"good"];
            poolArray = [infoDic valueForKey:@"bad"];
            [self creatAllButton];
        }
    } fail:^{
        
    }];
}
- (void)creatAllButton{
    NSArray *arr = @[@"好评",@"差评"];
    CGFloat yyyyy = 0.00;
    for (int i = 0; i < arr.count; i ++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, yyyyy, middleScroll.width, 40)];
        label.text = arr[i];
        label.font = SYS_Font(12);
        label.textColor = color32;
        label.textAlignment = NSTextAlignmentCenter;
        [middleScroll addSubview:label];
        NSArray *array;
        if (i == 0) {
            array = goodArray;
        }else{
            array = poolArray;
        }
        for (int j = 0; j < array.count; j++) {
            NSDictionary *dic = array[j];
            UIButton *btn = [UIButton buttonWithType:0];
            btn.frame = CGRectMake(10+j%3*90, label.bottom+5 + j/3*32, 70, 22);
            btn.layer.cornerRadius = 11;
            btn.layer.masksToBounds = YES;
            btn.layer.borderWidth = 1;
            btn.titleLabel.font = SYS_Font(11);
            [btn setTitle:minstr([dic valueForKey:@"name"]) forState:0];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                
                btn.layer.borderColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1).CGColor;
                [btn setTitleColor:RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1) forState:0];
                btn.tag = 1000+j;
            }else{
                btn.layer.borderColor = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1).CGColor;
                [btn setTitleColor:RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1) forState:0];
                btn.tag = 2000+j;
            }
            [middleScroll addSubview:btn];
            if (j == array.count - 1) {
                yyyyy = btn.bottom + 10;
                if (i == 1) {
                    middleScroll.contentSize = CGSizeMake(0, yyyyy+20);
                }
            }
        }
    }

}
- (void)btnClick:(UIButton *)sender{
    if (sender.tag < 2000) {
        if (poolSelectArray.count == 0) {
            if (goodSelectArray.count == 3) {
                NSDictionary *dic = goodArray[sender.tag - 1000];
                NSString *idStr = minstr([dic valueForKey:@"id"]);
                if ([goodSelectArray containsObject:idStr]) {
                    [goodSelectArray removeObject:idStr];
                    UIColor *color = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                    sender.layer.borderColor = color.CGColor;
                    [sender setBackgroundColor:[UIColor whiteColor]];
                    [sender setTitleColor:color forState:0];
                    
                }else{
                    [MBProgressHUD showError:@"最多选择三项"];

                }
            }else{
                NSDictionary *dic = goodArray[sender.tag - 1000];
                NSString *idStr = minstr([dic valueForKey:@"id"]);
                UIColor *color = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);

                if ([goodSelectArray containsObject:idStr]) {
                    [goodSelectArray removeObject:idStr];
                    sender.layer.borderColor = color.CGColor;
                    [sender setBackgroundColor:[UIColor whiteColor]];
                    [sender setTitleColor:color forState:0];
                    
                }else{
                    [goodSelectArray addObject:idStr];
                    sender.layer.borderColor = color.CGColor;
                    [sender setBackgroundColor:color];
                    [sender setTitleColor:[UIColor whiteColor] forState:0];
                }
            }
        }
    }else{
        if (goodSelectArray.count == 0) {
            if (poolSelectArray.count == 3) {
                NSDictionary *dic = poolArray[sender.tag - 2000];
                NSString *idStr = minstr([dic valueForKey:@"id"]);
                if ([poolSelectArray containsObject:idStr]) {
                    [poolSelectArray removeObject:idStr];
                    UIColor *color = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
                    sender.layer.borderColor = color.CGColor;
                    [sender setTitleColor:color forState:0];
                    [sender setBackgroundColor:[UIColor whiteColor]];
                    
                }else{
                    [MBProgressHUD showError:@"最多选择三项"];
                }
            }else{
                NSDictionary *dic = poolArray[sender.tag - 2000];
                NSString *idStr = minstr([dic valueForKey:@"id"]);
                UIColor *color = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);

                if ([poolSelectArray containsObject:idStr]) {
                    [poolSelectArray removeObject:idStr];
                    sender.layer.borderColor = color.CGColor;
                    [sender setTitleColor:color forState:0];
                    [sender setBackgroundColor:[UIColor whiteColor]];
                }else{
                    [poolSelectArray addObject:idStr];
                    sender.layer.borderColor = color.CGColor;
                    [sender setBackgroundColor:color];
                    [sender setTitleColor:[UIColor whiteColor] forState:0];
                }
            }

        }
    }
}
- (void)evaluationBtnClick{
    if (goodSelectArray.count == 0 && poolSelectArray.count == 0) {
        if (self.block) {
            self.block();
        }

    }else{
        NSLog(@"goodSelectArray=%@,poolSelectArray=%@",goodSelectArray,poolSelectArray);
        NSString *idsStrs = @"";
        if (goodSelectArray.count > 0) {
            for (NSString *str in goodSelectArray) {
                idsStrs = [idsStrs stringByAppendingFormat:@"%@,",str];
            }
        }else{
            for (NSString *str in poolSelectArray) {
                idsStrs = [idsStrs stringByAppendingFormat:@"%@,",str];
            }
        }

        if (idsStrs.length > 0) {
            //去掉最后一个逗号
            idsStrs = [idsStrs substringToIndex:[idsStrs length] - 1];
        }

        [YBToolClass postNetworkWithUrl:@"Label.SetEvaluate" andParameter:@{
                                                                            @"evaluateids":idsStrs,
                                                                            @"liveuid":liveUid
                                                                            }
        success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [MBProgressHUD showError:msg];
            if (self.block) {
                self.block();
            }

        } fail:^{
                                                                                
            if (self.block) {
                self.block();
            }

        }];
    }
}
@end
