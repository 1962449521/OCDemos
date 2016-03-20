//
//  HSClockView.h
//  ClockDemo
//
//  Created by 胡 帅 on 16/3/18.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HSClockViewProtocol <NSObject>
/**
 *  一个时钟与外界的通信，就是它的时间。
 *  要有setter/getter, KVO-compliance
 */
@property (nonatomic, assign) NSTimeInterval time;
/**
 *  暂停时钟运行
 */
- (void) pause;
/**
 *  继续或者开始时钟运行
 */
- (void) work;

/**
 *  设置表盘背景图
 *
 *  @param image 表盘背景图，UIImage对象
 */
- (void) setDialBackgroundImage:(UIImage *) image;

@end


@interface HSClockView : UIView<HSClockViewProtocol>

@property (nonatomic, assign) NSTimeInterval time;

@end
