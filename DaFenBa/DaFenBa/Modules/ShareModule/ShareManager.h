/*!
 @header ShareManager.h
 @abstract 分享事件管理类
 @author 胡 帅
 @version 1.00 2014/08/25 Creation
 */

#import "BaseObject.h"
#import "WXApi.h"
#import "WeiboApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

typedef NS_ENUM(NSUInteger, DaFenBaShareType) {DaFenBaShareTypePost=1, DaFenBaShareTypeGrade, DaFenBaShareTypeAdvice};

typedef struct ShareStruct{DaFenBaShareType type; int shareId; int decibelGot;long shareTime;}ShareStruct;

/*!
 @class
 @abstract 分享事件管理类
 */
@class AGViewDelegate;

@interface ShareManager : BaseObject
/*!
 @property 
 @abstract	分享编辑框的导航栏格式
 */
@property (nonatomic, strong) AGViewDelegate *viewDelegate;
/*!
 @method
 @abstract 注册SHARESDK下相关平台
 @discussion [ShareSDK registerService]
 */
+ (void)registerService;
/*!
 @method
 @abstract 与其他APP交互
 @discussion [ShareSDK handleOpenURL:(NSURL *)url wxDelegate:(id)delegate]
 @param url url scheme
 @param delegate 微信的代理对象
 */
+ (BOOL)handleOpenURL:(NSURL *)url wxDelegate:(id)delegate;
+ (BOOL)handleOpenURL:(NSURL *)url
      sourceApplication:(NSString *)sourceApplication
             annotation:(id)annotation
             wxDelegate:(id)wxDelegate;

/*!
 @method
 @abstract 弹出分享列表
 @discussion [[ShareSDK shareInstance]showShareList:(UIbutton *)sender]
 @param sender 调用该方法的按钮控件
 */
-(IBAction)showShareList:(id)sender;
-(IBAction)showShareListWithPhot:(NSString *)imageName andText:(NSString *)text shareStruct:(ShareStruct)shareStruct fromVC:(BaseVC *)vc;


/**
 *	@brief	取消授权
 *
 *	@param 	type 	平台类型
 */
+ (void)cancelAuthWithType:(NSUInteger)type;

@end
