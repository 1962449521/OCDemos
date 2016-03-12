//
//  CustomSearchBar.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-11.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "CustomSearchBar.h"


@interface CustomSearchBar ()
{
    UIImageView *_bgView;
}

@end
@implementation CustomSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    if(_bgView == nil)
    {
        _bgView = [[UIImageView alloc]initWithFrame:self.bounds];
        [_bgView setImage:[[UIImage imageNamed:@"searchBarBG"]stretchableImageWithLeftCapWidth:5 topCapHeight:5]];
        [self addSubview:_bgView];
    }
    if(_switchBtn == nil)
    {
        _switchBtn =[[SimpleSwitch alloc] initWithFrame:CGRectMake(237, 10, 80, 25)];
        _switchBtn.titleOn = @"关注";
        _switchBtn.titleOff = @"专家";
        _switchBtn.on = YES;
        _switchBtn.knobColor = ColorRGB(181.0, 181.0, 181.0);
        _switchBtn.fillColor = ColorRGB(231.0, 231.0, 231.0);
        _switchBtn.clipsToBounds = YES;
        _switchBtn.layer.cornerRadius = 13.0;
        _switchBtn.layer.borderWidth = 1;
        _switchBtn.layer.borderColor = [ColorRGB(206.0, 206.0, 206.0) CGColor];
        [self addSubview:_switchBtn];
    }
    //[self.switchBtn addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

    if(_searchBar == nil)
    {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 1, DEVICE_screenWidth - 83, 42)];
        //self.searchBar
        [self addSubview:_searchBar];
    }
    
    //searchbar 适配
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ([_searchBar respondsToSelector:@selector(barTintColor)]) {
        float iosversion7_1 = 7.1;
        if (version >= iosversion7_1)
        {
            //iOS7.1
            UIView *view = [[[_searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0];
            [view removeFromSuperview];
        }
        else
        {
            //iOS7.0
            [_searchBar setBarTintColor:[UIColor clearColor]];     }
    }
    else
    {
        //iOS7.0以下
        UIView *view = [_searchBar.subviews objectAtIndex:0] ;
        [view removeFromSuperview];
    }
    [self.searchBar setBackgroundColor:[UIColor whiteColor]];
    
    
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"searchbox.png"]stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    
    [self bringSubviewToFront:_searchBar];

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
