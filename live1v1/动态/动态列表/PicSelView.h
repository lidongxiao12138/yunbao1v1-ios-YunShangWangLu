//
//  PicSelView.h
//  yunbaolive
//
//  Created by YB007 on 2019/7/17.
//  Copyright © 2019 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PicBlock)(int codeEvent);

@interface PicSelView : UIView

@property(nonatomic,copy)PicBlock picEvent;

//方式
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBtnBottom;
+(instancetype)showPicAlert:(PicBlock)complete;



//价格
@property (weak, nonatomic) IBOutlet UIView *priceBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceFreeBottom;
@property (weak, nonatomic) IBOutlet UIImageView *priChargeIV;
@property (weak, nonatomic) IBOutlet UIImageView *priFreeIV;
@property(nonatomic,assign)int selType;//1-收费   0-免费
+(instancetype)showType:(int)selType and:(PicBlock)complete;


//删除
@property (weak, nonatomic) IBOutlet UIView *delBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *delCancelBottom;
+(instancetype)showDelAlert:(PicBlock)complete;


@end


