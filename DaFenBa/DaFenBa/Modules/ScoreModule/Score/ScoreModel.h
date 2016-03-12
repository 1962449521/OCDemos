//
//  ScoreModel.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-26.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//
@class GradeModel;
@protocol ReplyCellUserDelegate <NSObject>

- (void)replyMessage:(id)gradeOrReply;

@end

#import "BaseObject.h"

@interface ScoreModel : BaseObject
@property (nonatomic, strong) NSString *avartar;
@property (nonatomic, strong) NSNumber *gradeId;
@property (nonatomic, strong) NSNumber *grade;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSNumber *replyCount;
@property (nonatomic, strong) NSArray *reply;
@property (nonatomic, strong) NSDictionary *advice;

@end