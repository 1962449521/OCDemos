
/*!
 @header MemberManager.h
 @abstract 管理注册登录界面的唤起、功能实现
 @author 胡帅
 @version 1.00 2014/08/08 Creation

*/


#import "BaseObject.h"
#import "MemberModuleDelegate.h"


#import "SNSLoginParam.h"


/**
 *	@brief	用户自有服务器登录成功通知名
 */
extern  NSString * const MemberManagerLoginFinishedNotification;
/*!
 @class
 @abstract 管理注册登录界面的唤起、功能实现
 */


typedef NS_ENUM(bool, RelationOperType) {RelationOper_follow, RelationOper_deletefollow};
typedef NS_ENUM(int, ChangeRelationResult) {Relation_unknown, Relation_followed, Relation_notFollowed};
/**
 *	@brief	isSuccess 指示操作是否成功 isFollowed指示方法结束后的关注状态
 *   该参数主要用于更新界面，不做其他任何数据操作
 */
typedef void (^LoadRelationCompleteBlock)(BOOL isSuccess, ChangeRelationResult relation_result);

@interface MemberManager : BaseObject<MemberModuleDelegate, LoginDelegate, AsynNetAccessDelegate>
@property (nonatomic, assign) BOOL isLogined;
#if NS_BLOCKS_AVAILABLE
@property (nonatomic, strong) LoginSucessBlock loginSucessBlock;
@property (nonatomic, strong) LoginFailBlock loginFailBlock;
@property (nonatomic, strong) LoginCancelBlock loginCancelBlock;
#endif

@property (nonatomic, strong) UserProfile *userProfile;
@property (nonatomic, strong) UserProfile *temptUserProfile;

@property (nonatomic, strong) BaseVC *currentVC;

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
- (void) snsAuthSuccessWithUserInfo:(SNSLoginParam *) userInfo type:(ShareType) shareType;
- (void) snsAuthFail;

/**
 *	@brief	更改关注关系
 *
 *	@param 	type 	加关注：RelationOper_follow 取消关注 RelationOper_deletefollow
 *	@param 	anotherUser 	操作对象
 *	@param 	completedBlock 	操作完成的block调用
 *	@param 	fromVC 	调用的页面vc
 */
+ (void)changeRelation:(RelationOperType)type withUser:(UserProfile *)anotherUser  completedBlock:(LoadRelationCompleteBlock )completedBlock fromVC:(BaseVC *)fromVC ;




@end
