//
//  Corrdinator.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-9.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "Coordinator.h"
#import <objc/message.h>
static NSString *SecurityClassName = @"DaFenBaSecurity";
static NSString *MemberClassName   = @"DaFenBaMember";
@implementation Coordinator

#pragma mark - Security
// nonce
+ (long long)nonce:(int) length
{
    return  [NSClassFromString(SecurityClassName) nonce:length];
}
// aeskey
+ (NSString *)key:(NSString *)timeStamp
{
   return  [NSClassFromString(SecurityClassName) key:timeStamp];
}
// encode Password
+ (NSString *)encodePassword:(NSString *)password userName:(NSString *)userName
{
    return [NSClassFromString(SecurityClassName) encodePassword:password userName:userName];
}
// generate SignStr
+ (NSString *)generateSignStrWithUserId:(NSNumber *)userId userName:(NSString *)userName password:(NSString *)password nonce:(NSString *)nonce secretKey:(NSString *)secretKey timestamp:(NSString *)timestamp
{
    return [NSClassFromString(SecurityClassName) generateSignStrWithUserId:userId userName:userName password:password nonce:nonce secretKey:secretKey timestamp:timestamp];
}
// generate SignDic
+ (NSMutableDictionary *)generateSignDic:(long long)nonceLong timestampvalue:(NSNumber *)timestampvalue userId:(NSNumber *)userId sign:(NSString *)sign
{
    return [NSClassFromString(SecurityClassName) generateSignDic:nonceLong timestampvalue:timestampvalue userId:userId sign:sign];
}
// sha2 encrypt
+ (NSString*) sha1:(NSString *)str
{
    return [NSClassFromString(SecurityClassName) sha1:str];
}
// aes encrypt
+ (NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)gkey Iv:(NSString *)gIv
{
    return [NSClassFromString(SecurityClassName) AES128Encrypt:plainText key:gkey Iv:gIv];
}
// aes decrypt
+ (NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)gkey Iv:(NSString *)gIv
{
    return  [NSClassFromString(SecurityClassName) AES128Decrypt:encryptText key:gkey Iv:gIv];
}
#pragma mark - Member

+ (void)setIsLogined:(BOOL)isLogined
{
    [NSClassFromString(MemberClassName) setIsLogined:isLogined];
}
+ (BOOL)isLogined
{
    return [NSClassFromString(MemberClassName)  isLogined];
}
+ (void)setTemptUserProfile:(UserProfile *)temptUserProfile
{
    [NSClassFromString(MemberClassName) setTemptUserProfile:temptUserProfile];
}
+ (UserProfile *)temptUserProfile
{
    return [NSClassFromString(MemberClassName)  temptUserProfile];
}
+ (UserProfile *)userProfile
{
    return [NSClassFromString(MemberClassName)  userProfile];
}
+ (void)setUserProfile:(UserProfile *)userProfile
{
    [NSClassFromString(MemberClassName) setUserProfile:userProfile];
}
+ (void)ensureLoginFromVC:(BaseVC *)fromVC successBlock:(void (^)())sucessBlock failBlock:(void (^)())failBlock cancelBlock:(void (^)())cancelBlock
{
    [NSClassFromString(MemberClassName) ensureLoginFromVC:fromVC successBlock:sucessBlock failBlock:failBlock cancelBlock:cancelBlock];
}
+ (void)loginUserWithUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc
{
    [NSClassFromString(MemberClassName)  loginUserWithUserProfile:userProfile atVC:vc];
}

+ (void)loginOut
{
    [NSClassFromString(MemberClassName) loginOut];
}

+ (void)updateUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc
{
    [NSClassFromString(MemberClassName) updateUserProfile:userProfile atVC:vc];
}
//#pragma mark - push refresh
//- (void)followCategoryRefeshed
//{
//    id homeVC = APPDELEGATE.mainVC.viewControllers[0];
//    objc_msgSend([homeVC badge],@selector(setHidden:), NO);
//}
#pragma mark - message count num
+ (void)setMessageBadgeCount:(NSString *)count
{
    UILabel *label = [(TabBarView *)(APPDELEGATE.mainVC.tabBar) badge];
    
    //获取当前消息数
    NSString *curNumStr = label.text;
    int curNum = 0;
    if([curNumStr isEqualToString:@"N"])
        curNum = 10;
    else if([curNumStr isEqualToString:@""])
        curNum = 0;
    else
        curNum = [curNumStr intValue];
    
    //根据操作命令更新消息数
    if([count isEqualToString:@"add"])
    {
        curNum += 1;
    }
    else if([count isEqualToString:@"sub"])
    {
        curNum -= 1;
    }
    else if([count isEqualToString:@"clear"])
    {
        curNum = 0;
    }
    else
        curNum += [count intValue];
    
    //根据更新后的消息数 更新显示
    if(curNum == 0)
        [[(TabBarView *)(APPDELEGATE.mainVC.tabBar) badge] setHidden:YES];
    else if(curNum >= 10)
    {
        [label setText:@"N"];
    }
    else 
    {
        [[(TabBarView *)(APPDELEGATE.mainVC.tabBar) badge] setHidden:NO];
        [[(TabBarView *)(APPDELEGATE.mainVC.tabBar) badge] setText:STRING_fromInt(curNum)];
    }
}

@end
