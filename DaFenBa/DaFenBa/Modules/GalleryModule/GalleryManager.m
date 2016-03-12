//
//  GalleryManager.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-20.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "GalleryManager.h"
#import "PostProfile.h"
#import "MePhotoDetailVC.h"
#import "ScoreSuccessVC.h"
#import "ScoreVC.h"
#import "HomeVC.h"


@implementation GalleryManager
{
    PostProfile     *p_specialPost;
    TypeSpecialPost  p_specialType;
    BaseVC          *p_specialFromVC;
}
+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static GalleryManager* instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
    });
    if (instance) {
        if (!instance.allDataSource) {
            instance.allDataSource = [NSMutableArray arrayWithCapacity:0];
        }
        if (!instance.dataSourceFujing) {
            instance.dataSourceFujing = [NSMutableArray arrayWithCapacity:0];
        }
        if (!instance.dataSourceGuanZhu) {
            instance.dataSourceGuanZhu = [NSMutableArray arrayWithCapacity:0];
        }
        if (!instance.dataSourceTuijian) {
            instance.dataSourceTuijian = [NSMutableArray arrayWithCapacity:0];
        }
    }
    return instance;
}

- (NSMutableArray *)selectedDataSource
{
    switch (self.selectedIndex) {
        case 0:
            return self.dataSourceTuijian;
            break;
        case 1:
            return self.dataSourceGuanZhu;
            break;
        case 2:
            return self.dataSourceFujing;
            break;

        default:
            return nil;
            break;
    }
}

/**
 *	@brief	特殊照片的点击
 *
 *	@param 	postProfile 	<#postProfile description#>
 *	@param 	fromVC 	<#fromVC description#>
 *	@param 	type 	<#type description#>
 *
- (void)handleSpecialPost:(PostProfile *)postProfile fromVC:(BaseVC *)fromVC type:(TypeSpecialPost)type
{
    p_specialFromVC = fromVC;
    p_specialPost   = postProfile;
    p_specialType   = type;
    
    [self gotoGradedOrMyPostDetailVC];
    return;
    
    NSString *alertMessage;
    switch (type) {
        case TypeSpecialPostOwner:
            alertMessage = @"这张照片是你自己发的哦！要查看吗？";
            break;
            
        case TypeSpecialPostGraded:
            alertMessage = @"这张照片你已打过分了哦，要查看吗？";
            break;
    }
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:alertMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.delegate = self;

    
    [alertView show];
    return;
}
#pragma mark - UIAlertViewDelegate
          
- (void)gotoGradedOrMyPostDetailVC
{
    BaseVC *toVC;
    switch (p_specialType)
    {
        case TypeSpecialPostOwner:
        {
            MePhotoDetailVC *mePhotoDetailVC = [MePhotoDetailVC new];
            mePhotoDetailVC.postProfile = p_specialPost;
            toVC = mePhotoDetailVC;
        }
            break;
            
        case TypeSpecialPostGraded:
        {
            ScoreSuccessVC *scoreSuccessVC = [ScoreSuccessVC new];
            scoreSuccessVC.isOmittedScore  = YES;
            if([p_specialFromVC isKindOfClass:[ScoreVC class]])
            {
                ScoreVC *scoreVC = (ScoreVC *) p_specialFromVC;
                scoreSuccessVC.scoreManager = scoreVC.scoreManager;
                toVC = scoreSuccessVC;
            }
        }
            break;
    }
    
    if(toVC != nil)
    {
        UINavigationController *nav = p_specialFromVC.navigationController;
        if ([p_specialFromVC isKindOfClass:[ScoreVC class]]) {
            [nav popViewControllerAnimated:NO ];
        }
        [nav pushViewController:toVC animated:YES];
    }
    
    p_specialFromVC = nil;
    p_specialPost   = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if([p_specialFromVC isKindOfClass:[ScoreVC class]])
        {
            [p_specialFromVC.navigationController popToRootViewControllerAnimated:YES];
        }
        return;
    }
    else
    {
        [self gotoGradedOrMyPostDetailVC];
        
        
    }
}
*/

@end
