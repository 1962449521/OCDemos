//
//  ShareManager.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ShareManager.h"
#import "AGViewDelegate.h"

#import <ShareSDK/ShareSDK.h>
#import <QZoneConnection/ISSQZoneApp.h>
#import "UpYun.h"

#define IMAGE_NAME @"sharesdk_img"
#define IMAGE_EXT @"jpg"

#define CONTENT @"ShareSDK不仅集成简单、支持如QQ好友、微信、新浪微博、腾讯微博等所有社交平台，而且还有强大的统计分析管理后台，实时了解用户、信息流、回流率、传播效应等数据，详情见官网http://sharesdk.cn @ShareSDK"
#define SHARE_URL @"http://www.sharesdk.cn"
static NSString* prefix = DEFAULT_UPYUN_PREFIX;



@implementation ShareManager

+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static ShareManager * instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
        instance.viewDelegate = [[AGViewDelegate alloc] init];

    });
    
    return instance;
}

+ (void)registerService
{
    [ShareSDK registerApp:@"26aaf5843c64"];
    
    
    
    [ShareSDK connectQZoneWithAppKey:@"1101980409"
                           appSecret:@"hrlKWUXHWZbqH09i"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    
    [ShareSDK connectSinaWeiboWithAppKey:@"2326233672"
                               appSecret:@"fe8aa4a5190739d0ca88032cbf07ed1d"
                             redirectUri:@"http://www.sharesdk.cn"];
//    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
//                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
//                             redirectUri:@"http://www.sharesdk.cn"];

    
    [ShareSDK connectTencentWeiboWithAppKey:@"1101980409"
                                  appSecret:@"hrlKWUXHWZbqH09i"
                                redirectUri:@"http://www.sharesdk.cn"
                                   wbApiCls:[WeiboApi class]];
    
    
    [ShareSDK connectWeChatWithAppId:@"wx567cc63e8745259e"
                           appSecret:@"8951c72352a95cc5af58915dcce7f5c5"
                           wechatCls:[WXApi class]];
    
    
    [ShareSDK connectQQWithQZoneAppKey:@"1101980409"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];

    //开启QQ空间网页授权开关
    id<ISSQZoneApp> app =(id<ISSQZoneApp>)[ShareSDK getClientWithType:ShareTypeQQSpace];
    [app setIsAllowWebAuthorize:YES];
    
    
    [ShareSDK waitAppSettingComplete:^{
        
        NSLog(@"shareSDK registed");//在这里面调用相关的ShareSDK功能接口代码
        
    }];
}
+ (BOOL)handleOpenURL:(NSURL *)url wxDelegate:(id)delegate
{
    return [ShareSDK handleOpenURL:url wxDelegate:delegate];
}
+ (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation
           wxDelegate:(id)wxDelegate
{
    return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:wxDelegate];
}

-(IBAction)showShareListWithPhot:(NSString *)imageName andText:(NSString *)text  shareStruct:(ShareStruct)shareStruct fromVC:(BaseVC *)vc
{
    if ([imageName rangeOfString:@"http://"].length == 0) {
        imageName = [NSString stringWithFormat:@"%@post/%@!postpreview", prefix, imageName];
    }
    id<ISSContent> publishContent = [ShareSDK content:text
                                       defaultContent:text
                                                image:[ShareSDK imageWithUrl:imageName]
                                                title:@"内容分享"
                                                  url:imageName
                                          description:text
                                            mediaType:SSPublishContentMediaTypeNews];
    
    
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:_viewDelegate];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
        [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                           qqButtonHidden:NO
                                                    wxSessionButtonHidden:NO
                                                   wxTimelineButtonHidden:NO
                                                     showKeyboardOnAppear:NO
                                                        shareViewDelegate:_viewDelegate
                                                      friendsViewDelegate:_viewDelegate
                                                    picViewerViewDelegate:nil]
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateBegan) {
                                    [vc startAview];

                                }
                                
                                else if (state == SSPublishContentStateSuccess)
                                {
                                    
                                    NSNumber *userId = [Coordinator userProfile].userId;
                                    NSNumber *_type   = NUMBER(shareStruct.type);
                                    NSNumber *shareId = NUMBER(shareStruct.shareId);
                                    NSDate *curDate = [NSDate date];
                                    NSTimeInterval ts = [curDate timeIntervalSince1970];
                                    NSNumber *shareTime = [NSNumber numberWithLong:(long)ts];
                                    NSMutableDictionary *para = [NSMutableDictionary dictionary];
                                    [para setValue:userId forKey:@"userId"];
                                    [para setValue:_type forKey:@"type"];
                                    [para setValue:shareId forKey:@"shareId"];
                                    [para setValue:shareTime forKey:@"shareTime"];
                                    
                                    [para setValue:NUMBER(type) forKey:@"source"];
                                   
                                    
                                    NetAccess *netaccess = [NetAccess new];
                                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                        NSDictionary *resultDic = [netaccess passUrl:SnsModule_share andParaDic:@{@"share" : para} withMethod:SnsModule_share_method andRequestId:SnsModule_share_tag thenFilterKey:nil useSyn:YES dataForm:7];
                                        NSDictionary *result = resultDic[@"result"];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [vc stopAview];
                                            if (NETACCESS_Success)
                                            {
                                                NSString *message = @"恭喜你，分享成功";
                                                if(shareStruct.decibelGot!=0)
                                                {
                                                    NSString *temp = [NSString stringWithFormat:@"，还获得了%d分贝哦。",shareStruct.decibelGot ];
                                                    message = STRING_joint(message, temp);
                                                }
                                                
                                                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                                                [alertView show];
                                            }
                                            else
                                            {
                                                POPUPINFO(@"分享失败，请重试！");
                                            }

                                        });
                                    });
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    [vc stopAview];
                                    POPUPINFO(@"分享失败，请重试！");
                                    NSLog( @"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                                else if (state == SSPublishContentStateCancel)
                                    [vc stopAview];
                            }];
    }

+ (void)cancelAuthWithType:(NSUInteger)type
{
    ShareType _type = type;
    [ShareSDK cancelAuthWithType:_type];
}

@end
