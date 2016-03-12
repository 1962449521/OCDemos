//
//  AllCell.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-30.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseCell.h"

@implementation BaseCell

/**
 *	@brief	注册NIB文件
 *
 *  @param  cellIdentifiew nib文件名
 *	@param 	tableView 	cell所在的tableView
 *
 *	@return	由nib文件生成cell对象
 */
/**
 *	@brief	注册NIB文件
 *
 *  @param  cellIdentifiew nib文件名
 *	@param 	tableView 	cell所在的tableView
 *
 *	@return	由nib文件生成cell对象
 */
+ (id)cellRegisterNib:(NSString *)cellIdentifier tableView:(UITableView *)tableView

{
    Class clazz = [self class];
    UINib *nib = [UINib nibWithNibName:cellIdentifier bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier
                                                     owner:self options:nil];
        
        for (id oneObject in nib) {
            if ([oneObject isKindOfClass:[clazz class]]) {
                cell = oneObject;
                break;
            }
        }
    }
    return cell;
}
- (void) layoutSubviews
{
    [super layoutSubviews];
    if (!(DEVICE_versionAfter7_0))
    {
        self.backgroundView.frame = CGRectMake(-10, 0, 340, 44);
        self.selectedBackgroundView.frame = CGRectMake(-20, 0, 340, 44);
        
        self.backgroundColor = [UIColor whiteColor];
        
        NSArray *views = [self subviews];
        for (UIView *subView in views) {
            if (subView.left == 10 && subView.width == 300 && [subView isKindOfClass:[UIImageView class]] ) {
                [subView setX:-10];
                [subView setWidth:340];
            }
        }
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        
        
    }
}
@end
