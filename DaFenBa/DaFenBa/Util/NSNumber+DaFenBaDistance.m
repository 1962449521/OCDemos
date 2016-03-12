//
//  NSString+DaFenBaDistance.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-5.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "NSNumber+DaFenBaDistance.h"

@implementation NSNumber (DaFenBaDistance)


- (NSString *)daFenBaDistance
{
    int distance = [self intValue];
    if(distance >= 1000) return STRING_joint(STRING_fromInt(distance/1000), @"km");
    else return STRING_joint(STRING_fromInt(distance), @"m");
}


@end
