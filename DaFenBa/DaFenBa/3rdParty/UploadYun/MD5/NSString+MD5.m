//
//  NSString+MD5.m
//  banana_clock
//
//  Created by MAC on 13-12-19.
//  Copyright (c) 2013年 MAC. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)


-(NSString *)md5HexDigest
{
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}
-(NSString *)imageType
{
    //默认为空
    NSString * imageTypeStr = @"";
    //从url中获取图片类型
    NSMutableArray *arr = (NSMutableArray *)[self componentsSeparatedByString:@"."];
    if (arr) {
        imageTypeStr = [arr objectAtIndex:arr.count-1];
    }
    return imageTypeStr;
}

@end
