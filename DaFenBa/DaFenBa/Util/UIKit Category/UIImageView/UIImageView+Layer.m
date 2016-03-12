//
//  UIImageView+Layer.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-24.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "UIImageView+Layer.h"

@implementation UIImageView (Layer)


- (void)setCornerRadius:(NSNumber *)cornerRadius
{
    self.layer.cornerRadius = [cornerRadius floatValue];
    self.clipsToBounds = YES;
}
- (NSNumber *)cornerRadius
{
    return @0.0;
}
- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = [borderColor CGColor];
}
- (void)setBorderWidth:(NSNumber *)borderWidth
{
    self.layer.borderWidth = [borderWidth floatValue];
}
- (NSNumber *)borderWidth
{
    return nil;
}
- (UIColor *)borderColor
{
    return nil;
}
@end
