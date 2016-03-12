/*!
 @header FilterNoticeTwoGroupVC.h
 @abstract 文件描述
 @author 胡帅
 @version 1.0 2014/08 Creation
 */


#import "BaseVC.h"

@interface FilterNoticeTwoGroupVC : BaseVC<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) IBOutlet UITableView *tableView;

@end