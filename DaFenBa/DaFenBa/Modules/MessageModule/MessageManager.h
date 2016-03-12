/*!
 @header MessageManager.h
 @abstract 消息模块
 @author  胡 帅
 @version 1.00 2014/08/25 Creation
 */
#import "BaseObject.h"
/*!
 @class
 @abstract 消息模块
 */
@interface MessageManager : BaseObject
/*!
 @method
 @abstract 注册相关服务，包括APNS和应用内消息
 @discussion [MessagerManager registerService:lauchOptions]
 @param launchOptions 程序加载参数
 */
+ (void)registerService: (NSDictionary *)launchOptions;
/*!
 @method
 @abstract 上报服务器deviceToken
 @discussion [MessagerManager registerService:lauchOptions]
 @param deviceToken 用于APNs的设备标识
 */
+ (void)registerDeviceToken:(NSData *)deviceToken;
/*!
 @method
 @abstract 处理收到的远程推送消息
 @discussion [MessagerManager handleRemoteNotification:userInfo]
 @param userInfo 收到的远程推送消息
 */
+ (void)handleRemoteNotification:(NSDictionary *)userInfo;
@end
