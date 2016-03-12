/*!
 @header MemberModuleDelegate.h
 @abstract Member模块主功能类协议
 @author 胡帅
 @version 1.00 2014/09
 */

#import <Foundation/Foundation.h>
#import "MemberModuleFacadeDelegate.h"
#import <ShareSDK/ShareSDK.h>

@protocol MemberModuleDelegate <NSObject, MemberModuleFacadeDelegate>
#pragma mark -facade
/*!
 @method
 @abstract 检测用户是否已登录
 @discussion 如没有，则自动登录，或跳转至注册页
 @result
 */
+ (void)ensureLoginFromVC:(BaseVC *)fromVC successBlock:(void (^)(void))sucessBlock failBlock:(void (^)(void))failBlock cancelBlock:(void (^)(void))cancelBlock;
/**
 *	@brief	登录
 *
 *	@param 	userProfile 	登录的用户资料
 *	@param 	vc 	触发VC
 */
+ (void)loginUserWithUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc;


/**
 *	@brief	注销
 */
+ (void)loginOut;


/**
 *	@brief	修改用户资料
 *
 *	@param 	userProfile 	新的用户资料
 *	@param 	vc 	触发VC
 */
+ (void)updateUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc;





#pragma mark - abstract delegate

@property (nonatomic, assign) BOOL isLogined;

@property (nonatomic, strong) UserProfile *userProfile;
@property (nonatomic, strong) UserProfile *temptUserProfile;



#if NS_BLOCKS_AVAILABLE
@property (nonatomic, strong) LoginSucessBlock loginSucessBlock;
@property (nonatomic, strong) LoginFailBlock loginFailBlock;
@property (nonatomic, strong) LoginCancelBlock loginCancelBlock;
#endif


@property (nonatomic, strong) BaseVC *currentVC;
/**
 *	@brief	注册
 *
 *	@param 	userProfile 	注册的用户资料
 *	@param 	vc 	触发VC
 */
+ (void)registerUserWithUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc;

/**
 *	@brief	获取用户信息
 *
 *	@param 	id 	目标用户id
 *	@param 	vc 	触发VC
 */
+ (void)getSelfDetail;

/*!
 @method
 @abstract 验证用户输入的用户名和密码
 @discussion
 @result
 */
+ (BOOL)validateUserInputUserName:(NSString *)userName password:(NSString *)password;
/**
 *	@brief	第三方登录
 *
 *	@param 	shareType 	平台类型
 */
- (void)SNSLogin:(ShareType)shareType currentVC:(BaseVC *)currentVC;


@end
