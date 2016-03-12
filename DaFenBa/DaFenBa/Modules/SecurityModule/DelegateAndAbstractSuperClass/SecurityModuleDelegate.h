/*!
 @header Security.h
 @abstract 加密模块协议规定需实现的方法集合
 @author 胡帅
 @version 1.0 2014/08 Creation
 */
#import <Foundation/Foundation.h>

@protocol SecurityModuleDelegate <NSObject>


#pragma mark - generate Method
// nonce
+ (long long)nonce:(int) length;
// aeskey
+ (NSString *)key:(NSString *)timeStamp;
// encode Password
+ (NSString *)encodePassword:(NSString *)password userName:(NSString *)userName;
// generate SignStr
+ (NSString *)generateSignStrWithUserId:(NSNumber *)userId userName:(NSString *)userName password:(NSString *)password nonce:(NSString *)nonce secretKey:(NSString *)secretKey timestamp:(NSString *)timestamp;
// generate SignDic
+ (NSMutableDictionary *)generateSignDic:(long long)nonceLong timestampvalue:(NSNumber *)timestampvalue userId:(NSNumber *)userId sign:(NSString *)sign;
#pragma mark - crypt Method
// sha2 encrypt
+ (NSString*) sha1:(NSString *)str;
//+ (NSData *)  sha1:(NSData *) data;
// aes encrypt
+ (NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)gkey Iv:(NSString *)gIv;
// aes decrypt
+ (NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)gkey Iv:(NSString *)gIv;


@end
