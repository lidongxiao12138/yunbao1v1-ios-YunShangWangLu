//
//  ImageBrowserViewController.m
//  ImageBrowser
//
//  Created by msk on 16/9/1.
//  Copyright © 2016年 msk. All rights reserved.
//

#import "ImageBrowserViewController.h"
#import "PhotoView.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ImageBrowserViewController ()<UIScrollViewDelegate,PhotoViewDelegate>{
    
    NSMutableArray *_subViewArray;//scrollView的所有子视图
    
    UILabel *indexLb;
    NSUInteger currentIndex;

}

/** 背景容器视图 */
@property(nonatomic,strong) UIScrollView *scrollView;

/** 外部操作控制器 */
@property (nonatomic,weak) UIViewController *handleVC;

/** 图片浏览方式 */
@property (nonatomic,assign) PhotoBroswerVCType type;

/** 图片数组 */
@property (nonatomic,strong) NSMutableArray *imagesArray;

/** 初始显示的index */
@property (nonatomic,assign) NSUInteger index;

/** 圆点指示器 */
@property(nonatomic,strong) UIPageControl *pageControl;

/** 记录当前的图片显示视图 */
@property(nonatomic,strong) PhotoView *photoView;

@property(nonatomic,strong)UIButton *deleteBtn;

@property(nonatomic,assign)BOOL hideBool;
@end

@implementation ImageBrowserViewController

-(instancetype)init{
    
    self=[super init];
    if (self) {
        _subViewArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}
-(void)returnBtnClick{
    [self hideScanImageVC];
}
-(void)creatNavi {
    
    UIView *navi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _window_width, 64+statusbarHeight)];
    navi.backgroundColor = [UIColor blackColor];
    [self.view addSubview:navi];
    
    
    UIButton *retrunBtn = [UIButton buttonWithType:0];
    retrunBtn.frame = CGRectMake(10, 25+statusbarHeight, 30, 30);
    [retrunBtn setImage:[UIImage imageNamed:@"white_backImg"] forState:0];
    [retrunBtn addTarget:self action:@selector(returnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navi addSubview:retrunBtn];
    
    indexLb = [[UILabel alloc]init];
    indexLb.frame = CGRectMake(100, 22+statusbarHeight, 80, 30);
    indexLb.textColor = [UIColor whiteColor];
    indexLb.font = [UIFont systemFontOfSize:15];
    indexLb.textAlignment = NSTextAlignmentCenter;
    [navi addSubview:indexLb];
    indexLb.centerX = navi.centerX;
    
    _deleteBtn = [UIButton buttonWithType:0];
    _deleteBtn.frame = CGRectMake(_window_width-60, 22+statusbarHeight, 40, 40);
    [_deleteBtn setImage:[UIImage imageNamed:@"trends删除white"] forState:0];
    _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
    //    publishBtn.enabled = NO;
    _deleteBtn.hidden = self.hideBool;
    [navi addSubview:_deleteBtn];
    
//    [[YBToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 63+statusbarHeight, _window_width, 1) andColor:colorf5 andView:navi];
    
}
-(void)deleteBtnClick{
    NSLog(@"imagebbuuuuu_---:%ld",currentIndex);
    if (currentIndex ==  0) {
        [self.imagesArray removeObjectAtIndex:currentIndex];
        if (self.imagesArray.count == 0) {
            if (self.backEvent) {
                self.backEvent(self.imagesArray);
            }
            [self hideScanImageVC];
            return;
        }else{
            _scrollView.contentSize = CGSizeMake(_window_width*self.imagesArray.count-1, HEIGHT-64-statusbarHeight);
            [self loadPhote:0];

        }
    }else{
        [self.imagesArray removeObjectAtIndex:currentIndex];
        _scrollView.contentSize = CGSizeMake(_window_width*self.imagesArray.count, HEIGHT-64-statusbarHeight);
        [self loadPhote:currentIndex-1];

    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor blackColor];
    [self creatNavi];
    //去除自动处理
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //设置contentSize
    self.scrollView.contentSize = CGSizeMake(WIDTH * self.imagesArray.count, 0);
    
    for (int i = 0; i < self.imagesArray.count; i++) {
        [_subViewArray addObject:[NSNull class]];
    }
    
    self.scrollView.contentOffset = CGPointMake(WIDTH*self.index, 0);//此句代码需放在[_subViewArray addObject:[NSNull class]]之后，因为其主动调用scrollView的代理方法，否则会出现数组越界
    
//    if (self.imagesArray.count==1) {
//        _pageControl.hidden=YES;
//    }else{
//        self.pageControl.currentPage=self.index;
//    }
    currentIndex = 0;
    [self loadPhote:self.index];//显示当前索引的图片
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCurrentVC:)];
    [self.view addGestureRecognizer:tap];//为当前view添加手势，隐藏当前显示窗口
}

-(void)hideCurrentVC:(UIGestureRecognizer *)tap{
    [self hideScanImageVC];
}

#pragma mark - 显示图片
-(void)loadPhote:(NSInteger)index{
    
    if (index<0 || index >=self.imagesArray.count) {
        return;
    }
    indexLb.text =[NSString stringWithFormat:@"%ld/%ld",index+1,self.imagesArray.count];

    id currentPhotoView = [_subViewArray objectAtIndex:index];
    if (![currentPhotoView isKindOfClass:[PhotoView class]]) {
        //url数组或图片数组
        CGRect frame = CGRectMake(index*_scrollView.frame.size.width, 0, _window_width, self.scrollView.height);
        
        if ([[self.imagesArray firstObject] isKindOfClass:[UIImage class]]) {
            PhotoView *photoV = [[PhotoView alloc] initWithFrame:frame withPhotoImage:[self.imagesArray objectAtIndex:index]];
            photoV.delegate = self;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewArray replaceObjectAtIndex:index withObject:photoV];
            self.photoView=photoV;
        }else if ([[self.imagesArray firstObject] isKindOfClass:[NSString class]]){
            PhotoView *photoV = [[PhotoView alloc] initWithFrame:frame withPhotoUrl:[self.imagesArray objectAtIndex:index]];
            photoV.delegate = self;
            [self.scrollView insertSubview:photoV atIndex:0];
            [_subViewArray replaceObjectAtIndex:index withObject:photoV];
            self.photoView=photoV;
        }
    }
}

#pragma mark - 生成显示窗口
+(void)show:(UIViewController *)handleVC type:(PhotoBroswerVCType)type hideDelete:(BOOL)isDelete index:(NSUInteger)index imagesBlock:(NSArray *(^)())imagesBlock retrunBack:(imageDeleteEvent)back{
    
    NSArray *photoModels = imagesBlock();//取出相册数组
    
    if(photoModels == nil || photoModels.count == 0) {
        return;
    }
    
    ImageBrowserViewController *imgBrowserVC = [[self alloc] init];
    
    if(index >= photoModels.count){
        return;
    }
    
    imgBrowserVC.index = index;
    
    imgBrowserVC.imagesArray = photoModels;
    
    imgBrowserVC.type =type;
    
    imgBrowserVC.backEvent = back;
    
    imgBrowserVC.handleVC = handleVC;
    imgBrowserVC.hideBool = isDelete;
    
    [imgBrowserVC show]; //展示
}

/** 真正展示 */
-(void)show{
    
    switch (_type) {
        case PhotoBroswerVCTypePush://push
            
            [self pushPhotoVC];
            
            break;
        case PhotoBroswerVCTypeModal://modal
            
            [self modalPhotoVC];
            
            break;
            
        case PhotoBroswerVCTypeZoom://zoom
            
            [self zoomPhotoVC];
            
            break;
            
        default:
            break;
    }
}

/** push */
-(void)pushPhotoVC{
    
    [_handleVC.navigationController pushViewController:self animated:YES];
}


/** modal */
-(void)modalPhotoVC{
    
    [_handleVC presentViewController:self animated:YES completion:nil];
}

/** zoom */
-(void)zoomPhotoVC{
    
    //拿到window
    UIWindow *window = _handleVC.view.window;
    
    if(window == nil){
        NSLog(@"错误：窗口为空！");
        return;
    }
    
    self.view.frame=[UIScreen mainScreen].bounds;
    
    [window addSubview:self.view]; //添加视图
    
    [_handleVC addChildViewController:self]; //添加子控制器
}

#pragma mark - 隐藏当前显示窗口
-(void)hideScanImageVC{
    
    switch (_type) {
        case PhotoBroswerVCTypePush://push
            
            [self.navigationController popViewControllerAnimated:YES];
            
            break;
        case PhotoBroswerVCTypeModal://modal
            
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
            
        case PhotoBroswerVCTypeZoom://zoom
            
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            
            break;
            
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page<0||page>=self.imagesArray.count) {
        return;
    }
//    self.pageControl.currentPage = page;
    currentIndex = page;
    indexLb.text = [NSString stringWithFormat:@"%ld/%ld",page+1,self.imagesArray.count];
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[PhotoView class]]) {
            PhotoView *photoV=(PhotoView *)[_subViewArray objectAtIndex:page];
            if (photoV!=self.photoView) {
                [self.photoView.scrollView setZoomScale:1.0 animated:YES];
                self.photoView=photoV;
            }
        }
    }
    
    [self loadPhote:page];
}

#pragma mark - PhotoViewDelegate
-(void)tapHiddenPhotoView{
    [self hideScanImageVC];//隐藏当前显示窗口
}

#pragma mark - 懒加载
-(UIScrollView *)scrollView{
    
    if (_scrollView==nil) {
        _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, WIDTH, HEIGHT-64-statusbarHeight)];
        _scrollView.delegate=self;
        _scrollView.pagingEnabled=YES;
        _scrollView.contentOffset=CGPointZero;
        //设置最大伸缩比例
        _scrollView.maximumZoomScale=3;
        //设置最小伸缩比例
        _scrollView.minimumZoomScale=1;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIPageControl *)pageControl{
    if (_pageControl==nil) {
        UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-40, WIDTH, 30)];
        bottomView.backgroundColor=[UIColor clearColor];
        _pageControl = [[UIPageControl alloc] initWithFrame:bottomView.bounds];
        _pageControl.currentPage = self.index;
        _pageControl.numberOfPages = self.imagesArray.count;
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:153 green:153 blue:153 alpha:1];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:235 green:235 blue:235 alpha:0.6];
        [bottomView addSubview:_pageControl];
        [self.view addSubview:bottomView];
    }
    return _pageControl;
}

#pragma mark - 系统自带代码
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
