//
//  EventModel.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-19.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"
@class UserProfile;
@interface EventModel : BaseObject

@property (nonatomic, strong) NSNumber *eventId;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSNumber *decibelId;
@property (nonatomic, strong) NSNumber *decibelChange;
@property (nonatomic, strong) NSNumber *createTime;


/**
 *	@brief	引起该事件发生的用户
 */
@property (nonatomic, strong) UserProfile *srcUser;
/**
 *	@brief	 该事件的操作对象
 *
 *  发送私信，关注某人时为                 user
 *	上传照片，打分照片，分享照片时为         post
 *  主动打分，回复打分时为                 grade
 *	如查看建议，回复建议时为               advice
 *  回复另一条回复为                      reply
 *	登录时为系统，此时省略，置              nil
 */
@property (nonatomic, strong) BaseObject *tgtObject;

/**
 *	@brief	服务器拼接好的完整信息
 */
@property (nonatomic, strong) NSString *message;



@end
