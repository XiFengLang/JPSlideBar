//
//  CollectViewTestVC.m
//  JPSlideBar
//
//  Created by apple on 16/1/5.
//  Copyright © 2016年 XiFengLang. All rights reserved.
//

#import "CollectViewTestVC.h"
#import "JPBaseTableViewController.h"
#import "JPSlideBar.h"

@interface CollectViewTestVC ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong)NSArray * titleArray;
@property (nonatomic, strong)JPSlideBar * slideBar;
@end

@implementation CollectViewTestVC

static NSString * const MYKEY = @"UICollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleArray = @[@"简书",@"ONE",@"网易云音乐",@"腾讯百度",@"谷歌",@"特斯拉",@"阿里巴巴"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:MYKEY];
    [self addChildViewControllers];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    
    [self addJPSlideBar];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}


- (void)addChildViewControllers{
    for (NSInteger index = 0; index < self.titleArray.count; index ++) {
        JPBaseTableViewController * vc = [[JPBaseTableViewController alloc]init];
        vc.dataSourceArray = [self.titleArray mutableCopy];
        [self addChildViewController:vc];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
}

- (void)addJPSlideBar{
#pragma mark -【1、初始化并显示底层毛玻璃/有数据再配置slideBar】
    self.slideBar = [JPSlideBar showInViewController:self
                                observableScrollView:self.collectionView
                                        frameOriginY:64
                                           itemSpace:30
                                 slideBarSliderStyle:JPSlideBarStyleShowSliderAndGradientColor];
    
    
    Weak(self);
    [self.slideBar configureSlideBarWithTitles:self.titleArray
                                     titleFont:[UIFont systemFontOfSize:18]
                           normalTitleRGBColor:JColor_RGB(153,153,153)
                         selectedTitleRGBColor:JColor_RGB(26,34,255)
                                 selectedBlock:^(NSInteger index) {
                                     Strong(self);
                                     CGFloat scrollX = CGRectGetWidth(self.collectionView.bounds) * index;
                                     [self.collectionView setContentOffset:CGPointMake(scrollX, 0)];
                                 }];
    
    
    
    // 设置背景颜色，默认毛玻璃效果
    [self.slideBar setSlideBarBackgroudColorIfNecessary:[UIColor whiteColor]];
    
    
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

#pragma mark - collectionView代理


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:MYKEY forIndexPath:indexPath];
    
    // 先移除 子视图的View
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 再添加 子视图的View
    JPBaseTableViewController * subVC = self.childViewControllers[indexPath.row];
    subVC.view.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-64);
    [cell.contentView addSubview:subVC.view];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [UIScreen mainScreen].bounds.size;
}



- (void)dealloc{
    
    NSLog(@"%@被释放",[self class]);
}

@end
