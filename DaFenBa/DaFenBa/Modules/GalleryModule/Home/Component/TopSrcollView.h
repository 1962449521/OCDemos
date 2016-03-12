/*!
 @header TopScrollView.h
 @abstract 主页的栏目切换tab栏
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import <UIKit/UIKit.h>
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface TopSrcollView : UIScrollView
/*!
 @property
 @abstract 未读关注标志
 */
@property (weak, nonatomic) IBOutlet UILabel *bageGuanzhu;
/*!
 @property
 @abstract 未读推荐标志
 */
@property (weak, nonatomic) IBOutlet UILabel *bageTuijian;
/*!
 @property
 @abstract 未读附近标志
 */
@property (weak, nonatomic) IBOutlet UILabel *bageFujing;
@end
