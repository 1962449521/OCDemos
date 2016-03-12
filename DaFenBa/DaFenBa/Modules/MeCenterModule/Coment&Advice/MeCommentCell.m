//
//  MeCommentCell.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-31.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MeCommentCell.h"
#import "GradeModel.h"
#import "AdviceModel.h"
#import "PostProfile.h"

@implementation MeCommentCell
{
    UITapGestureRecognizer *cellTapRec;
    UILongPressGestureRecognizer *commentLongPressRec;
    UILongPressGestureRecognizer *adviceLongPressRec;
    UITapGestureRecognizer *commentPressRec;
    UITapGestureRecognizer *advicePressRec;
    UITapGestureRecognizer *postPressRec;
    
    GradeModel *grade;
    BOOL commentLongPressing;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
/**
 *	@brief	分析内容长点击
 *
 *	@param 	reg 	<#reg description#>
 */
- (void)commentLabelLongClick:(UILongPressGestureRecognizer *)reg
{
    if (reg.state == UIGestureRecognizerStateBegan) {
        if(grade.comment && [grade.comment length] != 0)
            [self.delegate commentLongClick:self.indextWithinDataSource];
        else
            [self commentLabelClick:nil];
    }

}
/**
 *	@brief	建议内容长点击
 *
 *	@param 	reg 	<#reg description#>
 */
- (void)adviceLabelLongClick:(UILongPressGestureRecognizer *)reg
{

    if (reg.state == UIGestureRecognizerStateBegan ) {
        if(grade.advice && [grade.advice.content length] != 0)
            [self.delegate adviceLongClick:self.indextWithinDataSource];
        else
            [self adviceLabelClick:nil];
    }
    
}

/**
 *	@brief	图片点击
 *
 *	@param 	sender 	<#sender description#>
 */
- (IBAction)postClick:(id)sender {
    [self.delegate postClick:self.indextWithinDataSource];
}
/**
 *	@brief	删除整行
 *
 *	@param 	sender 	<#sender description#>
 */
- (IBAction)deleteCell:(id)sender {
    [self.delegate deleteCell:self.indextWithinDataSource];
}
- (IBAction)commentLabelClick:(id)sender {
    if (grade.comment == nil || [grade.comment length] == 0)
        [self.delegate commentClick:self.indextWithinDataSource];
}
- (IBAction)adviceLabelClick:(id)sender {
    if (grade.advice == nil || [grade.advice.content length] == 0)
        [self.delegate adviceClick:self.indextWithinDataSource];
}
- (IBAction)shareCell:(id)sender
{
    [self.delegate shareCell:self.indextWithinDataSource];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rectComment  = self.commentBtn.frame;
    CGRect rectLeftView = self.leftView.frame;
    CGRect rectAdvice   = self.adviceBtn.frame;
    CGRect rectGarbage  = self.garbageBtn.frame;
    CGRect rectShare    = self.shareBtn.frame;
    NSArray *rectArr = @[[NSValue valueWithCGRect:rectComment],
                         [NSValue valueWithCGRect:rectAdvice],
                         [NSValue valueWithCGRect:rectLeftView],
                         [NSValue valueWithCGRect:rectGarbage],
                         [NSValue valueWithCGRect:rectShare]
                         ];
    NSArray *viewArr = @[self.commentBtn,self.adviceBtn,self.postBtn,self.garbageBtn,self.shareBtn];
    
    for (int index = 0; index < [rectArr count]; index++) {
        CGRect rect = [rectArr[index] CGRectValue];
        if (CGRectContainsPoint(rect, point)) {
            return viewArr[index];
        }
    }
    return [super hitTest:point withEvent:event];
}

- (void) setDataSource:(GradeModel *)agrade
{

    AdviceModel *advice = agrade.advice;
    grade = agrade;
    PostProfile *post = agrade.post;
    
    [self.commentLabel setText:STRING_judge(grade.comment)];
    [self.adviceLabel setText:STRING_judge(advice.content)];
    
    [self.photo setPost:STRING_fromId(grade.post.pic)];
    [self.meGradeLabel setText:STRING_fromId(grade.grade)];
    if ([post.avgGrade floatValue] >= 10)
        [self.avgGradeBtn setText:[NSString stringWithFormat:@"%d", [post.avgGrade intValue]]];
    else
        [self.avgGradeBtn setText:[NSString stringWithFormat:@"%.1f", [post.avgGrade floatValue]]];
    [self.meGradeLabel setText:STRING_fromId(agrade.grade)];
    
    
    if (commentLongPressRec == nil) {
        commentLongPressRec = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(commentLabelLongClick:)];
        [self.commentBtn addGestureRecognizer:commentLongPressRec];
        
    }
    if (adviceLongPressRec == nil) {
        adviceLongPressRec = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(adviceLabelLongClick:)];
        [self.adviceBtn addGestureRecognizer:adviceLongPressRec];
        
    }
    if (commentPressRec == nil) {
        commentPressRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentLabelClick:)];
        [self.commentBtn addGestureRecognizer:commentPressRec];
        
        
    }
    if (advicePressRec == nil) {
        advicePressRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(adviceLabelClick:)];
        [self.adviceBtn addGestureRecognizer:advicePressRec];
        
    }
    
    if (postPressRec == nil) {
        postPressRec = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(postClick:)];
        [self.postBtn addGestureRecognizer:postPressRec];
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}





@end
