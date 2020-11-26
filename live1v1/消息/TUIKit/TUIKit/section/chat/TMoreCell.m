//
//  TMoreCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/21.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TMoreCell.h"
#import "THeader.h"
#import "TUIKit.h"

@implementation TMoreCellData
@end

@implementation TMoreCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];
    
    _title = [[UILabel alloc] init];
    [_title setFont:[UIFont systemFontOfSize:10]];
    [_title setTextColor:color96];
    _title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_title];
}

- (void)defaultLayout
{
}

+ (CGSize)getSize{
    CGSize menuSize = TMoreCell_Image_Size;
    return CGSizeMake(menuSize.width, menuSize.height + TMoreCell_Title_Height);
}

- (void)setData:(TMoreCellData *)data
{
    //set data
    _image.image = [[[TUIKit sharedInstance] getConfig] getResourceFromCache:data.path];
    [_title setText:data.title];
    //update layout
    CGSize menuSize = TMoreCell_Image_Size;
    _image.frame = CGRectMake(menuSize.width/4, menuSize.width/4, menuSize.width/2, menuSize.width/2);
    _title.frame = CGRectMake(0, menuSize.height, menuSize.width, TMoreCell_Title_Height);
}
@end
