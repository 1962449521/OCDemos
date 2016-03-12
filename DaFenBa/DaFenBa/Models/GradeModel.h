//
//  GradeModel.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-6.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"

@class UserProfile;
@class AdviceModel;
@class PostProfile;

@interface GradeModel : BaseObject

@property (nonatomic, strong) NSNumber *gradeId;

@property (nonatomic, strong) NSNumber *grade;
@property (nonatomic, strong) NSNumber *colorGrade;
@property (nonatomic, strong) NSNumber *sizeGrade;
@property (nonatomic, strong) NSNumber *matchGrade;
@property (nonatomic, strong) NSNumber *styleGrade;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSNumber *createTime;

/**
 *	@brief	打分依赖于user对象而存在，无user即无grade
 */
@property (nonatomic, strong) UserProfile *user;
/**
 *	@brief	建议依赖于grade对象而存在，无grade即无advice
 */
@property (nonatomic, strong) AdviceModel *advice;
/**
 *	@brief	打分依赖于post对象而存在，无post即无grade
 */
@property (nonatomic, strong) PostProfile   *post;
/**
 *	@brief	如下三个属性关于填入本对象的回复对象，数组中填入ReplyModel
 */
@property (nonatomic, strong) NSNumber *repliesLastRefreshTime;
@property (nonatomic, strong) NSNumber *repliesCount;
@property (nonatomic, strong) NSMutableArray *replies;

@end
