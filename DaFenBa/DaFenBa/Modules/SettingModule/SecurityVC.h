/*!
 @header SecurityVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */


#import "BaseVC.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface SecurityVC : BaseVC

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;


@property (nonatomic, weak) IBOutlet  UIImageView *bg2;

@property (nonatomic, weak) IBOutlet UIImageView *boundImageView;

@property (nonatomic, weak) IBOutlet UILabel *boundPhoneNumLabel;

@property (nonatomic, weak) IBOutlet UIButton *bindBtn;

@end
