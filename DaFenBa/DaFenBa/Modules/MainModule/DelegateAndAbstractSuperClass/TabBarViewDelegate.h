/*!
 @header MainModuleDelegate.h
 @abstract 程序主界面的tabBar需要实现的协议
 @author 胡 帅
 @version 1.00 2014/08/04 Creation
 */
#import <Foundation/Foundation.h>

@protocol TabBarViewDelegate <NSObject>

/**
 *	@brief	该tabbarview所属的mainVC
 */
@property (nonatomic, weak) MainVC *delegate;


/**
 *	@brief	消息栏的badge提示
 */
@property (nonatomic, weak) IBOutlet UILabel *badge;

/**
 *	@brief	taBar上的按钮被单击
 *
 *	@param 	sender 	<#sender description#>
 */
- (IBAction)buttonClicked:(UIButton *)sender;

/**
 *	@brief	指定tabBar某栏被选中
 *
 *	@param 	index 	<#index description#>
 */
- (void)setSelectedIndex:(NSInteger )index;


@end
