//
//  XHSysatemRefreshTableViewController.m
//  XHRefreshControlExample
//
//  Created by dw_iOS on 14-6-17.
//  Copyright (c) 2014年 曾宪华 QQ群: (142557668) QQ:543413507  Gmail:xhzengAIB@gmail.com. All rights reserved.
//

#import "HSRefreshScrollViewController.H"

@interface HSRefreshScrollViewController ()<UIScrollViewDelegate>


@end

@implementation HSRefreshScrollViewController

@synthesize scrollView;
- (void)beginPullDownRefreshing
{

}
- (void)beginLoadMoreRefreshing
{
}
- (void)startPullDownRefreshing {
    [self.customRefreshControl startPullDownRefreshing];
}

- (void)endPullDownRefreshing {
    [self.customRefreshControl endPullDownRefreshing];
}

- (void)endLoadMoreRefreshing {
    [self.customRefreshControl endLoadMoreRefresing];

}

- (void)endMoreOverWithMessage:(NSString *)message {
    [self.customRefreshControl endMoreOverWithMessage:message];
}

- (void)handleLoadMoreError {
    [self.customRefreshControl handleLoadMoreError];
}

#pragma mark - Life Cycle

- (void)setupRefreshControl {
    if (self.refreshControlDelegate == nil) {
        self.refreshControlDelegate = self;
    }
    if (!_customRefreshControl) {
        _customRefreshControl = [[XHRefreshControl alloc] initWithScrollView:self.scrollView delegate:self.refreshControlDelegate];
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



- (void)viewDidLoad {
    [self.view setFrame:CGRectMake(0, 0, DEVICE_screenWidth, DEVICE_screenHeight - 20 - 44 -44 - 49)];
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.contentSize = CGSizeMake(DEVICE_screenWidth, self.scrollView.height + 1);
    self.scrollView.delegate    = self;
    [self.scrollView setBackgroundColor:ThemeBGColor];
    [self.view addSubview:self.scrollView];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 数据源方法
- (void)loadDataSource
{

}

#pragma mark - XHRefreshControl Delegate
//
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
//- (void)loadDataSource
//{
//    
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
