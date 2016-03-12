/*!
 @header NoticeVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import "BaseVC.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface NoticeVC : BaseVC<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
