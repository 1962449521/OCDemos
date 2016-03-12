//
//  NSDate+DaFenBa.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-17.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "DaFenBaDate.h"

@implementation DaFenBaDate
{
    DateStruct dateStruct;
//    NSInteger  year;
//    NSInteger month;
//    NSInteger day;
//    NSInteger hour;
//    NSInteger minute;
//    NSInteger second;
}


- (void) buildComponent
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit |
    NSMonthCalendarUnit | NSYearCalendarUnit | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self.date];
    
    dateStruct.day = [components day];
    dateStruct.month= [components month];
    dateStruct.year= [components year];
    dateStruct.hour = [components hour];
    dateStruct.minute = [components minute];
    dateStruct.second = [components second];
}
- (NSInteger)year
{
    return dateStruct.year;
}
- (NSInteger)month
{
    return dateStruct.month;
}
- (NSInteger)day
{
    return dateStruct.day;
}
- (NSInteger )hour
{
    return dateStruct.hour;
}
- (NSInteger )minute
{
    return dateStruct.minute;
}
- (NSInteger)second
{
    return dateStruct.second;
}
- (DateStruct)dateStruct
{
    return dateStruct;
}


+ (NSString *)curStrFromTime:(long)time
{
    long nowTime = [[NSDate date] timeIntervalSince1970];
    long delta = nowTime - time;
    if(delta <60)
        return  [NSString stringWithFormat:@"%ld秒前", delta];
    else if(delta < 60*60)
        return [NSString stringWithFormat:@"%ld分前", delta/60];
    else if(delta < 60*60*24)
        return [NSString stringWithFormat:@"%ld小时前", delta/60/60];
    else if(delta < 360*60*60*24)
        return [NSString stringWithFormat:@"%ld天前", delta/60/60/24];
    else
        return @"很久前";
}
+ (NSString *)curStr2FromTime:(long) createTime
{
    DaFenBaDate *date = [DaFenBaDate new];
    DaFenBaDate *curDate = [DaFenBaDate new];
    date.date =  [NSDate dateWithTimeIntervalSince1970:createTime];
    curDate.date =  [NSDate date];
    [date buildComponent];
    [curDate buildComponent];
    if (date.year != curDate.year) {
        return [NSString stringWithFormat:@"%d-%02d-%02d", date.year, date.month, date.day];
    }
    else if (date.month != curDate.month || date.day != curDate.day  ) {
        return [NSString stringWithFormat:@"%02d-%02d %02d:%02d", date.month, date.day, date.hour, date.minute];
    }
    else
        return [NSString stringWithFormat:@"%02d:%02d", date.hour, date.minute ];
    
}




@end
