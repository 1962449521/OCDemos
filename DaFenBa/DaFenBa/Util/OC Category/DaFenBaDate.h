//
//  NSDate+DaFenBa.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-17.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct DateStruct
{
    NSInteger  year;
    NSInteger month;
    NSInteger day;
    NSInteger hour;
    NSInteger minute;
    NSInteger second;
}DateStruct;



@interface DaFenBaDate : NSObject

@property (nonatomic, strong) NSDate *date;
- (void) buildComponent;
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)hour;
- (NSInteger)minute;
- (NSInteger)second;
- (DateStruct)dateStruct;

+ (NSString *)curStrFromTime:(long)time;
+ (NSString *)curStr2FromTime:(long) createTime;

@end
