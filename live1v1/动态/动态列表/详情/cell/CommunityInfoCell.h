//
//  CommunityInfoCell.h
//  yunbaolive
//
//  Created by Boom on 2018/12/17.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commentModel.h"
#import <YYWebImage/YYWebImage.h>

@protocol CommunityInfoCellDelegate <NSObject>

-(void)pushDetails:(NSDictionary *)commentdic;//跳回复列表

-(void)makeLikeRloadList:(NSString *)commectid andLikes:(NSString *)likes islike:(NSString *)islike;
- (void)reloadCurCell:(commentModel *)model andIndex:(NSIndexPath *)curIndex andReplist:(NSArray *)list needRefresh:(BOOL)needRefresh;;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CommunityInfoCell : UITableViewCell<UITableViewDelegate,UITableViewDataSource>{
    BOOL isSounding;

}
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UIButton *zanBtn;
@property (weak, nonatomic) IBOutlet UILabel *zanNumL;
@property (weak, nonatomic) IBOutlet UITableView *replyTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeight;
@property(nonatomic,strong)NSMutableArray *replyArray;
@property(nonatomic,strong)UIButton *Reply_Button;//回复
@property(nonatomic,strong)UIView *replyBottomView;//回复

@property(nonatomic,strong)NSIndexPath *curIndex;//回复
@property (nonatomic,assign) BOOL isNoMore;//判断是不是没有更多了
@property(nonatomic,strong)commentModel *model;
@property(nonatomic,assign)id<CommunityInfoCellDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIButton *voiceBtn;
@property (strong, nonatomic) IBOutlet UIView *audioBack;
@property (strong, nonatomic) IBOutlet YYAnimatedImageView *animationView;
@property (strong, nonatomic) IBOutlet UILabel *voiceTimeL;
@property (nonatomic,strong) NSURL *anImgUrl;

@property (nonatomic,strong) AVPlayer *voicePlayer;
@property (nonatomic,assign) BOOL isPlaying;
@property (strong, nonatomic) IBOutlet UIImageView *pauseImage;

//监听播放起状态的监听者
@property (nonatomic ,strong) id playbackTimeObserver;

@end

NS_ASSUME_NONNULL_END
