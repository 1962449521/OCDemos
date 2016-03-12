//
//  SettingManager.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-29.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "SettingManager.h"

@implementation SettingManager

/**
 *	@brief	构建单例
 *
 *	@return	返回单例
 */
+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static SettingManager *instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
        instance.settingDic = [NSMutableArray array];
    });
    return instance;
}


@end
