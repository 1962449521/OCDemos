//
//  ReplyMessageVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-10.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"

#import "XHPullRefreshTableViewController.h"


@interface ReplyMessageVC : BaseVC<XHRefreshControlDelegate, UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) XHPullRefreshTableViewController *tableVC;


@end

