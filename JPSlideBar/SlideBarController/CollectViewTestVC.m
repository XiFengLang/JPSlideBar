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
@property (nonatomic, strong)JPSlideNavigationBar * slideBar;
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
    
    
    // 解决scrollView的pan手势和侧滑返回手势冲突,ScrollView+VC.view的模式尽量不要用leftBarButtonItem
    NSArray *gestureArray = self.navigationController.view.gestureRecognizers;
    for (UIGestureRecognizer *gesture in gestureArray) {
        if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:gesture];
            break;
        }
    }

    
    
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
}

- (void)addJPSlideBar{
    self.slideBar = [JPSlideNavigationBar slideBarWithObservableScrollView:self.collectionView
                                                            viewController:self
                                                              frameOriginY:64
                                                       slideBarSliderStyle:JPSlideBarStyleTransformationAndGradientColor];
    
    [self.view addSubview:self.slideBar];
    
    Weak(self);
    [self.slideBar configureSlideBarWithTitles:self.titleArray
                                     titleFont:[UIFont systemFontOfSize:18]
                                     itemSpace:30
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
    [JPNotificationCenter addObserver:self selector:@selector(doSomeThingWhenScrollViewChangePage:) name:JPSlideBarChangePageNotification object:nil];
}

- (void)doSomeThingWhenScrollViewChangePage:(NSNotification *)notification{
    CGFloat offsetX = [notification.userInfo[JPSlideBarScrollViewContentOffsetX] floatValue];
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
