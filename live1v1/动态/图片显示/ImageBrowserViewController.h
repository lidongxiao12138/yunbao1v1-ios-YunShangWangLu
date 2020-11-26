//
//  ImageBrowserViewController.h
//  ImageBrowser
//
//  Created by msk on 16/9/1.
//  Copyright © 2016年 msk. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 * 跳转方式
 */
typedef NS_ENUM(NSUInteger,PhotoBroswerVCType) {
    
    //modal
    PhotoBroswerVCTypePush=0,
    
    //push
    PhotoBroswerVCTypeModal,
    
    //zoom
    PhotoBroswerVCTypeZoom,
};

typedef void (^imageDeleteEvent)(NSMutableArray *imgearr) ;
@interface ImageBrowserViewController : UIViewController


@property(nonatomic,copy)imageDeleteEvent backEvent;
/**
 *  显示图片
 */
+(void)show:(UIViewController *)handleVC type:(PhotoBroswerVCType)type hideDelete:(BOOL)isDelete index:(NSUInteger)index imagesBlock:(NSArray *(^)())imagesBlock retrunBack:(imageDeleteEvent)back;
@end
