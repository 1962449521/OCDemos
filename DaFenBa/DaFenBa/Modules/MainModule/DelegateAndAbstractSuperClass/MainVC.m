//
//  MainVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-9-6.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldSelectIndex:(NSInteger)index
{
    HSLogTrace();
    return NO;
}
- (void)didSelectedIndex:(NSInteger)index
{
    HSLogTrace();
}

- (void)didSelectedMiddle;
{
    HSLogTrace();
}
- (void)hideTabBar;
{
    HSLogTrace();
}
- (void)showTabBar
{
    HSLogTrace();
}

@end
