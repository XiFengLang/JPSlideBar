//
//  ViewController.h
//  JPSlideBar
//
//  Created by apple on 16/1/5.
//  Copyright © 2016年 XiFengLang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)NSMutableArray * masterDataArray;
@end
