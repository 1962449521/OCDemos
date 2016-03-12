//
//  BaseObject.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation BaseObject
{
    NSMutableArray *_keys;
}

/**
 *	@brief	构建单例
 *
 *	@return	返回单例
 */
+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static id instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
    });
    return instance;
}

/**
 *	@brief	dic to object
 *
 *	@param 	dic
 */
- (void)assignValue:(NSDictionary *)dic
{
    for (NSString *key in dic) {
        NSString *capKey = STRING_joint([[key substringToIndex:1]capitalizedString], [key substringFromIndex:1]);
        SEL setMethod = NSSelectorFromString(STRING_joint(STRING_joint(@"set", capKey),@":"));
        if ([self respondsToSelector:setMethod])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:setMethod withObject:dic[key]];
#pragma clang diagnostic pop

            
    }
}
/**
 *	@brief	reset all param
 */

- (void)resetAll
{
    @try {
        NSArray *arr = [self getPropertyList:[self class]];
        for (NSString *value in arr) {
            NSString *capKey = STRING_joint([[value substringToIndex:1]capitalizedString], [value substringFromIndex:1]);
            SEL setMethod = NSSelectorFromString(STRING_joint(STRING_joint(@"set", capKey),@":"));
            //SEL getMethod = NSSelectorFromString(value);
            if ([self respondsToSelector:setMethod])
            {
                objc_msgSend(self, setMethod, 0);
                objc_msgSend(self, setMethod, nil);
            }
        }

    }
    @catch (NSException *exception) {
    }
    @finally {
        
    }
    
}

/**
 *	@brief	返回属性数组
 *
 *	@return	属性数组
 */
- (NSArray *)getPropertyList: (Class)clazz
{
    u_int count;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertyArray;
}


/**
 *	@brief	object to dic
 *
 *	@return	dic
 */
- (NSDictionary *)dictionary

{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *propertyList = [self getPropertyList:[self class]];
    for (NSString *key in propertyList) {
        //SEL selector = NSSelectorFromString(key);
        id value = [self valueForKey:key];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        //id value = [self performSelector:selector];
#pragma clang diagnostic pop

        if ([value isKindOfClass:[BaseObject class]] && [[value getPropertyList:[value class]] count] > 0)
        {
            [dict setObject:[value dictionary] forKey:key];
        }
        
//        if (value == nil) {
//            value = [NSNull null];
//        }
        else if(value != nil)
            [dict setObject:value forKey:key];
    }
    return dict;
}


/**
 *	@brief	本地获取
 */
+ (void)getUserDefault

{
    NSData *data = USERDEFAULT_get(NSStringFromClass([self class]));
    if(data == nil || [data length] == 0)
        return;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    NSDictionary *dic = [unarchiver decodeObjectForKey:NSStringFromClass([self class])];
    [[[self class]shareInstance]assignValue:dic];
}

/**
 *	@brief	本地存储
 */
+ (void)storeUserDeault

{
    NSDictionary *dic = [[[self class]shareInstance]dictionary];//NSNull null 不符合NSCoding协议，不能直接写入
    NSMutableData *data = [NSMutableData dataWithCapacity:0];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:NSStringFromClass([self class])];
    [archiver finishEncoding];
    USERDEFAULT_set(data, NSStringFromClass([self class]));
    USERDEFAULT_syn;
}
@end
