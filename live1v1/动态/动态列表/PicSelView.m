//
//  PicSelView.m
//  yunbaolive
//
//  Created by YB007 on 2019/7/17.
//  Copyright © 2019 cat. All rights reserved.
//

#import "PicSelView.h"
@interface PicSelView()<UIGestureRecognizerDelegate,UITextFieldDelegate>
{
    UIAlertController *_alerC;
}
@end
@implementation PicSelView

- (void)awakeFromNib {
    [super awakeFromNib];
    //方式
    if (_cancelBtnBottom) {
        _cancelBtnBottom.constant = ShowDiff;

    }
    
    //价格
    if (_priceFreeBottom) {
        _priceFreeBottom.constant = 20+ShowDiff;
    }
}
-(void)setupUI {
    self.frame = [UIScreen mainScreen].bounds;
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    ges.delegate = self;
    [self addGestureRecognizer:ges];
    
    [self show];
}
-(void)show {
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
    [UIView animateWithDuration:.3 animations:^{
        self.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0.3];
    }];
}
- (void)dismiss {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeFromSuperview];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.bgView] ||[touch.view isDescendantOfView:self.priceBgView]|| [touch.view isDescendantOfView:self.delBgView]) {
        return NO;
    }
    return YES;
}

//方式

+(instancetype)showPicAlert:(PicBlock)complete {
    PicSelView *pic = [[[NSBundle mainBundle]loadNibNamed:@"PicSelView" owner:nil options:nil]objectAtIndex:0];
    if (complete) {
        pic.picEvent = ^(int codeEvent) {
            complete(codeEvent);
        };
    }
    [pic setupUI];
    
    return pic;
}

- (IBAction)clickCancelBtn:(UIButton *)sender {
    [self dismiss];
}

- (IBAction)clickLocationBtn:(UIButton *)sender {
    if (self.picEvent) {
        self.picEvent(1);
    }
    [self dismiss];
}
- (IBAction)clcikCanmeraBtn:(UIButton *)sender {
    if (self.picEvent) {
        self.picEvent(2);
    }
    [self dismiss];
}

//价格
+(instancetype)showType:(int)selType and:(PicBlock)complete {
    PicSelView *pic = [[[NSBundle mainBundle]loadNibNamed:@"PicSelView" owner:nil options:nil]objectAtIndex:1];
    if (complete) {
        pic.picEvent = ^(int codeEvent) {
            complete(codeEvent);
        };
    }
    pic.selType = selType;
    if (selType==1) {
        pic.priChargeIV.hidden = NO;
        pic.priFreeIV.hidden = YES;
    }else {
        pic.priChargeIV.hidden = YES;
        pic.priFreeIV.hidden = NO;
    }
    [pic setupUI];
    return pic;
}
- (IBAction)clickPriCloseBtn:(UIButton *)sender {
    [self dismiss];
}

- (IBAction)clickPirChargeBtn:(UIButton *)sender {
    //1-收费   0-免费
    _selType = 1;
    WeakSelf;
    _alerC = [UIAlertController alertControllerWithTitle:@"设置收费金额" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [_alerC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = weakSelf;
        textField.placeholder = @"";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancleA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *suerA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *alertTextField = _alerC.textFields.firstObject;
        if (alertTextField.text.length<=0) {
            [MBProgressHUD showError:@"请填写收费金额"];
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:_alerC animated:YES completion:nil];
            return ;
        }
        [weakSelf setMoney:alertTextField.text];
    }];
    [_alerC addAction:cancleA];
    [_alerC addAction:suerA];
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 9.0) {
        [suerA setValue:RGB_COLOR(@"#323232", 1) forKey:@"_titleTextColor"];
        [cancleA setValue:RGB_COLOR(@"#969696", 1) forKey:@"_titleTextColor"];
    }
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:_alerC animated:YES completion:nil];
    
}

-(void)setMoney:(NSString *)money {
    
    [YBToolClass postNetworkWithUrl:@"Photos.setPhotocoin" andParameter:@{@"coin":money,@"ispay":(_selType==1?@"1":@"0")} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD showError:msg];
        if (code == 0) {
            if (_selType == 1) {
                _priChargeIV.hidden = NO;
                _priFreeIV.hidden = YES;
            }else {
                _priChargeIV.hidden = YES;
                _priFreeIV.hidden = NO;
            }
            [self dismiss];
        }else {
            if (_selType == 1) {
                [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:_alerC animated:YES completion:nil];
            }
        }
    } fail:^{
        
    }];
    
}

- (IBAction)clickPirFreeBtn:(UIButton *)sender {
    //1-收费   0-免费
    _selType = 0;
    [self setMoney:@"0"];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _alerC.textFields.firstObject) {
        //新输入的
        if (string.length == 0) {
            return YES;
        }
        NSString *checkStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *regex = @"^[1-9]\\d*$";//只能输入非零的正整数( 包含0 @"^[1-9]\\d*|0$")
        return [self isValid:checkStr withRegex:regex];
    }
    return YES;
}
- (BOOL) isValid:(NSString*)checkStr withRegex:(NSString*)regex {
    NSPredicate *predicte = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicte evaluateWithObject:checkStr];
}


//删除
+(instancetype)showDelAlert:(PicBlock)complete {
    PicSelView *pic = [[[NSBundle mainBundle]loadNibNamed:@"PicSelView" owner:nil options:nil]objectAtIndex:2];
    if (complete) {
        pic.picEvent = ^(int codeEvent) {
            complete(codeEvent);
        };
    }
    [pic setupUI];
    
    return pic;
}

- (IBAction)clickDelCancelBtn:(UIButton *)sender {
    [self dismiss];
}
- (IBAction)clickDelDelBtn:(UIButton *)sender {
    if (self.picEvent) {
        self.picEvent(1);
    }
    [self dismiss];
}

@end
