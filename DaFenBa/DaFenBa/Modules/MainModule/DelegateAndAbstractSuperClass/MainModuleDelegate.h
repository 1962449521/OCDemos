
/*!
 @header MainModuleDelegate.h
 @abstract 程序主界面需实现的协议
 @author 胡 帅
 @version 1.00 2014/08/04 Creation
 */


#import <Foundation/Foundation.h>

@protocol MainModuleDelegate <NSObject>

/**
 *	@brief	tabBar
 */
@property (nonatomic, strong) UIView *tabBar;

/**
 *	@brief	当前选择序号
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 *	@brief	当前选择VC
 */
@property (nonatomic, assign) UINavigationController *selectedViewController;

/**
 *	@brief	子控制器数组
 */
@property (nonatomic, strong) NSArray *viewControllers;

/**
 *	@brief	将要选择第index栏
 *
 *	@param 	index 	将选择VC的tabBar序号
 *
 *	@return	返回是否允许选择该栏
 */
- (BOOL)shouldSelectIndex:(NSInteger)index;

/**
 *	@brief	已选择时需执行的动作，如更换显示的view
 *
 *	@param 	index 	已选择VC的taBar序号
 */
- (void)didSelectedIndex:(NSInteger)index;
/**
 *	@brief	选中中间按钮时单独处理
 */
- (void)didSelectedMiddle;


/**
 *	@brief	tabBar当前状态是否为隐藏
 */
@property (nonatomic, assign) BOOL isHidenTabBar;

/**
 *	@brief	执行隐藏tabBar
 */
- (void)hideTabBar;

/**
 *	@brief	执行显示taBar
 */
- (void)showTabBar;


@end
