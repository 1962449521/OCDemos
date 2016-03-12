//
//  TabBarView.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-5.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ConcreteTabBarView.h"
#define BARIMAGEVIEWTAG 9999

@implementation ConcreteTabBarView

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
    self.badge.clipsToBounds = YES;
    self.badge.layer.cornerRadius = self.badge.width/2.0;
}

- (IBAction)buttonClicked:(UIButton *)sender
{
    if (sender.tag == 2) {
        [self middleClicked:sender];
    }
    if ([self.delegate shouldSelectIndex:sender.tag]) {
        [self setSelectedIndex:sender.tag];
        [self.delegate didSelectedIndex:sender.tag];
    }
}
- (void)setSelectedIndex:(NSInteger )index
{
    UIImageView *barBGImage = (UIImageView *)[self viewWithTag:BARIMAGEVIEWTAG];
    NSString *imageName = STRING_joint(@"tabbar_", STRING_fromInt(index));
    [barBGImage setImage:[UIImage imageNamed:imageName]];
}
- (IBAction)middleClicked:(id)sender {
    [self.delegate didSelectedMiddle];
}

@end
