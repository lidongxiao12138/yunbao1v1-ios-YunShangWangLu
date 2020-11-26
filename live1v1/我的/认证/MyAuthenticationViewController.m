//
//  MyAuthenticationViewController.m
//  live1v1
//
//  Created by IOS1 on 2019/4/3.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "MyAuthenticationViewController.h"
#import "authPicCell.h"
#import "TZImagePickerController.h"
#import "authTextCell.h"
#import "authTextViewCell.h"
#import "authImpressCell.h"
#import <Qiniu/QiniuSDK.h>

@interface MyAuthenticationViewController ()<UITableViewDelegate,UITableViewDataSource,authPicCellDelegate,TZImagePickerControllerDelegate,authTextViewCellDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>{
    UITableView *editTable;
    NSArray *leftArray;
    NSArray *placeholdArray;
    NSMutableArray *singlePicArray;
    NSMutableArray *numPicArray;
    NSString *thumbStr;
    NSString *thumbListStr;
    BOOL clickFirst;
    
    UITextField *nameT;
    NSString *nameStr;
    UITextField *phoneT;
    NSString *phoneStr;
    UITextField *sexT;
    NSString *sexStr;
    UITextField *heightT;
    NSString *heightStr;
    UITextField *boadT;
    NSString *boadStr;
    UITextField *starT;
    NSString *starStr;
    UITextField *improssT;
    NSString *improssStr;
    UITextField *cityT;
    NSString *cityStr;

    UITextView *introduceTextV;
    NSString *introduceStr;
    UITextView *autographTextV;
    NSString *autographStr;
    
    
    UIView *cityPickBack;
    UIPickerView *cityPicker;
    //省市区-数组
    NSArray *province;
    NSArray *city;
    NSArray *district;
    
    //省市区-字符串
    NSString *provinceStr;
    NSString *cityStrrrrrrr;
    NSString *districtStr;
    
    NSDictionary *areaDic;
    NSString *selectedProvince;

    UIView *starBackView;
    UIPickerView *starPicker;
    NSArray *starArray;
    NSArray *starShowArray;
    
    UIView *impressBackView;
    NSArray *impressArray;
    UICollectionView *impressColloctionView;
    NSMutableArray *selectImpressA;
    NSArray *sureImpressA;
    authTextCell *impressCell;
    
    NSMutableArray *oldThumbArray;
    NSMutableArray *oldPhotosArray;
    NSMutableArray *oldImpressArray;
}

@end

@implementation MyAuthenticationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"我的认证";
    self.rightBtn.hidden = NO;
    [self.rightBtn setTitle:@"提交" forState:0];
    self.rightBtn.userInteractionEnabled = NO;
    [self.rightBtn setTitleColor:[normalColors colorWithAlphaComponent:0.3] forState:0];
    leftArray = @[@"*请上传一张本人真实照片，将作为列表封面展示",@"*请务必上传至少一张本人真实照片，将作为个人主页背景墙展示",@"真实姓名",@"手机号码",@"性别",@"身高",@"体重",@"星座",@"形象标签",@"所在城市",@"个人介绍",@"个性签名"];
    placeholdArray = @[@"",@"",@"请输入真实姓名(必填)",@"请输入手机号码(必填)",@"请选择性别(必填)",@"请输入身高cm(必填)",@"请输入体重kg(必填)",@"请选择星座(必填)",@"请选择形象标签(必填)",@"请选择所在城市(必填)",@"请编辑个人介绍(必填)",@"请编辑个性签名(必填)"];

    singlePicArray = [NSMutableArray array];
    numPicArray = [NSMutableArray array];
    selectImpressA = [NSMutableArray array];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"area" ofType:@"plist"];
    areaDic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSArray *components = [areaDic allKeys];
    NSArray *sortedArray = [components sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSMutableArray *provinceTmp = [[NSMutableArray alloc] init];
    for (int i=0; i<[sortedArray count]; i++) {
        NSString *index = [sortedArray objectAtIndex:i];
        NSArray *tmp = [[areaDic objectForKey: index] allKeys];
        [provinceTmp addObject: [tmp objectAtIndex:0]];
    }
    //---> //rk_3-7 修复首次加载问题
    province = [[NSArray alloc] initWithArray: provinceTmp];
    NSString *index = [sortedArray objectAtIndex:0];
    //NSString *selected = [province objectAtIndex:0];
    selectedProvince = [province objectAtIndex:0];
    NSDictionary *proviceDic = [NSDictionary dictionaryWithDictionary: [[areaDic objectForKey:index]objectForKey:selectedProvince]];
    
    NSArray *cityArray = [proviceDic allKeys];
    NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [proviceDic objectForKey: [cityArray objectAtIndex:0]]];
    //city = [[NSArray alloc] initWithArray: [cityDic allKeys]];
    
    NSArray *citySortedArray = [cityArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;//递减
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;//上升
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    NSMutableArray *m_array = [[NSMutableArray alloc] init];
    for (int i=0; i<[citySortedArray count]; i++) {
        NSString *index = [citySortedArray objectAtIndex:i];
        NSArray *temp = [[proviceDic objectForKey: index] allKeys];
        [m_array addObject: [temp objectAtIndex:0]];
    }
    city = [NSArray arrayWithArray:m_array];
    NSString *selectedCity = [city objectAtIndex: 0];
    district = [[NSArray alloc] initWithArray: [cityDic objectForKey: selectedCity]];

    starArray = @[@"白羊座",@"金牛座",@"双子座",@"巨蟹座",@"狮子座",@"处女座",@"天秤座",@"天蝎座",@"射手座",@"摩羯座",@"水瓶座",@"双鱼座"];
    starShowArray = @[@"白羊座(3.21-4.19)",@"金牛座(4.20-5.20)",@"双子座(5.21-6.21)",@"巨蟹座(6.22-7.22)",@"狮子座(7.23-8.22)",@"处女座(8.23-9.22)",@"天秤座(9.23-10.23)",@"天蝎座(10.24-11.22)",@"射手座(11.23-12.21)",@"摩羯座(12.22-1.19)",@"水瓶座(1.20-2.18)",@"双鱼座(2.19-3.20)"];

    [self creatUI];
    if (_subDic) {
        provinceStr = minstr([_subDic valueForKey:@"province"]);
        cityStrrrrrrr = minstr([_subDic valueForKey:@"city"]);
        districtStr = minstr([_subDic valueForKey:@"district"]);
        cityStr = [NSString stringWithFormat:@"%@%@%@",provinceStr,cityStrrrrrrr,districtStr];
        heightStr = minstr([_subDic valueForKey:@"height"]);
        phoneStr = minstr([_subDic valueForKey:@"mobile"]);
        sexStr = minstr([_subDic valueForKey:@"sex"]);
        boadStr = minstr([_subDic valueForKey:@"weight"]);
        introduceStr = minstr([_subDic valueForKey:@"intr"]);
        autographStr = minstr([_subDic valueForKey:@"signature"]);
        nameStr = minstr([_subDic valueForKey:@"name"]);
        starStr = minstr([_subDic valueForKey:@"constellation"]);
        oldThumbArray = @[minstr([_subDic valueForKey:@"thumb"])].mutableCopy;
        oldPhotosArray = [[_subDic valueForKey:@"photos_list"] mutableCopy];
        oldImpressArray = [[_subDic valueForKey:@"label_list"] mutableCopy];
        singlePicArray = oldThumbArray;
        numPicArray = oldPhotosArray;
        sureImpressA = oldImpressArray;
        [editTable reloadData];
    }
    
    //性别不可更改
    sexStr = minstr([Config getSex]);
    
}
- (void)creatUI{
    editTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight-ShowDiff) style:0];
    editTable.delegate = self;
    editTable.dataSource = self;
    editTable.separatorStyle = 0;
    [self.view addSubview:editTable];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return leftArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 2) {
        authPicCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"authPicCell_%ld",indexPath.row]];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"authPicCell" owner:nil options:nil] lastObject];
            [cell.picCollectionV registerNib:[UINib nibWithNibName:@"AuthPicCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"AuthPicCollectionCELL"];
        }
        cell.titleL.text = leftArray[indexPath.row];
        cell.delegate = self;
        if (indexPath.row == 0) {
            cell.isSingle = YES;
            cell.picArray = singlePicArray;
            [cell.picCollectionV reloadData];
            [cell.picCollectionV setContentOffset:CGPointMake(0, 0)];
            
        }else{
            cell.isSingle = NO;
            cell.picArray = numPicArray;
            [cell.picCollectionV reloadData];
//            [cell moveToRight];
            
        }
        if (_subDic) {
            cell.hidden = YES;
        }
        return cell;

    }else {
        if (indexPath.row < 10) {
            authTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"authTextCell_%ld",indexPath.row]];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"authTextCell" owner:nil options:nil] lastObject];
            }
            cell.titleL.text = leftArray[indexPath.row];
            cell.textT.placeholder = placeholdArray[indexPath.row];
            [cell.textT addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
            switch (indexPath.row) {
                case 2:
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = YES;
                    cell.textT.userInteractionEnabled = YES;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    cell.textT.text = nameStr;
                    nameT = cell.textT;
                    break;
                case 3:
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = YES;
                    cell.textT.userInteractionEnabled = YES;
                    cell.textT.keyboardType = UIKeyboardTypeNumberPad;
                    cell.textT.text = phoneStr;
                    phoneT = cell.textT;
                    break;
                case 4:
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = NO;
                    cell.textT.userInteractionEnabled = NO;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    if (sexStr) {
                        if ([sexStr isEqual:@"1"]) {
                            cell.textT.text = @"男";
                        }else{
                            cell.textT.text = @"女";
                        }
                    }else{
                        cell.textT.text = sexStr;
                    }
                    sexT = cell.textT;
                    break;
                case 5:
                    cell.rightImgV.hidden = YES;
                    cell.textT.userInteractionEnabled = YES;
                    cell.textT.keyboardType = UIKeyboardTypeNumberPad;
                    cell.textT.text = heightStr;
                    heightT = cell.textT;
                    if (heightStr.length > 0) {
                        cell.lllllll.text = @"cm";
                    }else{
                        cell.lllllll.text = @"";
                    }
                    break;
                case 6:
                    cell.rightImgV.hidden = YES;
                    cell.textT.userInteractionEnabled = YES;
                    cell.textT.keyboardType = UIKeyboardTypeNumberPad;
                    cell.textT.text = boadStr;
                    boadT = cell.textT;
                    if (boadStr.length > 0) {
                        cell.lllllll.text = @"kg";
                    }else{
                        cell.lllllll.text = @"";
                    }
                    break;
                case 7:
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = NO;
                    cell.textT.userInteractionEnabled = NO;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    cell.textT.text = starStr;
                    starT = cell.textT;
                    break;
                case 8:
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = NO;
                    cell.textT.userInteractionEnabled = NO;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    cell.textT.text = improssStr;
                    improssT = cell.textT;

                    if (sureImpressA.count > 0) {
                        cell.textT.hidden = YES;
                        [self creatSelectImpressView:cell];
                    }else{
                        cell.textT.hidden = NO;
                    }
                    break;
                case 9:
                    cell.lllllll.text = @"";
                    cell.rightImgV.hidden = NO;
                    cell.textT.userInteractionEnabled = NO;
                    cell.textT.keyboardType = UIKeyboardTypeDefault;
                    cell.textT.text = cityStr;
                    cityT = cell.textT;
                    break;
                    
                default:
                    break;
            }
            return cell;

        }else{
            authTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"authTextViewCell_%ld",indexPath.row]];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"authTextViewCell" owner:nil options:nil] lastObject];
            }
            cell.delegate = self;
            cell.titleL.text = leftArray[indexPath.row];
            cell.placeholdLabel.text = placeholdArray[indexPath.row];
            if (indexPath.row == 10) {
                cell.isAutograph = NO;
                if (introduceStr.length > 0) {
                    cell.placeholdLabel.hidden = YES;
                }else{
                    cell.placeholdLabel.hidden = NO;
                }
                cell.textV.text = introduceStr;
                introduceTextV = cell.textV;
                cell.wordNumL.text  = [NSString stringWithFormat:@"%ld/40",introduceStr.length];
            }else{
                cell.isAutograph = YES;
                if (autographStr.length > 0) {
                    cell.placeholdLabel.hidden = YES;
                }else{
                    cell.placeholdLabel.hidden = NO;
                }
                cell.textV.text = autographStr;
                autographTextV = cell.textV;
                cell.wordNumL.text  = [NSString stringWithFormat:@"%ld/40",autographStr.length];

            }
            return cell;

        }

    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        if (_subDic) {
            return 0;
        }
        return 140;
    }else if (indexPath.row == 1) {
        if (_subDic) {
            return 0;
        }
        return 200;
    }else{
        if (indexPath.row < 10) {
            return 45;
        }else
        {
            return 120;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 4) {
        [MBProgressHUD showError:@"性别不可更改"];
        return;
        //性别
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:@"请选择性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *manAction = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            sexT.text = @"男";
            sexStr = @"1";
            [self changeRightBtnState];
        }];
        [alertContro addAction:manAction];
        [manAction setValue:color32 forKey:@"_titleTextColor"];

        UIAlertAction *womanAction = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            sexT.text = @"女";
            sexStr = @"2";
            [self changeRightBtnState];
        }];
        [alertContro addAction:womanAction];
        [womanAction setValue:color32 forKey:@"_titleTextColor"];

        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertContro addAction:sureAction];
        [sureAction setValue:color96 forKey:@"_titleTextColor"];

        [self presentViewController:alertContro animated:YES completion:nil];

    }
    if (indexPath.row == 7) {
        //星座
        [self selectStarType];
    }
    if (indexPath.row == 8) {
        //印象
        [self showAllImpressView];
    }
    if (indexPath.row == 9) {
        //城市
        [self selectCityType];
    }

}
#pragma mark ============图片选择=============
- (void)didSelectPicBtn:(BOOL)isSingle{
    clickFirst = isSingle;
    if (isSingle) {
        TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
        imagePC.allowCameraLocation = YES;
        imagePC.allowTakeVideo = NO;
        imagePC.allowPickingVideo = NO;
        imagePC.showSelectBtn = NO;
        imagePC.allowCrop = YES;
        imagePC.allowPickingOriginalPhoto = NO;
        imagePC.cropRect = CGRectMake(0, (_window_height-_window_width)/2, _window_width, _window_width);
        [self presentViewController:imagePC animated:YES completion:nil];
    }else{
        TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:6-numPicArray.count delegate:self];
        imagePC.allowCameraLocation = YES;
        imagePC.allowTakeVideo = NO;
        imagePC.allowPickingVideo = NO;
        [self presentViewController:imagePC animated:YES completion:nil];
    }

}
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    if (clickFirst) {
        singlePicArray = [photos mutableCopy];
        authPicCell *cell = (authPicCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.picArray = singlePicArray;
        [cell.picCollectionV reloadData];

    }else{
        for (UIImage *img in photos) {
            [numPicArray addObject:img];
        }
        authPicCell *cell = (authPicCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.picArray = numPicArray;
        [cell.picCollectionV reloadData];
        [cell moveToRight];
    }
    [self changeRightBtnState];
}

- (void)removeImage:(NSIndexPath *)index andSingle:(BOOL)isSingle{
//    if (isSingle) {
//        [singlePicArray removeObjectAtIndex:index.row];;
//    }else{
//        [numPicArray removeObjectAtIndex:index.row];;
//    }
}
#pragma mark ============输入框=============
- (void)textChange:(UITextField *)textfield{
    if (textfield == nameT) {
        nameStr = textfield.text;
        nameStr = [nameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (textfield == phoneT) {
        phoneStr = textfield.text;
        phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (textfield == heightT) {
        heightStr = textfield.text;
        heightStr = [heightStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        authTextCell *cell = (authTextCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        if (heightStr.length > 0) {
            cell.lllllll.text = @"cm";
        }else{
            cell.lllllll.text = @"";
        }
    }
    if (textfield == boadT) {
        boadStr = textfield.text;
        boadStr = [boadStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        authTextCell *cell = (authTextCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
        if (boadStr.length > 0) {
            cell.lllllll.text = @"kg";
        }else{
            cell.lllllll.text = @"";
        }
    }
    [self changeRightBtnState];
}
- (void)changeStr:(NSString *)str andIsAutograph:(BOOL)isAutograph{
    if (isAutograph) {
        autographStr = str;
    }else{
        introduceStr = str;
    }
    [self changeRightBtnState];
}
- (void)changeRightBtnState{
    if (singlePicArray.count > 0 && numPicArray.count > 0 && nameStr.length > 0 && phoneStr.length > 0&& sexStr.length > 0&& cityStr.length > 0&& heightStr.length > 0&& boadStr.length > 0&& sexStr.length > 0&& starStr.length > 0 && introduceStr.length > 0 && autographStr.length > 0) {
        self.rightBtn.userInteractionEnabled = YES;
        [self.rightBtn setTitleColor:normalColors forState:0];
    }else{
        self.rightBtn.userInteractionEnabled = NO;
        [self.rightBtn setTitleColor:[normalColors colorWithAlphaComponent:0.3] forState:0];

    }
}
#pragma mark ============pickview=============
- (void)selectCityType{
    if (!cityPickBack) {
        cityPickBack = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        cityPickBack.backgroundColor = RGB_COLOR(@"#000000", 0.3);
        [self.view addSubview:cityPickBack];
        
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-240, _window_width, 40)];
        titleView.backgroundColor = RGB_COLOR(@"#ececec", 1);
        [cityPickBack addSubview:titleView];
        UILabel *pickTitleL = [[UILabel alloc]initWithFrame:CGRectMake(_window_width/2-50, 0, 100, 40)];
        pickTitleL.textAlignment = NSTextAlignmentCenter;
//        pickTitleL.text = @"选择地区";
        pickTitleL.font = [UIFont systemFontOfSize:13];
        [titleView addSubview:pickTitleL];
        
        UIButton *cancleBtn = [UIButton buttonWithType:0];
        cancleBtn.frame = CGRectMake(0, 0, 60, 40);
        cancleBtn.tag = 100;
        [cancleBtn setTitle:@"取消" forState:0];
        [cancleBtn setTitleColor:color96 forState:0];
        cancleBtn.titleLabel.font = SYS_Font(13);
        [cancleBtn addTarget:self action:@selector(cityCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:cancleBtn];
        UIButton *sureBtn = [UIButton buttonWithType:0];
        sureBtn.frame = CGRectMake(_window_width-60, 0, 60, 40);
        sureBtn.tag = 101;
        [sureBtn setTitle:@"确定" forState:0];
        sureBtn.titleLabel.font = SYS_Font(13);
        [sureBtn setTitleColor:normalColors forState:0];
        [sureBtn addTarget:self action:@selector(cityCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:sureBtn];
        
        cityPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, _window_height-200, _window_width, 200)];
        cityPicker.backgroundColor = [UIColor whiteColor];
        cityPicker.delegate = self;
        cityPicker.dataSource = self;
        cityPicker.showsSelectionIndicator = YES;
        [cityPicker selectRow: 0 inComponent: 0 animated: YES];
        [cityPickBack addSubview:cityPicker];
    }else{
        cityPickBack.hidden = NO;
    }
    
}
- (void)cityCancleOrSure:(UIButton *)button{
    if (button.tag == 100) {
        //return;
    }else{
        NSInteger provinceIndex = [cityPicker selectedRowInComponent: 0];
        NSInteger cityIndex = [cityPicker selectedRowInComponent: 1];
        NSInteger districtIndex = [cityPicker selectedRowInComponent: 2];
        
        provinceStr = [province objectAtIndex: provinceIndex];
        cityStrrrrrrr = [city objectAtIndex: cityIndex];
        districtStr = [district objectAtIndex:districtIndex];
        NSString *dizhi = [NSString stringWithFormat:@"%@%@%@",provinceStr,cityStrrrrrrr,districtStr];
        cityT.text = dizhi;
        cityStr = dizhi;
    }
    cityPickBack.hidden = YES;
    
}

- (void)selectStarType{
    if (!starBackView) {
        starBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        starBackView.backgroundColor = RGB_COLOR(@"#000000", 0.3);
        [self.view addSubview:starBackView];
        
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-190, _window_width, 40)];
        titleView.backgroundColor = RGB_COLOR(@"#ececec", 1);
        [starBackView addSubview:titleView];
        
        UIButton *cancleBtn = [UIButton buttonWithType:0];
        cancleBtn.frame = CGRectMake(0, 0, 60, 40);
        cancleBtn.tag = 200;
        [cancleBtn setTitle:@"取消" forState:0];
        [cancleBtn setTitleColor:color96 forState:0];
        cancleBtn.titleLabel.font = SYS_Font(13);
        [cancleBtn addTarget:self action:@selector(starCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:cancleBtn];
        UIButton *sureBtn = [UIButton buttonWithType:0];
        sureBtn.frame = CGRectMake(_window_width-60, 0, 60, 40);
        sureBtn.tag = 201;
        [sureBtn setTitle:@"确定" forState:0];
        sureBtn.titleLabel.font = SYS_Font(13);
        [sureBtn setTitleColor:normalColors forState:0];
        [sureBtn addTarget:self action:@selector(starCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:sureBtn];
        
        starPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, _window_height-150, _window_width, 150)];
        starPicker.backgroundColor = [UIColor whiteColor];
        starPicker.delegate = self;
        starPicker.dataSource = self;
        starPicker.showsSelectionIndicator = YES;
        [starPicker selectRow: 0 inComponent: 0 animated: YES];
        [starBackView addSubview:starPicker];
    }else{
        starBackView.hidden = NO;
    }
    
}
- (void)starCancleOrSure:(UIButton *)button{
    if (button.tag == 200) {
        //return;
    }else{
        NSInteger index = [starPicker selectedRowInComponent: 0];
        
        starStr = [starArray objectAtIndex: index];
        starT.text = starStr;
    }
    starBackView.hidden = YES;
    
}

#pragma mark- Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == cityPicker) {

        return 3;
    }else{
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == cityPicker) {

        if (component == 0) {
            return [province count];
        }
        else if (component == 1) {
            return [city count];
        }
        else {
            return [district count];
        }
    }else{
        return [starArray count];
    }
}


#pragma mark- Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == cityPicker) {
        if (component == 0) {
            return [province objectAtIndex: row];
        }
        else if (component == 1) {
            return [city objectAtIndex: row];
        }
        else {
            return [district objectAtIndex: row];
        }
    }else{
        return [starShowArray objectAtIndex: row];
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView == cityPicker) {

        if (component == 0) {
            selectedProvince = [province objectAtIndex: row];
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [areaDic objectForKey: [NSString stringWithFormat:@"%ld", row]]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: selectedProvince]];
            NSArray *cityArray = [dic allKeys];
            NSArray *sortedArray = [cityArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;//递减
                }
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;//上升
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (int i=0; i<[sortedArray count]; i++) {
                NSString *index = [sortedArray objectAtIndex:i];
                NSArray *temp = [[dic objectForKey: index] allKeys];
                [array addObject: [temp objectAtIndex:0]];
            }
            
            city = [[NSArray alloc] initWithArray: array];
            
            NSDictionary *cityDic = [dic objectForKey: [sortedArray objectAtIndex: 0]];
            district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [city objectAtIndex: 0]]];
            [cityPicker selectRow: 0 inComponent: 1 animated: YES];
            [cityPicker selectRow: 0 inComponent: 2 animated: YES];
            [cityPicker reloadComponent: 1];
            [cityPicker reloadComponent: 2];
            
        } else if (component == 1) {
            NSString *provinceIndex = [NSString stringWithFormat: @"%ld", [province indexOfObject: selectedProvince]];
            NSDictionary *tmp = [NSDictionary dictionaryWithDictionary: [areaDic objectForKey: provinceIndex]];
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary: [tmp objectForKey: selectedProvince]];
            NSArray *dicKeyArray = [dic allKeys];
            NSArray *sortedArray = [dicKeyArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSDictionary *cityDic = [NSDictionary dictionaryWithDictionary: [dic objectForKey: [sortedArray objectAtIndex: row]]];
            NSArray *cityKeyArray = [cityDic allKeys];
            
            district = [[NSArray alloc] initWithArray: [cityDic objectForKey: [cityKeyArray objectAtIndex:0]]];
            [cityPicker selectRow: 0 inComponent: 2 animated: YES];
            [cityPicker reloadComponent: 2];
        }
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (pickerView == cityPicker) {

        if (component == 0) {
            return 80;
        }
        else if (component == 1) {
            return 100;
        }
        else {
            return 115;
        }
    }else{
        return _window_width;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    if (pickerView == cityPicker) {

        if (component == 0) {
            myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width/3, 30)];
            myView.textAlignment = NSTextAlignmentCenter;
            myView.text = [province objectAtIndex:row];
            myView.font = [UIFont systemFontOfSize:14];
            myView.backgroundColor = [UIColor clearColor];
        }
        else if (component == 1) {
            myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width/3, 30)];
            myView.textAlignment = NSTextAlignmentCenter;
            myView.text = [city objectAtIndex:row];
            myView.font = [UIFont systemFontOfSize:14];
            myView.backgroundColor = [UIColor clearColor];
        }
        else {
            myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width/3, 30)];
            myView.textAlignment = NSTextAlignmentCenter;
            myView.text = [district objectAtIndex:row];
            myView.font = [UIFont systemFontOfSize:14];
            myView.backgroundColor = [UIColor clearColor];
        }
    }else{
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width, 30)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.text = [starShowArray objectAtIndex:row];
        myView.font = [UIFont systemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];

    }
    return myView;
}
#pragma mark ============印象=============
- (void)showAllImpressView{
    if (impressArray.count > 0) {
        impressBackView.hidden = NO;
    }else{
        [YBToolClass postNetworkWithUrl:@"Auth.GetLabel" andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                impressArray = info;
                [self creatImpressBackView];

            }
        } fail:^{

        }];
    }
}
- (void)creatImpressBackView{
    impressBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    impressBackView.backgroundColor = RGB_COLOR(@"#000000", 0.3);
    [self.view addSubview:impressBackView];
    NSInteger count = 0;
    if (impressArray.count%3 == 0) {
        count = impressArray.count/3;
    }else{
        count = impressArray.count/3+1;
    }
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height-70-ShowDiff-32*count, _window_width, 30)];
    titleView.backgroundColor = RGB_COLOR(@"#ececec", 1);
    [impressBackView addSubview:titleView];
    
    UIButton *cancleBtn = [UIButton buttonWithType:0];
    cancleBtn.frame = CGRectMake(0, 0, 60, 30);
    cancleBtn.tag = 300;
    [cancleBtn setTitle:@"取消" forState:0];
    [cancleBtn setTitleColor:color96 forState:0];
    cancleBtn.titleLabel.font = SYS_Font(13);
    [cancleBtn addTarget:self action:@selector(impressCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:cancleBtn];
    UIButton *sureBtn = [UIButton buttonWithType:0];
    sureBtn.frame = CGRectMake(_window_width-60, 0, 60, 30);
    sureBtn.tag = 301;
    [sureBtn setTitle:@"确定" forState:0];
    sureBtn.titleLabel.font = SYS_Font(13);
    [sureBtn setTitleColor:normalColors forState:0];
    [sureBtn addTarget:self action:@selector(impressCancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:sureBtn];
    
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, titleView.bottom, _window_width, _window_height-titleView.bottom)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [impressBackView addSubview:whiteView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _window_width, 40)];
    label.text = @"请选择形象标签，最多可选择三个";
    label.textColor = color96;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = SYS_Font(11);
    [whiteView addSubview:label];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.itemSize = CGSizeMake(70, 22);
    flow.minimumLineSpacing = 10;
    flow.minimumInteritemSpacing = 10;
    flow.sectionInset = UIEdgeInsetsMake(5, 10,5, 10);
    
    impressColloctionView = [[UICollectionView alloc]initWithFrame:CGRectMake((_window_width-270)/2,40, 270, whiteView.height-40) collectionViewLayout:flow];
    impressColloctionView.delegate   = self;
    impressColloctionView.dataSource = self;
    impressColloctionView.backgroundColor = [UIColor whiteColor];
    [whiteView addSubview:impressColloctionView];
    [impressColloctionView registerNib:[UINib nibWithNibName:@"authImpressCell" bundle:nil] forCellWithReuseIdentifier:@"authImpressCELL"];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return impressArray.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = impressArray[indexPath.row];
//    NSString *str = minstr([dic valueForKey:@"id"]);
    if ([selectImpressA containsObject:dic]) {
        [selectImpressA removeObject:dic];
    }else{
        if (selectImpressA.count == 3) {
            [MBProgressHUD showError:@"最多选择三项"];
            return;
        }
        [selectImpressA addObject:dic];
    }
    [impressColloctionView reloadData];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    authImpressCell *cell = (authImpressCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"authImpressCELL" forIndexPath:indexPath];
    NSDictionary *dic = impressArray[indexPath.row];

//    NSString *str = minstr([dic valueForKey:@"id"]);
    BOOL isCons = NO;
    for (NSDictionary *ssss in selectImpressA) {
        if ([dic isEqual:ssss]) {
            isCons = YES;
        }
    }
    cell.titleL.text = minstr([dic valueForKey:@"name"]);
    UIColor *color= RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);
    cell.titleL.layer.borderColor = color.CGColor;
    if (isCons) {
        cell.titleL.backgroundColor = color;
        cell.titleL.textColor = [UIColor whiteColor];
    }else{
        cell.titleL.textColor = color;
        cell.titleL.backgroundColor = [UIColor clearColor];
    }

    return cell;
}
- (void)impressCancleOrSure:(UIButton *)button{
    if (button.tag == 300) {
        if (sureImpressA.count > 0) {
            selectImpressA = [sureImpressA mutableCopy];
        }
        //return;
    }else{
        if (oldImpressArray.count > 0) {
            [oldImpressArray removeAllObjects];
            sureImpressA = @[];
        }
        sureImpressA = selectImpressA;
        [self creatSelectImpressView:nil];
    }
    impressBackView.hidden = YES;
    
}
- (void)creatSelectImpressView:(authTextCell *)cell{
    if (!cell) {
        cell = (authTextCell *)[editTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:8 inSection:0]];
    }
    
    if (cell) {
        cell.rightImgV.hidden = NO;
        if (sureImpressA.count > 0) {
            cell.textT.hidden = YES;
        }else{
            cell.textT.hidden = NO;
            cell.textT.text = @"";
        }
        [cell.editView removeAllSubviews];
        improssStr = @"";
        CGFloat speace = 0.00;
        for (int i = 0; i < sureImpressA.count; i++) {
            NSDictionary *dic = sureImpressA[i];
            UIColor *color = RGB_COLOR(minstr([dic valueForKey:@"colour"]), 1);;
            CGFloat width = [[YBToolClass sharedInstance] widthOfString:minstr([dic valueForKey:@"name"]) andFont:SYS_Font(11) andHeight:22] + 20;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake((_window_width-100)-width-speace, 11.5, width, 22)];
            label.textColor = [UIColor whiteColor];
            label.layer.cornerRadius = 11;
            label.layer.masksToBounds = YES;
            label.text = minstr([dic valueForKey:@"name"]);
            label.font = SYS_Font(11);
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = color;
            [cell.editView addSubview:label];
            speace += (width + 10);
            if ([dic valueForKey:@"id"]) {
                improssStr = [improssStr stringByAppendingFormat:@"%@,",minstr([dic valueForKey:@"id"])];
            }else{
                improssStr = [improssStr stringByAppendingFormat:@"%@,",minstr([dic valueForKey:@"name"])];
            }
        }
        [self changeRightBtnState];

    }
}
- (void)rightBtnClick{
//    [MBProgressHUD showError:@"已提交"];
    [MBProgressHUD showMessage:@"正在提交认证"];
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
    for (int i = 0; i < singlePicArray.count; i++) {
        if (i == 0) {
            id image = singlePicArray[0];
            if ([image isKindOfClass:[UIImage class]]) {
                NSData *imageData = UIImagePNGRepresentation(image);
                NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"thumb.png"];
                [upManager putData:imageData key:[NSString stringWithFormat:@"image_%@",imageName] token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                    if (info.ok) {
                        thumbStr = key;
                        [self uploadPhotos:token];
                    }else{
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:@"提交失败"];
                        return ;
                    }
                } option:option];
            }else{
                thumbStr = image;
                [self uploadPhotos:token];

            }
        }
    }

}
- (void)uploadPhotos:(NSString *)token{
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        
    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    thumbListStr = @"";
    NSMutableArray *linshiArray = [NSMutableArray array];
    for (int i = 0; i < numPicArray.count; i++) {
        id image = numPicArray[i];
        if ([image isKindOfClass:[UIImage class]]) {
            NSData *imageData = UIImagePNGRepresentation(image);
            NSString *imageName = [YBToolClass getNameBaseCurrentTime:@"thumb.png"];
            [upManager putData:imageData key:[NSString stringWithFormat:@"image%d_%@",i,imageName] token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                if (info.ok) {
                    [linshiArray addObject:key];
                    thumbListStr = [thumbListStr stringByAppendingFormat:@"%@,",key];
                    if (linshiArray.count == numPicArray.count) {
                        [self submitAllMessage];
                    }
                }else{
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"提交失败"];
                    return;
                }
            } option:option];

        }else{
            [linshiArray addObject:image];
            thumbListStr = [thumbListStr stringByAppendingFormat:@"%@,",image];
            if (linshiArray.count == numPicArray.count) {
                [self submitAllMessage];
            }
        }
        NSLog(@"---------------------------%d",i);
    }

}
- (void)submitAllMessage{
    NSDictionary *dic = @{
                          @"thumb":thumbStr,
                          @"photos":thumbListStr,
                          @"name":nameStr,
                          @"mobile":phoneStr,
                          @"sex":sexStr,
                          @"height":heightStr,
                          @"weight":boadStr,
                          @"constellation":starStr,
                          @"label":improssStr,
                          @"province":provinceStr,
                          @"city":cityStrrrrrrr,
                          @"district":districtStr,
                          @"intr":introduceStr,
                          @"signature":autographStr
                          };
    [YBToolClass postNetworkWithUrl:@"Auth.SetAuth" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:msg];
        if (code == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"提交失败"];

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
