//
//  ScoreCellForMePhoto.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-18.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ScoreCellForMePhoto.h"
#import "ScoreMoreReplyVC.h"
#import "GradeModel.h"
#import "AdviceModel.h"
#import "ScoreListVC.h"
@implementation ScoreCellForMePhoto

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)assignValue:(GradeModel *)model
{
    [super assignValue:model];
    
    if (model.advice == nil || model.advice.adviceId ==nil)
    {
        [self.adviceBtn setTitle:@"邀请建议" forState:UIControlStateNormal];
        self.adviceBtn.enabled = YES;
    }
    else
    {
        [self.adviceBtn setTitle:@"私人建议" forState:UIControlStateNormal];
        self.adviceBtn.enabled = YES;
    }
    [self.lzNameLabel sizeToFit];
    [self.date sizeToFit];
    [self.date setX:self.lzNameLabel.right + 5.0];
}

@end
