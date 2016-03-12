//
//  UIView+frame.m
//  TXDS_Refactor
//
//  Created by SookinMac05 on 14-5-24.
//  Copyright (c) 2014年 sookin. All rights reserved.
//

#import "UIView+frame.h"

@implementation UIView (frame)

- (void)setX:(float)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(float)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setHeight:(float)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setWidth:(float)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
@end


