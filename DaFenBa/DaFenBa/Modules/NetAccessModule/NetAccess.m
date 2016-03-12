//
//  AsynNetAccess.m
//  testNetwork
//  网络访问框架 - 异步访问
//  Created by hushuai on 14-5-15.
//

#import "NetAccess.h"
#import "DaFenBaOpenUDID.h"
#import "ASIDataDecompressor.h"
#import "ASIDataCompressor.h"
#import "Coordinator.h"
#import "SBJson.h"
#import "ASIFormDataRequest.h"

@interface ASIHTTPRequest ()

@property(retain,readwrite) NSNumber * requestID;

@end//更改requesId为可写



@implementation NetAccess


#pragma mark - init 单例
+ (id)shareSynNetAccess
{
    static dispatch_once_t once;
    static NetAccess *synNetAccess;
    dispatch_once(&once, ^{synNetAccess = [[NetAccess alloc]init];});
    return synNetAccess;
}

#pragma mark - NetAccessDelegate
/**
 *	@brief	获取timeStamp后执行私有方法
 *
 */
- (id)passUrl:(NSString *)urlstr andParaDic:(NSDictionary *)paraDicOrigin withMethod:(AccessMethod)accessMehod andRequestId:(NSNumber *)requestId thenFilterKey:(NSString *)filterKey useSyn:(BOOL)isSyn dataForm:(NSUInteger)dataForm

{
    if (!NETWORK_isReachable && NETWORK_NeedTest)
    {
        NSLog(@"erro0:网络故障!");
        if (isSyn)
            return nil;// -----------------------------------------------------------------------------出口00
        else
            [self.delegate netAccessFailedAtRequestId:requestId withErro:ErrorNet];//asy
        return nil;
    }

    
    if(isSyn)
    {
        NSNumber *timeStamp = [self getServerTimestamp];
        if (timeStamp == nil) {
            //POPUPINFO(@"连接超时，请重试！");
            if (!isSyn)
                [self.delegate netAccessFailedAtRequestId:requestId withErro:ErrorTimeOut];
            return nil;
        }
        else
            return [self passUrl:urlstr tiemStamp:timeStamp andParaDic:paraDicOrigin withMethod:accessMehod andRequestId:requestId thenFilterKey:filterKey useSyn:isSyn dataForm:dataForm];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSNumber *timeStamp = [self getServerTimestamp];
            if (timeStamp == nil) {
                //POPUPINFO(@"连接超时，请重试！");
                dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate netAccessFailedAtRequestId:requestId withErro:ErrorTimeOut];
                });
               // POPUPINFO(@"服务器出错，"ACCESSFAILEDMESSAGE);
                return ;
            }
            else
            {
//                LastRefreshTime *lrt = [LastRefreshTime shareInstance];
//                // 记录最后更新时间
//                if([requestId isEqual:FriendModule_count_tag])
//                    lrt.requestTime_FriendCount = timeStamp;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self passUrl:urlstr tiemStamp:timeStamp andParaDic:paraDicOrigin withMethod:accessMehod andRequestId:requestId thenFilterKey:filterKey useSyn:isSyn dataForm:dataForm];
                });
            }
        });
    }
    return nil;
    
}

#pragma mark - 请求执行主要方法
/**
 *	@brief	私有方法 完成requst参数设置后发起请求
 *
 *	@param 	request 	<#request description#>
 *	@param 	filterKey 	<#filterKey description#>
 *	@param 	responseString 	<#responseString description#>
 *	@param 	accessMehod 	<#accessMehod description#>
 *	@param 	methodarr 	<#methodarr description#>
 *	@param 	isSyn 	<#isSyn description#>
 *
 *	@return	<#return value description#>
 */
- (id)startRequest:(__weak ASIHTTPRequest *)request filterKey:(NSString *)filterKey responseString:(NSString *)responseString accessMehod:(AccessMethod)accessMehod methodarr:(NSArray *)methodarr isSyn:(BOOL)isSyn

{
    if (isSyn)
    {
        NSLog(@"syn request begin!");
        [request setRequestMethod:methodarr[accessMehod]];
        [request startSynchronous];
        NSLog(@"syn request end!");
        NSError *error = [request error ];
        
        if(error) return nil;
        
        // 如果请求成功，返回 Response
        NSDictionary *dic = [request responseHeaders];
        NSString *X_F = dic[@"X-F"];
        NSString *X_T = dic[@"X-T"];
        NSData *responseData = [request rawResponseData ];
        if (X_F!= nil && ([X_F isEqualToString:@"4"] || [X_F isEqualToString:@"7"])) {
            responseData = [ASIDataDecompressor uncompressData:responseData error:NULL];
        }
        
        NSString *responseString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:[request responseEncoding]] ;
        // MARK: -解密处理-----------------------------------
        NSString *timeStamp = X_T;
        NSString *key = [Coordinator key:timeStamp];
        NSString *iv  = IVKEY;
        responseString = AES_decode(responseString, key, iv);
        NSLog(@"syn responseString: %@", responseString);
        NSLog(@"syn request end!");

        return [self processResponseString:responseString withFilterKey:filterKey];
    }
    else
    {
        [AsynNetAccessQueue addRequest:request];
        return nil;//asy
    }
}



/**
 *	@brief	私有方法，在确定timeStamp后执行
 *
 */
- (id)passUrl:(NSString *)urlstr tiemStamp:(NSNumber *)timestampvalue andParaDic:(NSDictionary *)paraDicOrigin withMethod:(AccessMethod)accessMehod andRequestId:(NSNumber *)requestId thenFilterKey:(NSString *)filterKey useSyn:(BOOL)isSyn dataForm:(NSUInteger)dataForm
{
    [self monitorRegisterAndLogin:requestId];
    
    __weak ASIHTTPRequest *request;
    __block NSString *responseString;
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithDictionary:paraDicOrigin];
    NSString *giv = IVKEY;
    
    
    
    if (!NETWORK_isReachable && NETWORK_NeedTest)
    {
        NSLog(@"erro0:网络故障!");
        if (isSyn)
            return nil;// -----------------------------------------------------------------------------出口00
        else
            [self.delegate netAccessFailedAtRequestId:requestId withErro:ErrorNet];//asy
        return nil;
    }
    else
    {
        //签名
        UserProfile *userProfile = [Coordinator userProfile];
        NSString *userName, *password;
        NSNumber *userId;
        if(userProfile != nil){
            userId   = userProfile.userId;
            userName = userProfile.name;
            password = userProfile.password;}
        
        NSString *timestamp = [NSString stringWithFormat:@"%@", timestampvalue];
        long long nonceLong = [Coordinator nonce:10];
        NSString *nonce = [NSString stringWithFormat:@"%lld", nonceLong];
        NSString *secretKey = SECRETKEY;
        
        NSString * sign = [Coordinator generateSignStrWithUserId:userId userName:userName password:password nonce:nonce secretKey:secretKey timestamp:timestamp];
        NSMutableDictionary *signature  = [Coordinator generateSignDic:nonceLong timestampvalue:timestampvalue userId:userId sign:sign];
        [paraDic setValue:signature forKey:@"signature"];
        
        NSString *aeskey = [Coordinator key:timestamp];//aes 密钥
        // 生成request
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:UTF8_encode(urlstr)]];
        // 设置requestId
        request.requestID = requestId;
        // 设置method
        NSArray *methodarr = @[ @"GET", @"POST", @"PUT", @"DELETE", @"HEAD"];
        [request setRequestMethod:methodarr[accessMehod]];
        // 设置头部
        [self setRequestHeader:dataForm timestamp:timestamp request:request];
        // 设置body
        [self setPostBody:paraDic giv:giv aeskey:aeskey request:request dataForm:dataForm];
        
        // 设置超时
        [request setTimeOutSeconds:NETWORK_TimeoutInterVal];
        // 设置缓存
        [self setCache:request];
        
        // 设置执行块
        void (^ASICompletionBlock)(void) = ^(void)
        {
            if(isSyn)
                return;
            NSData *responseData = [request rawResponseData];
            NSDictionary *dic = [request responseHeaders];
            NSString *X_F = dic[@"X-F"];
            //NSString *X_R = dic[@"X-R"];
            NSString *X_TK = dic[@"X-TK"];
            NSString *X_T = dic[@"X-T"];
            if (responseData !=nil &&  X_T != nil) {
                if (X_TK != nil )
                {
//                    UserProfile *userProfile = [Coordinator userProfile];
//                    if (userProfile)
//                        userProfile.accessToken = X_TK;
//                    else
//                        [[Coordinator temptUserProfile]setAccessToken:X_TK];
                }
                
                //            if ([X_R isEqualToString:@"false"]) {
                //                 responseData = nil;
                //             }
                //解压
                //else
                if (X_F!= nil && ([X_F isEqualToString:@"4"] || [X_F isEqualToString:@"7"])) {
                    responseData = [ASIDataDecompressor uncompressData:responseData error:NULL];
                }
                
                responseString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:[request responseEncoding]] ;
                // MARK: -解密处理-----------------------------------
                NSString *timeStamp = X_T;
                NSString *key = [Coordinator key:timeStamp];
                NSString *iv  = IVKEY;
                responseString = AES_decode(responseString, key, iv);
                
                HSLog(@"response string:%@", responseString);
            }
            else
                responseString = nil;
            
            if (responseString == nil || [UTF8_decode(responseString) length] == 0) {
                // TODO: 当服务器返回不是JSON字符串时
                //NSData *responseData = [request responseData];
            }
            if ([request didUseCachedResponse]) {
                NSLog(@"Data is fetched from local cache");
            }
            if (!isSyn) {
                NSLog(@"HTTPSTATUS:%d",[request responseStatusCode]);
                id receivedObject = [self processResponseString:responseString withFilterKey:filterKey];
                [self.delegate receivedObject:receivedObject withRequestId:requestId];
            }
        };
        void (^ASIFailedBlock)(void)     = ^(void)
        {
            NSError *error = [request error];
            NSLog(@"HTTPSTATUS:%d, 网络模块错误:%@",[request responseStatusCode],error);
            if (!isSyn && !request.isCancelled)
            {
                [self.delegate netAccessFailedAtRequestId:requestId withErro:ErrorASI];
            }
        };
        void (^ASIRedirectedBlock)(void) = ^(void){NSLog(@"redirect"); ASIFailedBlock();};
        [request setCompletionBlock:ASICompletionBlock];
        [request setFailedBlock:ASIFailedBlock];
        [request setRequestRedirectedBlock:ASIRedirectedBlock];
        return [self startRequest:request filterKey:filterKey responseString:responseString accessMehod:accessMehod methodarr:methodarr isSyn:isSyn];
    }
}

#pragma mark - 参数设置
/**
 *	@brief	当请求为注册或者是登录时做特别处理
 *
 *	@param 	requestId 	请求的标识号
 */
- (void)monitorRegisterAndLogin:(NSNumber *)requestId
{
    
    if(([requestId isEqualToNumber:UserModule_register_tag]) || ([requestId isEqualToNumber:UserModule_login_tag]) || ([requestId isEqualToNumber:SnsModule_login_tag]))
    {//如果请求是注册或登录，要将保存到内存的用户资料清空
        [Coordinator setUserProfile:nil];
        
    }
   
}
/**
 *	@brief	得到系统的时间戳
 *
 *	@return	<#return value description#>
 */
- (NSNumber *)getServerTimestamp

{
    NSNumber *timestamp = nil;
    __weak ASIHTTPRequest *request;
    NSString *responseString;
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:UTF8_encode(UtiModule_time)]];
    [request startSynchronous];
    responseString = [request responseString];
    if ([STRING_judge(responseString) isEqualToString: @""]) {
        return nil;
    }
    id object = [[SBJsonParser ShareSBJson] objectWithString:responseString];
    
    if (TYPE_isDictionary(object)){
        timestamp = object[@"time"];
    }
    return timestamp;
}
/**
 *	@brief	设置头部
 *
 *	@param 	dataForm 	数据类型 7
 *	@param 	timestamp 	<#timestamp description#>
 *	@param 	request 	<#request description#>
 */
- (void)setRequestHeader:(NSUInteger)dataForm timestamp:(NSString *)timestamp request:(__weak ASIHTTPRequest *)request

{
    // MARK:设置Request头部
    //request.allowCompressedResponse = YES;
    //request.shouldCompressRequestBody = YES;
    [request buildRequestHeaders];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [request addRequestHeader:@"X-D" value:[DaFenBaOpenUDID value]];
    [request addRequestHeader:@"X_P" value:@"1"];
    [request addRequestHeader:@"X-V" value:[infoDictionary objectForKey:@"CFBundleShortVersionString"]  ];
    [request addRequestHeader:@"X-O" value:STRING_joint([[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion])];
    [request addRequestHeader:@"X-F" value:STRING_fromInt(dataForm)];
    [request addRequestHeader:@"X-T" value:timestamp];
    
    UserProfile *tUserProfile = [Coordinator userProfile];
    if(tUserProfile && tUserProfile.accessToken != nil && ![request.requestID isEqualToNumber:UserModule_register_tag] && ![request.requestID isEqualToNumber:UserModule_login_tag])
        [request addRequestHeader:@"X-TK" value:tUserProfile.accessToken];
    [request setHaveBuiltRequestHeaders:YES];
    NSLog(@"request url: %@", request.url);
    NSLog(@"request method: %@", request.requestMethod);
    NSLog(@"request Header : %@", [request requestHeaders]);
}
/**
 *	@brief	设置BODY
 *
 *	@param 	paraDic 	<#paraDic description#>
 *	@param 	giv 	<#giv description#>
 *	@param 	aeskey 	<#aeskey description#>
 *	@param 	request 	<#request description#>
 */
- (void)setPostBody:(NSMutableDictionary *)paraDic giv:(NSString *)giv aeskey:(NSString *)aeskey request:(__weak ASIHTTPRequest *)request dataForm:(NSInteger)dataForm

{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *postBodyJson = [writer stringWithObject:paraDic];
    NSLog(@"request Body : %@", postBodyJson);
    /* ** X-F: 7 // 1: json, Binary: 1, 2: encode, Binary: 10; 3: json and encode, Binary: 11; 4: gzip, Binary: 100; 7: json, encode and gzip, Binary: 111
     */
    if(dataForm == 2 || dataForm == 3 || dataForm == 7)
        postBodyJson = AES_encode(postBodyJson, aeskey, giv);
    NSLog(@"aes encode body:%@", postBodyJson);
    
    NSData *postBody = [NSMutableData dataWithData:[postBodyJson dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"unCompressedPostBodybytes:");
    [self PrintNSData:postBody];
    if(dataForm == 4 || dataForm == 7)
    {
        postBody = [ASIDataCompressor compressData:postBody error:nil];
        NSLog(@"compressedPostBodybytes:");
        [self PrintNSData:postBody];
    }
//    NSLog(@"可逆验证：");
//    NSData *tt = [ASIDataDecompressor uncompressData:compressedPostBody error:nil];
//    NSString *ss = [[NSString alloc]initWithData:tt encoding:NSUTF8StringEncoding];
//    NSString *aa = AES_decode(ss, aeskey, giv);
//    NSLog(@"验证结果：%@", aa);
    /* ** X-F: 7 // 1: json, Binary: 1, 2: encode, Binary: 10; 3: json and encode, Binary: 11; 4: gzip, Binary: 100; 7: json, encode and gzip, Binary: 111
*/
        request.postBody = [NSMutableData dataWithData:postBody];
    [request buildPostBody];
}
/**
 *	@brief	输出nsdata字节流
 */
-(void)PrintNSData: (NSData *)data
{
//    Byte *bytes = (Byte *)[data bytes];
//    
//    for(int i=0;i<[data length];i++)
//    {
//        int k = bytes[i] & 0xff;
//        printf("%d-", k);
//    }
//    printf("\n");
    NSLog(@"%@", [data base64String]);
}


/**
 *	@brief	设置缓存
 *
 *	@param 	request 	<#request description#>
 */
- (void)setCache:(__weak ASIHTTPRequest *)request
{
    //缓存设置
    //对相同的URL地址，获取本地数据，前提是服务器的缓存机制不能设定为NO-CACHE、NO-STORE（默认，当然也可以更改此项判断，但会引发冲突）
    //+ (BOOL)serverAllowsResponseCachingForRequest:(ASIHTTPRequest *)request
    //缓存有效时间，可自定义设置，[ request setSecondsToCache:60*60*24*30];// 缓存30天
    //使用CACHE时应查询本地的头文件：[[ ASIDownloadCache sharedCache ] setShouldRespectCacheControlHeaders:YES ];(默认)
    // MARK:缓存设置
    [request  setDownloadCache:[ASIDownloadCache sharedCache]];
    [[ASIDownloadCache sharedCache ]setShouldRespectCacheControlHeaders:YES];
    [request setSecondsToCache:2];
    [request setCacheStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
    [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy | ASIFallbackToCacheIfLoadFailsCachePolicy];
}



#pragma mark - 结果处理
//
/**
 *	@brief	json转nsdictionary 并过滤键值
 *
 *	@param 	responseString 	<#responseString description#>
 *	@param 	filterKey 	<#filterKey description#>
 *
 *	@return	<#return value description#>
 */
- (id) processResponseString:(NSString *)responseString withFilterKey:(NSString *)filterKey
{
    if([UTF8_decode(responseString) length] == 0)
    {
        NSLog(@"erro1:服务器内部故障");//-----------------------------------出口01
        return nil;
    }
    else//服务器正确返回数据
        
    {
        id object = [[SBJsonParser ShareSBJson] objectWithString:responseString];//receiveStr.length > 0 时，object必不为nil
        id receive;
        if(TYPE_isString(filterKey) && [filterKey length] > 0)
            receive = [self findObjectWithKey:filterKey inObject:object];//提交了查找关键字
        else
            receive = object;
        //NSLog(@"success:数据返回--%@",receive);
            return receive;//-----------------------------------------------------------------------出口10/11
    }
    
}
//
/**
 *	@brief	在数据的返回对象中查找对应关键字的nsobject
 *
 *	@param 	recKey 	<#recKey description#>
 *	@param 	object 	<#object description#>
 *
 *	@return	<#return value description#>
 */
- (id)findObjectWithKey:(NSString *)recKey inObject:(id)object
{
    if(object && TYPE_isDictionary(object) && object[recKey])
        return object[recKey];//在根结点查找成功
    else if((TYPE_isDictionary(object) || TYPE_isArray(object)) && [object count] > 0)
    {
        NSEnumerator *enumerater = [object objectEnumerator];
        id result,child;
        while(nil == result && (child = [enumerater nextObject]) )
            result = [self findObjectWithKey:recKey inObject:child];
        return result;
    }
    else
        return nil;
}

@end
