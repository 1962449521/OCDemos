//
//  HomeVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-24.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "HomeVC.h"
#import "NSDate+TimeAgo.h"
#import "LocationManager.h"

#define isMOCKDATADebugger YES

@interface HomeVC ()< UIScrollViewDelegate, LocationManagerDelegate>
{
    HomeContenVC *currentVC;
    UIButton *callBtn;
    NSArray *filterBtns;
}
@end

@implementation HomeVC
@synthesize GoToTheTop;
@synthesize currentVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        filterBtns = @[@"filter_boy", @"filter_girl", @"filter_all"];
        

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavBar];
    [self setSwitchView];
    [self setChildViews];
    
 
    
    //返回顶部按钮
    if (GoToTheTop == nil) {
        GoToTheTop = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        GoToTheTop.alpha = 1;
        GoToTheTop.layer.cornerRadius = 20;
        GoToTheTop.clipsToBounds = YES;
//        GoToTheTop.backgroundColor = ColorRGB(243.0, 160.0, 81.0);
        [GoToTheTop setBottom:DEVICE_screenHeight - 64 - 44 - 20];
        [GoToTheTop setRight:DEVICE_screenWidth - 20];
        [self.view addSubview:GoToTheTop];
        [GoToTheTop setBackgroundImage:[UIImage imageNamed:@"goToTheTop"] forState:UIControlStateNormal];
       // [GoToTheTop setTitle:@"上" forState:UIControlStateNormal];
        [GoToTheTop addTarget:self action:@selector(scorllToTop) forControlEvents:UIControlEventTouchUpInside];
        GoToTheTop.alpha = 0;
        CGPoint center = GoToTheTop.center;
        [GoToTheTop setSize:CGSizeMake(1, 1)];
        [GoToTheTop setCenter:center];
    }
    


    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    
    //未登录时，tab项会被按钮遮挡
    if ([Coordinator isLogined])
    {
        self.GuangzhuBtn.hidden = YES;
        if(_isTabChangeIn)
        {    // !!!:更新标志的更新推迟到tab切入时

            [self getRefreshBadge];
            _isTabChangeIn = NO;
        }
    }
    else
    {
        _isTabChangeIn = NO;
        self.GuangzhuBtn.hidden = NO;
    }
    [self.view setHeight:DEVICE_screenHeight - 64];
    [self.slideSwitchView setHeight:self.view.height];
    [self.view layoutIfNeeded];
    [self.currentVC.collectionView setHeight:self.currentVC.view.height];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.filterFujingView removeFromSuperview];
    [super viewWillDisappear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    [self setFilterView];
    [currentVC.collectionView reloadData];
    [super viewDidAppear:animated];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 更新badge
/**
 *	@brief	检查是否有更新
 */
- (void) getRefreshBadge
{

    LastRefreshTime *lrt = [LastRefreshTime shareInstance];
    [LastRefreshTime getUserDefault];
    NSNumber *lastReqTime = lrt.requestTime_GuangzhuPost;
    NSNumber *userId = [Coordinator userProfile].userId;

    
    if(lastReqTime == nil || [lastReqTime longLongValue] == 0 ||userId == nil)
        return;
    //获取最新 不是附近的话 就传个0吧
//    [_geoInfoCondition lock];
//    while (_longitude == 0)
//        [_geoInfoCondition wait];
//    [_geoInfoCondition unlock];

    
    NSDictionary *para = @{@"userId" : userId, @"type" : @[@2], @"longitude" :@0, @"latitude" : @0, @"lastReqTime" : lastReqTime};
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *receiveDic = [self.netAccess passUrl:PostModule_count andParaDic:para withMethod:PostModule_count_method andRequestId:unQueueRequestId thenFilterKey:nil useSyn:YES dataForm:7];
        
        NSDictionary *result = receiveDic[@"result"];
        if (NETACCESS_Success) {
            NSNumber *ts = receiveDic[@"ts"];
            lrt.requestTime_GuangzhuPost = ts;
            [LastRefreshTime storeUserDeault];
            
            NSDictionary *dic = receiveDic[@"counts"];
            int refreshCount;
            if(TYPE_isDictionary(dic) && [dic count] > 0 )
            {
                refreshCount = [dic[@"2"] intValue];
                GalleryManager *galleryManager = [GalleryManager shareInstance];
                NSInteger selectedIndex = galleryManager.selectedIndex ;
            
                if (refreshCount > 0 && [lastReqTime longLongValue]!=0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_topScrollView.bageGuanzhu setHidden:NO];
                        [_topScrollView bringSubviewToFront:_topScrollView.bageGuanzhu];
                        if (selectedIndex == 1) {//当前是在关注栏目
                            [_topScrollView.bageGuanzhu setBackgroundColor:[UIColor whiteColor]];
                        }
                        else
                            [_topScrollView.bageGuanzhu setBackgroundColor:ColorRGB(255.0, 101.0, 49.0)];
                    });
                }
            }
        }
    });
    
}

#pragma mark - 私有方法

/**
 *	@brief	设置导航栏
 */
- (void)setNavBar
{
    self.isNeedBackBTN = NO;
    [self setNavTitle:@"打分吧"];

    CGRect frame = CGRectMake(0, 12, 60, 20);
//    if (DEVICE_versionAfter7_0) {
//        frame.origin.x = 20;
//        
//    }
    UIColor *textcolor = ColorRGB(244.0, 149.0, 42.0);

    NSString *title = @"筛选";
    
    UIView *rightBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    callBtn.frame = CGRectMake(0, 0, 60, 44);
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(frame.origin.y, frame.origin.x, 44 - frame.origin.y - frame.size.height, 60 - frame.origin.x - frame.size.width);
    if(textcolor != nil)
        [callBtn setTitleColor:textcolor forState:UIControlStateNormal];
    [callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [callBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    if(title != nil)\
        [callBtn setTitle:title forState:UIControlStateNormal];
    [callBtn addTarget:self action:@selector(filterFujing:) forControlEvents:UIControlEventTouchUpInside];
    callBtn.titleEdgeInsets = edgeInsets;
    [callBtn setBackgroundImage: [UIImage imageNamed:@"transculent"] forState:UIControlStateHighlighted];
    [rightBarView addSubview:callBtn];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rightBarView];
    self.navigationItem.rightBarButtonItem = rightBtn;

    [callBtn setAlpha:0];

}
/**
 *	@brief	初始化选项卡视图容器
 */
- (void)setSwitchView
{
    self.slideSwitchView.tabItemNormalColor = [SUNSlideSwitchView colorFromHexRGB:@"868686"];
    self.slideSwitchView.tabItemSelectedColor = [SUNSlideSwitchView colorFromHexRGB:@"bb0b15"];
    self.slideSwitchView.shadowImage = [UIImage imageNamed:@"red_line_and_shadow.png"];
}
/**
 *	@brief	初始化tab选项卡下的各子视图
 */
- (void)setChildViews
{
    self.vc1 = [[HomeCategoryTuiJian alloc] init];
    self.vc2 = [[HomeCategoryGuangzhu alloc] init];
    self.vc3 = [[HomeCategoryFujing alloc] init];
    //badge 设为圆角
    _topScrollView = self.slideSwitchView.topScrollView;
    for (int tag = 1; tag < 4; tag++) {
        UILabel *view = (UILabel *)[_topScrollView viewWithTag:tag];
        view.layer.cornerRadius = view.width / 2;
        view.clipsToBounds = YES;
    }
    
    
    
    
    [self.slideSwitchView buildUI];
}
/**
 *	@brief	初始化附近选择菜单
 */
- (void)setFilterView
{
    self.filterFujingView.clipsToBounds = YES;
    [self.filterFujingView setFrame:CGRectMake(6, 48, 309, 108)];
    [APPDELEGATE.mainVC.view addSubview:self.filterFujingView];
    [self.filterFujingView setHeight:0];
    for (int index = 0; index < [filterBtns count]; index++) {
        UIButton *btn = (UIButton *)[self.filterFujingView viewWithTag:index +100 ];
       
        [btn setBackgroundImage:[UIImage imageNamed:STRING_joint(filterBtns[index], @"_selected")] forState:UIControlStateSelected];
        if (index == 2) {
            [btn setSelected:YES];
        }
    }

}
/**
 *	@brief	弹出附近选择菜单
 */
- (void)filterFujing:(UIButton *)sender
{
    UIViewBeginAnimation(kDuration);
     if (self.filterFujingView.height == 108)
         [self.filterFujingView setHeight:0];
    else if (self.filterFujingView.height == 0)
        [self.filterFujingView setHeight:108];
    [UIView commitAnimations];}
/**
 *	@brief	确定过滤附近条件
 *
 *	@param 	sender 	按钮
 */
- (IBAction)filerFujingFinished:(UIButton *)sender
{
    
    UIViewBeginAnimation(kDuration);
    [self.filterFujingView setHeight:0];
    
    [UIView commitAnimations];
    for (int index = 0; index < [filterBtns count]; index++) {
        UIButton *btn = (UIButton *)[self.filterFujingView viewWithTag:index+100];
        [btn setSelected:NO];
    }
    [sender setSelected:YES];
    switch (sender.tag) {
        case 100:
            self.filterResult = 1;
            break;
        case 101:
            self.filterResult = 2;
            break;
        case 102:
            self.filterResult = 0;
            break;
        default:
            break;
    }
    [self.currentVC startPullDownRefreshing];
}
- (IBAction)hideFujingView:(id)sender {
    UIViewBeginAnimation(kDuration);
    [self.filterFujingView setHeight:0];
    
    [UIView commitAnimations];
}




#pragma mark - slideSwitchView Delegate

- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view
{
    return 3;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    if (number == 0) {
        return self.vc1;
    } else if (number == 1) {
        return self.vc2;
    } else if (number == 2) {
        return self.vc3;
    } else {
        return nil;
    }
}


- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    
    HomeContenVC *vc = nil;
    CGPoint point = callBtn.center;
    UIViewBeginAnimation(kDuration);
    [callBtn setAlpha:0];
    [callBtn setWidth:60];
    [callBtn setHeight:2];
    callBtn.center = point;
    [UIView commitAnimations];
    
    [self.filterFujingView setHeight:0];
    if (number == 0) {
        vc = self.vc1;
        
    } else if (number == 1) {
        
        vc = self.vc2;
        
    } else if (number == 2) {
        vc = self.vc3;
        
        UIViewBeginAnimation(kDuration);
        [callBtn setAlpha:1];
        [callBtn setHeight:44];
        [callBtn setWidth:60];
        [callBtn setCenter:point];
        [UIView commitAnimations];
    }
    
    [[GalleryManager shareInstance]setSelectedIndex:number];
    currentVC = vc;
    
    vc.refreshControlDelegate = vc;
    
    UIViewController<MainModuleDelegate> *mainVC = APPDELEGATE.mainVC;
    [mainVC showTabBar];
    [self.view setHeight:DEVICE_screenHeight - 64];
    [self.slideSwitchView setHeight:self.view.height];
    [self.view layoutIfNeeded];
    [self.currentVC.collectionView setHeight:self.currentVC.view.height];
    [vc viewDidCurrentView];
    

}

#pragma mark - /点击滚至顶部
- (void)scorllToTop
{
    [currentVC.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];

}
#pragma mark - 确认登录权限
- (IBAction)ensureLogin:(id)sender {
    [self startAview];
    [Coordinator ensureLoginFromVC:self successBlock:^{
        UIButton *btn = (UIButton *)[self.slideSwitchView.topScrollView viewWithTag:101];
        [self.slideSwitchView selectNameButton:btn];
        [self stopAview];
    } failBlock:^{
        [self stopAview];
    } cancelBlock:^{
        [self stopAview];
    }];
}

- (IBAction)hideWizardView:(id)sender
{
    self.wizardView.hidden = YES;
}



@end