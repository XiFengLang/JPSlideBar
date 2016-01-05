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
    self.titleArray = @[@"游客",@"待",@"VIP",@"腾讯百度",@"黑名单",@"特斯拉",@"阿里巴巴"];
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
                                        frameOriginY:64
                                           itemSpace:30
                                 slideBarSliderStyle:JPSlideBarStyleShowSliderAndGradientColor];
    
    
    [self.slideBar configureSlideBarWithTitles:self.titleArray
                                     titleFont:[UIFont systemFontOfSize:18]
                           normalTitleRGBColor:JCBLACK_COLOR
                         selectedTitleRGBColor:JCYELLOW_COLOR
                                 selectedBlock:^(NSInteger index) {
                                     CGFloat scrollX = CGRectGetWidth(self.collectionView.bounds) * index;
                                     [self.collectionView setContentOffset:CGPointMake(scrollX, 0)];
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


#pragma mark - collectionView代理


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:MYKEY forIndexPath:indexPath];
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    // 添加子视图的View
    JPBaseTableViewController * subVC = self.childViewControllers[indexPath.row];
    subVC.view.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-64);
    [cell.contentView addSubview:subVC.view];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [UIScreen mainScreen].bounds.size;
}


- (void)dealloc{
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
    NSLog(@"%@被释放",[self class]);
}

@end
