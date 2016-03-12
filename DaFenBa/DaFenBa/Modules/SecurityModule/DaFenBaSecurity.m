//
//  Security.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-8.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#define cutTo16(a, b)\
for (int i = 0; i<16; i++)\
a[i] = b[i];\
a[16] = '\0';


#import "DaFenBaSecurity.h"
#import "NSData+CommonCrypto.h"

@interface DaFenBaSecurity()
#pragma mark - auxiliary method
// sort wtih char
+ (NSString *)sortAsc:(NSString *)str;
// sort with string
+ (NSString *)sortAscArr:(NSArray *)arr;
@end

@implementation DaFenBaSecurity

/**
 *	@brief	按字符排序
 *
 *	@param 	str 	<#str description#>
 *
 *	@return	<#return value description#>
 */
+ (NSString *)sortAsc:(NSString *)str

{
    if(![self judgeString:str])
        return nil;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    int length = str.length;
    for (int i = 0; i < length; i++) {
        NSString *temp = [str substringWithRange:NSMakeRange(i,1)];
        [arr addObject:temp];
    }
    NSArray *arr2 = [arr sortedArrayUsingSelector:@selector(compare:)];
    NSString *result = [arr2 componentsJoinedByString:@""];
    return result;
}
+(NSString *)sortAscArr:(NSArray *)arr
{
    if(![self judgeArr:arr])
        return nil;
    NSArray *arr2 = [arr sortedArrayUsingSelector:@selector(compare:)];
    NSString *result = [arr2 componentsJoinedByString:@""];
    return result;
}
/**
 *	@brief	生成aes密钥
 *
 *	@param 	timeStamp 	<#timeStamp description#>
 *
 *	@return	<#return value description#>
 */
+ (NSString *)key:(NSString *)timeStamp

{
    if(![self judgeString:timeStamp])
        return nil;
    NSMutableString *newTimeStamp0 = [NSMutableString stringWithString:timeStamp];
    [newTimeStamp0 appendString:DEFAULTKEY];
    
    NSString *newTimeStamp = [self sortAsc:(NSString *)newTimeStamp0];
    HSLog(@"------aesKey:base64(SHA1(concat(sortAsc(default key + timestamp)))[0….15])------");
    HSLog(@"------AES密钥生成 key:%@, timestamp:%@, 拼接:%@", DEFAULTKEY, timeStamp, newTimeStamp);
    NSString *seed = [self sha1:newTimeStamp];
    HSLog(@"----AES sha1加密：%@",seed);
    NSData *seedData = [seed dataUsingEncoding:NSUTF8StringEncoding];
    const char *constbyte = [seedData bytes];
    char byte[17];
    cutTo16(byte, constbyte);
    NSString *seedStr = [self CharToNSString:byte];
    NSLog(@"-----AES 截取前16字节:%@", seedStr);
    NSString *aesKey = [seedStr base64String];
    HSLog(@"----AES 截取16字节BASE64：%@",aesKey);
    return  aesKey;
    
}
/**
 *	@brief	生成签名字符串
 *
 *	@param 	userId 	<#userId description#>
 *	@param 	userName 	<#userName description#>
 *	@param 	password 	<#password description#>
 *	@param 	nonce 	<#nonce description#>
 *	@param 	secretKey 	<#secretKey description#>
 *	@param 	timestamp 	<#timestamp description#>
 *
 *	@return	<#return value description#>
 */
+ (NSString *)generateSignStrWithUserId:(NSNumber *)userId userName:(NSString *)userName password:(NSString *)password nonce:(NSString *)nonce secretKey:(NSString *)secretKey timestamp:(NSString *)timestamp
{
    NSMutableArray *signArr = [NSMutableArray arrayWithCapacity:0];
    if(userName) [signArr addObject:[userName base64String]];
    if(password) [signArr addObject:password];
    if(nonce) [signArr addObject:STRING_fromId(nonce)];
    if(userId) [signArr addObject:STRING_fromId(userId)];
    if(secretKey) [signArr addObject:secretKey];
    if (timestamp) [signArr addObject:timestamp];
    HSLog(@"-------签名 base64(SHA1(concat(sortAsc(base64(user name), encoded password, timestamp, nonce, user id, secretKey)))) 组成部分：");
    HSLog(@"userId: %@/ userName: %@/ encodedPwd:%@/ nonce: %@/ timestamp:%@/ secretKey: %@",userId, [userName base64String], password, nonce, timestamp, secretKey);
    
    NSString *signstr = [self sortAscArr:signArr];
    HSLog(@"排序拼接：%@", signstr);
    NSString *sha1Sign = [self sha1:signstr];
    HSLog(@"sha1散列: %@", sha1Sign);
    
    if (![self judgeString:sha1Sign]) {
        return nil;
    }
    NSString *sign = [sha1Sign base64String];
    HSLog(@"base64签名: %@", sign);
    return sign;
}

/**
 *	@brief	生成签名字典
 *
 *	@param 	nonceLong 	<#nonceLong description#>
 *	@param 	timestampvalue 	<#timestampvalue description#>
 *	@param 	userId 	<#userId description#>
 *	@param 	sign 	<#sign description#>
 *
 *	@return	<#return value description#>
 */
+ (NSMutableDictionary *)generateSignDic:(long long)nonceLong timestampvalue:(NSNumber *)timestampvalue userId:(NSNumber *)userId sign:(NSString *)sign
{
    NSMutableDictionary *signature = [NSMutableDictionary dictionaryWithCapacity:0];
    [signature setValue:[NSNumber numberWithLongLong:nonceLong] forKey:@"nonce"];
    [signature setValue:timestampvalue forKey:@"timestamp"];
    [signature setValue:userId forKey:@"userId"];
    [signature setValue:sign forKey:@"sign"];
    return signature;
}
/**
 *	@brief	sha1加密
 *
 *	@param 	input 	<#input description#>
 *
 *	@return	<#return value description#>
 */
+ (NSString*) sha1:(NSString *)input

{
    if(![self judgeString:input])
        return nil;

    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH *2];
    
    for (int i =0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02X", digest[i]];
    }
    return output;
}

/**
 *	@brief	裁剪key,iv至16位
 *
 *	@param 	keyOrIv 	base64编码
 *
 *	@return	裁剪结果
 */
+ (NSData *)cutKeyOrIv:(NSString *)keyOrIv

{
    if(![self judgeString:keyOrIv])
        return nil;

    NSData *decryptBase64Key = [NSData dataWithBase64String:keyOrIv];
    const char *constbyte = [decryptBase64Key bytes];
    char byte[17];
    cutTo16(byte, constbyte);
    constbyte = (const char *)byte;
    NSData *keyData = [NSData dataWithBytes:constbyte length:16];
    return keyData;
}


/**
 *	@brief	aes加密
 *
 *	@param 	plainText 	<#plainText description#>
 *	@param 	gkey 	<#gkey description#>
 *	@param 	gIv 	<#gIv description#>
 *
 *	@return	<#return value description#>
 */
+ (NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)gkey Iv:(NSString *)gIv

{
    if (![self judgeString:plainText] || ![self judgeString:gkey] || ![self judgeString:gIv]) {
        return nil;
    }
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [result dataEncryptedUsingAlgorithm:kCCAlgorithmAES128 key:[self cutKeyOrIv:gkey] initializationVector:[self cutKeyOrIv:gIv] options:kCCOptionPKCS7Padding error:&status];
    NSString *base64EncodedString = [MF_Base64Codec base64StringFromData:encryptedData];
    return base64EncodedString;
}
/**
 *	@brief	aes解密
 *
 *	@param 	encryptText 	未加密字符串
 *	@param 	gkey 	base64
 *	@param 	gIv 	base64
 *
 *	@return	加密结果
 */
+ (NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)gkey Iv:(NSString *)gIv

{
    if (![self judgeString:encryptText] || ![self judgeString:gkey] || ![self judgeString:gIv]) {
        return nil;
    }
    CCCryptorStatus status = kCCSuccess;
    NSData *encryptedData = [NSData dataWithBase64String:encryptText];
    NSData *decryptedData = [encryptedData decryptedDataUsingAlgorithm:kCCAlgorithmAES128 key:[self cutKeyOrIv:gkey] initializationVector:[self cutKeyOrIv:gIv] options:kCCOptionPKCS7Padding error:&status];
    NSString *decrtptStr =  [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    return decrtptStr;
}

/**
 *	@brief	length位的随机长度整型
 *
 *	@return	lwngth位随机数
 */
+ (long long)nonce:(int) length
{
    long long ratio = 1;
    long long sum = 0;
    long long oldsum;
    for (int i = 1; i <= length; i++) {
        int base = arc4random() % 10;
        sum += base * ratio;
        ratio *= 10;
        oldsum = sum;
    }
    if(sum < ratio/10)sum += ratio/10;

    return sum;
}
/**
 *	@brief	用户密码加密
 *
 *	@param 	password 	原始密码
 *	@param 	userName 	用户名
 *
 *	@return	加密结果
 */
+ (NSString *)encodePassword:(NSString *)password userName:(NSString *)userName
{
    if(![self judgeString:password] || ![self judgeString:userName])
        return nil;
    HSLog(@"----encodePassword Begin, original:%@, name:%@, algorithm: base64(SHA1(SHA1(original password) + SHA1(base64(user name))))", password,userName);
    userName = STRING_judge(userName);
    password = STRING_judge(password);
    NSString *base64UserName = [userName base64String];
    HSLog(@"base64(user name): %@", base64UserName);
    NSString *sha1Base64UserName = [self sha1:base64UserName];
    HSLog(@"SHA1(base64(user name)):%@", sha1Base64UserName);
    NSString *sha1password = [self sha1:password];
    HSLog(@"SHA1(original password):%@", sha1password);
    NSString *saltpassword = STRING_joint(sha1password, sha1Base64UserName);
    HSLog(@"SHA1(original password) + SHA1(base64(user name)):%@", saltpassword);
    saltpassword = [self sha1:saltpassword];
    HSLog(@"SHA1(SHA1(original password) + SHA1(base64(user name))):%@",saltpassword);
    NSString *base64SaltPassword = [saltpassword base64String];
    HSLog(@"encodePasswor:%@", base64SaltPassword);
    return base64SaltPassword;
}

/**
 *	@brief	nsstring 转const char*
 *
 *	@param 	str 	<#str description#>
 *
 *	@return	<#return value description#>
 */
const char *NStringToChar(NSString * str)

{
    if(str == nil || !([str isKindOfClass:[NSString class]]) || [str length] == 0)
        return NULL;
    
    
    const char *char_content = [str cStringUsingEncoding:NSASCIIStringEncoding];
    return char_content;
}
/**
 *	@brief	const char *转nsstring
 *
 *	@return	<#return value description#>
 */
+ (NSString *)CharToNSString:(const char *) str

{
    if (str == NULL ) {
        return nil;
    }
    NSString *string_content = [[NSString alloc] initWithCString:str encoding:NSASCIIStringEncoding];
    return string_content;
}

+ (BOOL)judgeString:(NSString *)str
{
    if(str == nil || !([str isKindOfClass:[NSString class]]) || [str length] == 0)
        return NO;
    else
        return YES;
}
+ (BOOL)judgeArr:(NSArray *)arr
{
    if(arr == nil || !([arr isKindOfClass:[NSArray class]]) || [arr count] == 0)
        return NO;
    else
        return YES;
}

@end
