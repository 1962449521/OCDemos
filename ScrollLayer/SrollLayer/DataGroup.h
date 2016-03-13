//
//  DateItem.h
//  SrollLayer
//
//  Created by 胡 帅 on 16/3/13.
//  Copyright © 2016年 Disney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataItem : NSObject
@property (nonatomic, assign) double highValue;
@property (nonatomic, assign) double lowValue;
@property (nonatomic, assign) double timeStamp;
@end

@interface DataGroup : NSObject
@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, assign) double maxValue;
@property (nonatomic, assign) double minValue;
@property (nonatomic, assign) double maxTS;
@property (nonatomic, assign) double minTS;

@end
