
/*!
 @header MessageVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */


#import "BaseVC.h"
#import "XHPullRefreshTableViewController.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */
@interface MessageVC : BaseVC<XHRefreshControlDelegate, UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) XHPullRefreshTableViewController *tableVC;

@property (weak, nonatomic) IBOutlet UIImageView *filterBG;

@property (strong, nonatomic) IBOutlet UIView *filterView;

@end
