//
//  PostProfile.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-14.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"
@class UserProfile;
@interface PostProfile : BaseObject


@property (nonatomic, strong) NSNumber *postId;
@property (nonatomic, strong) NSString *pic;
@property (nonatomic, strong) NSString *comment;

@property (nonatomic, strong) NSNumber *gradeCount;
@property (nonatomic, strong) NSNumber *adviceCount;

@property (nonatomic, strong) NSNumber *avgGrade;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *texture;
@property (nonatomic, strong) NSString *highlight;
@property (nonatomic, strong) NSString *buyUrl;
@property (nonatomic, strong) NSString *buyAddress;

@property (nonatomic, strong) NSString *createTime;

@property (nonatomic, strong) NSNumber *picH;
@property (nonatomic, strong) NSNumber *picW;

@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *distance;

@property (nonatomic, strong) UIImage *post;

@property (nonatomic, strong) UserProfile *user;


@end
