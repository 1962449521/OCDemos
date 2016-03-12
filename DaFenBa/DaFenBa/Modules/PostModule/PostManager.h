//
//  PostManager.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-21.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"
@class PostProfile;
@interface PostManager : BaseObject

@property (nonatomic, strong) PostProfile *postProfile;
@property (nonatomic, weak) BaseVC *currentVC;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *location;



//唤起该模块
- (void)envokeUploadModule;
- (void)submitPostFromVC:(BaseVC *)fromVC;
@end
