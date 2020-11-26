//
//  liveCommon.m
//  
//
//  Created by 王敏欣 on 2017/1/18.
//
//
#import "liveCommon.h"
@implementation liveCommon
-(instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if(self)
    {
        
        _share_title = minstr([dic valueForKey:@"share_title"]);
        _share_des = minstr([dic valueForKey:@"share_des"]);
        _wx_siteurl = minstr([dic valueForKey:@"wx_siteurl"]);
        _ipa_ver = minstr([dic valueForKey:@"ipa_ver"]);
        _app_ios = minstr([dic valueForKey:@"ipa_url"]);
        _ios_shelves =[NSString stringWithFormat:@"%@",[dic valueForKey:@"ios_shelves"]];
        _name_coin = [NSString stringWithFormat:@"%@",[dic valueForKey:@"name_coin"]];
        _name_votes = [NSString stringWithFormat:@"%@",[dic valueForKey:@"name_votes"]];
        
        _maintain_switch = [NSString stringWithFormat:@"%@",[dic valueForKey:@"maintain_switch"]];
        _maintain_tips = [NSString stringWithFormat:@"%@",[dic valueForKey:@"maintain_tips"]];
        
        _userLevel = [dic valueForKey:@"levellist"];
        _levelanchorlist = [dic valueForKey:@"levelanchorlist"];
        
        _sprout_eye = [NSString stringWithFormat:@"%@",[dic valueForKey:@"sprout_eye"]];
        _sprout_white = [NSString stringWithFormat:@"%@",[dic valueForKey:@"sprout_white"]];
        _sprout_key = [NSString stringWithFormat:@"%@",[dic valueForKey:@"sprout_key"]];
        _sprout_pink = [NSString stringWithFormat:@"%@",[dic valueForKey:@"sprout_pink"]];
        _sprout_face = [NSString stringWithFormat:@"%@",[dic valueForKey:@"sprout_face"]];
        _sprout_saturated = [NSString stringWithFormat:@"%@",[dic valueForKey:@"sprout_saturated"]];
        _sprout_skin = [NSString stringWithFormat:@"%@",[dic valueForKey:@"sprout_skin"]];
        _jpush_sys_roomid = [NSString stringWithFormat:@"%@",[dic valueForKey:@"jpush_sys_roomid"]];
        _share_video_title = minstr([dic valueForKey:@"share_video_title"]);
        _share_video_des = minstr([dic valueForKey:@"share_video_des"]);
        _qiniu_domain = minstr([dic valueForKey:@"qiniu_domain"]);

        _tximgfolder = [NSString stringWithFormat:@"%@",[dic valueForKey:@"tximgfolder"]];
        _txvideofolder = minstr([dic valueForKey:@"txvideofolder"]);
        _video_audit_switch = minstr([dic valueForKey:@"video_audit_switch"]);
        _cloudtype = minstr([dic valueForKey:@"cloudtype"]);
        _share_agent_des = minstr([dic valueForKey:@"share_agent_des"]);
        _share_agent_title = minstr([dic valueForKey:@"share_agent_title"]);
        _im_tips = minstr([dic valueForKey:@"im_tips"]);

        id shareTYPE = [dic valueForKey:@"share_type"];
        if ([shareTYPE isKindOfClass:[NSArray class]]) {
            _share_type = [dic valueForKey:@"share_type"];
        }else{
            _share_type = @[];
        }

    }
    return self;
}
+(instancetype)modelWithDic:(NSDictionary *)dic
{
    return [[self alloc] initWithDic:dic];
}
@end
