//
//  ScoreListVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-11.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//


#import "BaseVC.h"

@class PostProfile;
@class XHPullRefreshTableViewController;


@interface ScoreListVC : BaseVC


@property (strong, nonatomic) NSMutableArray *dataSource;

// 数据展示控件
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UIButton *loadMoreBtn;
//---

@property (strong, nonatomic) ScoreManager *scoreManager;
@property (strong, nonatomic) XHPullRefreshTableViewController *tableVC;
//@property (assign, nonatomic) BOOL isOmittedScore;

@property (weak, nonatomic) id userDelegate;

- (void)replyMessage:(NSDictionary *)info;
- (void)refreshGrade:(GradeModel *)grade;


@end
