
#import <Foundation/Foundation.h>


@interface HSTimer : NSObject

#pragma - 重写 NSTimer的四个类方法及一个指定实例化方法

/**
 *  即时fire  SEL形式
 *
 *  @param ti        时间间隔
 *  @param aTarget   事件通知对象
 *  @param aSelector 事件执行方法
 *  @param userInfo  事件参数
 *  @param yesOrNo   是否重复
 *
 *  @return 计时器对象
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:( id)userInfo repeats:(BOOL)yesOrNo;

/**
 *  未指明fireDate SEL形式 需自行强持有
 *
 *  @param ti        时间间隔
 *  @param aTarget   事件通知对象
 *  @param aSelector 事件执行方法
 *  @param userInfo  事件参数
 *  @param yesOrNo   是否重复
 *
 *  @return 计时器对象
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

/**
 *  即时fire NSInvocation形式
 *
 *  @param ti         时间间隔
 *  @param invocation 事件通知对象及执行方法
 *  @param yesOrNo    是否重复
 *
 *  @return 计时器对象
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;

/**
 *  未指明fireDate NSInvocation形式 需自行强持有
 *
 *  @param ti         时间间隔
 *  @param invocation 事件通知对象及执行方法
 *  @param yesOrNo    是否重复
 *
 *  @return 计时器对象
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;

/**
 *  指定构造方法
 *
 *  @param date 触发时间 需自行强持有
 *  @param ti   时间间隔
 *  @param t    事件通知对象
 *  @param s    事件执行方法
 *  @param ui   事件参数
 *  @param rep  是否重复
 *
 *  @return 计时器对象
 */
- (NSTimer *)timerWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:( id)ui repeats:(BOOL)rep ;

@end
