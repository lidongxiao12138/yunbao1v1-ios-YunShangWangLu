//
//  MessageViewController.h
//  live1v1
//
//  Created by IOS1 on 2019/3/30.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TChatController.h"
NS_ASSUME_NONNULL_BEGIN

@interface MessageViewController : UIViewController
@property (nonatomic, strong) TConversationCellData *conversation;

@end

NS_ASSUME_NONNULL_END
