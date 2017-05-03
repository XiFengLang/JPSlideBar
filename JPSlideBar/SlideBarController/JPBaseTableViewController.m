//
//  JPBaseTableViewControllerWW.m
//  JPAttributeTest
//
//  Created by zongIMac on 15/12/24.
//  Copyright © 2015年 zongIMac. All rights reserved.
//

#import "JPBaseTableViewController.h"

@interface JPBaseTableViewController ()

@end

@implementation JPBaseTableViewController

static NSString * identifier = @"JPTableViewCell";
- (instancetype)init{
    return [self initWithNibName:NSStringFromClass([JPBaseTableViewController class]) bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self,
    self.tableView.delegate = self;
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsMake(42, 0, 0, 0);
    NSLog(@"%@",NSStringFromSelector(_cmd));
}






#pragma mark - tableView代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataSourceArray[indexPath.row];
    cell.contentView.backgroundColor = JCRandomColor;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

//  分割线的偏移量
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
//  分割线的偏移量
-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // 无线条的设置
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}



- (NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        _dataSourceArray = [[NSMutableArray alloc]init];
    }return _dataSourceArray;
}

- (void)dealloc{
    JKLog(@"%@实例对象被释放",[self class]);
}

@end
