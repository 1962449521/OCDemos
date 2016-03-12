
#import "BaseObject.h"
/*!
 @header LastRefreshTime.h
 @abstract 存放各个分页列表最后的更新时间
 @author 胡 帅
 @version 1.00 2014/08/25 Creation
 */

/*!
 @class
 @abstract 存放各个分页列表最后的更新时间
 */
@interface LastRefreshTime :BaseObject
/*!
 @method
 @abstract 单例实现静态全局变量
 @discussion [LastRefreshTime shareInstance]
 */
+ (id)shareInstance;

/*!
 @property
 @abstract	关注页的最后更新时间 封装long
 */
@property (nonatomic, strong) NSNumber *requestTime_GuangzhuPost;
/*!
 @property
 @abstract	关注页的最后更新时间 封装long
 */
@property (nonatomic, strong) NSNumber *requestTime_FriendCount;


@end
