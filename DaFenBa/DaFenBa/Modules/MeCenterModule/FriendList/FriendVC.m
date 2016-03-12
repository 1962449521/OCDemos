//
//  FriendVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-21.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "FriendVC.h"
#import "XHPullRefreshTableViewController.h"
#import "HomePageVC.h"
#import <objc/message.h>
#import "FriendListCell.h"
#import "MeVC.h"


@interface FriendVC ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation FriendVC
{
    NSMutableArray *_dataSource;
    NSNumber *maxPage;
    NSNumber *lastRefreshTime;
    UIView *loadView;
    int tempCellIndex;
    int tempTargetType;
}

@synthesize tableVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
        lastRefreshTime = @0;
        maxPage = @8;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setHeight:DEVICE_screenHeight - 20 - 44];
    self.isNeedBackBTN = YES;
    self.isNeedHideTabBar = YES;
    switch (self.type) {
        case FriendListTypeStranger:
            [self setNavTitle:@"添加好友"];
            break;
        case FriendListTypeFollow:
            [self setNavTitle:@"关注"];
            break;
        case FriendListTypeFollower:
            [self setNavTitle:@"粉丝"];
            break;
        default:
            break;
    }
    
    tableVC = [[XHPullRefreshTableViewController alloc]init];
    tableVC.refreshControlDelegate = tableVC;
    tableVC.tableView.delegate = self;
    tableVC.tableView.dataSource = self;
    [self.view addSubview:tableVC.tableView];
    
    if (tableVC.pullDownRefreshed) {
        [tableVC setupRefreshControl];
    }
    loadView = tableVC.refreshControl.loadMoreView;
    [self.view addSubview:loadView];
    [loadView setTop:self.view.height - loadView.height];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];

    [tableVC startPullDownRefreshing];
    [tableVC.tableView setContentOffset:CGPointMake(0, -60) animated:YES];

    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - super methods
//- (void)backToPreVC:(id)sender
//{
//    UINavigationController *nav = self.navigationController;
//    NSArray *vcArr = [nav viewControllers];
//    int count = vcArr.count;
//    MeVC *toVC = vcArr[count - 2];
//    if ([toVC isKindOfClass:[MeVC class]]) {
//        toVC.isTabChangeIn = YES;//冒充是其他tab进到meVC中， ：）
//    }
//    [super backToPreVC:sender];
//}
#pragma mark - dataSource
- (void)loadDataSource
{
    if (tableVC.requestCurrentPage == 0 && [maxPage intValue] == 0) {
        maxPage = @30000;
    }
    if (tableVC.requestCurrentPage + 1 > [maxPage intValue]) {
        [tableVC revokeHsRefresh];
        [tableVC revokeHsLoadMore];
        [tableVC endMoreOverWithMessage:@"没有更多页了"];
        return;
    }
    NSNumber *userId = [Coordinator userProfile].userId;
    if(userId == nil) userId = @32;
    int typInt;
    if(self.type == FriendListTypeFollow) typInt = 1;
    else if(self.type == FriendListTypeFollower) typInt = 2;
    else if(self.type == FriendListTypeStranger) typInt = 0;
    NSNumber *type =  [NSNumber numberWithInt: typInt];
    NSDictionary *pager = @{@"pageNumber" : [NSNumber numberWithInt: (tableVC.requestCurrentPage + 1)], @"pageSize" : @20};
    
    NSDictionary *para = @{@"userId" : userId, @"type" : type,  @"pager" : pager, @"lastRefreshTime" : lastRefreshTime};
    [self.netAccess passUrl:FriendModule_list andParaDic:para withMethod:FriendModule_list_method andRequestId:FriendModule_list_tag thenFilterKey:nil useSyn:NO dataForm:7];
}
/**
 *	@brief	将新获得的数据源显示至列表
 *
 *	@param 	dataSource
 */
- (void)assignDataSource:(NSArray *)dataSource{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *indexPaths;
        if (tableVC.requestCurrentPage) {
            indexPaths = [[NSMutableArray alloc] initWithCapacity:dataSource.count];
            [dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:_dataSource.count + idx inSection:0]];
            }];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tableVC.requestCurrentPage) {
                if (dataSource == nil) {
                    [tableVC revokeHsRefresh];
                    [tableVC revokeHsLoadMore];
                } else {
                    [_dataSource addObjectsFromArray:dataSource];
                    [tableVC.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    [tableVC endLoadMoreRefreshing];
                }
            } else {
                if (dataSource != nil && [dataSource count] > 0) {
                    [_dataSource removeAllObjects];
                    [_dataSource addObjectsFromArray:dataSource];
                    
                    [tableVC.tableView reloadData];
                }
                
                [tableVC endPullDownRefreshing];
            }
        });
    });
    
    
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"FriendListCell";

    
    FriendListCell *cell = (FriendListCell *)[BaseCell cellRegisterNib:cellIdentifier tableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.btn1.tag = indexPath.row;
    [cell.btn1 addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    NSDictionary *dic = _dataSource[indexPath.row];
    
    objc_msgSend(cell, @selector(setDataSource:), dic);
    return cell;
    
}
- (void)cellSelected:(UIButton *)sender
{
    int index = sender.tag;
    tempCellIndex = index;
    UserProfile *user = _dataSource[index];
     //relationType: 1 // 0: no relationship, 1: follow, 2: follower 3: mutual follow
    int type = [user.relationType intValue];
    NSNumber *tgtId = user.userId;
    NSString *tgtName = user.name;
    UserProfile *userProfile = [Coordinator userProfile];
    NSNumber *srcId = userProfile.userId;
    NSString *srcName = userProfile.name;
    switch (type) {
        case 0:
            tempTargetType = 1;
            break;
        case 1:
            tempTargetType = 0;
            break;
        case 2:
            tempTargetType = 3;
            break;
        case 3:
            tempTargetType = 2;
            break;
        default:
            break;
    }
    
        [self startAview];

    NSDictionary *para;
    if(tempTargetType == 1 || tempTargetType == 3)//加关注
    {
        para = @{@"follow" : @{@"srcId": srcId, @"srcName" : srcName, @"tgtId" : tgtId, @"tgtName" : tgtName}};
        [self.netAccess passUrl:FriendModule_follow andParaDic:para withMethod:FriendModule_follow_method andRequestId:FriendModule_follow_tag thenFilterKey:nil useSyn:NO dataForm:7];
    }
    else
    {
        para = @{@"follow": @{@"srcId" : srcId, @"tgtId" : tgtId}};
        [self.netAccess passUrl:FriendModule_deleteFollow andParaDic:para withMethod:FriendModule_deleteFollow_method andRequestId:FriendModule_deleteFollow_tag thenFilterKey:nil useSyn:NO dataForm:7];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.navigationController) {
        UserProfile *userProfile = _dataSource[indexPath.row];
        [HomePageVC enterHomePageOfUser:userProfile fromVC:self];
    }
    
}
#pragma mark - AsynNetAccessDelegate
- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    if([self.aview isAnimating])
        [self stopAview];
    NSDictionary *receiveDic;
    
    if (!TYPE_isDictionary(receiveObject))
    {
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
        if([requestId isEqualToNumber:FriendModule_list_tag])
            [self assignDataSource:nil];
        return;
    }
    else
        receiveDic = (NSDictionary *)receiveObject;
    NSDictionary *result = receiveDic[@"result"];
    if ([requestId isEqualToNumber:FriendModule_list_tag]) {
        
        if (NETACCESS_Success)
        {
            NSArray *userDics = receiveDic[@"users"];
            NSMutableArray *usersNew = [NSMutableArray array];
            for (NSDictionary *userDicL in userDics) {
                NSMutableDictionary *userDicM = [userDicL mutableCopy];
                [userDicM renameKey:@"id" withNewName:@"userId"];
                [userDicM renameKey:@"relationship" withNewName:@"relationType"];

                UserProfile *newUser = [UserProfile new];
                [newUser assignValue:userDicM];
                [usersNew addObject:newUser];
            }
            if (receiveDic[@"lastRefreshTime"]) {
                lastRefreshTime = receiveDic[@"lastRefreshTime"];
                maxPage = receiveDic[@"pager"][@"pageCount"];
            }
            [self assignDataSource:usersNew];
        }
        else
        {
            [self assignDataSource:nil];
            POPUPINFO(STRING_joint(@"列表获取失败", result[@"msg"]));
            
        }
    }
    else if([requestId isEqualToNumber:FriendModule_follow_tag] )
    {
        if (NETACCESS_Success)
        {
            POPUPINFO(@"添加关注成功");
            NSMutableDictionary *extInfo = [Coordinator userProfile].extInfo;
            if (extInfo[@"followCount"])
            {
                int newFollowCount = [extInfo[@"followCount"] intValue];
                [extInfo setValue:NUMBER(newFollowCount + 1) forKey:@"followCount"];
            }
            UserProfile *user = _dataSource[tempCellIndex];
            user.relationType = [NSNumber numberWithInt:tempTargetType];
            NSIndexPath *path = [NSIndexPath indexPathForRow:tempCellIndex inSection:0];
            [tableVC.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            POPUPINFO(@"添加关注失败");
        }
        
    }
    else if([requestId isEqualToNumber:FriendModule_deleteFollow_tag])
    {
        if (NETACCESS_Success)
        {
            POPUPINFO(@"取消关注成功");
            NSMutableDictionary *extInfo = [Coordinator userProfile].extInfo;
            if (extInfo[@"followCount"])
            {
                int newFollowCount = [extInfo[@"followCount"] intValue];
                [extInfo setValue:NUMBER(newFollowCount - 1) forKey:@"followCount"];
            }
            UserProfile *user = _dataSource[tempCellIndex];
            user.relationType = [NSNumber numberWithInt:tempTargetType];
            NSIndexPath *path = [NSIndexPath indexPathForRow:tempCellIndex inSection:0];
            [tableVC.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            POPUPINFO(@"取消关注失败");
        }

    }
}

- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    if([self.aview isAnimating])
        [self stopAview];
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
    if([requestId isEqualToNumber:FriendModule_list_tag])
        [self assignDataSource:nil];
    
    
}
@end
