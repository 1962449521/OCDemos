//
//  MemberManager.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-8.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MemberManager.h"

#import "MeProfileDetailVC.h"

#import "LoginVC.h"
#import "RegisterVC.h"
#import "ShareManager.h"


#import "HomeVC.h"

NSString * const MemberManagerLoginFinishedNotification = @"memberManagerLoginFinishedNotification";
@implementation MemberManager
{
    BaseVC *fromVC;
}
@synthesize temptUserProfile;
@synthesize userProfile = userProfile_;


+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static MemberManager* instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
    });
    if (instance) {

        instance.netAccess = [[NetAccess alloc]init];
        instance.netAccess.delegate = instance;
        
    }

    return instance;
}

/**
 *	@brief	弹出登录模块 并接收相应的处理block
 *
 *	@param 	aFromVC 	<#aFromVC description#>
 *	@param 	sucessBlock 	<#sucessBlock description#>
 *	@param 	failBlock 	<#failBlock description#>
 *	@param 	cancelBlock 	<#cancelBlock description#>
 */
+ (void)ensureLoginFromVC:(BaseVC *)aFromVC successBlock:(LoginSucessBlock)sucessBlock failBlock:(LoginFailBlock)failBlock cancelBlock:(LoginCancelBlock)cancelBlock
{
    [[MemberManager shareInstance]ensureLoginFromVC:aFromVC successBlock:sucessBlock failBlock:failBlock cancelBlock:cancelBlock];
}
- (void)ensureLoginFromVC:(BaseVC *)aFromVC successBlock:(LoginSucessBlock)sucessBlock failBlock:(LoginFailBlock)failBlock cancelBlock:(LoginCancelBlock)cancelBlock

{
    if (self.isLogined)
        sucessBlock();
    else
    {
        fromVC = aFromVC;
        self.loginSucessBlock = [sucessBlock copy];
        self.loginFailBlock = [failBlock copy];
        self.loginCancelBlock = [cancelBlock copy];
        [self evokeLoginFromVC:fromVC];
    }
}
/**
 *	@brief	弹出登录模块
 *
 *	@param 	vc 	<#vc description#>
 */
- (void)evokeLoginFromVC:(BaseVC *)vc

{
    [self fetchLoginUserInfo];
    UserProfile *userProfile = self.userProfile;

    
    if(userProfile!= nil && userProfile.name != nil && userProfile.password != nil)
    {
        [self autoLogin:vc];
            }
    else
    {
        LoginVC *loginVC = [[LoginVC alloc]init];
        _currentVC = loginVC;
        UINavigationController *toNav = [[UINavigationController alloc]initWithRootViewController:loginVC];
        toNav.hidesBottomBarWhenPushed = YES;
        toNav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        UIViewController *tempVC;// = APPDELEGATE.mainVC;
//        if([fromVC isKindOfClass:[PhotoUploadVC class]])
            tempVC = fromVC;
            
        [tempVC presentViewController:toNav animated:YES completion:nil];

    }
   
    
}
- (void)autoLogin:(BaseVC *)vc
{
    LoginFailBlock autoLoginFailBlock= ^(void)
    {
        [self removeloginUserInfo];
        [self ensureLoginFromVC:vc successBlock:self.loginSucessBlock failBlock:self.loginFailBlock cancelBlock:self.loginCancelBlock];
    };
    self.loginFailBlock = [autoLoginFailBlock copy];

    [self loginUserWithUserProfile:self.userProfile atVC:vc];
    
}
+ (void)loginOut
{
    [[MemberManager shareInstance]loginOut];
}
- (void)loginOut
{
    [ShareManager cancelAuthWithType:ShareTypeSinaWeibo];
    [ShareManager cancelAuthWithType:ShareTypeQQSpace];
    [ShareManager cancelAuthWithType:ShareTypeWeixiSession];

    [self resetAll];
    
    
    [APPDELEGATE.mainVC setSelectedIndex:0];
    UINavigationController *nav = (UINavigationController *)APPDELEGATE.mainVC.viewControllers[0];
    HomeVC *homeVC = (HomeVC *)nav.viewControllers[0];
    UIButton *btn = (UIButton *)[homeVC.slideSwitchView.topScrollView viewWithTag:100];
    [homeVC.slideSwitchView selectNameButton:btn];
    
    
}
#pragma mark - 状态维持
- (void)resetAll
{
    [super resetAll];
    
    [self storeLoginUserInfo];
}
- (void)storeLoginUserInfo
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:self.userProfile forKey:@"userProfile"];
    [archiver finishEncoding];
    USERDEFAULT_set(data, @"userProfile");
    USERDEFAULT_syn;
    
}
- (void)fetchLoginUserInfo
{
    //归档
    NSData *data = USERDEFAULT_get(@"userProfile");
    if(data == nil) return;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    self.userProfile = [unarchiver decodeObjectForKey:@"userProfile"];
    [unarchiver finishDecoding];
    
}
- (void)removeloginUserInfo
{
    self.userProfile = [UserProfile new];
    self.temptUserProfile = [UserProfile new];
    USERDEFAULT_remove(@"userProfile");
}


#pragma mark  - 注册登录

/**
 *	@brief	注册新用户
 *
 *	@param 	userProfile 	<#userProfile description#>
 *	@param 	vc 	<#vc description#>
 */
+ (void)registerUserWithUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc

{
    [[MemberManager shareInstance]registerUserWithUserProfile:userProfile atVC:vc];
    }
- (void)registerUserWithUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc
{
    [self setCurrentVC : vc];
    NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [userDic setValue:userProfile.name forKeyPath:@"name"];
    [userDic setValue:userProfile.password forKeyPath:@"password"];
    [userDic setValue:userProfile.gender forKeyPath:@"gender"];
    if(![vc.aview isAnimating])
        [vc startAview];
    NSDictionary *param = @{@"user" :userDic};
    [self.netAccess passUrl:UserModule_register andParaDic:param withMethod:UserModule_register_method andRequestId:UserModule_register_tag thenFilterKey:nil useSyn:NO dataForm:7];
    temptUserProfile = userProfile;

}
/**
 *	@brief	登录
 *
 *	@param 	userProfile 	<#userProfile description#>
 *	@param 	vc 	<#vc description#>
 */
+ (void)loginUserWithUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc
{
    [[MemberManager shareInstance]loginUserWithUserProfile:userProfile atVC:vc];
}
- (void)loginUserWithUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc
{
    [self setCurrentVC : vc];
    if(![vc.aview isAnimating])
        [vc startAview];
    NSDictionary *para = @{@"user" : @{@"name" : userProfile.name, @"password": userProfile.password}};
    temptUserProfile = userProfile;
    [self.netAccess passUrl:UserModule_login andParaDic:para withMethod:UserModule_login_method andRequestId:UserModule_login_tag thenFilterKey:nil useSyn:NO dataForm:7];
    
}
/**
 *	@brief	修改用户资料
 *
 *	@param 	userProfile 	<#userProfile description#>
 *	@param 	vc 	<#vc description#>
 */
+ (void)updateUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc
{
    [[self shareInstance]updateUserProfile:userProfile atVC:vc];
}
-(void)updateUserProfile:(UserProfile *)userProfile atVC:(BaseVC *)vc
{
    [self setCurrentVC : vc];
    if(![vc.aview isAnimating])
        [vc startAview];

    NSMutableDictionary *para0 = [NSMutableDictionary dictionaryWithDictionary:[userProfile dictionary]];
    [para0 renameKey:@"userId" withNewName:@"id"];
    
    NSDictionary *para = @{@"user" : para0};
    self.temptUserProfile = userProfile;
    [self.netAccess passUrl:UserModule_update andParaDic:para withMethod:UserModule_update_method andRequestId:UserModule_update_tag thenFilterKey:nil useSyn:NO dataForm:7];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self SNSLogin:ShareTypeQQSpace currentVC:_currentVC];
    
}


- (void)SNSLogin:(ShareType)shareType currentVC:(BaseVC *)aCurrentVC
{
    _currentVC = aCurrentVC;
    if (shareType == ShareTypeWeixiSession && ![WXApi isWXAppInstalled]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"微信客户端未安装或版本过低，将跳转至QQ登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alertView show];
        return;
    }
    [_currentVC startAview];
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:[[ShareManager shareInstance]viewDelegate]];
    [authOptions setPowerByHidden:YES];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"打分吧"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"打分吧"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    [ShareSDK getUserInfoWithType:shareType
                      authOptions:authOptions
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
                               if (result)
                               {
                                   SNSLoginParam *loginParam = [[SNSLoginParam alloc]init];
                                   loginParam.user = [[SNSUser alloc]init];
                                   SNSUser *user = loginParam.user;
                                   
                                   user.srcAcc   = STRING_judge([userInfo uid]);
                                   user.srcName  = STRING_judge([userInfo nickname]);
                                   user.gender = [userInfo gender] + 1;
                                   switch (shareType) {
                                       case ShareTypeQQSpace:
                                           user.source = 1;
                                           break;
                                       case ShareTypeSinaWeibo:
                                           user.source = 2;
                                           break;
                                       case ShareTypeWeixiSession:
                                           user.source = 3;
                                           break;
                                       default:
                                           break;
                                   }
                                   
                                   user.token    = STRING_judge([[userInfo credential]token]);
                                   user.reExpiresIn =[[[userInfo credential]expired]timeIntervalSince1970];
                                   user.avatar   = STRING_judge([userInfo profileImage]);

                                   [self snsAuthSuccessWithUserInfo:loginParam type:shareType];
                               }
                               else
                               {
                                   
                                   [self snsAuthFail];
                                   NSLog(@"%ld:%@",(long)[error errorCode], [error errorDescription]);
                               }
                               
                           }];

}

- (void) snsAuthSuccessWithUserInfo:(SNSLoginParam *) loginParam type:(ShareType) shareType
{
//    [_currentVC stopAview];
    NSDictionary *params = [loginParam dictionary];
    [self loginAfterSNSSuccess:params currentVC:_currentVC];
}
- (void) snsAuthFail
{
    [_currentVC stopAview];
    POPUPINFO(@"登录失败！");
}

- (void)loginAfterSNSSuccess:(NSDictionary *)params currentVC:(BaseVC *)currentVC
{
    self.currentVC = currentVC;
    [self.currentVC startAview];
    temptUserProfile = [UserProfile new];
    [self.netAccess passUrl:SnsModule_login andParaDic:params withMethod:SnsModule_login_method andRequestId:SnsModule_login_tag thenFilterKey:nil useSyn:NO dataForm:7];
}


+ (void)getSelfDetail
{
    NSNumber *userId = [[self shareInstance]userProfile].userId;
    NetAccess *netAccess = [[MemberManager shareInstance]netAccess];
    [netAccess passUrl:UserModule_detail andParaDic:@{@"userId" : userId} withMethod:UserModule_detail_method andRequestId:UserModule_detail_tag thenFilterKey:nil useSyn:NO dataForm:7];
}

/**
 *	@brief	验证用户、密码的合法性
 *
 *	@param 	userName 	<#userName description#>
 *	@param 	password 	<#password description#>
 *
 *	@return	<#return value description#>
 */
+ (BOOL)validateUserInputUserName:(NSString *)userName password:(NSString *)password

{
    //用户名
    if ([STRING_judge(userName) isEqualToString: @""] )  {
        return NO;
    }
    //密码
    if([STRING_judge(password) isEqualToString: @""] )
    {
        return NO;
    }
    return YES;
}


#pragma mark - LoginUserDelegate
- (void) LoginSuccessful:(id)message
{
    self.isLogined = YES;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:MemberManagerLoginFinishedNotification object:self.userProfile.userId];
    
    if ([self.currentVC isKindOfClass:[LoginVC class]] || [self .currentVC isKindOfClass:[RegisterVC class]]) {
        UIViewController *tempVC;// = APPDELEGATE.mainVC;
            tempVC = fromVC;

        [tempVC dismissViewControllerAnimated:NO completion:nil];
    }
    self.loginSucessBlock();
    
}
- (void) LoginFail:(id)message
{
    
    self.loginFailBlock();
}
- (void) LoginCancel:(id)message
{
    UIViewController *tempVC;
        tempVC = fromVC;
    [tempVC dismissViewControllerAnimated:YES completion:nil];
    self.loginCancelBlock();
}
#pragma mark - AsynNetAccessDelegate

/**
 *	@brief	将暂时变量赋给对象属性
 */
- (UserProfile *)solidifyUserProfile

{
    if (self.userProfile == nil) {
        self.userProfile = temptUserProfile;
        temptUserProfile = nil;
    }
    return self.userProfile;
}

- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    //注册网络访问成功
    NSDictionary *receiveDic;
    
    UserProfile *userProfile;

    if (!TYPE_isDictionary(receiveObject))
    {
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
        return;
    }
    else
        receiveDic = (NSDictionary *)receiveObject;
    NSDictionary *result = receiveDic[@"result"];
    if ([requestId isEqualToNumber:UserModule_register_tag]) {
        [self.currentVC stopAview];//停止网络访问指示
        if (NETACCESS_Success)
        {
            [self solidifyUserProfile];
            NSDictionary *user = receiveDic[@"user"];
            userProfile.userId = user[@"id"];
            [self LoginSuccessful:nil];
            
        }
        else
        {
            POPUPINFO(STRING_joint(@"注册失败", result[@"msg"]));
        }

    }
    //登录访问成功
    else if([requestId isEqualToNumber:UserModule_login_tag])
    {
        if (NETACCESS_Success)
        {
            userProfile = [self solidifyUserProfile];
            NSDictionary *user = receiveDic[@"user"];
            NSNumber *userId = user[@"id"];
            userProfile.userId = userId;
            [MemberManager getSelfDetail];
        }
        else
        {
            [self.currentVC stopAview];//停止网络访问指示
            [self LoginFail:nil];
            POPUPINFO(STRING_joint(@"登录失败", result[@"msg"]));
        }
    }
    else if([requestId isEqualToNumber:UserModule_detail_tag])
    {
        [self.currentVC stopAview];//停止网络访问指示
        if (NETACCESS_Success)
        {
            userProfile = [self solidifyUserProfile];
            NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithDictionary: receiveDic[@"user"]];
            [userDic renameKey:@"id" withNewName:@"userId" ];
            [userProfile assignValue:userDic];
            [self storeLoginUserInfo];
            [self LoginSuccessful:nil];
        }
        else
        {
            [self LoginFail:nil];
            POPUPINFO(STRING_joint(@"获取个人资料失败", result[@"msg"]));
        }
    }
    else if([requestId isEqualToNumber:SnsModule_login_tag])
    {
        
        if (NETACCESS_Success)
        {
            userProfile = [self solidifyUserProfile];
            userProfile.userId = receiveDic[@"user"][@"id"];
            userProfile.name = receiveDic[@"user"][@"name"];
            userProfile.password = receiveDic[@"user"][@"password"];
            
            [MemberManager getSelfDetail];
        }
        else
        {
            [self.currentVC stopAview];
            POPUPINFO(STRING_joint(@"登录失败", result[@"msg"]));
        }
    }
    else if([requestId isEqualToNumber:UserModule_update_tag])
    {
        [self.currentVC stopAview];//停止网络访问指示
        if (NETACCESS_Success)
        {
            
            NSDictionary *newDic = [self.temptUserProfile dictionary];
            [self.userProfile assignValue:newDic];
            
            
            self.temptUserProfile  = nil;
            [self storeLoginUserInfo];
            POPUPINFO(@"资料修改成功");

        }
        else
        {
            POPUPINFO(STRING_joint(@"资料修改失败", result[@"msg"]));
        }

    }
    
}
- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    [self.currentVC stopAview];//停止网络访问指示
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
    
    if ([requestId isEqualToNumber:UserModule_register_tag]) {
    }
    //登录访问成功
    else if([requestId isEqualToNumber:UserModule_login_tag])
    {
        [self LoginFail:nil];

    }
    else if([requestId isEqualToNumber:UserModule_detail_tag])
    {
        [self LoginFail:nil];
    }
    else if([requestId isEqualToNumber:SnsModule_login_tag])
    {
        [self LoginFail:nil];
    }
    
    return;
}

+ (void)changeRelation:(RelationOperType)type withUser:(UserProfile *)anotherUser  completedBlock:(LoadRelationCompleteBlock )completedBlock fromVC:(BaseVC *)fromVC ;
{
    ChangeRelationResult relation_result = Relation_unknown;
    if (anotherUser.relationType) {
        if ([anotherUser.relationType intValue] == 1 || [anotherUser.relationType intValue] == 3) {
            relation_result = Relation_followed;
        }
        else
            relation_result = Relation_notFollowed;
    }
    else
    {
        [fromVC startAview];

        [Coordinator ensureLoginFromVC:fromVC successBlock:^{//登录成功
            NetAccess *netAccess = [NetAccess new];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSDictionary *resultDic = [netAccess passUrl:FriendModule_isFollow andParaDic:@{@"srcId" : [Coordinator userProfile].userId, @"tgtId" :anotherUser.userId} withMethod:FriendModule_isFollow_method andRequestId:FriendModule_isFollow_tag thenFilterKey:nil useSyn:YES dataForm:7];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *result = resultDic[@"result"];
                    if(NO)//result[@"followed"] == nil)
                    {
                        [fromVC stopAview];
                        completedBlock(NO, Relation_unknown);
                    }
                    else
                    {// relation got success
                        bool temp = false;//[result[@"followed"] boolValue];
                        if (temp && type == RelationOper_follow)
                        {
                            [fromVC stopAview];
                            completedBlock(NO, Relation_followed);
                        }
                        else if(!temp && type == RelationOper_deletefollow)
                        {
                            [fromVC stopAview];
                            completedBlock(NO, Relation_notFollowed);
                        }
                        else if ( type == RelationOper_follow)
                        {
                            NSDictionary *para = @{@"follow" : @{@"srcId": [Coordinator userProfile].userId, @"srcName" : [Coordinator userProfile].name , @"tgtId" : anotherUser.userId, @"tgtName" : anotherUser.name}};
                            NetAccess *netAccess = [NetAccess new];
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                NSDictionary *result = [netAccess passUrl:FriendModule_follow andParaDic:para withMethod:FriendModule_follow_method andRequestId:FriendModule_follow_tag thenFilterKey:@"result" useSyn:YES dataForm:7];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [fromVC stopAview];
                                    if (NETACCESS_Success) {//follow success
                                        if(anotherUser.extInfo && anotherUser.extInfo[@"followerCount"] )
                                            [anotherUser.extInfo setValue:NUMBER([anotherUser.extInfo[@"followerCount"] intValue] + 1) forKey:@"followerCount"];
                                        NSMutableDictionary *extInfo = [Coordinator userProfile].extInfo;
                                        if (extInfo[@"followCount"])
                                        {
                                            int newFollowCount = [extInfo[@"followCount"] intValue];
                                            [extInfo setValue:NUMBER(newFollowCount + 1) forKey:@"followCount"];
                                        }
                                        anotherUser.relationType = @1;
                                        completedBlock(true, Relation_followed);
                                    }
                                    else
                                    {
                                        [fromVC stopAview];
                                        completedBlock(NO, Relation_notFollowed);
                                    }
                                });
                                
                            });
                            
                        }
                        else
                        {
                           NSDictionary *para = @{@"follow" : @{@"srcId": [Coordinator userProfile].userId, @"srcName" : [Coordinator userProfile].name , @"tgtId" : anotherUser.userId, @"tgtName" : anotherUser.name}};
                            NetAccess *netAccess = [NetAccess new];
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                NSDictionary *result = [netAccess passUrl:FriendModule_deleteFollow andParaDic:para withMethod:FriendModule_deleteFollow_method andRequestId:FriendModule_deleteFollow_tag thenFilterKey:@"result" useSyn:YES dataForm:7];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [fromVC stopAview];
                                    if (NETACCESS_Success) {//delete follow success
                                        if(anotherUser.extInfo && anotherUser.extInfo[@"followerCount"] )
                                            [anotherUser.extInfo setValue:NUMBER([anotherUser.extInfo[@"followerCount"] intValue] - 1) forKey:@"followerCount"];
                                        NSMutableDictionary *extInfo = [Coordinator userProfile].extInfo;
                                        if (extInfo[@"followCount"])
                                        {
                                            int newFollowCount = [extInfo[@"followCount"] intValue];
                                            [extInfo setValue:NUMBER(newFollowCount - 1) forKey:@"followCount"];
                                        }
                                        anotherUser.relationType = @0;
                                        completedBlock(true, Relation_notFollowed);

                                    }
                                    else
                                    {
                                        [fromVC stopAview];
                                        completedBlock(NO, Relation_followed);

                                    }
                                });
                            });


                        }
                    }
                });
            });
            
        } failBlock:^{
            [fromVC stopAview];
            completedBlock(NO, Relation_unknown);
        } cancelBlock:^{
            [fromVC stopAview];
            completedBlock(NO, Relation_unknown);
        }];
        
    }
}

@end
