//
//  InviteCell.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-24.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "SystemAdaptedCell.h"

@interface InviteCell : BaseCell

@property BOOL isSelected;
@property (nonatomic, strong) NSString *userId;
@property(nonatomic, retain) NSDictionary *dataSource;
@end
