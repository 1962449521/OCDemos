//
//  ReplyModel.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-14.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

typedef NS_ENUM(NSUInteger, ReplyType)
{
    ReplyTypeGrade = 1,
    ReplyTypeAdvice,
    ReplyTypeReply
};

#import "BaseObject.h"


@class UserProfile;
@interface ReplyModel : BaseObject

@property (nonatomic, strong) NSNumber    *replyId;

@property (nonatomic, strong) NSNumber    *postId;
@property (nonatomic, strong) NSNumber    *tgtReplyId;

@property (nonatomic, strong) NSNumber    *gradeId;
@property (nonatomic, strong) NSNumber    *adviceId;


//@property (nonatomic, strong) NSNumber    *tgtId;
@property (nonatomic, strong) UserProfile *srcUser;
@property (nonatomic, strong) UserProfile *tgtUser;
@property (nonatomic, strong) NSString    *content;
@property (nonatomic, strong) NSNumber    *createTime;

@end
