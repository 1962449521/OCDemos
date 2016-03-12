//
//  TuiJianSectionHeaderView.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-29.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "TuiJianSectionHeaderView.h"

@implementation TuiJianSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)scoreStar:(id)sender {
    POPUPINFO(@"跳到该张图片的打分页！");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
