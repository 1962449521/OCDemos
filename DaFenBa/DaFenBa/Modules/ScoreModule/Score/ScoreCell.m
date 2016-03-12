//
//  ScoreCell.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ScoreCell.h"
#import "ScoreMoreReplyVC.h"
#import "GradeModel.h"
#import "AdviceModel.h"
#import "ScoreListVC.h"
#import "DaFenBaDate.h"
#import "HomePageVC.h"

@implementation ScoreCell
{
    GradeModel * _model;
    NSMutableArray *replyViews;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
//- (void)layoutSubviews
//{
//        self.firstSubView = (SubReplyView *)[[[NSBundle mainBundle]loadNibNamed:@"SubReplyView" owner:self options:nil]lastObject];
//        self.secondSubView =  (SubReplyView *)[[[NSBundle mainBundle]loadNibNamed:@"SubReplyView" owner:self options:nil]lastObject];
//        self.thirdView = (SubReplyView *)[[[NSBundle mainBundle]loadNibNamed:@"SubReplyView" owner:self options:nil]lastObject];
//    CGRect frame = CGRectMake(53, 92, 261, 46);
//    [self.firstSubView setFrame:frame];
//    [self addSubview:self.firstSubView];
//    frame.origin.y = 92+46;
//    [self.secondSubView setFrame:frame];
//    [self addSubview:self.secondSubView];
//    frame.origin.y = 92+46+46;
//    [self.thirdView setFrame:frame];
//    [self addSubview:self.thirdView];
//}
- (NSString *)p_curStrFromTime:(long)time
{
    return [DaFenBaDate curStrFromTime:time];
    
}

- (void)assignValue:(GradeModel *)model
{
    _model = model;
    [self.lzAvatarImageView setAvartar:STRING_fromId( model.user.avatar)];
    [self.lzNameLabel setText:STRING_fromId(model.user.srcName)];
    [self.lzReplyLabel setText:model.comment];
    [self.date setText:[self p_curStrFromTime:[model.createTime longValue]]];
    [self.gradeLabel setText:STRING_fromId(model.grade)];
    [self.lzReplyLabel sizeToFit];
    if (self.lzReplyLabel.height > 34) {//自适应高度
        [self.replyBtn setTop:self.lzReplyLabel.bottom + 5];
        [self.adviceBtn setTop:self.lzReplyLabel.bottom +5];
        [self.baseView setHeight: self.replyBtn.bottom - 4];
        [self.contentView setHeight:self.baseView.bottom];
        
        [self setHeight:self.contentView.bottom];
        [self.replySeperatorView setTop:self.contentView.bottom];
    }
    NSString *replyBtnStr;
    if(model.repliesCount )
        replyBtnStr = [NSString stringWithFormat:@"回复（%d）", [model.repliesCount intValue]];
    if ([model.repliesCount intValue] == 0) {
        self.replyBtn.enabled = NO;
    }
    else
        self.replyBtn.enabled = YES;
    
    [self.replyBtn setTitle:replyBtnStr forState:UIControlStateNormal];
    self.advice = model.advice;
    NSNumber *userIdLogin = [Coordinator userProfile].userId;
    NSNumber *userIdGrade = model.user.userId;
    if ([userIdGrade isEqualToNumber:userIdLogin]) {
        [self.lzNameLabel setText:@"我"];

        self.adviceBtn.hidden = YES;
    }
    else if (model.advice == nil || model.advice.adviceId ==nil)
    {
        [self.adviceBtn setTitle:@"未给建议" forState:UIControlStateNormal];
        self.adviceBtn.enabled = NO;
    }
    else
    {
        [self.adviceBtn setTitle:@"查看建议" forState:UIControlStateNormal];
        self.adviceBtn.enabled = YES;
    }
}
- (IBAction)moreReply:(id)sender
{
    ScoreMoreReplyVC *vc = [[ScoreMoreReplyVC alloc]init];
    ScoreListVC *delegateVC = (ScoreListVC *)self.delegate;
    vc.tableVC.requestCurrentPage = 0;
    vc.userDelegate = delegateVC;
    vc.grade = _model;
    
    [ [delegateVC.userDelegate navigationController] pushViewController:vc animated:YES];
}
- (IBAction)enterHomePage:(id)sender
{
    ScoreListVC *delegateVC = (ScoreListVC *)self.delegate;
    [HomePageVC enterHomePageOfUser:_model.user fromVC:delegateVC.userDelegate];
}

- (void)strechDown:(NSArray *)replies
{
    if (!replyViews ||[replyViews count] == 0)
    {
        replyViews = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < 3; i++) {
            SubReplyView *view = (SubReplyView *)[[[NSBundle mainBundle]loadNibNamed:@"SubReplyView" owner:self options:nil]lastObject];
            view.delegate = self.delegate;
            [replyViews addObject:view];
        }
    }
    /*
     {id: reply id, postId: post id, content: reply content, srcUserId: source user id, srcName: source user name, tgtUserId: target user id, tgtName: target user name, type: reply type, gradeId: target grade id, adviceId: target advice id, replyId: target reply id, createTime: reply time}
     */
    NSArray *replyArr = replies;
    
    
    int count = [replyArr count];
    [self.moreReplyBtn setHidden:YES];
    
    float lastY = self.height;
    for (int i = 0; i < count && i<3; i++) {
        SubReplyView *view = replyViews[i];
        [view assignValue:replyArr[i]];
        [view setTop:lastY];
        if(i == 0) [view setTop:view.top + 5];
        [view setX:66];
        [self.contentView addSubview:view];
        [self.contentView setHeight:view.bottom];

        lastY = view.bottom;
    }
    if (count > 3)
    {
        [self.moreReplyBtn setHidden:NO];
        [self.moreReplyBtn setTop:((UIView *)replyViews[2]).bottom +10];
        [self.contentView setHeight:self.moreReplyBtn.bottom + 3];
    }
    else if (count > 0)
    {
        [self.contentView setHeight:((UIView *)replyViews[count-1]).bottom + 3];
        
    }
    [self setHeight:self.contentView.height];
}
- (void)strechUp:(id)sender
{
    [self setHeight:self.replyBtn.bottom -4];
}
- (IBAction)cellClicked:(id)sender {
    
    

    [self.delegate replyMessage:_model];
}
@end
