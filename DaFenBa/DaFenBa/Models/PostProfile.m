//
//  PostProfile.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-14.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "PostProfile.h"

@implementation PostProfile
/* 
 id: post id, pic: post pic name, picH: pic height, picW: pic width, comment: post comment, gradeCount: grade count, distance: post distance // when type = 3 and longitude/latitude are not both 0, createTime: post createTime
 */

- (void)setUser:(UserProfile *)user
{
    if([user isKindOfClass:[UserProfile class]])
        _user = user;
    else if([user isKindOfClass:[NSDictionary class]])
    {
        UserProfile *newUser = [UserProfile new];
        [newUser assignValue:(NSDictionary *)user];
        _user = newUser;
    }
    
}


@end
