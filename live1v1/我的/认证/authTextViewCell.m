//
//  authTextViewCell.m
//  live1v1
//
//  Created by IOS1 on 2019/4/3.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "authTextViewCell.h"

@implementation authTextViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text

{    if (![text isEqualToString:@""])
    
    {
        
        _placeholdLabel.hidden = YES;
        
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1)
        
    {
        
        _placeholdLabel.hidden = NO;
        
    }
    
    return YES;
    
}
//正在改变
- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"%@", textView.text);
    //实时显示字数
    _wordNumL.text = [NSString stringWithFormat:@"%lu/40", (unsigned long)textView.text.length];
    //字数限制操作
    if (textView.text.length >= 40) {
        textView.text = [textView.text substringToIndex:40];
        _wordNumL.text = @"40/40";
    }
    [self.delegate changeStr:textView.text andIsAutograph:_isAutograph];
}


@end
