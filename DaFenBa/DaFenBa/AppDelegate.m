//
//  HSAppDelegate.m
//  SharePhoto
//
//  Created by 胡 帅 on 14-7-22.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "AppDelegate.h"
#import "ConcreteMainVC.h"
#import "LoadVC.h"
//#import "libRDP.h"

#import "ScoreSuccessVC.h"
#import "ScoreListVC.h"

#import "ShareManager.h"
#import "DaFenBaSecurity.h"

#define isMOCKDATADebugger NO

@implementation AppDelegate
{
    NSNumber    *_clientId;
    NSNumber    *_loginId;
}


@synthesize mainVC;


#pragma mark - UIApplicationDelegate
- (void)registerServices:(NSDictionary *)launchOptions
{
    // ShareSDK
    [ShareManager registerService];
    // BKMap
    [[LocationManager shareInstance] setDelegate: self];

    [LocationManager registerService];
    
    _geoInfoCondition = [NSCondition new];
    if(isMOCKDATADebugger)
    {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            sleep(1.5);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.latitude = 30.54878662130653;
//                self.longitude = 114.33233792838277;
//                self.isGeoInfoGot = YES;
//            });
//        });
    }
    
    
    // JPUSH
//    [MessageManager registerService:launchOptions];
    // libRDP
//    [RDP startServer];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    HSLogTrace();
    
    NSString *encrp = [DaFenBaSecurity AES128Encrypt:@"A" key:@"1qaz@WSX1qaz@WSX" Iv:@"1234567890123456"];
    NSLog(@"%@", encrp);
    //+nhcpHHTei5rnO3wPEFg==
    NSString *decrp = [DaFenBaSecurity AES128Decrypt:encrp key:@"1234567809876543" Iv:@"1234567890123456"];
//    LoadVC *loadVC = [[LoadVC alloc]init];
    mainVC = [[ConcreteMainVC alloc]init];
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = mainVC;//loadVC;
    
    [self.window makeKeyAndVisible];

    // 文件 IO -- province
    [self fetchProvinceToMemory];
    // 照片拾取器
    [self initImagePickerView];
    // 注册第三方库 BMP、SHARESDK、 JPUSH、 RDP
    [self registerServices:launchOptions];
    // 收听登录完成，上传绑定
    // addObserver;
    [self addObserver];
    return YES;
}
/*
*/

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (_isNotFirstFetchGeo) {
        _isGeoInfoGot = NO;
        [[LocationManager shareInstance]starGetCurlocation];
    }
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 上传deviceToken 至 JPUSH服务器
    [MessageManager registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
// 第三方APP 交互
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{

    return [ShareManager handleOpenURL:url wxDelegate:self];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareManager handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}
// APNS
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required
    NSLog(@"userInfo:%@", userInfo);
    [MessageManager handleRemoteNotification:userInfo];
}

// APNS adapt to 7.0
#ifdef __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [MessageManager handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}
#endif

#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req
{
    HSLogTrace();
}

-(void) onResp:(BaseResp*)resp
{
    HSLogTrace();
}

#pragma mark - 初始化省份数据 文件IOS
- (void)fetchProvinceToMemory
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //加载省份数据
        APPDELEGATE.provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ProvincesAndCities.plist" ofType:nil]];
    });
}
- (void)initImagePickerView
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //初始化照片拾取器
        if (nil == _pickerImageVC)
            _pickerImageVC = [[UIImagePickerController alloc] init];//初始化VC
        UIView *view = _pickerImageVC.view;//初始化view
    });
}


#pragma mark - 帐号绑定

/**
 *	@brief	监视push服务器和网站服务器的登录变更
 */
- (void)addObserver

{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clientIdGot:) name:@"clientId" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loginIdGot:) name:MemberManagerLoginFinishedNotification object:nil];
}
/**
 *	@brief	push服务器登录成功
 *
 *	@param 	notification
 */
- (void)clientIdGot:(NSNotification *)notification

{
    _clientId = notification.object;
    [self updateIdBind];
}
/**
 *	@brief	自有服务器登录成功
 *
 *	@param 	notification
 */
- (void)loginIdGot:(NSNotification *)notification

{
    _loginId = notification.object;
    [self updateIdBind];
}
/**
 *	@brief	上传绑定关系
 */
- (void)updateIdBind

{
    if (_loginId == nil || _clientId == nil)
        return;
    else
    {
        NetAccess *netAccess = [NetAccess new];
        [netAccess passUrl:PushModule_add andParaDic:@{@"push" : @{@"userId" : _loginId, @"pushId" : _clientId, @"source" : @1}} withMethod:PushModule_add_method andRequestId:PushModule_add_tag thenFilterKey:nil useSyn:NO dataForm:7];
    }
    
}
#pragma mark - LocationManagerDelegate

- (void)setIsGeoInfoGot:(BOOL)isGeoInfoGot
{
    [_geoInfoCondition lock];
    _isGeoInfoGot = isGeoInfoGot;
    [_geoInfoCondition signal];
    [_geoInfoCondition unlock];
    
    
}

@end
