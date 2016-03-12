/*!
 @header FirstEnterTime.h
 @abstract 第一次进入某页面，或某元素第一次呈现，用于决定是否显示引导页或引导元素
 @author 胡 帅
 @version 1.00 2014/08/25 Creation
 */
#import "BaseObject.h"
/*!
 @class
 @abstract 第一次进入某页面，或某元素第一次呈现，用于决定是否显示引导页或引导元素
 */
@interface FirstEnterTime : BaseObject
/*!
 @property
 @abstract	是否第一次进入到图片列表 封装bool变量
 */
@property (nonatomic, strong)NSNumber *isFirstEnterGalleryPage;
/*!
 @property
 @abstract	是否第一次进入到打分列表 封装bool变量
 */
@property (nonatomic, strong)NSNumber *isFirstEnterScorePage;
/*!
 @property
 @abstract	是否第一次进入到打分完成页 封装bool变量
 */
@property (nonatomic, strong)NSNumber *isFirstEnterScoreSuccessPage;
/*!
 @property
 @abstract	是否查看建议按钮第一次出现 封装bool变量
 */

@property (nonatomic, strong)NSNumber *isFirstAppearWatchAddvice;
@end
