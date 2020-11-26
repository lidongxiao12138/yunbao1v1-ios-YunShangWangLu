//
//  Config.m
//  yunbaolive
//
//  Created by cat on 16/3/9.
//  Copyright © 2016年 cat. All rights reserved.
//

#import "Config.h"

NSString * const KAvatar = @"avatar";
NSString * const KBirthday = @"birthday";
NSString * const KCoin = @"coin";
NSString * const KID = @"id";
NSString * const KSex = @"sex";
NSString * const KToken = @"token";
NSString * const KUser_nicename = @"user_nickname";
NSString * const KSignature = @"signature";
NSString * const Kcity = @"city";
NSString * const Klevel = @"level";
NSString * const kavatar_thumb = @"avatar_thumb";
NSString * const Klogin_type = @"login_type";
NSString * const Klevel_anchor = @"level_anchor";
NSString * const Kusersig = @"usersig";


NSString * const vip_type = @"vip_type";
NSString * const liang = @"liang";
NSString * const Kisauth = @"isauth";
NSString * const Kisreg = @"isreg";
NSString * const KisUserauth = @"isUserauth";

@implementation Config

#pragma mark - user profile

//保存靓号和vip
+(void)saveVipandliang:(NSDictionary *)subdic{
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     [userDefaults setObject:minstr([subdic valueForKey:@"vip_type"]) forKey:@"vip_type"];
     [userDefaults setObject:minstr([subdic valueForKey:@"liang"]) forKey:@"liang"];
     [userDefaults synchronize];
}
+(NSString *)getVip_type{
    
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *viptype = minstr([userDefults objectForKey:vip_type]);
    return viptype;
    
}
+(NSString *)getliang{
    
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *liangnum = minstr( [userDefults objectForKey:liang]);
    return liangnum;
    
}



+ (void)saveProfile:(LiveUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:user.avatar forKey:KAvatar];
    [userDefaults setObject:user.level_anchor forKey:Klevel_anchor];
    [userDefaults setObject:user.avatar_thumb forKey:kavatar_thumb];
    [userDefaults setObject:user.coin forKey:KCoin];
    [userDefaults setObject:user.sex forKey:KSex];
    [userDefaults setObject:user.ID forKey:KID];
    [userDefaults setObject:user.token forKey:KToken];
    [userDefaults setObject:user.user_nickname forKey:KUser_nicename];
    [userDefaults setObject:user.signature forKey:KSignature];
    [userDefaults setObject:user.login_type forKey:Klogin_type];
    
    [userDefaults setObject:user.birthday forKey:KBirthday];
    [userDefaults setObject:user.city forKey:Kcity];
    [userDefaults setObject:user.level forKey:Klevel];
    [userDefaults setObject:user.usersig forKey:Kusersig];
    [userDefaults setObject:user.isauth forKey:Kisauth];
    [userDefaults setObject:user.isreg forKey:Kisreg];
    [userDefaults setObject:user.isUserauth forKey:KisUserauth];

    [userDefaults synchronize];
    
}
+ (void)updateProfile:(LiveUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(user.user_nickname != nil) [userDefaults setObject:user.user_nickname forKey:KUser_nicename];
    if(user.level_anchor != nil) [userDefaults setObject:user.level_anchor forKey:Klevel_anchor];
    if(user.signature!=nil) [userDefaults setObject:user.signature forKey:KSignature];
    if(user.avatar!=nil) [userDefaults setObject:user.avatar forKey:KAvatar];
    if(user.avatar_thumb!=nil) [userDefaults setObject:user.avatar_thumb forKey:kavatar_thumb];
    if(user.coin!=nil) [userDefaults setObject:user.coin forKey:KCoin];
    if(user.birthday!=nil) [userDefaults setObject:user.birthday forKey:KBirthday];
    if(user.login_type!=nil) [userDefaults setObject:user.login_type forKey:Klogin_type];
    if(user.city!=nil) [userDefaults setObject:user.city forKey:Kcity];
    if(user.sex!=nil) [userDefaults setObject:user.sex forKey:KSex];
    if(user.level!=nil) [userDefaults setObject:user.level forKey:Klevel];
    if(user.usersig!=nil) [userDefaults setObject:user.usersig forKey:Kusersig];
    if(user.isauth!=nil) [userDefaults setObject:user.isauth forKey:Kisauth];
    if(user.isUserauth!=nil) [userDefaults setObject:user.isUserauth forKey:KisUserauth];

    [userDefaults synchronize];
}

+ (void)clearProfile
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:Klevel_anchor];
    [userDefaults setObject:nil forKey:KAvatar];
    [userDefaults setObject:nil forKey:KBirthday];
    [userDefaults setObject:nil forKey:KCoin];
    [userDefaults setObject:nil forKey:KID];
    [userDefaults setObject:nil forKey:KSex];
    [userDefaults setObject:nil forKey:KToken];
    [userDefaults setObject:nil forKey:KUser_nicename];
    [userDefaults setObject:nil forKey:Klogin_type];
    [userDefaults setObject:nil forKey:KSignature];
    [userDefaults setObject:nil forKey:Kcity];
    [userDefaults setObject:nil forKey:Klevel];
    [userDefaults setObject:nil forKey:kavatar_thumb];
    [userDefaults setObject:nil forKey:vip_type];
    [userDefaults setObject:nil forKey:liang];
    [userDefaults setObject:nil forKey:Kusersig];
    [userDefaults setObject:nil forKey:@"notifacationOldTime"];
    [userDefaults setObject:nil forKey:Kisauth];
    [userDefaults setObject:nil forKey:Kisreg];
    [userDefaults setObject:nil forKey:KisUserauth];

    [userDefaults synchronize];
}

+ (LiveUser *)myProfile
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    LiveUser *user = [[LiveUser alloc] init];
    user.avatar = [userDefaults objectForKey: KAvatar];
    user.birthday = [userDefaults objectForKey: KBirthday];
    user.coin = [userDefaults objectForKey: KCoin];
    user.level_anchor = [userDefaults objectForKey: Klevel_anchor];
    user.ID = [userDefaults objectForKey: KID];
    user.sex = [userDefaults objectForKey: KSex];
    user.token = [userDefaults objectForKey: KToken];
    user.user_nickname = [userDefaults objectForKey: KUser_nicename];
    user.signature = [userDefaults objectForKey:KSignature];
    user.level = [userDefaults objectForKey:Klevel];
    user.city = [userDefaults objectForKey:Kcity];
    user.avatar_thumb = [userDefaults objectForKey:kavatar_thumb];
    user.login_type = [userDefaults objectForKey:Klogin_type];
    user.usersig = [userDefaults objectForKey:Kusersig];
    user.isauth = [userDefaults objectForKey:Kisauth];
    user.isUserauth = [userDefaults objectForKey:KisUserauth];

    user.isreg = [userDefaults objectForKey:Kisreg];

    return user;
}

+(NSString *)getOwnID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* ID = [userDefaults objectForKey: KID];
    return ID;
}

+(NSString *)getOwnNicename
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* nicename = [userDefaults objectForKey: KUser_nicename];
    return nicename;
}

+(NSString *)getOwnToken
{

    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefults objectForKey:KToken];
    return token;
}

+(NSString *)getOwnSignature
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *signature = [userDefults objectForKey:KSignature];
    return signature;
}
+(NSString *)getavatar
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *avatar = [NSString stringWithFormat:@"%@",[userDefults objectForKey:KAvatar]];
    return avatar;
}
+(NSString *)getavatarThumb
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *signature = [userDefults objectForKey:kavatar_thumb];
    return signature;
}
+(NSString *)getLevel
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *level = [userDefults objectForKey:Klevel];
    return level;
}
+(NSString *)getSex
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *sex = [userDefults objectForKey:KSex];
    return sex;
}
+(NSString *)getcoin
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *coin = [userDefults objectForKey:KCoin];
    return coin;
}
+(NSString *)level_anchor
{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *level_anchors = [userDefults objectForKey:Klevel_anchor];
    return level_anchors;
}
+(NSString *)lgetUserSign{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *sign = [userDefults objectForKey:Kusersig];
    return sign;

}
+(NSString *)getIsauth{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *isauth = [userDefults objectForKey:Kisauth];
    return isauth;
}
+(NSString *)getIsUserauth{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *Userauth = [userDefults objectForKey:KisUserauth];
    return Userauth;

}
+(NSString *)canshu{
    return @"zh_cn";

//    if ([lagType isEqual:ZH_CN]) {
//
//    }
}
+(void)saveRegisterlogin:(NSString *)isreg{
    [[NSUserDefaults standardUserDefaults] setObject:isreg forKey:Kisreg];
}
+(NSString *)getIsRegisterlogin{
    NSUserDefaults *userDefults = [NSUserDefaults standardUserDefaults];
    NSString *isauth = [userDefults objectForKey:Kisreg];
    return isauth;
}

@end
