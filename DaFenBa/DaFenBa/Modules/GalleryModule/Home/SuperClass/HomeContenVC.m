//
//  TuijianVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#define isMOCKDATADebugger NO
#define SLEEP






#import "HomeVC.h"
#import "HomeContenVC.h"
#import "HomeContentCell.h"
#import "HomeCategoryTuijian.h"
#import "HomeCategoryGuangzhu.h"
#import "TuiJianSectionHeaderView.h"
#import "WaterFallFooter.h"
#import "FirstEnterTime.h"
#import "LastRefreshTime.h"

#import "PostProfile.h"

static const float cellspace = 5.0;
static const float headspace = 5.0;
static const int homeContentVCAutoDownloadPagesCount = 8;
static const float topScrollViewHeight = 32;
static const float loadViewHeight = 60;


@interface HomeContenVC ()<UIScrollViewDelegate>

@property float leftBottom;//左边瀑布流的底部Y值
@property float rightBottom;//右边瀑布流的底部Y值

@property BOOL isHaveAppeared;

@end

@implementation HomeContenVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        oldOffsetY = 0;
        
        maxPage = @8;
        lastRequestTime = @0;

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView setBounces:YES];
    self.collectionView.alwaysBounceVertical = YES;
    [self checkFirstAppear];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!loadMoreView) {
        loadMoreView = self.customRefreshControl.loadMoreView;
        [self.view addSubview:loadMoreView];
        [loadMoreView setTop:DEVICE_screenHeight - 64 - topScrollViewHeight - loadMoreView.height];//64.. 44 topscrollview
    }
    
    UIViewController<MainModuleDelegate> *mainVC = APPDELEGATE.mainVC;
    UINavigationController *nav = (UINavigationController *)APPDELEGATE.mainVC.viewControllers[0];
    HomeVC *homeVC = (HomeVC *)nav.viewControllers[0];
    
    float newOffsetY;
    if (scrollView.contentOffset.y < 0) {
        newOffsetY = 0;
    }
    else if(scrollView.contentOffset.y > scrollView.contentSize.height - (DEVICE_screenHeight - 64 - topScrollViewHeight))
        newOffsetY = scrollView.contentSize.height - (DEVICE_screenHeight - 64 - topScrollViewHeight);
    else
        newOffsetY = scrollView.contentOffset.y;
    if (newOffsetY <= 0) {
        [homeVC.GoToTheTop setAlpha:0];
        return;
    }
    
    if (newOffsetY > oldOffsetY + loadViewHeight ) {
        //向上
        oldOffsetY = newOffsetY;
        if (mainVC.isHidenTabBar) {
            return;
        }

        [mainVC hideTabBar];
        UIViewBeginAnimation(kDuration);
        homeVC.GoToTheTop.alpha = 0;
        CGPoint center = homeVC.GoToTheTop.center;
        [homeVC.GoToTheTop setSize:CGSizeMake(1, 1)];
        [homeVC.GoToTheTop setCenter:center];
        [UIView commitAnimations];

    }
    else if(newOffsetY < oldOffsetY - loadViewHeight  ) {
        //向下
        oldOffsetY = newOffsetY;
        if (!mainVC.isHidenTabBar)
        {
            return;
        }
        [mainVC showTabBar];
        UIViewBeginAnimation(kDuration);
        homeVC.GoToTheTop.alpha = 0.8;
        CGPoint center = homeVC.GoToTheTop.center;
        [homeVC.GoToTheTop setSize:CGSizeMake(40, 40)];
        [homeVC.GoToTheTop setCenter:center];
        [UIView commitAnimations];
        
    }
}

#pragma mark - 公共方法
/**
 *	@brief	检查是否为第一次出现，并需要引导页
 */
- (void)checkFirstAppear

{
    //首次访问
    UINavigationController *nav = (UINavigationController *)APPDELEGATE.mainVC.viewControllers[0];
    HomeVC *homeVC = (HomeVC *)nav.viewControllers[0];

    FirstEnterTime *first = [FirstEnterTime shareInstance];
    [FirstEnterTime getUserDefault];
    if (first.isFirstEnterGalleryPage && [first.isFirstEnterGalleryPage boolValue])
    {
        [APPDELEGATE.mainVC.view addSubview:homeVC.wizardView];
        [homeVC.wizardView setX:0];
        [homeVC.wizardView setY:0];
        
        homeVC.wizardView.hidden = NO;
        first.isFirstEnterGalleryPage = @NO;
        [FirstEnterTime storeUserDeault];
        
    }
    else
    {
        homeVC.wizardView.hidden = YES;
    }

}
/**
 *	@brief	当视图处于当前选择卡时
 */
- (void)viewDidCurrentView
{
    UINavigationController *nav = (UINavigationController *)APPDELEGATE.mainVC.viewControllers[0];
    HomeVC *homeVC = (HomeVC *)nav.viewControllers[0];

    if(self.pullDownRefreshed )
    if (!self.isHaveAppeared || [homeVC.currentVC isKindOfClass:[HomeCategoryGuangzhu class]] ) {//1.第一次出现  2.当前栏目是关注栏
        [self setupRefreshControl];
        [self startPullDownRefreshing];
        self.isHaveAppeared = YES;
    }
    
}



#pragma mark - dataSource
/**
 *	@brief	数据源
 */
- (void)loadDataSource
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UINavigationController *nav = (UINavigationController *)APPDELEGATE.mainVC.viewControllers[0];
        HomeVC *homeVC = (HomeVC *)nav.viewControllers[0];
        if (self.requestCurrentPage == 0 && [maxPage intValue] == 0)
            maxPage = @30000;
        //没有更多页
        if(self.requestCurrentPage + 1 > [maxPage intValue])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self endMoreOverWithMessage:@"没有更多页了"];
            });
            return;
        }
        // 进附近页面时要传地理信息
        if ([self isKindOfClass:[HomeCategoryFujing class]]) {
            [APPDELEGATE.geoInfoCondition lock];
            while (!APPDELEGATE.isGeoInfoGot)
                [APPDELEGATE.geoInfoCondition wait];
            [APPDELEGATE.geoInfoCondition unlock];
            if (APPDELEGATE.latitude == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self revokeHsRefresh];
                    [self revokeHsLoadMore];
                    POPUPINFO(@"未获取到坐标，尝试重启APP或设置设备！Sorry");
                });
                return;
            }

        }
        double latitude = APPDELEGATE.latitude;
        double longitude = APPDELEGATE.longitude;
        NSNumber *userId = [Coordinator userProfile].userId;
        //type
        GalleryManager *galleryManager = [GalleryManager shareInstance];
        int type =  galleryManager.selectedIndex + 1;
        //gender
        int gender = homeVC.filterResult;
        NSMutableDictionary *para = [@{ @"type" : NUMBER(type), @"longitude" :[NSNumber numberWithDouble:longitude], @"latitude" : [NSNumber numberWithDouble:latitude], @"pager" : @{@"pageNumber": NUMBER(self.requestCurrentPage + 1), @"pageSize" : @20}, @"lastRefreshTime" : lastRequestTime} mutableCopy];
        if (userId)
            [para setObject:userId forKey:@"userId"];
        if(gender != 0)
            [para setObject:NUMBER(gender) forKey:@"gender"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.netAccess passUrl:PostModule_list andParaDic:para withMethod:PostModule_list_method andRequestId:PostModule_list_tag thenFilterKey:nil useSyn:NO dataForm:7];
        });
        
    }
);
}
/**
 *	@brief	数据源赋值
 *
 *	@param 	dataSource 	新获取的数据
 */
- (void)assignDataSource:(NSArray *)dataSource
{
    
    NSMutableArray *arr = [[[GalleryManager shareInstance]selectedDataSource] mutableCopy];
    if (self.requestCurrentPage && dataSource != nil && [dataSource count] != 0)
    {//加载更多
        [arr addObjectsFromArray:dataSource];
        [self endLoadMoreRefreshing];
    }
    else//刷新
    {
        arr = [dataSource mutableCopy];
    }
    [[[GalleryManager shareInstance] selectedDataSource] removeAllObjects];
    [[[GalleryManager shareInstance] selectedDataSource] addObjectsFromArray:arr];
    
    [self.collectionView reloadData];
    
}



//删除所有内容图片
- (void)dumpAllContentCell
{
    
    [[[GalleryManager shareInstance] selectedDataSource] removeAllObjects];
    [self.collectionView reloadData];

}
#pragma mark UICollectionViewDataSource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *arr = [[GalleryManager shareInstance] selectedDataSource];

    return [arr count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"HomeContentCell";
    UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:[NSBundle mainBundle]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
    HomeContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier
                                                     owner:self options:nil];
        
        for (id oneObject in nib) {
            if ([oneObject isKindOfClass:[UICollectionViewCell class]]) {
                cell = oneObject;
                break;
            }
        }
    }
    
    PostProfile *model = [[GalleryManager shareInstance] selectedDataSource][indexPath.row];
    [cell assignValue:model];
    if (![self isKindOfClass:[HomeCategoryFujing class]]) {
        cell.disctanceIcon.hidden = YES;
        cell.distanceLabel.hidden = YES;
    }
    
    return cell;

}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    PostProfile *model = [[GalleryManager shareInstance] selectedDataSource][indexPath.row];
    UINavigationController *nav = (UINavigationController *)APPDELEGATE.mainVC.viewControllers[0];
    HomeVC *homeVC = (HomeVC *)nav.viewControllers[0];

    [ScoreManager evokeScoreWithPostOrScoreManager:model FromVC:homeVC];
    
}

#pragma mark ADD Header AND Footer
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

#pragma mark  UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [[GalleryManager shareInstance] selectedDataSource];
    PostProfile *model = arr[indexPath.row];
    float ratio = [model.picH floatValue]/[model.picW floatValue];
    float height = 150.0 * ratio;
    CGSize size = {150, height + 38};
    return size;
}


#pragma mark - XHRefreshControl Delegate

- (void)beginPullDownRefreshing {
    self.requestCurrentPage = 0;
    int t = (1<<31) + 1;
    t = -t;
    maxPage = NUMBER(t);
    lastRequestTime = @0;

    [self loadDataSource];
    //[currentVC loadDataSource];
}

- (void)beginLoadMoreRefreshing {
    self.requestCurrentPage ++;
    [self loadDataSource];
    
    // [currentVC loadDataSource];
}

- (NSString *)lastUpdateTimeString {
    
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:[lastRequestTime longValue]];
    
    NSString *destDateString = [nowDate timeAgo];
    
    return destDateString;
}
- (BOOL)isPullDownRefreshed {
    return self.pullDownRefreshed;
}
- (BOOL)isLoadMoreRefreshed {
    return self.loadMoreRefreshed;
}
- (XHRefreshViewLayerType)refreshViewLayerType {
    return XHRefreshViewLayerTypeOnScrollViews;
}

- (XHPullDownRefreshViewType)pullDownRefreshViewType {
    return self.refreshViewType;
}

- (NSInteger)autoLoadMoreRefreshedCountConverManual {
    return homeContentVCAutoDownloadPagesCount;
}
- (NSString *)displayAutoLoadMoreRefreshedMessage
{
    return @"查看下二十条";
}
#pragma mark - AsynNetAccessDelegate


- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    [self revokeHsRefresh];
    
    
    NSDictionary *dic;
    if (!TYPE_isDictionary(receiveObject))
    {
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
        [self revokeHsLoadMore];
        return;
    }
    else
    {
        dic = (NSDictionary *)receiveObject;
    }
    
    NSDictionary *result = dic[@"result"];
    if (!NETACCESS_Success)
    {
        POPUPINFO(@"列表获取失败");
        [self revokeHsLoadMore];
        return;
    }
    else
    {
        GalleryManager *galleryManager = [GalleryManager shareInstance];
        NSInteger selectIndex = galleryManager.selectedIndex;
        if (selectIndex == 1 && self.requestCurrentPage == 0) {//当前是关注栏并且刷新成功
            UINavigationController *nav = (UINavigationController *)APPDELEGATE.mainVC.viewControllers[0];
            HomeVC *homeVC = (HomeVC *)nav.viewControllers[0];

            [homeVC.topScrollView.bageGuanzhu setHidden:YES];//隐藏新增标志
    }
        
        
        
        NSArray *postResponseArr = receiveObject[@"posts"];
        NSMutableArray *postArr ;
        
        if(receiveObject[@"lastRefreshTime"] != nil)
        {
            lastRequestTime = receiveObject[@"lastRefreshTime"];
            if(receiveObject[@"pager"][@"pageCount"] != nil)
                maxPage = receiveObject[@"pager"][@"pageCount"];
            if ([self isKindOfClass:[HomeCategoryGuangzhu class]]) {
                LastRefreshTime *lrt = [LastRefreshTime shareInstance];
                [LastRefreshTime getUserDefault];
                lrt.requestTime_GuangzhuPost = lastRequestTime;
                [LastRefreshTime storeUserDeault];
            }
        }
        
        if(postResponseArr && [postResponseArr count] > 0)
        {
            postArr = [NSMutableArray array];
            for (NSDictionary *dic in postResponseArr) {
                PostProfile *post = [PostProfile new];
                NSMutableDictionary *dic2 = [dic mutableCopy];
                [dic2 renameKey:@"id" withNewName:@"postId"];
                [post assignValue:dic2];
                if(dic2[@"user"] != nil)
                {
                    NSMutableDictionary *postUser = [dic2[@"user"] mutableCopy];
                    [postUser renameKey:@"id" withNewName:@"userId"];
                    UserProfile *user = [UserProfile new];
                    [user assignValue:postUser];
                    post.user = user;
                }
                
                
                [postArr addObject:post];
            }
        }
        [self assignDataSource:postArr];
        return;
        
    }
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    
    [self revokeHsRefresh];
    [self revokeHsLoadMore];
    
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
}


@end
