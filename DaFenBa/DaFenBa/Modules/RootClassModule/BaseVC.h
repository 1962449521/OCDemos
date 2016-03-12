
/*!
 @header BaseVC.h
 @abstract UIViewController的自定义超类
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import <UIKit/UIKit.h>
#import "TYMActivityIndicatorView.h"
#import "NetAccess.h"


///*!
// @enum
// @abstract 页面数据创建者类型
// @constant  FromOwner 页面数据由自身创建
// @constant  FromGuest 页面数据由他人创建
// */
//typedef enum VisitorType{
//    FromOwner,
//    FromGuest
//}VisitorType;
//


/*!
 @class
 @abstract UIViewController的自定义超类。
 */

@interface BaseVC : UIViewController<AsynNetAccessDelegate>


/*!
 @property
 @abstract 是否需要提供视图返回方法
 */
@property (nonatomic,assign) BOOL isNeedBackBTN;
/*!
 @property
 @abstract 是否需要将状态栏改为白色
 */
@property (nonatomic,assign) BOOL isStatusWhite;
/*!
 @property
 @abstract 是否需要隐藏NavBar
 */
@property (nonatomic,assign) BOOL isNeedHideNavBar;
/*!
 @property
 @abstract 是否需要隐藏tabBar
 */
@property (nonatomic,assign) BOOL isNeedHideTabBar;
/*!
 @property
 @abstract 是否需要提供隐藏键盘方法
 */
@property (nonatomic, assign) BOOL isNeedHideBack;




///*!
// @property
// @abstract 当前页面数据创建者的userId
// */
//@property (nonatomic, strong) NSNumber *VCOwnerId;
///*!
// @property
// @abstract 当前页面数据的创建者
// */
//@property (nonatomic, assign)VisitorType visitorType;
/*!
 @property
 @abstract 网络访问功能实例对象
 */
@property (nonatomic,strong) NetAccess *netAccess;
/*!
 @property
 @abstract 网络指示器
 */
@property (strong, nonatomic) TYMActivityIndicatorView *aview;
/*!
 @method configSubViews
 @abstract 绘制子视图
 @discussion 由子类重写
 */
- (void)configSubViews;

/*!
 @method startAview
 @abstract 开始运行网络访问动画
 @discussion [self startAview]
 */
- (void)startAview;
/*!
 @method stopAview
 @abstract 停止并隐藏网络指示
 @discussion [self stopAview]
 */
- (void)stopAview;
/*!
 @method justAview
 @abstract 调整指示器的位置
 @param title
 @discussion 子类对该方法覆盖
 */
- (void)ajustAview;
/*!
 @method setNavTitle:
 @abstract 自定义标题栏的标题设置
 @param title 标题文字
 @discussion [self setNavTitle:@"xxx"]
 */
- (void)setNavTitle:(NSString *)title;
/*!
 @method setNavBgImage:
 @abstract 设置导航栏背景
 @param imageName 背景图片
 @discussion [self setNavBgImage:@"xxx"]
 */
- (void)setNavBgImage:(NSString *)imageName;
/*!
 @method hideKeyBoard
 @abstract 隐藏键盘
 @discussion [self hideKeyBoard]
 */
- (void)hideKeyBoard;
/*!
 @method backToPreVC:
 @abstract 回到前页
 @param sender 触发按钮
 @discussion 按钮事件
 */
- (IBAction)backToPreVC:(id)sender;
/*!
 @method adaptIOSVersion:
 @abstract 使tableView适应IOS版本 主要是使<ios7的tableView扁平化
 @param tableView 操作对象
 @discussion [self adaptIOSVersion:self.tableView];
 */
- (void)adaptIOSVersion:(UITableView *)tableView;
/*!
 @method initWithParams:
 @abstract 带传入参数的初始化方法
 @param tableView 传入参数
 @discussion [ClassName initWithParams:param];
 @result 实例化对象
 */
- (id)initWithParams:(NSDictionary *)param;
@end