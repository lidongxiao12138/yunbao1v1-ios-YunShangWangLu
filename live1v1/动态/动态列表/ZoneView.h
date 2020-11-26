//
//  ZoneView.h
//  live1v1
//
//  Created by ybRRR on 2019/7/26.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFaceView.h"
#import "TUIKit.h"
#import "TFaceCell.h"
@protocol ZoneViewDelegate <NSObject>
@optional
-(void)njScrollViewDragging:(UIScrollView *)scroll;
-(void)njScrollViewDidScro:(UIScrollView *)scroll;
-(void)njScrollViewEndDrag:(UIScrollView *)scroll;

//- (void)onPressSend;
-(void)cellImgaeClick:(NSMutableArray *)imagearr atIndex:(NSInteger)index;
-(void)cellVideoClick:(NSString *)videourl;
@end

NS_ASSUME_NONNULL_BEGIN

@interface ZoneView : UIView
@property(nonatomic,strong)NSMutableArray *zoneInfo;
@property(nonatomic,assign)BOOL canSendNotice;
@property(nonatomic,weak)UIViewController *fVC;
@property(nonatomic,weak)id<ZoneViewDelegate> delegate;


@property (nonatomic,strong) UIImageView *nothingImgV;
@property (nonatomic,strong) UILabel *nothingTitleL;
@property (nonatomic,strong) UILabel *nothingMsgL;
@property (nonatomic,strong) UIButton *nothingBtn;
@property (nonatomic,strong) UIView  *nothingView;
@property (nonatomic, strong) TFaceView *emojiV;
@property (nonatomic,strong) NSString *cellUid;
@property (nonatomic, assign)NSIndexPath *cellIndex;
//-(void)pullData:(NSString *)url;
-(void)pullData:(NSString *)url withliveId:(NSString *)liveid;
-(void)layoutTableWithFlag:(NSString *)flag;

@end

NS_ASSUME_NONNULL_END
