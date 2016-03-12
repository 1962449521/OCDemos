//
//  BaseUserProfile.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-1.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile


/*
 @property (nonatomic, strong) NSString *intro;
 @property (nonatomic, strong) NSString *address;
 @property (nonatomic, strong) NSString *birthday;
 @property (nonatomic, strong) NSNumber *tall;
 @property (nonatomic, strong) NSNumber *weight;
 
 @property (nonatomic, strong) NSString *email;
 @property (nonatomic, strong) NSNumber *qq;
 @property (nonatomic, strong) NSString *weibo;
 @property (nonatomic, strong) NSString *weixin;

 */

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.srcName forKey:@"srcName"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    
    [aCoder encodeObject:self.intro forKey:@"intro"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.tall forKey:@"tall"];
    [aCoder encodeObject:self.weight forKey:@"weight"];
    
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.qq forKey:@"qq"];
    [aCoder encodeObject:self.weibo forKey:@"weibo"];
    [aCoder encodeObject:self.weixin forKey:@"weixin"];
    
    [aCoder encodeObject:self.relationType forKey:@"relationType"];
    
    
    [aCoder encodeObject:self.accessToken forKey:@"accessToken"];
    [aCoder encodeObject:self.extInfo forKey:@"extInfo"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self == [super init]) {
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.srcName = [aDecoder decodeObjectForKey:@"srcName"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        
        self.intro = [aDecoder decodeObjectForKey:@"intro"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.tall = [aDecoder decodeObjectForKey:@"tall"];
        self.weight = [aDecoder decodeObjectForKey:@"weight"];
        
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.qq = [aDecoder decodeObjectForKey:@"qq"];
        self.weibo = [aDecoder decodeObjectForKey:@"weibo"];
        self.weixin = [aDecoder decodeObjectForKey:@"weixin"];
        
        self.relationType = [aDecoder decodeObjectForKey:@"relationType"];
        
        self.accessToken = [aDecoder decodeObjectForKey:@"accessToken"];
        self.extInfo = [aDecoder decodeObjectForKey:@"extInfo"];
    }
    return self;
}
#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    UserProfile *copy = [[[self class] allocWithZone:zone] init];
    copy.userId = [self.userId copyWithZone:zone];
    copy.name = [self.name copyWithZone:zone];
    copy.password = [self.password copyWithZone:zone];
    copy.gender = [self.gender copyWithZone:zone];
    
    copy.intro = [self.intro copyWithZone:zone];
    copy.address = [self.address copyWithZone:zone];
    copy.birthday = [self.birthday copyWithZone:zone];
    copy.tall = [self.tall copyWithZone:zone];
    copy.weight = [self.weight copyWithZone:zone];
    
    copy.email = [self.email copyWithZone:zone];
    copy.qq = [self.qq copyWithZone:zone];
    copy.weibo = [self.weibo copyWithZone:zone];
    copy.weixin = [self.weixin copyWithZone:zone];

    copy.relationType = [self.relationType copyWithZone:zone];
    
    copy.accessToken = [self.accessToken copyWithZone:zone];
    copy.extInfo = [self.extInfo copyWithZone:zone];
    return copy;
}

@end
