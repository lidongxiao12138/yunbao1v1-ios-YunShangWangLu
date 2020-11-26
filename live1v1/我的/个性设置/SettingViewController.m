//
//  SettingViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/8.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SettingViewController.h"
#import "BlackUserViewController.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *itemArray;
    UITableView *setTable;
    float MBCache;

}
@property (nonatomic,strong) UISwitch *voiceSwitch;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"个性设置";
    itemArray = @[@"黑名单",@"私信音效",@"关于我们",@"检查更新",@"清除缓存"];
    NSUInteger bytesCache = [[SDImageCache sharedImageCache] getSize];
    //换算成 MB (注意iOS中的字节之间的换算是1000不是1024)
    MBCache = bytesCache/1000/1000;
    setTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, 45*itemArray.count+1) style:0];
    setTable.delegate =self;
    setTable.dataSource =self;
    setTable.scrollEnabled = NO;
    [self.view addSubview:setTable];
    
    UIButton *logOutBtn = [UIButton buttonWithType:0];
    logOutBtn.frame = CGRectMake(0, setTable.bottom+40, _window_width, 50);
    [logOutBtn setBackgroundColor:RGB_COLOR(@"#fafafa", 1)];
    [logOutBtn setTitle:@"退出登录" forState:0];
    [logOutBtn setTitleColor:color32 forState:0];
    logOutBtn.titleLabel.font = SYS_Font(12);
    [logOutBtn addTarget:self action:@selector(logOutBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logOutBtn];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return itemArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"setCell"];
        cell.textLabel.font = SYS_Font(12);
        cell.detailTextLabel.font = SYS_Font(12);
    }
    cell.textLabel.text = itemArray[indexPath.row];
    if (indexPath.row == 0 || indexPath.row == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 1) {
            [cell.contentView addSubview:self.voiceSwitch];
        }else if (indexPath.row == 3) {
            NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];//本地的版本号
            cell.detailTextLabel.text = build;
        }else{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fMB",MBCache];
        }
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self doBlackList];
            break;
        case 1:
            break;
        case 2:
            [self gunayuwomen];
            break;
        case 3:
            [self checkBuild];
            break;
        case 4:
            [self clearCrash];
            break;

        default:
            break;
    }
}
- (void)logOutBtnClick{
    [[YBToolClass sharedInstance] quitLogin];
}
- (void)gunayuwomen{

    YBWebViewController *web = [[YBWebViewController alloc]init];
    web.urls = [NSString stringWithFormat:@"%@/appapi/page/lists",h5url];
    [self.navigationController pushViewController:web animated:YES];
}
- (void)checkBuild{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSNumber *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];//本地
    NSNumber *build = (NSNumber *)[common ipa_ver];//远程
    NSComparisonResult r = [app_build compare:build];
    if (r == NSOrderedAscending || r == NSOrderedDescending) {//可改为if(r == -1L)
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[common app_ios]]];
        [MBProgressHUD hideHUD];
    }else if(r == NSOrderedSame) {//可改为if(r == 0L)
        [MBProgressHUD showError:@"当前已是最新版本"];
        
    }

}
- (void)clearCrash{
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    MBCache = 0;
    [setTable reloadData];
    [MBProgressHUD showError:@"缓存已清除"];
}
- (UISwitch *)voiceSwitch{
    if (!_voiceSwitch) {
       _voiceSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(_window_width-60, 7.5, 50, 30)];
        _voiceSwitch.on = [common voiceSwitch];
        [_voiceSwitch addTarget:self action:@selector(valueChanged) forControlEvents:(UIControlEventValueChanged)];
        _voiceSwitch.transform = CGAffineTransformMakeScale(0.65, 0.65);
    }
    return _voiceSwitch;
}
- (void)valueChanged{
    [common saveSwitch:_voiceSwitch.on];
}
- (void)doBlackList{
    BlackUserViewController *black = [[BlackUserViewController   alloc]init];
    [self.navigationController pushViewController:black animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
