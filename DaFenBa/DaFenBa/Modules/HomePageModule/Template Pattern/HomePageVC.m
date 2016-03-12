//
//  MeHomeVCViewController.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-29.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//



#import "HomePageVC.h"
#import "MeHomeVC.h"
#import "OtherHomeVC.h"
#import "XHLoadMoreView.h"
#import "PostProfile.h"
#import "DaFenBaDate.h"

static const float  kDeltaLayout = -130;
static const float  kMargin      = 10.0;

typedef NS_ENUM(NSUInteger, NotiType)
{
    NotiTypeAll     = 0,
    NotiTypePost    = 19,
    NotiTypeReply   = 21,
    NotiTypeMessage = 22,
    NotiTypeGrade   = 23,
    NotiTypeAdvice  = 24,
};
@interface TempModel : NSObject
@property (nonatomic) NSNumber *postId;
@property (nonatomic) NSString *avatar;
@property (nonatomic) NSString *content;
@property (nonatomic) NSNumber *createTime;

@end
@implementation TempModel
@end

@implementation HomePageVC
{
    NSMutableArray *dataSources[5];//dataSources[5]存放所有数据 4为所有

    XHLoadMoreView *loadView;
    
    NSUInteger selectedIndex;
    NotiType _notiType;
    NSNumber *lastRefreshTime[5];
    int  maxPage[5];
    int count[5];
}

@synthesize tableVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _notiType = NotiTypeAll;
        selectedIndex = 4;
        for (int i = 0; i < 5; i++) {
            lastRefreshTime[i] = @0;
            maxPage[i] = 8;
            count[i] = 0;
            dataSources[i] = [NSMutableArray array];
        }
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    
    [self assignValueForBasicInfo];
    [self setLayoutThem1];
    [tableVC startPullDownRefreshing];
    [tableVC.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
    [super viewWillAppear:animated];
}

#pragma mark - 视图准备

#pragma mark 模板方法
/**
 *	@brief	在viewDidLoad里执行
 */
- (void)configSubViews
{
    
    [self settingOption];
    [self addGesture];
    [self generateTableView];
    [self setSelectedUIForFilterBtn];
    
    [self AlternativeEditOrFollowSend];
}


#pragma mark  固有方法
- (void)settingOption
{//可选项设置
    self.isStatusWhite    = YES;
    self.isNeedHideTabBar = YES;
    self.isNeedHideNavBar = YES;
}
- (void)addGesture
{
    UISwipeGestureRecognizer *swipUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(scrollUPTableView)];
    swipUp.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *swipDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(slidDownTableView:)];
    swipDown.direction = UISwipeGestureRecognizerDirectionDown;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(slidDownTableView:)];
    [self.upperView addGestureRecognizer:swipUp];
    [self.upperView addGestureRecognizer:swipDown];
    [self.upperView addGestureRecognizer:tap];
}

- (void)generateTableView
{
    //tableview
    tableVC = [[XHPullRefreshTableViewController alloc]init];
    tableVC.refreshControlDelegate = tableVC;//self;
    [tableVC.view setX:0];
    [tableVC.view setY:21];

    [self.downView addSubview:tableVC.view];
    [self.downView sendSubviewToBack:tableVC.view];
    [tableVC.tableView setFrame:tableVC.view.bounds];
    tableVC.tableView.dataSource = self;
    tableVC.tableView.delegate  = self;
    [tableVC.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    if (tableVC.pullDownRefreshed) {
        [tableVC setupRefreshControl];
    }
    loadView = tableVC.refreshControl.loadMoreView;
    [self.view addSubview:loadView];
    [loadView setTop:self.view.height - loadView.height];
    loadView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    
}
- (NSArray *)filterNameArray
{
    return @[@"  给他人的回复", @"  给他人的打分", @"  给他人的建议", @"  上传照片"];//21 23 24 19
}


/**
 *	@brief	构造筛选框的按钮 设置筛选框的选中标志
 */
- (void)setSelectedUIForFilterBtn
{
    [self.filterView setBackgroundColor:[UIColor clearColor]];
    //筛选按钮 选中高光
    float startX = 10, startY = 12, cellSpace = 5, cellHeight = 28, cellWidth = 112;
    UIButton *btn;
    for (int i = 0 ; i < [self.filterNameArray count]; i++) {
        btn = [[UIButton alloc]initWithFrame:CGRectMake(startX, startY, cellWidth, cellHeight)];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.tag = i+100;
        [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [btn setTitle:self.filterNameArray[i] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:@"grayButton"]stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"transculent"] forState:UIControlStateNormal];
        [btn setTitleColor:ColorRGB(255.0, 165.0, 0) forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(filter:) forControlEvents:UIControlEventTouchUpInside];
        startY += cellHeight + cellSpace;
        [self.filterView addSubview:btn];
    }
    UIImageView *filterBG = (UIImageView *)[self.filterView viewWithTag:9999];
    [filterBG setHeight:btn.bottom + cellSpace];
    [filterBG setImage:[[UIImage imageNamed:@"filterView"]stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0]];
    
}
#pragma mark - 模板特有方法 需子类重写
/**
 *	@brief	设置 加关注、 发私信、 编辑资料 等控件的显示与隐藏
 */
- (void)AlternativeEditOrFollowSend
{
}
/**
 *	@brief	编辑资料按钮执行
 *
 */
- (IBAction)editProfile:(id)sender
{
}

/**
 *	@brief	控件赋值
 */
- (void)assignValueForBasicInfo
{
}

/**
 *	@brief	数据加载
 */
- (void)p_endMoreOverWithMessage:(NSString *)message
{
    NSString *str = loadView.loadMoreButton.titleLabel.text;
    [loadView.loadMoreButton setTitle:message forState:UIControlStateNormal];
    loadView.loadMoreButton.userInteractionEnabled = NO;
    [loadView setHidden:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loadView.loadMoreButton setTitle:str forState:UIControlStateNormal];
        loadView.loadMoreButton.userInteractionEnabled = YES;
        [loadView setHidden:YES];

    });
}
- (void)loadDataSource {
    if (tableVC.requestCurrentPage == 0 && maxPage[selectedIndex] == 0) {
        maxPage[selectedIndex] = 30000;
    }
    if (tableVC.requestCurrentPage + 1 > maxPage[selectedIndex] )
    {
        [tableVC revokeHsRefresh];
        [self p_endMoreOverWithMessage:@"没有更多页了"];
        return;
    }
 
    NSNumber *loginUserId = [Coordinator userProfile].userId;
    NSNumber *curUserId   = self.userProfile.userId;
    
    NSString *apiName = NotificationModule_listFromMe;
    NSMutableDictionary *para = [@{@"type" : NUMBER(_notiType), @"pager" : @{@"pageNumber" : NUMBER(tableVC.requestCurrentPage + 1), @"pageSize" : @20}, @"lastRefreshTime" : lastRefreshTime[selectedIndex]} mutableCopy];
    [para setValue:loginUserId forKeyPath:@"userId" ];
    [para setValue:NUMBER(_notiType) forKeyPath:@"type"];
    if([self isKindOfClass:[OtherHomeVC class]]){//别人的
        [para setValue:curUserId forKeyPath:@"hisId"];
        apiName = NotificationModule_listFromHis;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        sleep(5);
        NSDictionary *resultDic = [self.netAccess passUrl:apiName andParaDic:para withMethod:AccessMethodPOST andRequestId:unQueueRequestId thenFilterKey:nil useSyn:YES dataForm:7];
        NSDictionary *result = resultDic[@"result"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableVC revokeHsRefresh];
            if (!NETACCESS_Success) {
                POPUPINFO(@"数据获取失败,"ACCESSFAILEDMESSAGE);
                [tableVC revokeHsLoadMore];
            }
            else
            {
                if (resultDic[@"lastRefreshTime"])
                {
                    lastRefreshTime[selectedIndex] = resultDic[@"lastRefreshTime"];
                    maxPage[selectedIndex] = [resultDic[@"pager"][@"pageCount"] intValue];
                    count[selectedIndex]   = [resultDic[@"pager"][@"recordCount"] intValue];
                    self.recordCountLabel.text = [NSString stringWithFormat: @"全部（%d）", count[selectedIndex]];
                }
                NSArray *notifications = resultDic[@"notifications"];
                NSMutableArray *newDataSource = [NSMutableArray array];
                for (NSDictionary *newNotiL in notifications) {
                    TempModel *newNoti = [TempModel new];
                    newNoti.content = newNotiL[@"content"];
                    newNoti.postId = newNotiL[@"srcId"];
                    newNoti.avatar = newNotiL[@"targetUser"][@"avatar"];
                    newNoti.createTime = newNotiL[@"createTime"];
                    [newDataSource addObject:newNoti];
                }
                if ([newDataSource count] > 0) {
                    if (tableVC.requestCurrentPage == 0)
                        [dataSources[selectedIndex] removeAllObjects];
                    [dataSources[selectedIndex] addObjectsFromArray:newDataSource];
                }
                [tableVC.tableView reloadData];

            }
        });
    });
}
# pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.upperView.top == 0)
        return;
    [self scrollUPTableView];
}
#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSources[selectedIndex] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *cellIdentifier = @"UserActionRecordCell";
    BaseCell *cell = [BaseCell cellRegisterNib:cellIdentifier tableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TempModel *aModel = (TempModel *)dataSources[selectedIndex][indexPath.row];
    NSString *createTime = [DaFenBaDate curStr2FromTime:[aModel.createTime longValue]];
    NSString *displayStr = [NSString stringWithFormat:@"%@ %@",createTime, aModel.content];
    [cell.label1 setText:displayStr];
    [cell.label1 setWidth:225.0];
    [cell.label1 sizeToFit];
    if (cell.label1.height > 40) {
        cell.height = cell.contentView.height = cell.label1.bottom + 10.0;
    }
    [cell.imageView1 setAvartar:aModel.avatar];
    [cell.imageView1 setCenter:CGPointMake(cell.imageView1.center.x, cell.height / 2)];
    [cell.label1 setCenter:CGPointMake(cell.label1.center.x, cell.height / 2)];

    
    return cell;
}


#pragma mark  UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.filterView.hidden == NO)
    {
        [self.filterView setHidden:YES];
    }
    else
    {
        TempModel *aModel = (TempModel *)dataSources[selectedIndex][indexPath.row];

        PostProfile *post = [PostProfile new];
        post.postId = aModel.postId;
        
        [ScoreManager evokeScoreWithPostOrScoreManager:post FromVC:self];
        
    }
}
#pragma mark - 布局动画
/**
 *	@brief	正常视图外观
 */
- (void)setLayoutThem1
{
    [self.upperView setY:- 20];
    [self.introLabel setWidth:240];
    [self.introLabel sizeToFit];
    [self.operateView setTop:self.introLabel.bottom + kMargin];
    [self.upperView setHeight:self.operateView.bottom + kMargin];
    CGPoint oldcenter = self.avatarImageView.center;
    [self.avatarImageView setAlpha:1.0];
    [self.avatarImageView setWidth:60];
    [self.avatarImageView setHeight:60];
    [self.avatarImageView setCenter:oldcenter];

    [self setLayoutDownView];
}
/**
 *	@brief	查看tableview时的外观
 */
- (void)setLayoutThem2
{
    if (self.upperView.top > kDeltaLayout)
    {
        [self.upperView setY: kDeltaLayout];
        [self.introLabel setHeight:22.0];
        [self.operateView setTop:self.introLabel.bottom + kMargin];
        [self.upperView setHeight:self.operateView.bottom + kMargin];
        CGPoint oldcenter = self.avatarImageView.center;
        [self.avatarImageView setAlpha:0.0];
        [self.avatarImageView setWidth:0];
        [self.avatarImageView setHeight:0];
        [self.avatarImageView setCenter:oldcenter];
        
        [self setLayoutDownView];
    }
}
// 辅助方法
- (void) setLayoutDownView
{
    self.downView.top = self.upperView.bottom ;
    [self.view setHeight:DEVICE_screenHeight - StatusHeight];
    [self.downView setHeight:self.view.height - self.downView.top];
    [tableVC.tableView setHeight:self.downView.height - 26];
    [tableVC.view setHeight:self.downView.height - 26];
}
/**
 *	@brief	下移tableview
 */
- (void) scrollUPTableView
{
    tableVC.pullDownRefreshed =  NO;
    tableVC.loadMoreRefreshed  = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:kDuration];
    [self setLayoutThem2];
    [self.filterView setHidden:YES];
    [UIView commitAnimations];
    tableVC.pullDownRefreshed =  YES;
    tableVC.loadMoreRefreshed  = YES;

}
/**
 *	@brief	上移tableview
 *
 *	@param 	sender
 */
- (IBAction)slidDownTableView:(UIControl *)sender
{
    tableVC.pullDownRefreshed =  NO;
    tableVC.loadMoreRefreshed  = NO;
    [self.filterView setHidden:YES];

    if (self.upperView.top <= - 130)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:kDuration];
        [self setLayoutThem1];
        [self.filterView setHidden:YES];
        [UIView commitAnimations];
    }
    tableVC.pullDownRefreshed =  YES;
    tableVC.loadMoreRefreshed  = YES;

}
#pragma mark - filter
/**
 *	@brief	弹出筛选视图
 *
 *	@param 	sender
 */
- (IBAction)popFilterView:(id)sender
{
    [self.filterView setHidden:!self.filterView.hidden];
}
/**
 *	@brief	选中筛选条件
 *
 *	@param 	sender
 */
- (IBAction)filter:(UIButton *)sender
{
    [dataSources[4] removeAllObjects];
    int types[] = {21,23,24,19};
    selectedIndex = sender.tag - 100;
    
    self.recordCountLabel.text = [NSString stringWithFormat: @"全部（%d）", count[selectedIndex]];
    
    _notiType = types[selectedIndex];
    for (int i = 0 ; i < [self.filterNameArray count]; i++) {
        UIButton *btn = (UIButton *)[self.filterView viewWithTag:i+100];
        btn.selected = NO;
    }
    sender.selected = YES;
    [self.filterView setHidden:YES];
    int pageCount = (int)ceil([dataSources[selectedIndex] count]/20.0);
    tableVC.requestCurrentPage =  pageCount - 1 > 0? pageCount - 1 : 0;
    if ([lastRefreshTime[selectedIndex] intValue] == 0 ) {//栏目第一次进刷数据
        
        [tableVC startPullDownRefreshing];
    }
    else
        [tableVC.tableView reloadData];

}
+ (void)enterHomePageOfUser:(UserProfile *)user fromVC:(BaseVC *)startVC
{
    UserProfile *loginUser = [Coordinator userProfile];
    if (user.userId == nil) {
        POPUPINFO(@"不给我你要去主页用户的id号，我怎么知道怎么找！");
        return;
    }
    else if(loginUser && loginUser.userId!=nil && [user.userId isEqualToNumber:loginUser.userId])
    {
        MeHomeVC *meHomeVC = [MeHomeVC new];
        [startVC.navigationController pushViewController:meHomeVC animated:YES];
    }
    else
    {
        OtherHomeVC *otherHomeVC = [OtherHomeVC new];
        otherHomeVC.userProfile = user;
        [startVC.navigationController pushViewController:otherHomeVC animated:YES];
    }
    
}

@end
