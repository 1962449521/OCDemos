/*!
 @header SNSLoginParam.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import "BaseObject.h"
#import "SNSUser.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface SNSLoginParam:BaseObject

@property (nonatomic, strong) SNSUser *user;

@end
