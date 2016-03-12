//
//  MePhotoCell.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-25.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MePhotoCell.h"
#import "PostProfile.h"

@implementation MePhotoCell
{
    UITapGestureRecognizer *tap;
    UILongPressGestureRecognizer *longPress;
    PostProfile *_cellData;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bageComment.layer.cornerRadius = self.bageComment.height/2;
    self.bageAdvice.layer.cornerRadius = self.bageAdvice.height/2;
    self.bageComment.clipsToBounds = YES;
    self.bageAdvice.clipsToBounds = YES;
    
    self.layer.borderColor = [TheMeBorderColor CGColor];
    self.layer.borderWidth = 1.0;

    
}
- (void)assignValue:(PostProfile *)cellData
{
    self.contentView.userInteractionEnabled = YES;
    self.userInteractionEnabled = YES;
    _cellData = cellData;
    [self.post setPost:cellData.pic];
    if ([cellData.avgGrade floatValue] >= 10)
        [self.avgGrade setText:[NSString stringWithFormat:@"%d", [cellData.avgGrade intValue]]];
    else
        self.avgGrade.text = [NSString stringWithFormat:@"%.1f",[cellData.avgGrade floatValue]];

    if (tap == nil) {
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self.contentView addGestureRecognizer:tap];
        
    }
    
    if (longPress == nil) {
        longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [self.contentView addGestureRecognizer:longPress];
    }


}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
//    CGRect rect = [[self.superview hitTest:point withEvent:event] frame];
    CGRect rect = self.frame;
    if (CGRectContainsPoint(rect, point))
        return self.contentView;
    else return [super hitTest:point withEvent:event];
}

- (IBAction)tap:(id)sender {
    [ScoreManager evokeScoreWithPostOrScoreManager:_cellData FromVC:self.userDelegate];
//    [[GalleryManager shareInstance]handleSpecialPost:_cellData fromVC:self.userDelegate type:TypeSpecialPostOwner];
}
- (IBAction)longPress:(UILongPressGestureRecognizer *)reg {
  
    if (reg.state == UIGestureRecognizerStateBegan ) {
        SEL sel = NSSelectorFromString(@"deleteCell:");
        [self.userDelegate performSelector:sel withObject:_cellData ];
    }

}

@end
