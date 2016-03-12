//
//  LocationManager.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-21.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>

#define NOTFoundAddress @"找不到你的位置，在火星吗"

@implementation LocationManager
{
    BMKMapManager *_mapManager;

    BMKLocationService* locationService;
    BMKGeoCodeSearch *geocodesearch;
}
+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static LocationManager* instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
    });
    
    return instance;
}
+ (void)registerService
{
    // 要使用百度地图，请先启动BaiduMapManager
    [[self shareInstance] registerService];
}
- (void)registerService
{
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"5uSgIPgh0B10ttoWX42WP9PD" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    else
        [self starGetCurlocation];
}

#pragma mark - BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"百度地图联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"百度地图授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}
#pragma mark - BMKLocationServiceDelegate

- (void)starGetCurlocation
{
    
    if (locationService == nil )
    {
        locationService = [[BMKLocationService alloc]init];
        
    }
    locationService.delegate = self;
    [locationService startUserLocationService];
}

- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    APPDELEGATE.isNotFirstFetchGeo = YES;

    CLLocation *location = userLocation.location;
    CLLocationCoordinate2D cor = location.coordinate;
    [self.delegate setLatitude:cor.latitude];
    [self.delegate setLongitude:cor.longitude];
    [self.delegate setIsGeoInfoGot:YES];
    [locationService stopUserLocationService];
    
    
    if (nil == geocodesearch)
        geocodesearch = [[BMKGeoCodeSearch alloc]init];
    geocodesearch.delegate = self;
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc]init];
    option.reverseGeoPoint = cor;
    [geocodesearch reverseGeoCode:option];
    
}
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self.delegate setIsGeoInfoGot:YES];
    APPDELEGATE.isNotFirstFetchGeo = YES;
}

#pragma mark - BMKGeoCodeSearchDelegate
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
	if (error == 0) {
        [self.delegate setLocation:result.address];
    }
    else
    {
        [self.delegate setLocation:NOTFoundAddress];
    }
    geocodesearch.delegate = nil;
    locationService.delegate = nil;
    self.delegate = nil;
    
}

@end
