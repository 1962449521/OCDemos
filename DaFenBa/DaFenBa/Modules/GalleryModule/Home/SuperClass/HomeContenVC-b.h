/*!
 @header HomeContentVC.h
 @abstract 主页三个栏目的视图控制器的共同父类
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

 
#import "HSRefreshScrollViewController.h"
#import "HomeCalendarView.h"
#import "HomeContentModel.h"
#import "TuiJianSectionHeaderView.h"
/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface HomeContenVC : HSRefreshScrollViewController
/*!
 @property
 @abstract 日历控件
 */
//@property (strong, nonatomic) IBOutlet HomeCalendarView   *calendar;
/*!
 @property
 @abstract 左边列可插入新单元格的起始y
 */
@property float leftStartY;
/*!
 @property
 @abstract 右边列可插入新单元格的起始y
 */
@property float rightStartY;
/*!
 @method viewDidCurrentView
 @abstract 视图处于显示区域执行该行为
 @discussion
 @result
 */
- (void)viewDidCurrentView;
/*!
 @method insertNewContentCell:
 @abstract 插入一条新记录
 @discussion
 @result
 */
- (void)insertNewContentCell:(HomeContentModel *)contentModel;
/*!
 @method insertNewContentCells:
 @abstract 插入多条新记录
 @discussion
 @result
 */
- (void)insertNewContentCells:(NSArray *)contentModels;

@end