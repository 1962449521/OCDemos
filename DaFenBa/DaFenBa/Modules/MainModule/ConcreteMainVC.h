/*!
 @header MainVC.h
 @abstract 主界面 自定义taBarController,遵循MainModuleDelegate协议
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import <UIKit/UIKit.h>
#import "MainVC.h"
#import "ConcreteTabBarView.h"
@interface ConcreteMainVC :MainVC
#pragma mark - MainModuleDelegate
@property (nonatomic, strong) ConcreteTabBarView *tabBar;
@end
