/*!
 @header Security.h
 @abstract 加密模块 需实现SecurityModuleDelegate协议中的方法
 @author 胡帅
 @version 1.0 2014/08 Creation
 */

#import <Foundation/Foundation.h>
#import "MF_Base64Additions.h"
#import "SecurityModuleDelegate.h"
#define DEFAULTKEY @"5e480a28f21044a1"
#define IVKEY [@"646253d202202068" base64String]
#define SECRETKEY @"625d0e82a15748d7b2a36df3b275c630"

@interface DaFenBaSecurity : NSObject<SecurityModuleDelegate>

+ (NSString *)AES128Encrypt:(NSString *)plainText key:(NSString *)gkey Iv:(NSString *)gIv;
+ (NSString *)AES128Decrypt:(NSString *)encryptText key:(NSString *)gkey Iv:(NSString *)gIv;


//+ (NSString *)CharToNSString:(const char *) str;
//+ (BOOL)judgeString:(NSString *)str;
//+ (BOOL)judgeArr:(NSArray *)arr;
@end
