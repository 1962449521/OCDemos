//
//  BaseVC.m
//  SharePhoto
//
//  Created by 胡 帅 on 14-7-23.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"
#import "UINavigationBar+customBar.h"
#import "UserProfile.h"

@interface BaseVC ()

@end

@implementation BaseVC
//{
//    VisitorType _visitorType;
//}
@synthesize isNeedBackBTN;
@synthesize aview;

#pragma mark - 生命周期

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _netAccess = [[NetAccess alloc]init];
        _netAccess.delegate = self;
    }
    return self;
}

- (id)initWithParams:(NSDictionary *)param
{
    BaseVC *instance = [self init];
    [self assignValue:param];
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //导航栏
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = @"";
    //ios7兼容
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    //设置背景色
    [self.view setBackgroundColor:ThemeBGColor];
    [self setNavBgImage:@"NavBG"];
    
    //点击背景隐藏键盘
    //初始化aview
    [self configAview];
    
    
    
    
    
    
    [self configSubViews];
}

- (void)configSubViews
{
    
}
- (void)viewWillAppear:(BOOL)animated
{
    if (isNeedBackBTN)
    {
        CGRect frame = CGRectMake(0, 10, 25, 25);;
        BACK_TITLE(frame, @"", nil, @"backbtn", backToPreVC:);
    }
    if (self.isNeedHideBack) {
        UITapGestureRecognizer *tapBG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
        [self.view addGestureRecognizer:tapBG];

    }
    if (self.isNeedHideTabBar) {
        [APPDELEGATE.mainVC hideTabBar];
    }
    else
    {
        [APPDELEGATE.mainVC showTabBar];
    }
    if (self.isNeedHideNavBar && self.navigationController != nil)
    {
         [self.navigationController.navigationBar setHidden:YES];
    }
    else
    {
        [self.navigationController.navigationBar setHidden:NO];
    }
    if (DEVICE_versionAfter7_0)
    {
        if (self.isStatusWhite) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
        else
        {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
    }
    [self ajustAview];
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 自定义方法
/**
 *	@brief	将属性值数组赋给真实的属性
 *
 *	@param 	dic 	属性数组
 */
- (void)assignValue:(NSDictionary *)dic
{
    @try {
        for (NSString *key in dic) {
            NSString *capKey = STRING_joint([[key substringToIndex:1]capitalizedString], [key substringFromIndex:1]);
            SEL setMethod = NSSelectorFromString(STRING_joint(STRING_joint(@"set", capKey),@":"));
            if ([self respondsToSelector:setMethod])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:setMethod withObject:dic[key]];
#pragma clang diagnostic pop

        }

    }
    @catch (NSException *exception) {
        ;
    }
    @finally {
        ;
    }
}

/**
 *	@brief	uitableview分组视图时适应IOS版本
 *
 *	@param 	tableView 	
 */
- (void)adaptIOSVersion:(UITableView *)tableView

{
    //将分隔线拉至边线
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view setBackgroundColor:ThemeBGColor_gray];
    [tableView  setBackgroundColor:[UIColor clearColor]];
    //ios7以前做成扁平
    if (!(DEVICE_versionAfter7_0)) {
        [tableView setBackgroundColor:ThemeBGColor_gray];
        [tableView setBackgroundView:nil];
        [tableView setBackgroundView:[[UIView alloc]init] ];
    }
}


/**
 *	@brief	初始化网络指示图
 */
- (void)configAview

{
    aview = [[TYMActivityIndicatorView alloc]initWithActivityIndicatorStyle:TYMActivityIndicatorViewStyleLarge];
    [self.view addSubview:aview];
    [aview setHidden:YES];
}
/**
 *	@brief	设置aview位置
 */
- (void)ajustAview
{
    [aview setX:DEVICE_screenWidth/2.0 - aview.width/2];
    [aview setY:self.view.height/2 - aview.height/2];
}
/**
 *	@brief	开始运行网络访问动画
 */
-(void)startAview
{
    if(![aview isAnimating])
    {
        [self.view bringSubviewToFront:aview];
        self.view.userInteractionEnabled = NO;
        [aview startAnimating];
    }
}
/**
 *	@brief	停止并隐藏网络指示
 */
-(void)stopAview
{
    if([aview isAnimating])
    {
        self.view.userInteractionEnabled = YES;
        [aview stopAnimating];
    }
}
/**
 *	@brief	隐藏键盘
 */
-(void)hideKeyBoard
{
    [self hideKeyBoard:self.view];
}
-(IBAction)hideKeyBoard:(UIView *)containerView
{
    for (UIView *childView in [containerView subviews])
    {
        if ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]])
        {
            [childView resignFirstResponder];
        }
        else if([[childView subviews]count] > 0)
        {
            [self hideKeyBoard:childView];
        }
    }
    
}

/**
 *	@brief	回到前页
 */
- (IBAction)backToPreVC:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *	@brief	设置导航栏背景
 *
 *	@param 	imageName 	背景图片名
 */
-(void)setNavBgImage:(NSString *)imageName
{
    [self.navigationController.navigationBar drawBackground:imageName];
}
/**
 *	@brief	自定义标题栏标题设置
 *
 *	@param 	title 	标题
 */
-(void)setNavTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    titleLabel.font = [UIFont boldSystemFontOfSize:20];  //设置文本字体与大小
    titleLabel.textColor = ColorRGB(0.0, 0.0, 0.0);  //设置文本颜色
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;  //设置标题
    self.navigationItem.titleView = titleLabel;
}
//#pragma mark - setter/getter
//- (void)setVisitorType:(VisitorType)visitorType
//{
//    _visitorType = visitorType;
//}
//- (VisitorType)visitorType
//{
//    UserProfile *userProfile = [Coordinator userProfile];
//    if ([self.VCOwnerId isEqualToNumber: userProfile.userId]) {
//        return  FromOwner;
//    }
//    else
//        return FromGuest;
//}
#pragma mark - AsynNetAccessDelegate

- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    [self stopAview];
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    [self stopAview];
    POPUPINFO(@"网络访问失败,"ACCESSFAILEDMESSAGE);
    
}
#pragma mark - refreshControlDelegate
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
- (NSInteger)autoLoadMoreRefreshedCountConverManual {
    return 3;
}
- (NSString *)displayAutoLoadMoreRefreshedMessage
{
    return @"查看下二十条";
}

@end
