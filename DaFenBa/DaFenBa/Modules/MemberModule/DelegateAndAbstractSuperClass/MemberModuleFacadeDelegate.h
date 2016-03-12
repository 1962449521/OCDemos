
/*!
 @header MemberModuleFacadeDelegate.h
 @abstract Member外观协议
 @author 胡帅
 @version 1.00 2014/09
 */


#import <Foundation/Foundation.h>
#import "UserProfile.h"

#if NS_BLOCKS_AVAILABLE
typedef void (^LoginSucessBlock)(void);
typedef void (^LoginFailBlock)(void);
typedef void (^LoginCancelBlock)(void);
#endif

@protocol MemberModuleFacadeDelegate <NSObject>
@optional

+ (void)setIsLogined:(BOOL)isLogined;
+ (BOOL)isLogined;
+ (void)setTemptUserProfile:(UserProfile *)temptUserProfile;
+ (UserProfile *)temptUserProfile;
+ (UserProfile *)userProfile;
+ (void)setUserProfile:(UserProfile *)userProfile;


@required
/*!
 @method
 @abstract 检测用户是否已登录
 @discussion 如没有，则自动登录，或跳转至注册页
 @result
 */
+ (void)ensureLoginFromVC:(BaseVC *)fromVC successBlock:(void (^)())sucessBlock failBlock:(void (^)())failBlock cancelBlock:(void (^)())cancelBlock;


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



@end
