//
//  AdviceModel.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-6.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"

/**
 *	@brief	该对象没有单独存在的使用场景
 */
@interface AdviceModel : BaseObject

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSNumber *postId;

@property (nonatomic, strong) NSNumber *adviceId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *buyUrl;

@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, strong) NSNumber *isView;

@end
