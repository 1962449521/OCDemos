//
//  UINavigationBar+customBar.m
//  cuntomNavigationBar
//
//  Created by Edward on 13-4-22.
//  Copyright (c) 2013年 Edward. All rights reserved.
//

#import "UINavigationBar+customBar.h"
#import "UIImage+scale.h"


@implementation UINavigationBar (customBar)
- (void)customNavigationBar:(NSString *)imageName{
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self setBackgroundImage:[UIImage imageNamed:imageName] forBarMetrics:UIBarMetricsDefault];
    } else {
        [self drawRect:self.bounds];
    }
    
    [self drawRoundCornerAndShadow];
}

- (void)drawBackground:(NSString *)imageName{
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        if (DEVICE_versionAfter7_0) {
            [self setBackgroundImage:[UIImage imageNamed:imageName] forBarMetrics:UIBarMetricsDefault];
        }
        else
            [self setBackgroundImage:[[UIImage imageNamed:imageName]scaleTo:CGSizeMake(DEVICE_screenWidth, 44)] forBarMetrics:UIBarMetricsDefault];

            } else {
        [self drawRect:self.bounds];
    }
}

- (void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"Title"] drawInRect:rect];
}

- (void)drawRoundCorner
{
    CGRect bounds = self.bounds;
    bounds.size.height +=10;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    [self.layer addSublayer:maskLayer];
    self.layer.mask = maskLayer;
}
- (void)drawShadow
{
    self.layer.shadowOffset = CGSizeMake(3, 3);
    self.layer.shadowOpacity = 0.7;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)drawRoundCornerAndShadow {
    [self drawRoundCorner];
    [self drawShadow];
    
    
}
@end
