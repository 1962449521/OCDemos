
/*!
 @header DiscoverVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import "BaseVC.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface DiscoverVC : BaseVC


@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, weak) IBOutlet UILabel *linkLabel1;
@property (nonatomic, weak) IBOutlet UILabel *linkLabel2;

@end
