//
//  MessageVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-24.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MessageVC.h"
#import "BigFieldVC.h"

@interface MessageVC ()<pickerUserDelegate>
@property NSMutableArray *dataSource;

@end

@implementation MessageVC
{
    UIView *loadView;
    UIButton *callBtn;
    NSString *cellIdentifier;
    BigFieldVC *descriptionVC;
}

@synthesize tableVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        cellIdentifier = @"normalMessageCell";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"消息"];
    
    
    CGRect frame = CGRectMake(0, 12, 80, 20);
    if (!DEVICE_versionAfter7_0) {
        frame.origin.x = 12;
    }
    UIColor *textcolor = ColorRGB(244.0, 149.0, 42.0);
    UIView *rightBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    //rightBarView.backgroundColor = [UIColor redColor];
    NSString *title = @"消息筛选";
    callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    callBtn.frame = frame;
    
    callBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [callBtn setTitleColor:textcolor forState:UIControlStateNormal];
    [callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [callBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [callBtn setTitle:title forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(filterMessage:)forControlEvents:UIControlEventTouchUpInside];
    [callBtn setImage:[UIImage imageNamed:@"filterIcon"] forState:UIControlStateNormal];
    [rightBarView addSubview:callBtn];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rightBarView];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    [self.filterBG setImage:[[UIImage imageNamed:@"filterView"]stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    

    tableVC = [[XHPullRefreshTableViewController alloc]init];
    tableVC.refreshControlDelegate = tableVC;
    tableVC.tableView.delegate = self;
    tableVC.tableView.dataSource = self;
    tableVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableVC.tableView.backgroundColor = [UIColor clearColor];
    //self.isNeedBackBTN = YES;
    // Do any additional setup after loading the view.
    [self.view addSubview:tableVC.tableView];
    [self.view setHeight:DEVICE_screenHeight - 20 - 44 - 49];
    [tableVC.tableView setFrame:self.view.bounds];
    
    if (tableVC.pullDownRefreshed) {
        [tableVC setupRefreshControl];
    }
    // 别把这行代码放到别处，然后导致了错误，那就不好了嘛！
    loadView = self.tableVC.refreshControl.loadMoreView;
    [loadView setY:self.view.height - loadView.height];
    [tableVC startPullDownRefreshing];
    
    //tableVC.tableView
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [self setFilterView];

    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.filterView removeFromSuperview];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - UITableView DataSource

- (void)loadDataSource {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *dataSource = [[NSMutableArray alloc] initWithObjects:@"photo", @"photo",@"photo", nil];
        
        NSMutableArray *indexPaths;
        if (tableVC.requestCurrentPage) {
            indexPaths = [[NSMutableArray alloc] initWithCapacity:dataSource.count];
            [dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:self.dataSource.count + idx inSection:0]];
            }];
        }
        
        sleep(1.5);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tableVC.requestCurrentPage) {
                if (tableVC.requestCurrentPage == arc4random() % 10) {
                    [tableVC handleLoadMoreError];
                } else {
                    [self.dataSource addObjectsFromArray:dataSource];
                    [tableVC.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    [tableVC endLoadMoreRefreshing];
                }
            } else {
                
                self.dataSource = dataSource;
                [tableVC.tableView reloadData];
                [tableVC endPullDownRefreshing];
            }
        });
    });
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
    //return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BaseCell *cell = [BaseCell cellRegisterNib:cellIdentifier tableView:tableView];
    if (cell.btn1)
        [cell.btn1 addTarget:self action:@selector(relyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


- (void)click:(UIButton *)btn
{
    NSString *str = [NSString stringWithFormat:@"btn-%d",btn.tag];
    POPUPINFO(str);
}
#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cellIdentifier isEqualToString: @"replyMessageCell"]) {
        return 108;
    }
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.navigationController) {
    }
    
}


- (void)beginLoadMoreRefreshing
{
    
}
- (void)beginPullDownRefreshing
{
    
}

#pragma mark - 消息筛选
- (void)setFilterView
{
    self.filterView.clipsToBounds = YES;
    [self.filterView setX:175];
    [self.filterView setY:50];
    // modify begin
//    [self.tabBarController.view addSubview:self.filterView];
    [APPDELEGATE.mainVC.view addSubview:self.filterView];
    // modefy end
    [self.filterView setHeight:0];
    
    for (int k = 900; k <= 905; k++) {
        UIButton *btn = (UIButton *)[self.filterView viewWithTag:k];
        [btn setBackgroundImage:[[UIImage imageNamed:@"grayButton"]stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0] forState:UIControlStateSelected];
        [btn setTitleColor:ColorRGB(255.0, 165.0, 0) forState:UIControlStateSelected];
        
    }
}

- (void)filterMessage:(UIButton *)sender
{
    UIViewBeginAnimation(kDuration);
    [self.filterView setHeight:174];
    //[self.filterFujingView setAlpha:1];
    
    [UIView commitAnimations];

}
- (IBAction)filterFinish:(UIButton *)sender {
    UIViewBeginAnimation(kDuration);
    [self.filterView setHeight:0];
    for (int k = 900; k <= 905; k++) {
        UIButton *btn = (UIButton *)[self.filterView viewWithTag:k];
        [btn setSelected:NO];
    }
    [sender setSelected:YES];

    if (sender.tag == 904 || sender.tag == 905)
    {
        
        cellIdentifier = @"replyMessageCell";
        [self.tableVC.tableView reloadData];
        
        [self.view setBackgroundColor:ThemeBGColor_gray];
    }
    else
    {
        cellIdentifier = @"normalMessageCell";
        [self.tableVC.tableView reloadData];
        
        [self.view setBackgroundColor:ThemeBGColor];
        
    }
    
    //[self.filterFujingView setAlpha:1];
    
    [UIView commitAnimations];

}

- (IBAction)relyBtnClick:(id)sender
{
    if (descriptionVC == nil) {
        descriptionVC = [[BigFieldVC alloc]init];
        descriptionVC.userDelegate = self;
        descriptionVC.isUseSmallLayout = YES;
        descriptionVC.isMaskBG = YES;
        
        
        [self addChildViewController:descriptionVC];
        [self.view addSubview:descriptionVC.view];
        
    }
    descriptionVC.value = @"";
    descriptionVC.placeHolderStr = @"回复XXXXXX";
    [descriptionVC show];
}

/**
 *	@brief	拾取完成 代理机制
 *
 *	@param 	value
 *	@param 	sender
 */
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender
{
    }

/**
 *	@brief	拾取取消
 *
 *	@param 	sender 	<#sender description#>
 */
- (void)pickerCancelFrom:(id)sender
{
    [self hideKeyBoard];
}


@end
