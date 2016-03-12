
/*!
 @header LocationManager.h
 @abstract 地理定位管理
 @author 胡 帅
 @version 1.00 2014/08/25 Creation
 */
@protocol LocationManagerDelegate <NSObject>
@optional
- (void)setLocation:(NSString *)location;
- (void)setLongitude:(CLLocationDegrees)longitude;
- (void)setLatitude:(CLLocationDegrees)latitude;
- (void)setIsGeoInfoGot:(BOOL)isGot;
@end

#import "BaseObject.h"

@interface LocationManager : BaseObject< BMKGeneralDelegate,BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, weak) id<LocationManagerDelegate> delegate;


+ (void)registerService;
- (void)starGetCurlocation;
@end
