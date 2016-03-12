//
//  SubReplyView.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ScoreModel.h"
@class ReplyModel;
@interface SubReplyView : UIView
@property (nonatomic, weak)NSNumber *userId;
@property (nonatomic, weak)NSString *userName;
@property (nonatomic, weak) IBOutlet UIImageView *avartar;
@property (nonatomic, weak) IBOutlet UILabel *reply;

- (void)assignValue:(ReplyModel *)model;
@property (weak, nonatomic) id<ReplyCellUserDelegate>delegate;

@end
