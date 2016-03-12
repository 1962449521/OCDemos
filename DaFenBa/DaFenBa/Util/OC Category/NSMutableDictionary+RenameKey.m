//
//  NSDictionary+RenameKey.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-3.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "NSMutableDictionary+RenameKey.h"

@implementation NSMutableDictionary(RenameKey)

- (void) renameKey:(NSString *)oldKey withNewName:(NSString *)newKey
{
    if(self[oldKey] != nil)
    {
        [self setValue:self[oldKey] forKey:newKey];
        [self removeObjectForKey:oldKey];
    }
}


@end
