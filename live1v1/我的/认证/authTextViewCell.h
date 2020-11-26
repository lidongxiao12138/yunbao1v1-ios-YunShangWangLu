//
//  authTextViewCell.h
//  live1v1
//
//  Created by IOS1 on 2019/4/3.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol authTextViewCellDelegate <NSObject>

- (void)changeStr:(NSString *)str andIsAutograph:(BOOL)isAutograph;

@end
@interface authTextViewCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UITextView *textV;
@property (weak, nonatomic) IBOutlet UILabel *placeholdLabel;
@property (weak, nonatomic) IBOutlet UILabel *wordNumL;
@property (nonatomic,assign) BOOL isAutograph;
@property (nonatomic,weak) id<authTextViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
