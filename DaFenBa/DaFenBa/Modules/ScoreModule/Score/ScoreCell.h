//
//  ScoreCell.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//
#import "SubReplyView.h"
@class GradeModel;
@class AdviceModel;


@interface ScoreCell : BaseCell

@property (nonatomic, strong) GradeModel *grade;

@property BOOL isStrechDown;
@property (weak, nonatomic) IBOutlet UIImageView *lzAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *lzNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lzReplyLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradeLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (weak, nonatomic) IBOutlet UIButton *adviceBtn;
@property (strong, nonatomic) AdviceModel *advice;
@property (weak, nonatomic) IBOutlet UIImageView *replySeperatorView;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIButton *moreReplyBtn;


@property (weak, nonatomic) id<ReplyCellUserDelegate>delegate;

- (void)assignValue:(GradeModel *)model;
- (void)strechDown:(id)sender;
- (void)strechUp:(id)sender;
@end
