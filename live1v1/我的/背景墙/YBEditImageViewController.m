//
//  YBEditImageViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/5/9.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "YBEditImageViewController.h"
#import <Qiniu/QiniuSDK.h>

@interface YBEditImageViewController (){
    UIImageView *originalImageView;
    UIImage *eidtImage;
    CGFloat moveX;
    CGFloat moveY;
}

@end

@implementation YBEditImageViewController
- (void)rightBtnClick{
    [MBProgressHUD showMessage:@"正在上传"];
    CGRect frame;
    if (originalImageView.height < _window_width) {
        frame = CGRectMake(0, (_window_height-originalImageView.height)/2, _window_width, originalImageView.height);
    }else{
        frame = CGRectMake(0, (_window_height-_window_width)/2, _window_width, _window_width);
    }
    eidtImage = [self imageFromView:self.view atFrame:frame];
    if (eidtImage) {
        [self uploadNewThumb];
    }else{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"上传失败"];
    }
}

//获得某个范围内的屏幕图像
- (UIImage *)imageFromView: (UIView *) theView   atFrame:(CGRect)r
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(r);
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  [self ct_imageFromImage:theImage inRect:r];
}
/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *  @param image UIImage image 原始的图片
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
- (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
//    CGFloat scale = [UIScreen mainScreen].scale;
//    CGFloat x= rect.origin.x*scale,
//    y=rect.origin.y*scale,
//    w=rect.size.width*scale,
//    h=rect.size.height*scale;
//    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
}

- (void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    moveX = 0.0;
    moveY = 0.0;
    originalImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_width*(_originalImage.size.height/_originalImage.size.width))];
    originalImageView.center = self.view.center;
    originalImageView.userInteractionEnabled = YES;
    originalImageView.image = _originalImage;
    [self.view addSubview:originalImageView];
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, (_window_height-_window_width)/2)];
    view1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:view1];
    
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(0, (_window_height-_window_width)/2+_window_width, _window_width, (_window_height-_window_width)/2)];
    view2.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    
    
    UIButton *rBtn = [UIButton buttonWithType:0];
    rBtn.frame = CGRectMake(0, 24+statusbarHeight, 40, 40);
    //    _returnBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [rBtn setImage:[UIImage imageNamed:@"video--返回"] forState:0];
    [rBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rBtn];
    
    UIButton *rightBtn = [UIButton buttonWithType:0];
    rightBtn.frame = CGRectMake(_window_width-60, 24+statusbarHeight, 40, 40);
    
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"完成" forState:0];
    rightBtn.titleLabel.font = SYS_Font(15);
    [rightBtn setTitleColor:normalColors forState:0];
    [self.view  addSubview:rightBtn];

    [self.view addSubview:view2];
    
    
    //添加拖拽手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlepanss:)];
    [self.view addGestureRecognizer:pan];
    //添加捏合手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.view addGestureRecognizer:pinchGesture];

}
//拖拽手势方法
- (void) handlepanss: (UIPanGestureRecognizer *)sender{
    //获取手指点
    CGPoint point = [sender translationInView:sender.view];
    NSLog(@"center=====%f         %f",point.x,point.y);
    CGPoint center = CGPointMake(self.view.center.x+moveX, self.view.center.y+moveY);
    center.x += point.x/2;
    center.y += point.y/2;
    //设置移动距离
    originalImageView.center = center;
    //拖拽结束判断图片是否移动出想要裁剪的范围
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (originalImageView.right < _window_width) {
            originalImageView.right = _window_width;
        }
        
        if (originalImageView.x > 0) {
            originalImageView.x = 0;
        }

        if (originalImageView.bottom < _window_height/2 + _window_width/2 ) {
            originalImageView.bottom = _window_height/2 + _window_width/2;
        }

        if (originalImageView.y > (_window_height-_window_width)/2) {
            originalImageView.y = (_window_height-_window_width)/2 ;
        }
        moveX = originalImageView.center.x - self.view.center.x;
        moveY = originalImageView.center.y - self.view.center.y;
    }
}
//捏合手势方法
-(void) pinchGesture:(id)sender
{
    UIPinchGestureRecognizer *gesture = sender;
    //手势改变时
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        //捏合手势中scale属性记录的缩放比例
        originalImageView.transform = CGAffineTransformMakeScale(gesture.scale, gesture.scale);
    }
    //结束后恢复
    if(gesture.state==UIGestureRecognizerStateEnded)
    {
        if (originalImageView.width<_window_width) {
            [UIView animateWithDuration:0.5 animations:^{
                originalImageView.transform = CGAffineTransformIdentity;//取消一切形变
            }];
        }
        if (originalImageView.right < _window_width) {
            originalImageView.right = _window_width;
        }
        
        if (originalImageView.x > 0) {
            originalImageView.x = 0;
        }
        
        if (originalImageView.bottom < _window_height/2 + _window_width/2 ) {
            originalImageView.bottom = _window_height/2 + _window_width/2;
        }
        
        if (originalImageView.y > (_window_height-_window_width)/2) {
            originalImageView.y = (_window_height-_window_width)/2 ;
        }

    }
}
- (void)uploadNewThumb{
    [YBToolClass postNetworkWithUrl:@"Upload.GetQiniuToken" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            NSString *token = minstr([[info firstObject] valueForKey:@"token"]);
            [self uploadPicToQiNiu:token];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"提交失败"];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"提交失败"];
    }];
    
}
- (void)uploadPicToQiNiu:(NSString *)token{
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        
    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    //获取视频和图片
    NSData *imageData = UIImagePNGRepresentation(eidtImage);
    NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"userThumb.png"];
    [upManager putData:imageData key:[NSString stringWithFormat:@"image_%@",imageName] token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            [self uploadEditMessage:key];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"提交失败"];
            return ;
        }
    } option:option];
    
}
- (void)uploadEditMessage:(NSString *)headerName{
    NSString *sign = [YBToolClass sortString:@{@"uid":[Config getOwnID],@"thumb":headerName}];

    [YBToolClass postNetworkWithUrl:[NSString stringWithFormat:@"Wall.setCover&thumb=%@&sign=%@",headerName,sign] andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:msg];
    } fail:^{
        [MBProgressHUD hideHUD];
        
    }];
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
