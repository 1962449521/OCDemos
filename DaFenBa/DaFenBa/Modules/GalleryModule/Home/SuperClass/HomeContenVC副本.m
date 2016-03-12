//
//  TuijianVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#define cellspace 5.0
#define headspace 5.0
#define homeContentVCAutoDownloadPagesCount 8

#import "HomeVC.h"
#import "HomeContenVC.h"
#import "HomeContentModel.h"
#import "HomeContentCell.h"
#import "HomeCategoryTuijian.h"

#import "ScoreVC.h"


@interface HomeContenVC ()<UIScrollViewDelegate>

@property float leftBottom;//左边瀑布流的底部Y值
@property float rightBottom;//右边瀑布流的底部Y值

@property BOOL isHaveAppeared;

@end

@implementation HomeContenVC
{
    BOOL _isRefreshFinished;
    float oldOffsetY;
    UIView *loadMoreView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.leftStartY = headspace;// + 40 + cellspace;delete version2

        self.rightStartY =headspace;
        oldOffsetY = 0;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;    
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
        [loadMoreView setTop:DEVICE_screenHeight - 64 - 44 - loadMoreView.height];//64.. 44 topscrollview
    }
    
    //if(scrollView.isDecelerating)return;
    UIViewController<MainModuleDelegate> *mainVC = APPDELEGATE.mainVC;
    HomeVC *homeVC = (HomeVC *)[(UINavigationController *)[APPDELEGATE.mainVC selectedViewController]topViewController];
    
    float newOffsetY = scrollView.contentOffset.y;
    if (newOffsetY <= 0) {
        [homeVC.GoToTheTop setAlpha:0];
        return;
    }
     NSLog(@"oldY:%f   newY:%f", oldOffsetY, newOffsetY);
    if (newOffsetY > oldOffsetY + 60 ) {
        //向上
        oldOffsetY = newOffsetY;
        if (mainVC.isHidenTabBar) {
            return;
        }

        [mainVC hideTabBar];
//        [mainVC.view layoutIfNeeded];
//        [self.scrollView setHeight:self.view.height];
        UIViewBeginAnimation;
        homeVC.GoToTheTop.alpha = 0;
        CGPoint center = homeVC.GoToTheTop.center;
        [homeVC.GoToTheTop setSize:CGSizeMake(1, 1)];
        [homeVC.GoToTheTop setCenter:center];
        [UIView commitAnimations];

    }
    else if(newOffsetY < oldOffsetY - 60  ) {
        //向下
        oldOffsetY = newOffsetY;
        if (!mainVC.isHidenTabBar)
        {
            return;
        }
        [mainVC showTabBar];
//        [mainVC.view layoutIfNeeded];
//        [self.scrollView setHeight:self.view.height];
        UIViewBeginAnimation;
        homeVC.GoToTheTop.alpha = 0.3;
        CGPoint center = homeVC.GoToTheTop.center;
        [homeVC.GoToTheTop setSize:CGSizeMake(40, 40)];
        [homeVC.GoToTheTop setCenter:center];
        [UIView commitAnimations];
        
    }
}

#pragma mark - 公共方法
/*
- (void)addClendar
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    NSInteger year = [comps year] % 100;
    NSInteger week = [comps weekday];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    
    _calendar = [[[NSBundle mainBundle]loadNibNamed:@"HomeCalendarView" owner:self options:nil]lastObject];
    
    _calendar.calendarDate.text = [NSString stringWithFormat:@"%d",day];
    NSArray *weekstr = @[@"", @"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    _calendar.calendarWeek.text = [NSString stringWithFormat:@"周%@", weekstr[week]];
    _calendar.calendarYearMonth.text = [NSString stringWithFormat:@"%d年%d月", year, month];
    _calendar.layer.borderWidth = 1;
    _calendar.layer.borderColor = [TheMeBorderColor CGColor];
    [_calendar setY:headspace];
    [self.scrollView addSubview:_calendar];
}
*/
/**
 *	@brief	当视图处于当前选择卡时
 */
- (void)viewDidCurrentView
{
    if (self.pullDownRefreshed && !self.isHaveAppeared) {
        [self setupRefreshControl];
       // if (![self isKindOfClass:[HomeCategoryTuiJian class] ]) {
            [self.scrollView setContentOffset:CGPointMake(0, - refreshViewHeight)];
       // }
        
        [self startPullDownRefreshing];
        self.isHaveAppeared = YES;
        
        
    }
    
}
/**
 *	@brief	数据源
 */
- (void)loadDataSource
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.5);
        NSMutableArray *newDataSource = [NSMutableArray arrayWithCapacity:0];
#ifdef isUseMockData
        for (int i = 0; i < 5; i++) {
            HomeContentModel *aContentModel = [[HomeContentModel alloc]init];
            aContentModel.userId = @"1234";
            aContentModel.headIcon = @"headIcon";
            aContentModel.name     = [NSString stringWithFormat:@"%d-%d",self.requestCurrentPage, i];
            aContentModel.gender   = YES;
            aContentModel.photo    = @"photo";
            aContentModel.description = @"超喜欢的一条裙子，穿着它就像飞在天上一样，有种莫名的喜悦和憧憬，若是天有情，天亦会开心的笑出声来吧，觉得好看吗，那就给我打个分哦";
            [newDataSource addObject:aContentModel];
        }
#else
#endif
        NSNumber *lastRequestTime = @555;
        
        BOOL isLoadDataFail = NO;
//        if (self.requestCurrentPage == 4 || self.requestCurrentPage == 6)
//            isLoadDataFail = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *arr = [[[GalleryManager shareInstance]selectedDataSource] mutableCopy];
            if (self.requestCurrentPage)
            {//加载更多
                if (isLoadDataFail)
                    [self handleLoadMoreError];
                else
                {
                    [arr addObjectsFromArray:newDataSource];
                    [self endLoadMoreRefreshing];
                }
            }
            else//刷新
            {
                if ([[GalleryManager shareInstance]selectedIndex] == 1) {
                    HomeVC *homeVC = (HomeVC *)((UINavigationController *)APPDELEGATE.mainVC.selectedViewController).topViewController;
                    [homeVC.badge setHidden:YES];
                    LastRefreshTime *lrq = [LastRefreshTime shareInstance];
                    lrq.requestTime_GuangzhuPost = lastRequestTime;
                    
                }                
                [self dumpAllContentCell];
                arr = newDataSource;
                [self endPullDownRefreshing];
            }
            [[[GalleryManager shareInstance] selectedDataSource] removeAllObjects];
            [[[GalleryManager shareInstance] selectedDataSource] addObjectsFromArray:arr];
            id dd = [GalleryManager shareInstance];
            [self insertNewContentCells:newDataSource];
            
            //首次访问
            HomeVC *homeVC = (HomeVC *)((UINavigationController *)APPDELEGATE.mainVC.selectedViewController).topViewController;
            FirstEnterTime *first = [FirstEnterTime shareInstance];
            [FirstEnterTime getUserDefault];
            if (first.isFirstEnterGalleryPage && [first.isFirstEnterGalleryPage boolValue]) {
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
            }            //[currentVC endPullDownRefreshing];
        });
    });
}
//删除所有内容图片
- (void)dumpAllContentCell
{
    NSArray *cells = [self.scrollView subviews];
    for (UIView *cell in cells) {
        if ([cell isKindOfClass:[HomeContentCell class]])
            [cell removeFromSuperview];
    }
    self.leftStartY = headspace;
    self.rightStartY =headspace;

}
/**
 *	@brief	插入一条新记录
 *
 *	@param 	contentModel 	记录项
 */
- (void)insertNewContentCell:(HomeContentModel *)contentModel
{
    if ([self isKindOfClass:[HomeCategoryTuiJian class]] && self.leftStartY == self.rightStartY && self.rightStartY == headspace) {

        TuiJianSectionHeaderView *dd = [[[NSBundle mainBundle]loadNibNamed:@"TuiJianSectionHeaderView" owner:self options:nil]lastObject];
        

        [self.scrollView addSubview:dd];
        self.leftStartY = self.rightStartY = dd.bottom;
    }
    BOOL isInsertLeft = NO;
    if (self.leftStartY <= self.rightStartY)
    {
        isInsertLeft = YES;
    }
    //确定插入点
    float insertStartX, insertStartY;
    if (isInsertLeft)
    {
        insertStartX = 6.0;
        insertStartY = self.leftStartY;
    }
    else
    {
        insertStartX = 164.0;
        insertStartY = self.rightStartY;
    }
    //生成新单元格
    HomeContentCell *contentCell = [[[NSBundle mainBundle]loadNibNamed:@"HomeContentCell" owner:self options:nil]lastObject];
    [contentCell assignValueWithData:contentModel];
    [contentCell setX:insertStartX];
    [contentCell setY:insertStartY];
    
    [self.scrollView addSubview:contentCell];
    
    if (isInsertLeft) {
        self.leftStartY = contentCell.bottom + cellspace;
    }
    else{
        self.rightStartY = contentCell.bottom + cellspace;
    }
    
    if (contentCell.bottom + cellspace > self.scrollView.height) {
        self.scrollView.contentSize = CGSizeMake(DEVICE_screenWidth, contentCell.bottom + cellspace);
    }
    else{
        self.scrollView.contentSize = CGSizeMake(DEVICE_screenWidth, self.scrollView.height);
    }
    
}

/**
 *	@brief	插入多条新记录
 *
 *	@param 	contentModels 	记录项数组
 */
- (void)insertNewContentCells:(NSArray *)contentModels
{
    for (HomeContentModel *aContentModel in contentModels) {
        aContentModel.indexWithinDataSource = [contentModels  indexOfObject:aContentModel];
        int totalCount =  [[[GalleryManager shareInstance]selectedDataSource]count];
        if (contentModels.count != totalCount) {
            aContentModel.indexWithinDataSource += totalCount;
        }
        [self insertNewContentCell:aContentModel];
    }
}

#pragma mark - XHRefreshControl Delegate

- (void)beginPullDownRefreshing {
    self.requestCurrentPage = 0;
    [self loadDataSource];
    //[currentVC loadDataSource];
}

- (void)beginLoadMoreRefreshing {
    self.requestCurrentPage ++;
    [self loadDataSource];
    
    // [currentVC loadDataSource];
}

- (NSString *)lastUpdateTimeString {
    
    NSDate *nowDate = [NSDate date];
    
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
    return @"查看下二十二条";
}
- (UIView *)customPullDownRefreshView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -60, 320, 60)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.tag = 100;
    progressView.frame = CGRectMake(0, CGRectGetHeight(backgroundView.bounds) / 2.0 - 3, 320, 3);
    if ([progressView respondsToSelector:@selector(setTintColor:)]) {
        progressView.tintColor = [UIColor orangeColor];
    }
    [backgroundView addSubview:progressView];
    return backgroundView;
}

- (void)customPullDownRefreshView:(UIView *)customPullDownRefreshView withPullDownOffset:(CGFloat)pullDownOffset {
    UIProgressView *progessView = (UIProgressView *)[customPullDownRefreshView viewWithTag:100];
    [progessView setProgress:pullDownOffset / 40.0 animated:NO];
}

- (void)customPullDownRefreshViewWillStartRefresh:(UIView *)customPullDownRefreshView {
    UIProgressView *progressView = (UIProgressView *)[customPullDownRefreshView viewWithTag:100];
    [progressView setProgress:1.0];
    if ([progressView respondsToSelector:@selector(setTintColor:)]) {
        [progressView setTintColor:[UIColor greenColor]];
    }
}

- (void)customPullDownRefreshViewWillEndRefresh:(UIView *)customPullDownRefreshView {
    UIProgressView *progressView = (UIProgressView *)[customPullDownRefreshView viewWithTag:100];
    if ([progressView respondsToSelector:@selector(setTintColor:)]) {
        [progressView setTintColor:[UIColor greenColor]];
    }
    [progressView setProgress:0.0 animated:NO];
}

@end
