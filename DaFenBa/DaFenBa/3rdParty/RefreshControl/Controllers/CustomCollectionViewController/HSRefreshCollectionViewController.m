//
//  XHSysatemRefreshTableViewController.m
//  XHRefreshControlExample
//
//  Created by dw_iOS on 14-6-17.
//  Copyright (c) 2014年 曾宪华 QQ群: (142557668) QQ:543413507  Gmail:xhzengAIB@gmail.com. All rights reserved.
//

#import "HSRefreshCollectionViewController.H"

@interface HSRefreshCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@end

@implementation HSRefreshCollectionViewController

@synthesize collectionView;
//- (void)beginPullDownRefreshing
//{
//
//}
//- (void)beginLoadMoreRefreshing
//{
//}
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





#pragma mark - Life Cycle

- (void)setupRefreshControl {
    if (self.refreshControlDelegate == nil) {
        self.refreshControlDelegate = self;
    }
    if (!_customRefreshControl) {
        _customRefreshControl = [[XHRefreshControl alloc] initWithScrollView:self.collectionView delegate:self.refreshControlDelegate];
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
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 0, DEVICE_screenWidth, DEVICE_screenHeight - 20 - 44 -44 - 49)];
    WaterFLayout *layout = [[WaterFLayout alloc]init];
    layout.sectionInset  = UIEdgeInsetsMake(5, 5, 5, 5);

    self.collectionView  = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:layout];
    UIColor *bGcolor     = [UIColor colorWithPatternImage:[UIImage imageNamed:@"refreshControlBG"]];
    [self.collectionView setBackgroundColor:bGcolor];//ThemeBGColor];
    // MARK: add by hs
    [self.collectionView setContentSize:CGSizeMake(0, self.collectionView.contentSize.height)];
    [self.view addSubview:self.collectionView];
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    
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
#pragma mark UICollectionViewDataSource
//required
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 0;
}

/* For now, we won't return any sections */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //select Item
    NSLog(@"row= %i,section = %i",indexPath.item,indexPath.section);
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeZero;
}


#pragma mark ADD Header AND Footer
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section
{
    return 5;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
    return 5;
}


@end
