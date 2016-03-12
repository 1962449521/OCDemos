/*!
 @header MeCommentVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import "XHPullRefreshTableViewController.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface MeCommentVC : BaseVC<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) XHPullRefreshTableViewController *tableVC;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end
