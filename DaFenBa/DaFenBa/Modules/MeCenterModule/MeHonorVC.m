//
//  MeHonorVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-30.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MeHonorVC.h"
#import "EventModel.h"
#import "UserProfile.h"
#import "DaFenBaDate.h"



@interface MeHonorVC ()< UITableViewDataSource, UITableViewDelegate>

@property BOOL isStreched;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation MeHonorVC
{
    UIView *loadView;
    
    NSCondition *condition;
    BOOL isHonorGot;
    BOOL isMedalGot;
    
    int maxPage;
    NSNumber *lastRefreshTime;
}
@synthesize tableVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        tableVC = [[XHPullRefreshTableViewController alloc]init];
        tableVC.refreshControlDelegate = tableVC;
        maxPage = 8;
        lastRefreshTime = @0;
        self.dataSource = [NSMutableArray array];
        condition = [[NSCondition alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedHideTabBar = YES;
    self.isNeedHideNavBar = YES;

    [self assignValueForBasicUserInfo];

}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [condition lock];
        while (!isHonorGot || !isMedalGot) {
            [condition wait];
        }
        [condition unlock];
        isHonorGot = NO;
        isMedalGot = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
        });
    });
    [self getData];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - 控件赋值
/**
 *	@brief	动态赋值
 */
- (void)assignValueForBasicUserInfo
{
    UserProfile *userProfile = [Coordinator userProfile];
    
    [self.headIcon setAvartar:userProfile.avatar ];
    self.userName.text = userProfile.srcName;
    [self.userName sizeToFit];
    [self.userName setCenter:CGPointMake(DEVICE_screenWidth/2, self.userName.center.y)];
    //性别
    [self.genderIcon setX:self.userName.right + 5.0];
    NSNumber *gender = userProfile.gender;
    if ([gender isEqualToNumber:@1]) {
        self.genderIcon.image = [UIImage imageNamed:@"genderBoy"];
    }
    else if ([gender isEqualToNumber:@2]){
        self.genderIcon.image = [UIImage imageNamed:@"genderGirl"];
    }
    if ( [userProfile.extInfo[@"level"] intValue] > 0) {
        [self.rankButton setBackgroundImage:[UIImage imageNamed:@"rank1"] forState:UIControlStateNormal];
    }
    else
    {
        [self.rankButton setBackgroundImage:[UIImage imageNamed:@"rank0"] forState:UIControlStateNormal];
    }
    [self.rankButton setTitle: [NSString stringWithFormat:@"LV %@", userProfile.extInfo[@"level"] ] forState:UIControlStateNormal];
    [self.rankButton sizeToFit];
    [self.rankButton setHeight:15];
    [self.rankButton setCenter:CGPointMake(DEVICE_screenWidth/2, self.rankButton.center.y)];
}
/**
 *	@brief	静态赋值
 */

- (void)configSubViews
{
    //头像加边框
    self.headIcon.layer.borderWidth = 1;
    self.headIcon.layer.borderColor = [ColorRGB(194.0, 184.0, 213.0) CGColor];
    //背景给图
    [self.view setBackgroundColor:ColorRGB(246.0, 246.0, 246.0)];
    [self.bg1 setImage:areaBgImage];
    [self.bg2 setImage:areaBgImage];
    //赋值
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stretchSwitch)];
    [self.bg2 addGestureRecognizer:tap];
    self.bg2.userInteractionEnabled = YES;
    [self.upperView addSubview:tableVC.tableView];
    self.upperView.clipsToBounds = YES;
    [tableVC.tableView setTop:self.bg2.bottom];
    if (tableVC.pullDownRefreshed) {
        [tableVC setupRefreshControl];
    }
    loadView = self.tableVC.refreshControl.loadMoreView;
    tableVC.tableView.dataSource = self;
    tableVC.tableView.delegate  = self;
    tableVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:loadView];
   
    [loadView setTop:self.view.height - loadView.height];
    
    
}
/**
 *	@brief	标识刷新失败
 */
- (void)markRefreshFail
{
    [self.rankButton setTitle:@"更新失败，请退出重入" forState:UIControlStateNormal];
    [self.rankButton sizeToFit];
    [self.rankButton setHeight:15];
}
#pragma mark 列表收拢展开

- (void)stretchSwitch
{
    UIViewBeginAnimation(kDuration);
    if (!self.isStreched) {
        self.strechIcon.transform = CGAffineTransformMakeRotation(- M_PI);
        self.isStreched = YES;
        [self.upperView setTop:-303];
        [self.upperView setHeight:DEVICE_screenHeight + 303];
        [tableVC.tableView setHeight:DEVICE_screenHeight+ 303 - tableVC.tableView.top ];
        [self.backBtn setAlpha:0];
        
        [tableVC beginPullDownRefreshing];
    }
    else
    {
        self.strechIcon.transform = CGAffineTransformIdentity;
        self.isStreched = NO;
        [self.upperView setTop:-20];
        [self.upperView setHeight:382.0];
        [tableVC.tableView setHeight:382.0 - tableVC.tableView.top ];
        [self.backBtn setAlpha:1];
    }
    [UIView commitAnimations];
}

#pragma mark - 数据获取
- (void)getData
{
    UserProfile *userProfile = [Coordinator userProfile];
    NSDictionary *para;
    //发布照片数，打分数，建议数，等级
    para = @{@"userId" : userProfile.userId};
    
    [self.netAccess passUrl:UserHonorModule_list andParaDic:para withMethod:UserHonorModule_list_method andRequestId:UserHonorModule_list_tag thenFilterKey:nil useSyn:NO dataForm:7];
    //勋章
    [self.netAccess passUrl:MedalModule_list andParaDic:para withMethod:MedalModule_list_method andRequestId:MedalModule_list_tag thenFilterKey:nil useSyn:NO dataForm:0];

}
- (void)loadDataSource
{
    if (tableVC.requestCurrentPage == 0 && maxPage == 0) {
        maxPage = 30000;
    }
    if (tableVC.requestCurrentPage + 1 > maxPage) {
        [tableVC revokeHsRefresh];
        [tableVC endMoreOverWithMessage:@"没有更多页了"];
        return;
    }
    NSNumber *userId = [Coordinator userProfile].userId;
    NSNumber *page = [NSNumber numberWithInt:tableVC.requestCurrentPage + 1];
    NSDictionary *pager = @{@"pageNumber" : page, @"pageSize" : @20};
    NSNumber *lrt = lastRefreshTime;
    NSDictionary *para = @{@"userId" : userId, @"pager" : pager, @"lastRefreshTime" : lrt};
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary *resultDic = [self.netAccess passUrl:DecibelModule_list andParaDic:para withMethod:DecibelModule_list_method andRequestId:DecibelModule_list_tag thenFilterKey:nil useSyn:YES dataForm:7];
        NSDictionary * result = resultDic[@"result"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (NETACCESS_Success) {
                if(resultDic[@"lastRefreshTime"] != nil)
                {
                    lastRefreshTime = resultDic[@"lastRefreshTime"];
                    if(resultDic[@"pager"][@"pageCount"] != nil)
                        maxPage = [resultDic[@"pager"][@"pageCount"] intValue];
                }
                
                NSDictionary *decibels = resultDic[@"decibels"];
                NSMutableArray *newDataSource = [NSMutableArray array];
                for (NSDictionary *aDecibel in decibels) {
                    EventModel *newEvent = [EventModel new];
                    newEvent.eventId = aDecibel[@"event"];
                    newEvent.eventName = aDecibel[@"eventName"];
                    newEvent.createTime = aDecibel[@"createTime"];
                    newEvent.tgtObject = [BaseObject new];
                    newEvent.tgtObject.objectId =aDecibel[@"srcId"];
                    newEvent.message = aDecibel[@"message"];
                    newEvent.decibelId = aDecibel[@"id"];
                    newEvent.decibelChange = aDecibel[@"point"];
                    newEvent.extInfo = [NSMutableDictionary dictionary];
                    [newEvent.extInfo setValue:aDecibel[@"targetId"] forKeyPath:@"targetId"];
                    [newEvent.extInfo setValue:aDecibel[@"targetUserName"] forKeyPath:@"targetUserName"];
                    [newDataSource addObject:newEvent];
                }

                if(tableVC.requestCurrentPage == 0)
                    self.dataSource = newDataSource;
                else
                    [self.dataSource addObjectsFromArray:newDataSource];
                
                [tableVC.tableView reloadData];
            }
            else
            {
                [tableVC revokeHsLoadMore];
                POPUPINFO(@"网络访问出错,"ACCESSFAILEDMESSAGE);
            }
        });
        
    });
 
}


#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MeHonorCell";

    BaseCell *cell = [BaseCell cellRegisterNib:cellIdentifier tableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    EventModel *event = self.dataSource[indexPath.row];
    cell.label1.text = STRING_judge(event.message);
    NSString *timeStr = [DaFenBaDate curStr2FromTime:[event.createTime longValue]];
    cell.label2.text = STRING_judge(timeStr);
    [cell.label1 setWidth:200.0];
    [cell.label1 sizeToFit];
    
    float cellHeight = 44;
    if (cell.label1.height + 20 > 44)
        cellHeight = cell.label1.height + 20;
    cell.height = cell.contentView.height = cellHeight;
    
    [cell.label1 setCenter:CGPointMake(cell.label1.center.x, cell.height / 2)];
    [cell.label2 setCenter:CGPointMake(cell.label2.center.x, cell.height / 2)];

    return cell;
}


#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.height > 44) return cell.height;
    else return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - AsynNetAccessDelegate

- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    if ([requestId isEqual:MedalModule_list_tag]) {
        [condition lock];
        isMedalGot = YES;
        [condition signal];
        [condition unlock];
    }
    else if([requestId isEqual:UserHonorModule_list_tag])
    {
        [condition lock];
        isHonorGot = YES;
        [condition signal];
        [condition unlock];
    }
    NSDictionary *resultDic = (NSDictionary *)receiveObject;

    NSDictionary *result = resultDic[@"result"];
    if (!NETACCESS_Success)
    {
        [super netAccessFailedAtRequestId:requestId withErro:ErrorASI];
        [self markRefreshFail];
        return;
    }
    else
    {
        if ([requestId isEqualToValue:UserHonorModule_list_tag])
        {
            NSDictionary *userHonor = resultDic[@"userHonor"];
            self.decibelCountLabel.text = [NSString stringWithFormat:@"%@", userHonor[@"totalDb"]];
            if ( [userHonor[@"level"] intValue] > 0) {
                [self.rankButton setBackgroundImage:[UIImage imageNamed:@"rank1"] forState:UIControlStateNormal];
            }
            else
            {
                [self.rankButton setBackgroundImage:[UIImage imageNamed:@"rank0"] forState:UIControlStateNormal];
            }
            [self.rankButton setTitle: [NSString stringWithFormat:@"LV %@", userHonor[@"level"]] forState:UIControlStateNormal];
            [self.rankButton sizeToFit];
            [self.rankButton setHeight:15];
            
            UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
            if(userProfile.extInfo == nil) userProfile.extInfo = [NSMutableDictionary dictionary];
            NSMutableDictionary *extInfo = userProfile.extInfo;
            
            [extInfo setObject:userHonor[@"level"] forKey:@"level"];
            [extInfo setObject:userHonor[@"gradeCount"] forKey:@"gradeCount"];
            [extInfo setObject:userHonor[@"postCount"] forKey:@"postCount"];
            [extInfo setObject:userHonor[@"adviceCount"] forKey:@"adviceCount"];
            [extInfo setObject:userHonor[@"totalDb"] forKey:@"totalDb"];
            
            return;
        }
        else if([requestId isEqualToNumber:MedalModule_list_tag])
        {
            NSArray *medalArr = resultDic[@"medals"];
            NSArray *medalBtns = @[_honorBtn1, _honorBtn2, _honorBtn3];
            NSArray *medalImages = @[@"honor1_select", @"honor3_select", @"honor2_select"];
            self.medalCount.text = [NSString stringWithFormat:@"勋章（%d）", [medalArr count]];
            for (NSDictionary *aMedal in medalArr) {
                int index = [aMedal[@"id"] intValue] - 1;
                if (index >= 0 && index < 3) {
                    [((UIButton *)medalBtns[index]) setImage:[UIImage imageNamed:medalImages[index]] forState:UIControlStateNormal];
                }
                
            }
            return;
            /* 当使用网络图片填充时，使用如下方案
            NSArray *medalArr = dic[@"medals"];
            self.medalCount.text = [NSString stringWithFormat:@"勋章（%d）", [medalArr count]];
            int index = 0;
            float cellSpace = 10.0;
            float cellWidth = 40.0;
            float cellHeight = 40.0;
            for (NSDictionary *aMedal in medalArr) {
                NSString *imageUrl = aMedal[@"pic"];
                UIImageView *aMedalImageView = [[UIImageView alloc]initWithFrame:CGRectMake(index * (cellWidth +cellSpace), 0, cellWidth, cellHeight)];
                [aMedalImageView setUrlStr:imageUrl];
                [_medalScrollView addSubview:aMedalImageView];
                float curWidth = (index + 1)*(cellWidth + cellSpace) - cellSpace;
                [_medalScrollView setContentSize:CGSizeMake(curWidth, cellHeight)];
                if(curWidth < DEVICE_screenWidth)
                {
                    [_medalScrollView setWidth:curWidth];
                    [_medalScrollView setCenter:CGPointMake(DEVICE_screenWidth/2, _medalScrollView.center.y)];
                }
                index++;
            }*/
            
        }
        
    }
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
    [self markRefreshFail];

    if ([requestId isEqual:MedalModule_list_tag]) {
        [condition lock];
        isMedalGot = YES;
        [condition signal];
        [condition unlock];
        return;
    }
    else if([requestId isEqual:UserHonorModule_list_tag])
    {
        [condition lock];
        isHonorGot = YES;
        [condition signal];
        [condition unlock];
        return;
    }
    
}




@end
