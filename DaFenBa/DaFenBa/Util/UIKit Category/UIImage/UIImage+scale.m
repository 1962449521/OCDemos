//
//  UIImage+scale.m
//  TXDS_Refactor
//
//  Created by SookinMac05 on 14-5-21.
//  Copyright (c) 2014年 sookin. All rights reserved.
//

#import "UIImage+scale.h"

@implementation UIImage (scale)

//图片缩放
- (UIImage *)scaleTo:(CGSize)size
//(float)scaleSize
{
	UIGraphicsBeginImageContextWithOptions(size,NO,[[UIScreen mainScreen] scale]);
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end
