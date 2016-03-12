/*!
 @header DaFenBaMember.h
 @abstract Member模块外观类
 @author 胡帅
 @version 1.00 2014/09
 */


#import "BaseObject.h"
#import "MemberModuleFacadeDelegate.h"

@interface DaFenBaMember : BaseObject<MemberModuleFacadeDelegate>

+ (void)setIsLogined:(BOOL)isLogined;
+ (BOOL)isLogined;
+ (void)setTemptUserProfile:(UserProfile *)temptUserProfile;
+ (UserProfile *)temptUserProfile;
+ (UserProfile *)userProfile;
+ (void)setUserProfile:(UserProfile *)userProfile;


+ (void)ensureLoginFromVC:(BaseVC *)fromVC successBlock:(void (^)())sucessBlock failBlock:(void (^)())failBlock cancelBlock:(void (^)())cancelBlock;

+ (void)loginUserWithUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc;

+ (void)loginOut;

+ (void)updateUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc;





@end
