/*!
 @header FilterNoticeVC.h
 @abstract 单组选一的可复用页，代理收取选择结果
 @author 胡帅
 @version 1.0 2014/08 Creation
 */


#import "BaseVC.h"
/*!
 @protocol
 @abstract 这个c类的一个protocol
 @discussion 具体描述信息可以写在这里
 */
@protocol FilterNoticeDelegate <NSObject>

- (void)filishFilter:(NSUInteger)checkIndex withId:(NSUInteger)id;

@end

/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface FilterNoticeVC : BaseVC<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,assign) NSUInteger delegateRowId;

@property (nonatomic,strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *checkRecord;

@property (nonatomic,strong)NSString *headStr;

@property (nonatomic,strong) NSString *tailStr;




- (id)initWithCheckIndex:(NSUInteger)checkIndex;
@end
