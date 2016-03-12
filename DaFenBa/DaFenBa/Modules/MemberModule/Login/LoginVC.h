
/*!
 @header LoginVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */


#import <UIKit/UIKit.h>
#import "MemberManager.h"

/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */
@interface LoginVC : BaseVC

/*!
 @property
 @abstract	属性描述
 */
@property (weak, nonatomic) IBOutlet UITextField *user;
/*!
 @property
 @abstract	属性描述
 */
@property (weak, nonatomic) IBOutlet UITextField *password;


@end
