//
//  CommunityInfoHeader.h
//  yunbaolive
//
//  Created by YB007 on 2019/7/20.
//  Copyright © 2019 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>

@protocol CommunityHeaderDelegate <NSObject>

-(void)onClickNJCommentsBtn;

-(void)updateTabHeader;

-(void)clickImgTap:(int)index;
-(void)clickVideoTap:(NSString *)videoUrl;
-(void)clickgoCenter:(NSString *)liveid;
-(void)clickReportORDelete:(NSString *)commitid;

@end


@interface CommunityInfoHeader : UIView

@property(nonatomic,strong)UIImageView *headView;
@property(nonatomic,strong)UIButton *deleteBtn;
@property(nonatomic,strong)UIView *bodyView;

@property(nonatomic,strong)UIView *zanBarView;
@property(nonatomic,strong)UIButton *njCommentBnt;  //评论
@property(nonatomic,strong)UIButton *njZanBtn;      //赞

@property(nonatomic,strong)UIView *footView;

@property(nonatomic,strong)NSMutableArray *imgArray;
@property(nonatomic,strong)NSMutableArray *imgViewArray;
@property (strong, nonatomic)  YYAnimatedImageView *animationView;
@property (strong, nonatomic)UIImageView *audioBackImg;

@property(nonatomic,strong)TXLivePlayer *livePlayer;

@property(nonatomic,weak)id<CommunityHeaderDelegate> delegate;


-(void)setHeaderData:(NSDictionary *)infoDic;

-(CGFloat)getTableHeaderHeight;
-(NSString *)getIsLikeState;
-(NSString *)getLikesNum;
-(void)updataComments:(NSString *)comments;
-(NSString *)getCommentsNum;

-(void)stopVideoPlay;
@end


