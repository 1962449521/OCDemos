//
//  BaseUserProfile.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-1.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"

@interface UserProfile : BaseObject<NSCoding,NSCopying>

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *srcName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSString *avatar;

@property (nonatomic, strong) NSString *intro;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSNumber *tall;
@property (nonatomic, strong) NSNumber *weight;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSNumber *qq;
@property (nonatomic, strong) NSString *weibo;
@property (nonatomic, strong) NSString *weixin;

@property (nonatomic, strong) NSNumber *relationType;

@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, strong) NSMutableDictionary *extInfo;
@end
