//
//  AdviceMsgCee.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-17.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseCell.h"
@class ReplyModel;

@interface AdviceMsgCell : BaseCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLbl;
@property (weak, nonatomic) IBOutlet UILabel *sendDateLbl;
@property (weak, nonatomic) IBOutlet UIImageView *contentBGImageView;

- (void)assignValue:(ReplyModel *)reply;

@end
