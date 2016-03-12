//
//  ScoreMoreReplyVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-11.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"
#import "XHPullRefreshTableViewController.h"
@class GradeModel;
@class XHPullRefreshTableViewController;
@interface ScoreMoreReplyVC : BaseVC

@property (nonatomic, strong)GradeModel *grade;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) XHPullRefreshTableViewController *tableVC;
@property (weak, nonatomic) id userDelegate;
//vc.lastRefreshTime = _model.repliesLastRefreshTime;
//vc.dataSource = _model.replies;
@end
