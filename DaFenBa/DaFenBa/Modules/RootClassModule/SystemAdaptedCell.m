//
//  BaseCell.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-3.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "SystemAdaptedCell.h"

@implementation SystemAdaptedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    if (!(DEVICE_versionAfter7_0))
    {
        self.backgroundView.frame = CGRectMake(-10, 0, 340, 44);
        self.selectedBackgroundView.frame = CGRectMake(-20, 0, 340, 44);
        
        self.backgroundColor = [UIColor whiteColor];

        NSArray *views = [self subviews];
        for (UIView *subView in views) {
            if (subView.left == 10 && subView.width == 300 && [subView isKindOfClass:[UIImageView class]] ) {
                [subView setX:-10];
                [subView setWidth:340];
            }
        }
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.detailTextLabel setBackgroundColor:[UIColor clearColor]];

        
    }
}
@end
