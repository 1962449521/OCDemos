//
//  XHPullRefreshTableViewController.m
//  MessageDisplayExample
//
//  Created by 曾 宪华 on 14-6-6.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHPullRefreshTableViewController.h"

@interface XHPullRefreshTableViewController ()


@end

@implementation XHPullRefreshTableViewController

- (void)startPullDownRefreshing {
    [self.refreshControl startPullDownRefreshing];
}

- (void)endPullDownRefreshing {
    [self.refreshControl endPullDownRefreshing];
}

- (void)endLoadMoreRefreshing {
    [self.refreshControl endLoadMoreRefresing];
}

- (void)endMoreOverWithMessage:(NSString *)message {
    [self.refreshControl endMoreOverWithMessage:message];
}

- (void)handleLoadMoreError {
    self.requestCurrentPage--;  // add by hs
    [self.refreshControl handleLoadMoreError];
}

#pragma mark - Life Cycle

- (void)setupRefreshControl {
    if (self.refreshControlDelegate == nil) {
        self.refreshControlDelegate = self;
    }
    if (!_refreshControl) {
        _refreshControl = [[XHRefreshControl alloc] initWithScrollView:self.tableView delegate:self.refreshControlDelegate];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        self.pullDownRefreshed = YES;
        self.loadMoreRefreshed = YES;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.pullDownRefreshed) {
        [self setupRefreshControl];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XHRefreshControl Delegate

- (void)revokeHsRefresh
{
    if (self.requestCurrentPage == 0)
    {
        [self endPullDownRefreshing];
    }
    else{
        [self endLoadMoreRefreshing];
    }

}
- (void) revokeHsLoadMore
{
    if(self.requestCurrentPage != 0)
        self.requestCurrentPage--;
}

- (void)beginPullDownRefreshing {
    [self.refreshControl endLoadMoreRefresing];
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
    return 20;
}
- (NSString *)displayAutoLoadMoreRefreshedMessage
{
    return @"查看下二十二条";
}
- (UIView *)customPullDownRefreshView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -60, DEVICE_screenWidth, 60)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.tag = 100;
    progressView.frame = CGRectMake(0, CGRectGetHeight(backgroundView.bounds) / 2.0 - 3, DEVICE_screenWidth, 3);
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


//- (void)beginPullDownRefreshing {
//    self.requestCurrentPage = 0;
//    [self loadDataSource];
//}
//
//- (void)beginLoadMoreRefreshing {
//    self.requestCurrentPage ++;
//    [self loadDataSource];
//}
//
//- (NSString *)lastUpdateTimeString {
//    
//    NSString *destDateString;
//    destDateString = @"从未更新";
//    
//    return destDateString;
//}
//
//- (NSInteger)autoLoadMoreRefreshedCountConverManual {
//    return 5;
//}
//
//- (BOOL)isPullDownRefreshed {
//    return self.pullDownRefreshed;
//}
//
//- (BOOL)isLoadMoreRefreshed {
//    return self.loadMoreRefreshed;
//}
//
//- (XHRefreshViewLayerType)refreshViewLayerType {
//    return XHRefreshViewLayerTypeOnScrollViews;
//}
//
//- (XHPullDownRefreshViewType)pullDownRefreshViewType {
//    return self.refreshViewType;
//}
//
//- (NSString *)displayAutoLoadMoreRefreshedMessage {
//    return @"显示下10条";
//}

@end
