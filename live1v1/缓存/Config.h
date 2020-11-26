

#import <Foundation/Foundation.h>
#import "LiveUser.h"

@interface Config : NSObject
+ (void)saveProfile:(LiveUser *)user;
+ (void)updateProfile:(LiveUser *)user;
+ (void)clearProfile;
+ (LiveUser *)myProfile;
+(NSString *)getOwnID;
+(NSString *)getOwnNicename;
+(NSString *)getOwnToken;
+(NSString *)getOwnSignature;
+(NSString *)getavatar;
+(NSString *)getavatarThumb;
+(NSString *)getLevel;
+(NSString *)getSex;
+(NSString *)getcoin;
+(NSString *)level_anchor;//主播等级
+(NSString *)lgetUserSign;//IM签名
+(NSString *)getIsauth;//认证状态

+(void)saveVipandliang:(NSDictionary *)subdic;//保存靓号和vip
+(NSString *)getVip_type;
+(NSString *)getliang;

+(NSString *)canshu;

+(void)saveRegisterlogin:(NSString *)isreg;
+(NSString *)getIsRegisterlogin;
+(NSString *)getIsUserauth;
@end
