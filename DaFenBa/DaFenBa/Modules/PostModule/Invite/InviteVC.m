//
//  PersonListVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-31.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "InviteVC.h"
#import "HomePageVC.h"
#import "CustomSearchBar.h"
#import "XHPullRefreshTableViewController.h"

#import <objc/message.h>


typedef NS_ENUM(char, DataSourceType) {DataSourceTypeFollow, DataSourceTypeExpert, DataSourceTypeSearch};

@interface InviteVC ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)NSMutableArray *dataSource;//当前数据源
@end

@implementation InviteVC
{
    UIView *loadView;//加载更多指示
    int inviteNum;//邀请数量
    BOOL switchExpert;//switch切换值
    bool isFirstAppear[3];//三个tableVC的首次出现
    
    int maxPageCount[3];//三个
    
    NSMutableDictionary *selectIDs;//存放选中的ID号
    DataSourceType dataSourceType;//当前tableVC的类型
    XHPullRefreshTableViewController *tableVC ;//当前显示的tableVC
    NSMutableArray *dataSourceArr;//存放三个数据源，元素均为并集中的元素引用
    NSMutableArray *unionDataSource;//三个数据源的并集
    CustomSearchBar *searchBar;//自定义搜索栏
    
    NSMutableArray *lrt;//记录三个数据源的最后更新时间
    
    UIView *maskView;//遮挡tableVC之间的切换
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;
        _tableVCArr = [NSMutableArray array];
        dataSourceArr = [NSMutableArray array];
        NSMutableArray *arrFollow = [NSMutableArray array];
        NSMutableArray *arrExpert = [NSMutableArray array];
        NSMutableArray *arrSearch = [NSMutableArray array];
        [dataSourceArr addObject:arrFollow];
        [dataSourceArr addObject:arrExpert];
        [dataSourceArr addObject:arrSearch];
        unionDataSource = [NSMutableArray array];
        
        
        lrt = [@[@0, @0, @0] mutableCopy];
        selectIDs = [NSMutableDictionary dictionary];
        int t = (1<<31) + 1;
        t = -t;
        maxPageCount[0] = t;
        maxPageCount[1] = t;
        maxPageCount[2] = t;
    }
    return self;
}

- (void)setRightBtn
{
    CGRect frame = CGRectMake(0, 12, 120, 20);
    UIColor *textcolor = ColorRGB(244.0, 149.0, 42.0);
    UIView *rightBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    NSString *title = [NSString stringWithFormat:@"发送邀请（%d)", inviteNum];

    UIButton *callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if(!DEVICE_versionAfter7_0)
        [callBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    callBtn.frame = frame;
    
    callBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [callBtn setTitleColor:textcolor forState:UIControlStateNormal];
    [callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [callBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [callBtn setTitle:title forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(sendInvite) forControlEvents:UIControlEventTouchUpInside];
    [callBtn setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateSelected];
    

    [rightBarView addSubview:callBtn];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rightBarView];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightBtn , nil];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isNeedHideBack = YES;
    self.isNeedHideTabBar = YES;
    switch (self.type) {
        case TypeInviteAdvice:
            [self setNavTitle:@"邀请建议"];
            [self setRightBtn];
            break;
        case TypeInviteScore:
            [self setNavTitle:@"邀请打分"];
            [self setRightBtn];
        default:
            break;
    }
    for (int index = 0; index < 3; index++) {
        XHPullRefreshTableViewController *tableVC_ = [[XHPullRefreshTableViewController alloc]init];
        tableVC_.refreshControlDelegate = tableVC_;
        tableVC_.tableView.delegate = self;
        tableVC_.tableView.dataSource = self;
        
        if (tableVC_.pullDownRefreshed) {
            [tableVC_ setupRefreshControl];
        }
        [_tableVCArr addObject:tableVC_];
    }
    

    self.isNeedBackBTN = YES;
    // Do any additional setup after loading the view.
    [self.view setHeight:DEVICE_screenHeight - 20 - 44];
    
    float delta = 0;
//    if (self.isHaveSearchBar) {
        searchBar = [[CustomSearchBar alloc]initWithFrame:CGRectMake(0, 0, DEVICE_screenWidth, 44)];
        [searchBar.switchBtn addTarget:self action:@selector(switchValueChangeded:) forControlEvents:UIControlEventValueChanged];
        searchBar.searchBar.delegate = self;
        delta += searchBar.height;
        [self.view addSubview:searchBar];
//    }
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - AsynNetAccessDelegate
- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    if ([requestId isEqualToNumber:FriendModule_list_tag])
        [tableVC revokeHsRefresh];
    if([self.aview isAnimating])
        [self stopAview];
    NSDictionary *receiveDic;
    
    if (!TYPE_isDictionary(receiveObject))
    {
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
        if([requestId isEqualToNumber:FriendModule_list_tag])
            [tableVC revokeHsLoadMore];
        return;
    }
    else
        receiveDic = (NSDictionary *)receiveObject;
    NSDictionary *result = receiveDic[@"result"];
    if ([requestId isEqualToNumber:FriendModule_list_tag]) {
        
        if (NETACCESS_Success)
        {
            /*
            ** response: {result: {success: true, msg: error message}, users: [{id: user id, name: user name, avatar: user avatar url/name, intro: user intro, relationType: 1 // 0: no relationship, 1: follow, 2: follower}], pager: {pageNumber: 1, pageSize: 20, pageCount: page count. recordCount: record count}, lastRefreshTime: return last refresh time only when accessing first page and will cached by client}
             */
            
            NSArray *users = receiveDic[@"users"];
            NSMutableArray *usersOrigin = [users mutableCopy];
            NSMutableArray *usersNew = [NSMutableArray array];
            
            for (NSDictionary *aUser in usersOrigin) {
                NSNumber *loginUserId = [Coordinator userProfile].userId;
                if (!(loginUserId && [aUser[@"id"] isEqualToNumber:loginUserId])) {
                    NSMutableDictionary *bUser = [aUser mutableCopy];
                    [bUser setValue:@NO forKey:@"selected"];
                    bUser = [self insert:bUser toDataSource:unionDataSource];
                    [usersNew addObject:bUser];

                }
                
            }
            NSNumber *lastRefreshTime = receiveDic[@"lastRefreshTime"];
            if(lastRefreshTime)
            {
                lrt[dataSourceType] = lastRefreshTime;
                if(receiveObject[@"pager"][@"pageCount"] != nil)
                    maxPageCount[dataSourceType] = [receiveObject[@"pager"][@"pageCount"] intValue];
            }
            
            [self assignDataSource:usersNew];
        }
        else
        {
            
            [tableVC revokeHsLoadMore];

            POPUPINFO(STRING_joint(@"列表获取失败", result[@"msg"]));

        }
    }
    else if([requestId isEqualToNumber:GradeModule_invite_tag] || [requestId isEqualToNumber:AdviceModule_invite_tag])
    {
        if (NETACCESS_Success)
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"邀请发送成功，将扣除相应的分贝。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
//            POPUPINFO(@"邀请发送成功，将扣除相应的分贝。");
//            self.view.userInteractionEnabled = NO;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self backToPreVC:nil];
//            });
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"邀请发送失败，%@",result[@"msg"]];
            POPUPINFO(str);
        }
        
    }
}


- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    if ([requestId isEqualToNumber:FriendModule_list_tag])
        [tableVC revokeHsRefresh];
    if([self.aview isAnimating])
        [self stopAview];
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
    if([requestId isEqualToNumber:FriendModule_list_tag])
        [self assignDataSource:nil];
    
        
}
#pragma mark 邀请成功
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self backToPreVC:nil];
    
}

#pragma mark - 数据源获得处理
/**
 *	@brief	二分查找union_中是否有与待插入元素相同id的元素，如没有则插入，
 *          如union没有meta_，则返回meta_，如果存在，则返回union中的相同项。
 *	@param 	meta_ 	单个元素
 *	@param 	union_ 	meta_组成的有序表
 *
 *	@return	返回将被实际使用的meta_
 */
- (NSMutableDictionary *)insert:(NSMutableDictionary *)meta_ toDataSource:(NSMutableArray *)union_

{
    int low = 0, hight = [union_ count] - 1;
    while (low <= hight)
        {
            int middle = (low + hight)/2;
            if([union_[middle][@"id"] intValue] > [meta_[@"id"] intValue])
                hight = middle - 1;
            else if([union_[middle][@"id"] intValue] < [meta_[@"id"] intValue])
                low = middle + 1;
            else
                return union_[middle];
        }

    [union_ addObject:meta_];
    [union_ sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return  [obj1[@"id"] compare: obj2[@"id"]];
    }];
    return meta_;
}
/**
 *	@brief	更新加载数据
 */
- (void) loadDataSource

{
    if (tableVC.requestCurrentPage == 0 && maxPageCount[dataSourceType] == 0) {
        maxPageCount[dataSourceType] = 30000;
    }
    //没有更多页
    if(tableVC.requestCurrentPage + 1 > maxPageCount[dataSourceType])
    {
        
        [tableVC endMoreOverWithMessage:@"没有更多页了"];
        return;
    }
    NSNumber *userId = [Coordinator userProfile].userId;
    if(userId == nil) userId = @32;
    NSNumber *typInt;
    if(dataSourceType == DataSourceTypeExpert) typInt = @3;
    else if(dataSourceType == DataSourceTypeFollow) typInt = @1;
    else if(dataSourceType == DataSourceTypeSearch) typInt = @0;
    if(switchExpert) typInt = @3;
    else typInt = @1;
    
    
    NSString *name = [NSString stringWithFormat:@"%%%@%%", [STRING_judge(searchBar.searchBar.text) stringByReplacingOccurrencesOfString:@"" withString:@" "]];
//    if(dataSourceType != DataSourceTypeSearch) name = @"%%";
    NSDictionary *pager = @{@"pageNumber" : [NSNumber numberWithInt: (tableVC.requestCurrentPage + 1)], @"pageSize" : @20};
    
    
    NSNumber *lastRefreshTime = lrt[dataSourceType];
    NSDictionary *para = @{@"userId" : userId, @"type" : typInt, @"name" : name, @"pager" : pager, @"lastRefreshTime" : lastRefreshTime};
    
    [self.netAccess passUrl:FriendModule_list andParaDic:para withMethod:FriendModule_list_method andRequestId:FriendModule_list_tag thenFilterKey:nil useSyn:NO dataForm:7];
    
    
    
}
/**
 *	@brief	将新获得的数据源显示至列表
 *
 *	@param 	dataSource
 */
- (void)assignDataSource:(NSArray *)dataSource{
   
    
    
    if (tableVC.requestCurrentPage )
    {//加载更多
        if(dataSource != nil && [dataSource count] != 0)
        {
            [self.dataSource addObjectsFromArray:dataSource];
            [tableVC endLoadMoreRefreshing];
        }
    }
    
    else//刷新
    {
        if(dataSource != nil && [dataSource count] != 0)
        {
            self.dataSource = [dataSource mutableCopy];
        }

    }
    
    [tableVC.tableView reloadData];

}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"FriendListCell";
    switch (self.type) {
        case TypeInviteAdvice:
        case TypeInviteScore:
            cellIdentifier = @"InviteCell";
            
        default:
            break;
    }

    BaseCell *cell = [BaseCell cellRegisterNib:cellIdentifier tableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.btn1.tag = indexPath.row;
    [cell.btn1 addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    cell.btn3.tag = indexPath.row;

    [cell.btn3 addTarget:self action:@selector(enterHomePage:) forControlEvents:UIControlEventTouchUpInside];

    NSDictionary *dic = self.dataSource[indexPath.row];

    objc_msgSend(cell, @selector(setDataSource:), dic);
     return cell;

}
#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [searchBar.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark - 用户交互事件
- (IBAction)enterHomePage:(UIButton *)sender
{
    if (self.navigationController) {
        NSDictionary *dic = _dataSource[sender.tag];
        UserProfile *userProfile = [UserProfile new];
        userProfile.userId = dic[@"id"];
        userProfile.name = dic[@"name"];
        userProfile.intro = dic[@"intro"];
        if(dic[@"relationType"])userProfile.relationType = dic[@"relationType"];
        else if(dic[@"relationship"]) userProfile.relationType = dic[@"relationship"];
        userProfile.avatar = dic[@"avatar"];
        [HomePageVC enterHomePageOfUser:userProfile fromVC:self];
    }
}
/**
 *	@brief	选中
 *
 *	@param 	btn 	
 */
- (void)cellSelected:(UIButton *)btn

{
    [searchBar.searchBar resignFirstResponder];
    BaseCell *cell = (BaseCell *)[tableVC.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:btn.tag inSection:0]];
    NSNumber *isSelect = [NSNumber numberWithBool: [cell isSelected] ];
    NSMutableDictionary *dic = self.dataSource[btn.tag];
    [dic setValue:isSelect forKey:@"selected"];
    if([cell isSelected])
    {
        [selectIDs setValue:dic[@"id"] forKey:dic[@"id"]];
        inviteNum ++;
    }
    else
    {
        [selectIDs removeObjectForKey:dic[@"id"]];
        inviteNum --;
    }
    [self setRightBtn];
                     
}


/**
 *	@brief	切换switch
 *
 *	@param 	sender
 */
- (void) switchValueChangeded:(SimpleSwitch *)sender

{
    [searchBar.searchBar resignFirstResponder];
    
    BOOL value = sender.on;
    switchExpert = !value;
    dataSourceType = value? 0 : 1;
    
    tableVC = (XHPullRefreshTableViewController *)(_tableVCArr[dataSourceType]);
    self.dataSource = dataSourceArr[dataSourceType];
    [tableVC.tableView setFrame:self.view.bounds];
    [tableVC.tableView setY:44];
    [tableVC.tableView setHeight:self.view.height - 44];
    
    if (maskView == nil) {
        maskView = [[UIView alloc]initWithFrame:self.view.bounds];
        maskView.backgroundColor = [UIColor whiteColor];
        [maskView setY:44];
        [maskView setHeight:self.view.height - 44];

    }
    [self.view addSubview:maskView];
    [self.view addSubview:tableVC.tableView];
    loadView = tableVC.refreshControl.loadMoreView;
    [self.view addSubview:loadView];
    [loadView setTop:self.view.height - loadView.height];

    
    [tableVC.tableView reloadData];
    if((tableVC.requestCurrentPage == 0 && !isFirstAppear[dataSourceType]) || [_dataSource count] == 0  )
    {
    [self.dataSource removeAllObjects];
    

        [tableVC startPullDownRefreshing];
        
        [tableVC.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
    }
    isFirstAppear[dataSourceType] = YES;
}
/**
 *	@brief	点击搜索
 *
 *	@param 	asearchBar
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)asearchBar

{
    [searchBar.searchBar resignFirstResponder];
//    dataSourceType = 2;
    tableVC = (XHPullRefreshTableViewController *)(_tableVCArr[dataSourceType]);
    self.dataSource = dataSourceArr[dataSourceType];
    [tableVC.tableView setFrame:self.view.bounds];
    [tableVC.tableView setY:44];
    [tableVC.tableView setHeight:self.view.height - 44];
    [self.view addSubview:tableVC.tableView];
    loadView = tableVC.refreshControl.loadMoreView;
    [self.view addSubview:loadView];
    [loadView setTop:self.view.height - loadView.height];
    

    [tableVC startPullDownRefreshing];
    [tableVC.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
    

}
/**
 *	@brief	发送邀请
 */
- (void)sendInvite

{
    NSArray *selectIdArr = [selectIDs allKeys];
    //NSString *inviteId = [selectIdArr componentsJoinedByString:@","];
    NSNumber *userId = [Coordinator userProfile].userId;
    NSDictionary *para = @{@"userId" : userId , @"userIds" : selectIdArr, @"postId" : _postId};
    /*
    ** request: {userId: login user id, userIds: [1, 2] // invited user ids}
        ** response: {result: {success: true, msg: error message}}*/
    [self startAview];
    switch (self.type) {
        case TypeInviteAdvice:
            [self.netAccess passUrl:GradeModule_invite andParaDic:para withMethod:GradeModule_invite_method andRequestId:GradeModule_invite_tag thenFilterKey:nil useSyn:NO dataForm:7];
            break;
        case TypeInviteScore:
            [self.netAccess passUrl:AdviceModule_invite andParaDic:para withMethod:AdviceModule_invite_method andRequestId:AdviceModule_invite_tag thenFilterKey:nil useSyn:NO dataForm:7];
        default:
            break;
    }
}

@end
