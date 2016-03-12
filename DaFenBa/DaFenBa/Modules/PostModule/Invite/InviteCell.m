//
//  InviteCell.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-24.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "InviteCell.h"


@implementation InviteCell
{
    BOOL _isSelected;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - setting/getting
- (BOOL)isSelected
{
    return _isSelected;
}
- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if(_isSelected)
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"invite_selected"] forState:UIControlStateNormal];
    else
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"invite"] forState:UIControlStateNormal];
}
- (void)setDataSource:(NSDictionary *)dataSource
{
    
    [self.imageView1 setAvartar:dataSource[@"avatar"]];
    self.userId = dataSource[@"id"];
    self.label1.text = dataSource[@"srcName"];
    self.label2.text = dataSource[@"intro"];
    [self setIsSelected:[dataSource[@"selected"] boolValue]];
    
}
- (IBAction)switchSelect:(id)sender
{
    [self setIsSelected:!_isSelected];

}

@end
