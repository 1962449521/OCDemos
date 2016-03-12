//
//  AppDelegate.h
//  Password Management
//
//  Created by Mitty on 15/11/20.
//  Copyright © 2015年 Disney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DynamicModel *passwords;


@end

