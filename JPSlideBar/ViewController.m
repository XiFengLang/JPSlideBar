//
//  ViewController.m
//  JPSlideBar
//
//  Created by apple on 16/1/5.
//  Copyright © 2016年 XiFengLang. All rights reserved.
//

#import "ViewController.h"
#import "ScrollTestVC.h"
#import "JPTableViewCell.h"
#import "CollectViewTestVC.h"

@interface ViewController () 
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.masterDataArray addObject:@"ScrollView上添加多个子控制的View"];
    [self.masterDataArray addObject:@"CollectionView添加多个子控制的View"];
}


- (void)pushToScrollTestVC{
    ScrollTestVC * vc = [[ScrollTestVC alloc]init];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToCollectionViewTestVC{
    CollectViewTestVC * vc = [[CollectViewTestVC alloc]initWithNibName:@"CollectViewTestVC" bundle:nil];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.masterDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JPTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"JPTableViewCell"];
    cell.lable.text = self.masterDataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row ==0 ) {
        [self pushToScrollTestVC];
    }else if (indexPath.row == 1){
        [self pushToCollectionViewTestVC];
    }
}



- (NSMutableArray *)masterDataArray{
    if (!_masterDataArray) {
        _masterDataArray = [[NSMutableArray alloc]init];
    }return _masterDataArray;
}

@end
