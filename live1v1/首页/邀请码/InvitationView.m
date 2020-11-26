//
//  InvitationView.m
//  live1v1
//
//  Created by IOS1 on 2019/5/10.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "InvitationView.h"

@implementation InvitationView{
    UIView *showView;
    UITextField *codeTextF;
}

-(instancetype)initWithType:(BOOL)isForce{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHide)];
        [self addGestureRecognizer:tap];

        [self creatUI:isForce];
    }
    return self;
}
- (void)keyboardHide{
    [codeTextF resignFirstResponder];
}
- (void)showviewClick{
    
}
- (void)creatUI:(BOOL)isForce{
    
    showView = [[UIView alloc]initWithFrame:CGRectMake(_window_width*0.22, _window_height, _window_width*0.56, _window_width*0.56*0.76)];
    showView.backgroundColor = [UIColor whiteColor];
    showView.layer.cornerRadius = 10;
    showView.layer.masksToBounds = YES;
    showView.clipsToBounds = YES;
    [self addSubview:showView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showviewClick)];
    [showView addGestureRecognizer:tap];

    UIImageView *headerImgV = [[UIImageView alloc]init];
    headerImgV.userInteractionEnabled = YES;
    headerImgV.image = [UIImage imageNamed:@"邀请码背景"];
    [showView addSubview:headerImgV];
    [headerImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(showView);
        make.height.equalTo(showView).multipliedBy(0.28125);
    }];
    UILabel *label = [[UILabel alloc]init];
    label.font = SYS_Font(15);
    label.textColor = [UIColor whiteColor];
    label.text = @"输入邀请码";
    [headerImgV addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerImgV);
        make.centerY.equalTo(headerImgV).multipliedBy(1.1);
    }];
    if (!isForce) {
        UIButton *closeBtn = [UIButton buttonWithType:0];
        [closeBtn setImage:[UIImage imageNamed:@"邀请码关闭"] forState:0];
        [closeBtn addTarget:self action:@selector(hideSelf) forControlEvents:UIControlEventTouchUpInside];
        closeBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [headerImgV addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(showView);
            make.width.height.mas_equalTo(30);
        }];
    }
    
    
    codeTextF = [[UITextField alloc]init];
    codeTextF.textColor = color32;
    codeTextF.font = [UIFont boldSystemFontOfSize:20];
    codeTextF.layer.cornerRadius = 3;
    codeTextF.layer.masksToBounds = YES;
    codeTextF.layer.borderColor = RGB_COLOR(@"#e5e5e5", 1).CGColor;
    codeTextF.layer.borderWidth = 1;
    codeTextF.leftViewMode = UITextFieldViewModeAlways;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 40)];
    codeTextF.leftView = view;
    [showView addSubview:codeTextF];
    
    [codeTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(showView).multipliedBy(0.85);
        make.centerX.equalTo(showView);
        make.height.equalTo(showView).multipliedBy(0.25);
        make.centerY.equalTo(showView).multipliedBy(1.025);
    }];
    
    UIButton *sureBtn = [UIButton buttonWithType:0];
    [sureBtn setTitle:@"确定" forState:0];
    [sureBtn setTitleColor:normalColors forState:0];
    sureBtn.titleLabel.font = SYS_Font(15);
    [sureBtn addTarget:self action:@selector(submitInvitationCode) forControlEvents:UIControlEventTouchUpInside];
    [showView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.equalTo(showView);
        make.height.equalTo(showView).multipliedBy(0.25);
    }];

    
    [UIView animateWithDuration:0.3 animations:^{
        showView.centerY = self.centerY * 0.7;
    }completion:^(BOOL finished) {
        [codeTextF becomeFirstResponder];
    }];
}
- (void)hideSelf{
    [self keyboardHide];
    [UIView animateWithDuration:0.3 animations:^{
        showView.y = _window_height;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)submitInvitationCode{
    if (codeTextF.text == nil || codeTextF.text == NULL || codeTextF.text.length == 0) {
        [MBProgressHUD showError:@"邀请码不能为空"];
        return;
    }
    [YBToolClass postNetworkWithUrl:@"Agent.SetAgent" andParameter:@{@"code":codeTextF.text} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [self hideSelf];
        }
        [MBProgressHUD showError:msg];
    } fail:^{
        
    }];
}
@end
