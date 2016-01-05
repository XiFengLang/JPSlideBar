//
//  JPSlideBarViewController.m
//  JPSlideBar
//
//  Created by apple on 15/12/30.
//  Copyright © 2015年 XiFengLang. All rights reserved.
//

#import "ScrollTestVC.h"
#import "JPBaseTableViewController.h"
@interface ScrollTestVC ()
{
    NSArray * titles;
}
@property (nonatomic, strong)UIScrollView * scrollView;
@property (nonatomic, strong)JPSlideBar * slideBar;

@end

@implementation ScrollTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    titles = @[@"游客",@"待",@"VIP",@"腾讯百度",@"黑名单",@"特斯拉",@"阿里巴巴"];
    titles = @[@"游客",@"待",@"VIP",@"阿里巴巴"];
    
    [self initializeUI];
    
#pragma mark -【1、初始化并显示底层毛玻璃/有数据再配置slideBar】
    self.slideBar = [JPSlideBar showInViewController:self
                                        frameOriginY:64
                                           itemSpace:30
                                 slideBarSliderStyle:JPSlideBarStyleShowSliderAndChangeColor];
    
    
    [self.slideBar configureSlideBarWithTitles:titles
                                     titleFont:[UIFont systemFontOfSize:18]
                              normalTitleRGBColor:JCBLACK_COLOR
                            selectedTitleRGBColor:JCYELLOW_COLOR
                                 selectedBlock:^(NSInteger index) {
                                     CGFloat scrollX = CGRectGetWidth(self.scrollView.bounds) * index;
                                     [self.scrollView setContentOffset:CGPointMake(scrollX, 0)];
                                 }];
    
    // 设置背景颜色，默认毛玻璃效果
    //[self.slideBar setSlideBarBackgroudColorIfNecessary:[UIColor lightGrayColor]];
    
#pragma mark -【2、方法1、增加KVO观察者】,不太推荐这种方法，模拟器上测试KVO不够流畅
    //[self.scrollView addObserver:self.slideBar forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}



#pragma mark -【2、推荐方法2、实现scrollViewDidScroll方法，实现更新】
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.slideBar updateSlideBarWhenScrollViewDidScrollWithOffsetX:scrollView.contentOffset.x];
}

#pragma mark -【3、完成减速发个通知】
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter]postNotificationName:JPScrollViewDidEndDeceleratingNotification object:nil userInfo:@{JPScrollViewContentOffsetX:@(scrollView.contentOffset.x)}];
}


#pragma mark -【4、三步走,避免内存泄露】
- (void)back{
    // 1、[未使用KVO，则省略] 移除KVO观察者，slideBar 通过 KVO 监测scrollView.contentOffset
    // 2、self.view 强引用slideBar
    // 3、self强引用slideBar，如果不是成员属性，此步可省略
    
    //[self.scrollView removeObserver:self.slideBar forKeyPath:@"contentOffset"];
    [self.slideBar   removeFromSuperview];
    self.slideBar    = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}




- (void)initializeUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"JPSlideBar";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    
    
    [self initializeScrollViewWithStatusBarHeight:(64)];
    [self setupScrollViewSubViewsWithNumber:titles.count];
    self.scrollView.contentSize = CGSizeMake(titles.count * JPSCREEN_WIDTH, CGRectGetHeight(self.scrollView.bounds));
}


- (void)initializeScrollViewWithStatusBarHeight:(CGFloat)statusBarHeight{
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, statusBarHeight, JPSCREEN_WIDTH, JPSCREEN_HEIGHT-statusBarHeight)];
    self.scrollView.showsHorizontalScrollIndicator= NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
//    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (void)setupScrollViewSubViewsWithNumber:(NSInteger)count{
    for (NSInteger index = 0; index < count; index ++) {
        
        JPBaseTableViewController * subVC = [[JPBaseTableViewController alloc]init];
        subVC.dataSourceArray = [titles mutableCopy];
        subVC.view.frame = CGRectMake(self.scrollView.bounds.size.width * index, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        
        [self addChildViewController:subVC];
        [self.scrollView addSubview:subVC.view];
    }
}






- (void)dealloc{
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    NSLog(@"%@被释放",[self class]);
}




@end
