//
//  CommunityCell.h
//  CircleOfFriendsDisplay
//
//  Created by 李云祥 on 16/9/22.
//  Copyright © 2016年 李云祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommunityItem.h"
#import "UIImageView+WebCache.h"
#import <YYWebImage/YYWebImage.h>
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>

@class CommunityCell;
@protocol CommunityCellDelegate <NSObject>
@optional
- (void)onPressZanBtnOnDynamicCell:(CommunityCell *)cell;
- (void)onPressReplyBtnOnDynamicCell:(CommunityCell *)cell;
//- (void)onLongPressReplyBtnOnDynamicCell:(CommunityCell *)cell;
- (void)onPressReplyLabelView:(UIView *)view onDynamicCell:(CommunityCell *)cell;
- (void)onLongPressReplyLabelView:(UIView *)view onDynamicCell:(CommunityCell *)cell;
- (void)onPressDeleteBtnOnDynamicCell:(CommunityCell *)cell;
- (void)onPressImageView:(UIImageView *)imageView onDynamicCell:(CommunityCell *)cell;
- (void)onPressUrlOnDynamicCell:(CommunityCell *)cell;
- (void)onVideoClickWithUrl:(NSString *)videoUrl;
-(void)onCenterClick:(NSString *)liveId;
- (void)onTapImage:(NSMutableArray *)imageArr AtIndex:(NSInteger)tapIndex;
- (void)onPressMoreBtnOnDynamicCell:(CommunityCell *)cell;
- (void)onLongPressText:(NSString *)text onDynamicCell:(CommunityCell *)cell;
- (void)onLongPressImageView:(UIImageView *)imageView onDynamicCell:(CommunityCell *)cell;
- (void)onLongPressShareUrlOnDynamicCell:(CommunityCell *)cell;
- (void)onPressShareUrlOnUrl:(NSURL *)url;
- (void)onPressReSendOnDynamicCell:(CommunityCell *)cell;
//
-(void)onClickNJCommentsBtn:(NSIndexPath *)index;
-(void)onClickNJZanBtn:(NSIndexPath *)index;
-(void)onClickNJDelBtn:(NSIndexPath *)index;
-(void)onClickReportBtn:(NSIndexPath *)index;
- (void)onClickVoiceOnDynamicCell:(CommunityCell *)cell;

@end

@interface CommunityCell : UITableViewCell
@property(nonatomic,strong)UIImageView *headView;
@property(nonatomic,strong)UIButton *deleteBtn;
@property(nonatomic,strong)UIView *bodyView;

@property(nonatomic,strong)UIView *zanBarView;

@property(nonatomic,strong)UIButton *njCommentBnt;//评论
@property(nonatomic,strong)UIButton *njZanBtn;//赞'
@property(nonatomic,strong)UIButton *njDelBtn;
@property(nonatomic,strong)NSIndexPath *njIndex;//下标

@property(nonatomic,strong)UIView *footView;

@property(nonatomic,strong)CommunityItem *data;


@property(nonatomic,weak)id<CommunityCellDelegate> delegate;
@property(nonatomic,strong)NSMutableArray *imgArray;
@property(nonatomic,strong)NSMutableArray *imgViewArray;

@property (strong, nonatomic)  YYAnimatedImageView *animationView;
@property (strong, nonatomic)UIImageView *audioBackImg;

@property (nonatomic,strong) TXLivePlayer *txLivePlayer;
@property (nonatomic,strong)UIImageView *pauseIV;
@property (nonatomic,assign)BOOL isPlayingVideo;
@property (nonatomic,strong) AVPlayer *voicePlayer;
@property (nonatomic,assign) BOOL isSounding;
-(void)playVideoPath;
-(void)pauseVideo;
-(void)resumeVide;
-(void)playVoice:(BOOL)isVioce;
@end
