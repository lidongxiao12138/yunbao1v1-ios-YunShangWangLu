#import "common.h"
NSString *const  share_title = @"share_title";
NSString *const  share_des = @"share_des";
NSString *const  wx_siteurl = @"wx_siteurl";
NSString *const  ipa_ver = @"ipa_ver";
NSString *const  app_ios = @"app_ios";
NSString *const  ios_shelves = @"ios_shelves";
NSString *const  name_coin = @"name_coin";
NSString *const  name_votes = @"name_votes";

NSString *const  maintain_switch = @"maintain_switch";
NSString *const  maintain_tips = @"maintain_tips";
NSString *const  share_type = @"share_type";


NSString *const  agorakitid = @"agorakitid";

NSString *const  personc = @"personc";
NSString *const  liveclass = @"liveclass";

NSString *const  levelUser = @"levelUser";
NSString *const  levelanchorlist = @"levelanchorlist";

NSString *const  sprout_white = @"sprout_white";
NSString *const  sprout_skin = @"sprout_skin";
NSString *const  sprout_saturated = @"sprout_saturated";
NSString *const  sprout_pink = @"sprout_pink";
NSString *const  sprout_eye = @"sprout_eye";
NSString *const  sprout_face = @"sprout_face";
NSString *const  jpush_sys_roomid = @"jpush_sys_roomid";
NSString *const  qiniu_domain = @"qiniu_domain";
NSString *const  video_share_title = @"share_video_title";
NSString *const  video_share_des = @"share_video_des";

NSString *const  video_audit_switch = @"video_audit_switch";
NSString *const  tximgfolder = @"tximgfolder";
NSString *const  txvideofolder = @"txvideofolder";
NSString *const  cloudtype = @"cloudtype";

NSString *const  share_agent_title = @"share_agent_title";
NSString *const  share_agent_des = @"share_agent_des";
NSString *const  im_tips = @"im_tips";
NSString *const  Ksprout_key = @"sprout_key";

@implementation common
+ (void)saveProfile:(liveCommon *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:user.share_title forKey:share_title];
    [userDefaults setObject:user.share_des forKey:share_des];
    [userDefaults setObject:user.wx_siteurl forKey:wx_siteurl];
    [userDefaults setObject:user.ipa_ver forKey:ipa_ver];
    [userDefaults setObject:user.app_ios forKey:app_ios];
    [userDefaults setObject:user.ios_shelves forKey:ios_shelves];
    [userDefaults setObject:user.name_coin forKey:name_coin];
    [userDefaults setObject:user.name_votes forKey:name_votes];
    
    [userDefaults setObject:user.maintain_switch forKey:maintain_switch];
    [userDefaults setObject:user.maintain_tips forKey:maintain_tips];
    [userDefaults setObject:user.share_type forKey:share_type];
    [userDefaults setObject:user.userLevel forKey:levelUser];
    [userDefaults setObject:user.levelanchorlist forKey:levelanchorlist];
    
    [userDefaults setObject:user.sprout_white forKey:sprout_white];
    [userDefaults setObject:user.sprout_skin forKey:sprout_skin];
    [userDefaults setObject:user.sprout_saturated forKey:sprout_saturated];
    [userDefaults setObject:user.sprout_pink forKey:sprout_pink];
    [userDefaults setObject:user.sprout_eye forKey:sprout_eye];
    [userDefaults setObject:user.sprout_face forKey:sprout_face];
    [userDefaults setObject:user.jpush_sys_roomid forKey:jpush_sys_roomid];
    [userDefaults setObject:user.qiniu_domain forKey:qiniu_domain];
    [userDefaults setObject:user.share_agent_title forKey:video_share_title];
    [userDefaults setObject:user.share_video_des forKey:video_share_des];
    [userDefaults setObject:user.video_audit_switch forKey:video_audit_switch];
    [userDefaults setObject:user.tximgfolder forKey:tximgfolder];
    [userDefaults setObject:user.txvideofolder forKey:txvideofolder];
    [userDefaults setObject:user.cloudtype forKey:cloudtype];
    [userDefaults setObject:user.share_agent_title forKey:share_agent_title];
    [userDefaults setObject:user.share_agent_des forKey:share_agent_des];
    [userDefaults setObject:user.im_tips forKey:im_tips];
    [userDefaults setObject:user.sprout_key forKey:Ksprout_key];

    [userDefaults synchronize];
}
+ (void)clearProfile{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:share_title];
    [userDefaults setObject:nil forKey:share_des];
    [userDefaults setObject:nil forKey:wx_siteurl];
    [userDefaults setObject:nil forKey:ipa_ver];
    [userDefaults setObject:nil forKey:app_ios];
    [userDefaults setObject:nil forKey:ios_shelves];
    [userDefaults setObject:nil forKey:name_coin];
    [userDefaults setObject:nil forKey:name_votes];
    
    [userDefaults setObject:nil forKey:maintain_tips];
    [userDefaults setObject:nil forKey:maintain_switch];
    [userDefaults setObject:nil forKey:share_type];
    [userDefaults setObject:nil forKey:liveclass];
    [userDefaults setObject:nil forKey:qiniu_domain];
    [userDefaults setObject:nil forKey:video_share_title];
    [userDefaults setObject:nil forKey:video_share_des];
    [userDefaults setObject:nil forKey:im_tips];
    [userDefaults setObject:nil forKey:Ksprout_key];

    [userDefaults synchronize];
}
+ (liveCommon *)myProfile{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    liveCommon *user = [[liveCommon alloc] init];
    
    user.share_title = [userDefaults objectForKey:share_title];
    user.share_des = [userDefaults objectForKey:share_des];
    user.wx_siteurl = [userDefaults objectForKey:wx_siteurl];
    user.ipa_ver = [userDefaults objectForKey:ipa_ver];
    user.app_ios = [userDefaults objectForKey:app_ios];
    user.ios_shelves = [userDefaults objectForKey:ios_shelves];
    user.name_coin = [userDefaults objectForKey:name_coin];
    user.name_votes = [userDefaults objectForKey:name_votes];
    
    user.maintain_switch = [userDefaults objectForKey:maintain_switch];
    user.maintain_tips = [userDefaults objectForKey:maintain_tips];
    user.share_type = [userDefaults objectForKey:share_type];
    user.userLevel = [userDefaults objectForKey:levelUser];
    user.levelanchorlist = [userDefaults objectForKey:levelanchorlist];
    user.im_tips = [userDefaults objectForKey:im_tips];
    user.sprout_key = [userDefaults objectForKey:Ksprout_key];

    return user;
}
+(NSString *)name_coin{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* name_coinss = [userDefaults objectForKey: name_coin];
    return name_coinss;
}
+(NSString *)name_votes{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* name_votesss = [userDefaults objectForKey: name_votes];
    return name_votesss;
}
+(NSString *)share_title{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* share_titles = [userDefaults objectForKey: share_title];
    return share_titles;
}
+(NSString *)share_des{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* share_dess = [userDefaults objectForKey: share_des];
    return share_dess;
}
+(NSString *)wx_siteurl{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* wx_siteurls = [userDefaults objectForKey: wx_siteurl];
    return wx_siteurls;
}
+(NSString *)ipa_ver{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* ipa_vers = [userDefaults objectForKey: ipa_ver];
    return ipa_vers;
}
+(NSString *)app_ios{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* app_ioss = [userDefaults objectForKey: app_ios];
    return app_ioss;
}
+(NSString *)ios_shelves{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* ios_shelvess = [userDefaults objectForKey: ios_shelves];
    return ios_shelvess;
}

+(NSString *)maintain_tips {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *maintain_tipss = [userDefaults objectForKey: maintain_tips];
    
    return maintain_tipss;
}
+(NSString *)maintain_switch {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *maintain_switchs = [userDefaults objectForKey:maintain_switch];
    
    return maintain_switchs;
}
+(NSArray  *)share_type{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *share_typess = [userDefaults objectForKey:share_type];
    return share_typess;
    
}
+(NSArray *)liveclass{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *liveclasss = [userDefaults objectForKey:liveclass];
    return liveclasss;
}



//保存声网
+(void)saveagorakitid:(NSString *)agorakitids{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:agorakitids forKey:agorakitid];
    [userDefaults synchronize];
}
+(NSString  *)agorakitid{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *agorakitidss = [userDefaults objectForKey:agorakitid];
    return agorakitidss;
    
}
//保存个人中心选项缓存
+(void)savepersoncontroller:(NSArray *)arrays{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:arrays forKey:personc];
    [userDefaults synchronize];
}
+(NSArray *)getpersonc{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *personcs = [userDefaults objectForKey:personc];
    return personcs;
    
}
+(NSString *)getUserLevelMessage:(NSString *)level{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *levelArr = [userDefaults objectForKey:levelUser];
    NSDictionary *dic;
    if ([levelArr isKindOfClass:[NSArray class]]) {
        if ([level integerValue] - 1 < levelArr.count) {
            dic = levelArr[[level integerValue] - 1];
        }else{
            dic = [levelArr lastObject];
        }
        return minstr([dic valueForKey:@"thumb"]);
    }
    return nil;
}
+(NSString *)getAnchorLevelMessage:(NSString *)level{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *levelArr = [userDefaults objectForKey:levelanchorlist];
    NSDictionary *dic;
    if ([levelArr isKindOfClass:[NSArray class]]) {
        if ([level integerValue] - 1 < levelArr.count) {
            dic = levelArr[[level integerValue] - 1];
        }else{
            dic = [levelArr lastObject];
        }
        return minstr([dic valueForKey:@"thumb"]);

    }
    return nil;
}


+(NSString *)sprout_white{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_white];
    return sprout_keyss;
    
}
+(NSString *)sprout_skin{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_skin];
    return sprout_keyss;
    
}
+(NSString *)sprout_saturated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_saturated];
    return sprout_keyss;
    
}
+(NSString *)sprout_pink{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_pink];
    return sprout_keyss;
    
}
+(NSString *)sprout_eye{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_eye];
    return sprout_keyss;
    
}
+(NSString *)sprout_face{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:sprout_face];
    return sprout_keyss;
    
}
+(NSString *)jpush_sys_roomid{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:jpush_sys_roomid];
    return sprout_keyss;
}
+(NSString *)qiniu_domain{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *sprout_keyss = [userDefaults objectForKey:qiniu_domain];
    return sprout_keyss;
}
+(NSString *)video_share_des{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]init ];
    NSString* share_titles = [userDefaults objectForKey: video_share_des];
    return share_titles;
}
+(NSString *)video_share_title{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]init ];
    NSString* share_titles = [userDefaults objectForKey: video_share_title];
    return share_titles;
}
#pragma mark - 后台审核开关
+(NSString *)getAuditSwitch {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *auditSwitch = [userDefaults objectForKey:video_audit_switch];
    return auditSwitch;
}
#pragma mark - 腾讯空间
+(NSString *)getTximgfolder {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *auditSwitch = [userDefaults objectForKey:tximgfolder];
    return auditSwitch;
}
+(NSString *)getTxvideofolder {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *auditSwitch = [userDefaults objectForKey:txvideofolder];
    return auditSwitch;
}
#pragma mark - 存储类型（七牛-腾讯）
+(NSString *)cloudtype{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *cloudtypess = [userDefaults objectForKey:cloudtype];
    return cloudtypess;
}
+(NSString *)currencyCode:(NSString *)type{
    if ([type isEqual:@"1"]) {
        return @"HK$";
    }else if ([type isEqual:@"2"]){
        return @"NT$";
    }else{
        return @"¥";
    }
}
+(BOOL)voiceSwitch{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL voice = [userDefaults boolForKey:@"voiceSwitch"];
    return voice;

}
+(void)saveSwitch:(BOOL)swtich{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:swtich forKey:@"voiceSwitch"];
    
}
+(NSString *)share_agent_title{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]init ];
    NSString* share_titles = [userDefaults objectForKey: share_agent_title];
    return share_titles;

}
+(NSString *)share_agent_des{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]init ];
    NSString* share_titles = [userDefaults objectForKey: share_agent_des];
    return share_titles;

}
+(NSString *)im_tips{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]init ];
    NSString* tip = [userDefaults objectForKey: im_tips];
    return tip;
    
}
+(NSString *)getTISDKKey{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]init ];
    NSString* key = [userDefaults objectForKey: Ksprout_key];
    return key;
}

@end
