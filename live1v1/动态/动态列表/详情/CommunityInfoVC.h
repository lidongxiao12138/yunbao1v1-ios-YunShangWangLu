//
//  CommunityInfoVC.h
//  yunbaolive
//
//  Created by YB007 on 2019/7/19.
//  Copyright © 2019 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFaceView.h"
#import "TUIKit.h"
#import "TFaceCell.h"
#import "TRecordView.h"
typedef void (^CommunityInfoBlock)(int eventCode ,NSDictionary *eventDic);

@interface CommunityInfoVC : YBBaseViewController

@property(nonatomic,copy)CommunityInfoBlock infoEvent;

@property(nonatomic,strong)NSString *communityID;
@property(nonatomic,strong)NSString *communityUid;
@property(nonatomic,strong)NSDictionary *communityInfoDic;

@property (nonatomic, strong) TFaceView *emojiV;
@property (nonatomic, strong) TRecordView *record;

@end


