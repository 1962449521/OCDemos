/*!
 @header SNSUser.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */
#import "BaseObject.h"

/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */
@interface SNSUser:BaseObject

@property (nonatomic, strong) NSString * srcAcc;//userId
@property (nonatomic, strong) NSString * srcName;//name
@property NSUInteger source;//1: QQ, 2: weibo
@property (nonatomic, strong) NSString * token;
@property (nonatomic, strong) NSString * refreshToken;//刷新token
@property long reExpiresIn;//10位整型时间戳
@property long refreshExpiredTime;//刷新时间
@property (nonatomic,strong) NSString *avatar;//头像
@property NSUInteger gender;//性别 1:boy 2:girl


@end
