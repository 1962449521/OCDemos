//
//  GalleryManager.h
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-20.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "BaseObject.h"

typedef NS_ENUM(NSInteger, TypeSpecialPost)
{
    TypeSpecialPostOwner,
    TypeSpecialPostGraded
};

@class ScoreManager;
@class PostProfile;
@interface GalleryManager : BaseObject




/*!
 @property
 @abstract	数据源 推荐
 */
@property (nonatomic, strong) NSMutableArray *dataSourceTuijian;
/*!
 @property
 @abstract	数据源 关注
 */
@property (nonatomic, strong) NSMutableArray *dataSourceGuanZhu;
/*!
 @property
 @abstract	数据源 附近
 */
@property (nonatomic, strong) NSMutableArray *dataSourceFujing;
//指向以上三个数组之一
@property (nonatomic, strong) NSMutableArray *selectedDataSource;
//总体数据
@property (nonatomic, strong) NSMutableArray *allDataSource;


@property (nonatomic, assign) NSInteger selectedIndex;


//处理特殊图片的跳转
//- (void) handleSpecialPost:(PostProfile *)postProfile fromVC:(BaseVC *)fromVC type: (TypeSpecialPost) type;
@end
