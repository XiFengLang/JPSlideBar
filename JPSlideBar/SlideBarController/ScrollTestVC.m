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
//    titles = @[@"简书",@"ONE",@"网易云音乐",@"腾讯百度",@"谷歌",@"特斯拉",@"阿里巴巴"];
    titles = @[@"简书",@"腾讯",@"阿里",@"网易云"];
    
    [self initializeUI];
    self.scrollView.decelerationRate = 1.0;
    

    self.slideBar = [JPSlideBar showInViewController:self
                                observableScrollView:self.scrollView
                                        frameOriginY:64
                                           itemSpace:30
                                 slideBarSliderStyle:JPSlideBarStyleGradientColorOnly];
    
    Weak(self); //避免循环引用
    [self.slideBar configureSlideBarWithTitles:titles
                                     titleFont:[UIFont systemFontOfSize:18]
                           normalTitleRGBColor:JColor_RGB(0,0,0)
                         selectedTitleRGBColor:JColor_RGB(255,255,255)
                                 selectedBlock:^(NSInteger index) {
                                     Strong(self);
                                     CGFloat scrollX = CGRectGetWidth(self.scrollView.bounds) * index;
                                     [self.scrollView setContentOffset:CGPointMake(scrollX, 0)];
                                 }];
    
    // 可以监听每次翻页的通知,内部已经计算好。(比如刷新数据)
    [JPNotificationCenter addObserver:self selector:@selector(doSomeThingWhenScrollViewChangePage:) name:JPScrollViewDidChangePageNotification object:nil];
}

- (void)doSomeThingWhenScrollViewChangePage:(NSNotification *)notification{
    CGFloat offsetX = [notification.userInfo[JPScrollViewContentOffsetX] floatValue];
    NSInteger index = [notification.userInfo[JPSlideBarCurrentIndex] integerValue];
    
    JKLog(@"offsetX:%f    index:%ld",offsetX,index);
}









- (void)back{
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
    NSLog(@"%@被释放",[self class]);
}




@end
