
/*!
 @header HSAppDelegate.h
 @abstract DaFenBa APP 的入口文件
 @author 胡 帅
 @version 1.00 2014/07/22 Creation
 */

#import <UIKit/UIKit.h>
#import "MainVC.h"
#import "LocationManager.h"


/*!
 @class
 @abstract DaFenBa APP 的入口文件
 */

@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate,LocationManagerDelegate>
/*!
 @property
 @abstract	APP窗口
 */
@property (strong, nonatomic) UIWindow *window;
/*!
 @property
 @abstract	APP主界面 tabBarController
 */
@property (strong, nonatomic) MainVC* mainVC;
/*!
 @property
 @abstract	省市数据数组
 */
@property (strong, nonatomic) NSArray *provinces;
/*!
 @property
 @abstract	照片拾取器
 */
@property (strong, nonatomic) UIImagePickerController *pickerImageVC;


/*!
 @property
 @abstract	JPUSH的用户识别码
 */
@property (strong, nonatomic) NSString *registrationId;



/*!
 @property
 @abstract 地理信息
 */
@property (nonatomic, strong) NSCondition *geoInfoCondition;
@property (nonatomic, assign) BOOL isGeoInfoGot;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *location;

@property (nonatomic, assign) BOOL isNotFirstFetchGeo;


@end
