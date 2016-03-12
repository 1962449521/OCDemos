//
//  MePhotoCellModel.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-1.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"

@interface MePhotoCellModel : BaseObject

@property (nonatomic, strong) UIImage *post;
@property (nonatomic, strong) NSNumber *avgGrade;
@property (nonatomic, strong) NSNumber *unreadCommentCount;
@property (nonatomic, strong) NSNumber *unreadAdviceCount;
@property (nonatomic, strong) NSMutableDictionary *extInfo;
@end