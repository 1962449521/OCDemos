//
//  DaFenBaMember.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-11.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "DaFenBaMember.h"
#import "MemberManager.h"


static NSString *clazzName = @"MemberManager";


@implementation DaFenBaMember



+ (void)setIsLogined:(BOOL)isLogined
{
    [[NSClassFromString(clazzName) shareInstance]setIsLogined:isLogined];
}
+ (BOOL)isLogined
{
    return [[NSClassFromString(clazzName)  shareInstance]isLogined];
}
+ (void)setTemptUserProfile:(UserProfile *)temptUserProfile
{
    [[NSClassFromString(clazzName)  shareInstance]setTemptUserProfile:temptUserProfile];
}
+ (UserProfile *)temptUserProfile
{
    return [[NSClassFromString(clazzName)  shareInstance]temptUserProfile];
}
+ (UserProfile *)userProfile
{
    return [[NSClassFromString(clazzName)  shareInstance]userProfile];
}
+ (void)setUserProfile:(UserProfile *)userProfile
{
    [[NSClassFromString(clazzName)  shareInstance]setUserProfile:userProfile];
}
+ (void)ensureLoginFromVC:(BaseVC *)fromVC successBlock:(void (^)())sucessBlock failBlock:(void (^)())failBlock cancelBlock:(void (^)())cancelBlock
{
    [NSClassFromString(clazzName) ensureLoginFromVC:fromVC successBlock:sucessBlock failBlock:failBlock cancelBlock:cancelBlock];
}
+ (void)loginUserWithUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc
{
    [NSClassFromString(clazzName)  loginUserWithUserProfile:userProfile atVC:vc];
}

+ (void)loginOut
{
    [NSClassFromString(clazzName) loginOut];
}

+ (void)updateUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc
{
    [NSClassFromString(clazzName) updateUserProfile:userProfile atVC:vc];
}


@end
