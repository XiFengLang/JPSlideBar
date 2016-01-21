//
//  TestGestureVC.m
//  JPSlideBar
//
//  Created by apple on 16/1/21.
//  Copyright © 2016年 XiFengLang. All rights reserved.
//

#import "TestGestureVC.h"

@interface TestGestureVC ()<UIGestureRecognizerDelegate>

@end

@implementation TestGestureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds)*3, CGRectGetHeight(self.view.bounds));
    [self.view addSubview:scrollView];
    scrollView.pagingEnabled = YES;
    
    for (NSInteger index = 1; index <= 3; index++) {
        UIView * view = [[UIView alloc]initWithFrame:scrollView.bounds];
        if (index == 1 || index == 3) {
            view.backgroundColor = [UIColor darkGrayColor];
        }else{
            view.backgroundColor = [UIColor lightGrayColor];
        }
        [scrollView addSubview:view];
    }
    
    // 解决侧滑手势和leftBarButtonItem冲突,但是会影响其他界面的侧滑，并且有奇怪的现象（未解）
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
    
    // 解决侧滑手势和scrollView侧滑，建立优先级
    NSArray *gestureArray = self.navigationController.view.gestureRecognizers;
    for (UIGestureRecognizer *gesture in gestureArray) {
        if ([gesture isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            [scrollView.panGestureRecognizer requireGestureRecognizerToFail:gesture];
            break;
        }
    }
}

- (void)dealloc{
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    NSLog(@"%@实例对象被释放",[self class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
