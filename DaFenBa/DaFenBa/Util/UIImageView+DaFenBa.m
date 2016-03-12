//
//  UIImageView+DaFenBa.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-9.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "UIImageView+DaFenBa.h"
#import "UIImageView+LK.h"
#import "UpYun.h"
static NSString* prefix = DEFAULT_UPYUN_PREFIX;
@implementation UIImageView (DaFenBa)

- (void)setAvartar:(NSString *)avatarStr
{
    if ([STRING_judge(avatarStr) length] == 0) {
        [self setImage:[UIImage imageNamed:@"defaultAvatar"]];
        return;
    }
    if ([avatarStr rangeOfString:@"http://"].length == 0) {
        avatarStr = [NSString stringWithFormat:@"%@avatar/%@", prefix, avatarStr];
    }
    [self setImage:avatarStr defaultImageName:@"defaultAvatar"];
    
}
- (void)setPost:(NSString *)postStr
{
    if ([STRING_judge(postStr) length] == 0) {
        [self setImage:[UIImage imageNamed:@"remind_noImage"]];
        return;
    }
    if ([postStr rangeOfString:@"http://"].length == 0) {
        postStr = [NSString stringWithFormat:@"%@post/%@", prefix, postStr];
    }
    [self setImage:postStr defaultImageName:@"remind_noImage"];
}
- (void)setUrlStr:(NSString *)postUrl
{
 [self setImage:postUrl defaultImageName:@"remind_noImage"];
}
@end
