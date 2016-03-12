/*!
 @header BaseObject.h
 @abstract NSObject的自定义超类
 @author 胡帅
 @version 1.0 2014/08 Creation 
 */

#import <Foundation/Foundation.h>
#import "NetAccess.h"
#import "NSMutableDictionary+RenameKey.h"
/*!
 @class
 @abstract NSObject的自定义超类
 */
@interface BaseObject : NSObject

@property (nonatomic, strong)NetAccess *netAccess;
@property (nonatomic, strong)NSNumber *objectId;
@property (nonatomic, strong)NSMutableDictionary *extInfo;


@property  int indexWithinDataSource;


/*!
 @method shareInstance
 @abstract 单例
 @discussion [ClassName shareInstance]
 @result 实例化的单例对象
 */
+ (id)shareInstance;
/*!
 @method getUserDefault
 @abstract 取本地数据赋值单例的属性
 @discussion [ClassName getUserDefault]
 */
+ (void)getUserDefault;
/*!
 @method storeUserDeault
 @abstract 将单例对象的属性存入本地
 @discussion [ClassName storeUserDeault]
 */
+ (void)storeUserDeault;
/*!
 @method getPropertyList:
 @abstract 获得某个类的属性列表
 @discussion [self getPropertyList:[ClassName class]]
 @result 属性数组
 */
- (NSArray *)getPropertyList: (Class)clazz;
/*!
 @method stopAview
 @abstract 停止并隐藏网络指示
 @discussion [self stopAview]
 */
- (void)assignValue:(NSDictionary *)dic;
/*!
 @method stopAview
 @abstract 停止并隐藏网络指示
 @discussion [self stopAview]
 */
- (NSDictionary *)dictionary;
/*!
 @method stopAview
 @abstract 停止并隐藏网络指示
 @discussion [self stopAview]
 */
- (void)resetAll;



@end
