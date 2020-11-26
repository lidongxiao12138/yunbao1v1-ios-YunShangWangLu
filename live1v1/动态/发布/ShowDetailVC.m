//
//  ShowDetailVC.m
//  live1v1
//
//  Created by ybRRR on 2019/8/2.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "ShowDetailVC.h"
#import <TXLiteAVSDK_Professional/TXLivePlayer.h>

@interface ShowDetailVC ()<TXLivePlayListener>
{
    UIImageView *playVideoImg;
    TXLivePlayer *_livePlayer;

}
@end

@implementation ShowDetailVC

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (_livePlayer) {
        [_livePlayer stopPlay];
//        _livePlayer = nil;
    }
}
-(void)hideSelf{
    [[MXBADelegate sharedAppDelegate]popViewController:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.returnBtn.hidden = YES;
    UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)];
    [self.view addGestureRecognizer:hideTap];

    if (![self.fromStr isEqual:@"trendlist"]) {
        self.rightBtn.hidden = NO;
        [self.rightBtn setImage:[UIImage imageNamed:@"trends删除"] forState:0];
        [self.rightBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];

    }
    playVideoImg = [[UIImageView alloc]init];
    playVideoImg.frame = CGRectMake(0, 0, _window_width, _window_height);
    [self.view addSubview:playVideoImg];
    [self.view sendSubviewToBack:playVideoImg];
    
    _livePlayer  = [[TXLivePlayer alloc] init];
    _livePlayer.delegate = self;
    [_livePlayer setupVideoWidget:CGRectZero containView:playVideoImg insertIndex:0];
    [_livePlayer startPlay:self.videoPath type:PLAY_TYPE_LOCAL_VIDEO];
    [_livePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
}
#pragma mark TXLivePlayListener
-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_PLAY_END) {
            [_livePlayer startPlay:self.videoPath type:PLAY_TYPE_LOCAL_VIDEO];
            return;
        }
    });
    
}

-(void)deleteClick{
    UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:@"要删除此视频吗？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertContro addAction:cancleAction];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.deleteEvent) {
            self.deleteEvent(@"视频");

        }
        [[MXBADelegate sharedAppDelegate]popViewController:YES];
    }];
    [sureAction setValue:[UIColor redColor] forKey:@"_titleTextColor"];
    [alertContro addAction:sureAction];
    [self presentViewController:alertContro animated:YES completion:nil];

}

@end
