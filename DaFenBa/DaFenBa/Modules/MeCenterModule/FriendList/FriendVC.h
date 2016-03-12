//
//  FriendVC.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-21.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseVC.h"

typedef NS_ENUM(NSUInteger, FriendListType)
{
    FriendListTypeFollow,
    FriendListTypeFollower,
    FriendListTypeStranger
};

@class XHPullRefreshTableViewController;

@interface FriendVC : BaseVC

@property XHPullRefreshTableViewController *tableVC;
@property FriendListType type;

@end
