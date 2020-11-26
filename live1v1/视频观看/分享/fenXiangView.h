#import <UIKit/UIKit.h>
/******* 分享类头文件 ******/
#import <ShareSDK/ShareSDK.h>
//#import "SBJson4.h"
#import "MBProgressHUD.h"
/*******  分享 头文件结束 *********/
@protocol shareDelegate <NSObject>

- (void)shareSuccess;

@end
@interface fenXiangView : UIView

@property(nonatomic,strong)NSDictionary *zhuboDic;
@property (nonatomic,weak) id<shareDelegate> delegate;

-(void)GetDIc:(NSDictionary *)dic;
- (void)show;
@end


