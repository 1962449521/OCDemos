//
//  DetailViewController.h
//  Password Management
//
//  Created by Mitty on 15/11/20.
//  Copyright © 2015年 Disney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, assign) NSInteger index;


@property (nonatomic, strong) NSMutableDictionary *password;


@end

