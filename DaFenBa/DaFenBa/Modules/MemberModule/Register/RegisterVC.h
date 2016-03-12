
/*!
 @header RegisterVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

/*!
 @protocol
 @abstract 这个HelloDoc类的一个protocol
 @discussion 具体描述信息可以写在这里
 */
@protocol RegisterSuccessDelegater <NSObject>

@end
#import <UIKit/UIKit.h>
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface RegisterVC : BaseVC
/*!
 @property
 @abstract	属性描述
 */
//@property (strong, nonatomic) LoginVC * loginVC;
/*!
 @property
 @abstract	属性描述
 */
//@property (strong, nonatomic) IBOutlet UIImageView *headIcon;

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
