//
//  JPBaseTableViewControllerWW.h
//  JPAttributeTest
//
//  Created by zongIMac on 15/12/24.
//  Copyright © 2015年 zongIMac. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef  DEBUG       // 处于开发阶段
#define JKLog(...) NSLog(__VA_ARGS__)
#else               // 处于发布阶段
#define JKLog(...)
#endif

#define JCRandomColor [UIColor colorWithRed: arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]

@interface JPBaseTableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSMutableArray * dataSourceArray;



@end
