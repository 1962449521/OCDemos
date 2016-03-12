//
//  MessageManager.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MessageManager.h"
#import "APService.h"

@implementation MessageManager

+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static id instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
    });
    
    return instance;
}
#pragma mark - 注册服务和设备标识
+ (void)registerService: (NSDictionary *)launchOptions
{
    [[self shareInstance]registerService:launchOptions];
}
- (void)registerService: (NSDictionary *)launchOptions
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(networkDidSetup:) name:kAPNetworkDidSetupNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidClose:) name:kAPNetworkDidCloseNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidRegister:) name:kAPNetworkDidRegisterNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidLogin:) name:kAPNetworkDidLoginNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kAPNetworkDidReceiveMessageNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(serviceError:) name:kAPServiceErrorNotification object:nil];
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    [APService setupWithOption:launchOptions];
    
}

+ (void)registerDeviceToken:(NSData *)deviceToken
{
    [APService registerDeviceToken:deviceToken];
}
#pragma mark - 消息服务器连接事件监听
- (void)networkDidSetup:(NSNotification *)notification {
    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    NSLog(@"未连接。。。");
}

- (void)networkDidRegister:(NSNotification *)notification {
    NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"已登录");
}
- (void)serviceError:(NSNotification *)notification {
    NSLog(@"服务出错");
}
#pragma mark - 消息处理

/**
 *	@brief	应用内消息处理
 *
 *	@param 	notification 	应用内消息
 */
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSLog(@"收到消息\ndate:%@\ntitle:%@\ncontent:%@", [dateFormatter stringFromDate:[NSDate date]],title,content);
    POPUPINFO(@"收到自定义消息");
    
    
}
/**
 *	@brief	远程推送消息处理
 *
 *	@param 	userInfo 	远程推送消息处理
 */
+ (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    [APService handleRemoteNotification:userInfo];//上报收到消息并做前台显示
}
@end
