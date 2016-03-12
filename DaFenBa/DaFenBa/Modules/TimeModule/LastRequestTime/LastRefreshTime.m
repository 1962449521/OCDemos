//
//  LastRequestTime.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-14.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "LastRefreshTime.h"

@implementation LastRefreshTime

/**
 *	@brief	构建单例
 *
 *	@return	返回单例
 */
+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static LastRefreshTime * instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
        instance->_requestTime_GuangzhuPost = @0;
        instance->_requestTime_FriendCount  = @0;
    });
    return instance;
}



@end
