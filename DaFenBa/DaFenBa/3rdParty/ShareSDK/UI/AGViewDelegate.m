//
//  Created by ShareSDK.cn on 13-1-14.
//  官网地址:http://www.mob.com
//  技术支持邮箱:support@sharesdk.cn
//  官方微信:ShareSDK   （如果发布新版本的话，我们将会第一时间通过微信将版本更新内容推送给您。如果使用过程中有任何问题，也可以通过微信与我们取得联系，我们将会在24小时内给予回复）
//  商务QQ:4006852216
//  Copyright (c) 2013年 ShareSDK.cn. All rights reserved.
//
#import "AGViewDelegate.h"
#import <AGCommon/UIDevice+Common.h>
#import <AGCommon/UINavigationBar+Common.h>
#import <AGCommon/NSString+Common.h>
#import "UINavigationBar+customBar.h"


@implementation AGViewDelegate

#pragma mark - ISSShareViewDelegate

- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType
{
    
//    if ([[UIDevice currentDevice].systemVersion versionStringCompare:@"7.0"] != NSOrderedAscending)
//    {
        UIBarButtonItem *leftBtn = (UIBarButtonItem *)viewController.navigationItem.leftBarButtonItems[0];
        if (leftBtn == nil)leftBtn = (UIBarButtonItem *)viewController.navigationItem.leftBarButtonItem;
        
        UIBarButtonItem *rightBtn = (UIBarButtonItem *)viewController.navigationItem.rightBarButtonItems[0];
        if(rightBtn == nil)rightBtn = (UIBarButtonItem *)viewController.navigationItem.rightBarButtonItem;
        
//        [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [leftBtn setTintColor:[UIColor blackColor]];
        [rightBtn setTintColor:[UIColor blackColor]];
        [rightBtn setTitle:@"发送"];
        [leftBtn setTitle:@"取消"];

        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.text = @"内容分享";
        label.font = [UIFont boldSystemFontOfSize:18];
        [label sizeToFit];
        
        viewController.navigationItem.titleView = label;
        UINavigationBar *navBar = viewController.navigationController.navigationBar;
        [navBar setTintColor:[UIColor grayColor]];
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavBG@2x.png"] ] autorelease];
        [imageView setHeight:64];
        [imageView setWidth:DEVICE_screenWidth];
        [imageView setTop:-20];
        imageView.contentMode = UIViewContentModeScaleToFill;
            [navBar insertSubview:imageView atIndex:1];
        [label release];
//    }
    
    
}

- (void)view:(UIViewController *)viewController autorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation shareType:(ShareType)shareType
{
    if ([UIDevice currentDevice].isPad)
    {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iPadLandscapeNavigationBarBG.png"]];
        }
        else
        {
            [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iPadNavigationBarBG.png"]];
        }
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            if ([[UIDevice currentDevice] isPhone5])
            {
                [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iPhoneLandscapeNavigationBarBG-568h.png"]];
            }
            else
            {
                [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iPhoneLandscapeNavigationBarBG.png"]];
            }
        }
        else
        {
            [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iPhoneNavigationBarBG.png"]];
        }
    }
}

@end
