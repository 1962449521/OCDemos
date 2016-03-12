//
//  FriendListCell.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-21.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseCell.h"

@interface FriendListCell : BaseCell
@property (nonatomic, strong) NSNumber *userId;
@property(nonatomic, retain) NSDictionary *dataSource;
@end
