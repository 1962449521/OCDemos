//
//  UINavigationBar+customBar.h
//  cuntomNavigationBar
//
//  Created by Edward on 13-4-22.
//  Copyright (c) 2013年 Edward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface UINavigationBar (customBar)
- (void)customNavigationBar:(NSString *)imageName;
- (void)drawRoundCorner;
- (void)drawShadow;
- (void)drawRoundCornerAndShadow;
- (void)drawBackground:(NSString *)imageName;
@end
