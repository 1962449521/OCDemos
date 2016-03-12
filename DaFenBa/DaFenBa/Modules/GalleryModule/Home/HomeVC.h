/*!
 @header HomeVC.h
 @abstract 主页视图控制器
 @author 胡帅
 @version 1.0 2014/08 Creation
 */


#import "BaseVC.h"
#import "HSRefreshScrollViewController.h"
#import "SUNSlideSwitchView.h"
#import "HomeCategoryTuiJian.h"
#import "HomeCategoryGuangzhu.h"
#import "HomeCategoryFujing.h"

/*!
 @class
 @abstract 这里可以写关于这个类的一些描述。
 */

@interface HomeVC : BaseVC< SUNSlideSwitchViewDelegate>

/*!
 @property
 @abstract	视图外部容器
 */
@property (nonatomic, weak) IBOutlet SUNSlideSwitchView *slideSwitchView;
/*!
 @property
 @abstract 推荐子视图
 */
@property (weak, nonatomic) IBOutlet UIButton *GuangzhuBtn;
@property (nonatomic, strong) HomeCategoryTuiJian *vc1;
/*!
 @property
 @abstract	关注子视图
 */

@property (nonatomic, strong) HomeCategoryGuangzhu *vc2;
/*!
 @property
 @abstract 附近子视图
 */
@property (nonatomic, strong) HomeCategoryFujing *vc3;
/*!
 @property
 @abstract 附近过滤条件界面
 */
@property (strong, nonatomic) IBOutlet UIView *filterFujingView;
@property (assign, nonatomic) int filterResult;
/*!
 @property
 @abstract 首次访问引导页
 */
@property (strong, nonatomic) IBOutlet UIView *wizardView;

@property (strong, nonatomic) UIButton *GoToTheTop;
@property (strong, nonatomic) HomeContenVC *currentVC;



//是否由tab栏的切换进入该界面
@property(nonatomic, assign) BOOL isTabChangeIn;
//中部tab栏
@property (nonatomic, weak) TopSrcollView *topScrollView;


@end
