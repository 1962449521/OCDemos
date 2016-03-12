//
//  ScoreSuccessVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-13.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ScoreSuccessVC.h"
#import "ScoreSuccessHeaderVC.h"
#import "ScoreListVC.h"
#import "ScoreVC.h"
#import "BigFieldVC.h"

#import "AdviceFromMeVC.h"
#import "AdviceFromOtherVC.h"
#import "MeCommentVC.h"


#import "PostProfile.h"
#import "UserProfile.h"
#import "GradeModel.h"
#import "AdviceModel.h"

#import "FirstEnterTime.h"
#import "UIImageView+LK.h"

#import "ShareManager.h"


@interface ScoreSuccessVC ()<pickerUserDelegate, UIScrollViewDelegate>


@end

@implementation ScoreSuccessVC
{
    BigFieldVC *p_analyseFild;
    ScoreListVC *p_scoreList;
    ScoreSuccessHeaderVC *p_sshVC;
}


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

    p_sshVC = [[ScoreSuccessHeaderVC alloc]init];
    p_sshVC.scoreManager = self.scoreManager;
    p_sshVC.userDelegate = self;
    p_sshVC.isOmittedScore = self.isOmittedScore;
    
    p_scoreList = [ScoreListVC new];
    p_scoreList.scoreManager = self.scoreManager;
    p_scoreList.userDelegate = self;
    //[p_scoreList.view setHeight:DEVICE_screenHeight - 64 - 49];
    
    
    [self.view addSubview:p_scoreList.view];
    [self.view sendSubviewToBack:p_scoreList.view];
    
    p_scoreList.tableVC.tableView.tableHeaderView = p_sshVC.view;
    p_scoreList.tableVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _gradeCountLabel = p_sshVC.gradeCountLabel;

    self.isNeedHideTabBar = YES;
    self.isNeedBackBTN = YES;
    [self.view setBackgroundColor:ThemeBGColor_gray];
    [self p_setNavTitle];

    //first enter
    [self p_checkFirstEnter];
    //导航栏右按键
    CGRect frame = CGRectMake(35, 12, 20, 20);
    if (DEVICE_versionAfter7_0) {
        frame.origin.x = 90;
    }
    RIGHT_TITLE(frame, nil, nil, @"share", p_share);

    //图片可缩放观看
    self.photoScrollView.maximumZoomScale = 3.0;
    self.photoScrollView.minimumZoomScale = 1.0;
    self.photoScrollView.delegate = self;

    
    // MARK:大图
    [self.bigPhotoImageView setPost:self.scoreManager.postProfile.pic];
    [p_sshVC.showBigPostBtn addTarget:self action:@selector(showBigPost:) forControlEvents:UIControlEventTouchUpInside];
    self.bigPhotoImageView.onTouchTapBlock = ^(UIImageView *imageView)
    {
        float size = self.photoScrollView.zoomScale;
        if (size > 1) {
            [self.photoScrollView setZoomScale:1];
        }
        else
            [self hideBigPost];
    };

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 9999)
    {
        [self backToPreVC:nil];
        return;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(_isOmittedCheckPostDetail)
    {
        _isOmittedCheckPostDetail = NO;
        return;
    }
    // reload post detail
    [self.aview setCenter:CGPointMake(DEVICE_screenWidth/2, self.view.height/2)];
    [self startAview];
    PostProfile *postProfile = self.scoreManager.postProfile;
    NSNumber *postId = postProfile.postId;
    NSMutableDictionary *para = [@{@"id" : postId} mutableCopy];
    NSNumber *userId = [[MemberManager shareInstance]userProfile].userId;
    if(userId == nil)
        userId = @0;
    [para setObject:userId forKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic =  [self.netAccess passUrl:PostModule_detail andParaDic:para withMethod:PostModule_detail_method andRequestId:PostModule_detail_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            NSDictionary *result = resultDic[@"result"];
            if (!NETACCESS_Success)
            {
                
                POPUPINFO(@"获取照片详情失败，下拉下刷新吧");
//                [super viewWillAppear:animated];

                return;
            }
            else
            {
                NSDictionary *postGradeL = resultDic[@"grade"];
                
                if(postGradeL == nil && [postGradeL count] == 0 )//分数被删掉了
                {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"你对这张照片的打分被删掉了哦！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    alertView.delegate = self;
                    alertView.tag = 9999;
                    [alertView show];
                    return;
                    
                }
                else
                {
                    ///* 不更新也可以 更新数据更为真实
                    NSDictionary *picDic = resultDic[@"post"];
                    
                    ScoreManager *scoreManager = self.scoreManager;
                    
                    PostProfile *postProfile = scoreManager.postProfile;
                    postProfile.gradeCount = picDic[@"gradeCount"];
                    postProfile.adviceCount = picDic[@"adviceCount"];
                    postProfile.pic = STRING_judge( picDic[@"pic"]);
                    postProfile.comment = STRING_judge( picDic[@"comment"]);
                    postProfile.avgGrade = picDic[@"avgGrade"];
                    postProfile.title = STRING_judge( picDic[@"title"]);
                    postProfile.brand = STRING_judge( picDic[@"brand"]);
                    postProfile.texture = STRING_judge( picDic[@"texture"]);
                    postProfile.highlight = STRING_judge( picDic[@"highlight"]);
                    postProfile.buyUrl = STRING_judge( picDic[@"buyUrl"]);
                    postProfile.buyAddress = STRING_judge( picDic[@"buyAddress"]);
                    
                    
                    //赋值 postGrade
                    NSMutableDictionary *postGradeM = [postGradeL mutableCopy];
                    [postGradeM renameKey:@"id" withNewName:@"gradeId"];
                    GradeModel *postGrade = [GradeModel new];
                    [postGrade assignValue:postGradeM];
                    scoreManager.postGrade = postGrade;
                    
                    //赋值 postAdvice
                    NSMutableDictionary *postAdviceM = [resultDic[@"advice"] mutableCopy];
                    [postAdviceM renameKey:@"id" withNewName:@"adviceId"];
                    if(postAdviceM != nil)
                    {
                        AdviceModel *postAdvice = [AdviceModel new];
                        [postAdvice assignValue:postAdviceM];
                        scoreManager.postAdvice = postAdvice;
                    }
                    //更新表头
                    [p_sshVC assignValueForControls];
                     //*/
                    if (self.scoreManager.postAdvice == nil || self.scoreManager.postAdvice.adviceId ==nil)
                    {
                        [self.adviceBtn setTitle:@"给建议" forState:UIControlStateNormal];
                    }
                    else
                    {
                        [self.adviceBtn setTitle:@"查看建议" forState:UIControlStateNormal];
                    }
                    
                    [p_scoreList.tableVC beginPullDownRefreshing];
                    
//                    [p_scoreList.tableVC.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
//                    [super viewWillAppear:animated];
                }
                
            }

        });
    });

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showBigPost:(id)sender
{
    UIViewBeginAnimation(kDuration);
    [self.photoScrollView setAlpha:1];
    [self.bigPhotoImageView  setWidth:self.view.width];
    [self.bigPhotoImageView  setHeight:self.view.height];
    [self.bigPhotoImageView  setX:0];
    [self.bigPhotoImageView  setY:0];
    
    
    [UIView commitAnimations];
}
- (void)hideBigPost
{
    UIViewBeginAnimation(kDuration);
    [self.photoScrollView setAlpha:0];
    [self.bigPhotoImageView setFrame:p_sshVC.photoImageView.bounds];
    [UIView commitAnimations];
    
    
    [self.photoScrollView setZoomScale:1];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if(scrollView == self.photoScrollView)
        return self.bigPhotoImageView;
    else
        return nil;
}

#pragma mark - 用户交互
- (void)backToPreVC:(id)sender
{
    NSArray *arr = [self.navigationController viewControllers];
    int top = [arr count]-1;
    if ([arr[top -1] isKindOfClass:[ScoreVC class]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *	@brief	跳转至我的打分列表页面
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)watchScoreList:(id)sender
{
    MeCommentVC *vc = [[MeCommentVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
/**
 *	@brief	隐藏导航页
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)hideWizardView:(id)sender

{
    self.wizardView.hidden = YES;
    [self.wizardView removeFromSuperview];
}



/**
 *	@brief	headerView的代理方法 使用了respondsToSelector 弹出回复编辑框
 */
- (void)popAnalyzeLabel
{
    if(p_analyseFild == nil)
        p_analyseFild = [[BigFieldVC alloc]init];
    p_analyseFild.userDelegate = self;
    p_analyseFild.isMaskBG = YES;
    p_analyseFild.titlestr = @"分析";
    [self.view addSubview:p_analyseFild.view];
    p_analyseFild.textView.returnKeyType = UIReturnKeyDone;
    p_analyseFild.value = @"";
    [p_analyseFild show];

}
/**
 *	@brief	图片分析编辑完成 代理机制
 *
 *	@param 	value
 *	@param 	sender
 */
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender
{
    [self hideKeyBoard];
    
    ScoreManager *scoreManager = self.scoreManager;
    NSNumber *gradeId = scoreManager.postGrade.gradeId;
    NSNumber *userId  = [Coordinator userProfile].userId;
    NSNumber *postId  = scoreManager.postProfile.postId;
    NSNumber *grade   = scoreManager.postGrade.grade;
    NSNumber *colorGrade = scoreManager.postGrade.colorGrade;
    NSNumber *sizeGrade  = scoreManager.postGrade.sizeGrade;
    NSNumber *matchGrade = scoreManager.postGrade.matchGrade;
    
    NSDictionary *para = @{@"grade" : @{@"id" : gradeId, @"userId" : userId, @"postId" : postId, @"grade" : grade, @"colorGrade" : colorGrade, @"sizeGrade" : sizeGrade, @"matchGrade" : matchGrade, @"comment" : value}};
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:GradeModule_update andParaDic:para withMethod:GradeModule_update_method andRequestId:GradeModule_update_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                scoreManager.postGrade.comment = value;
                POPUPINFO(@"分析编辑成功！");
                NSMutableArray *listDataSource = p_scoreList.dataSource;
                int index = 0;
                for (GradeModel *aGrade in listDataSource) {
                    
                    if ([aGrade.gradeId isEqualToNumber:gradeId]) {
                        aGrade.comment = value;
                        break;
                    }
                    index++;
                }
                //[p_scoreList.tableVC startPullDownRefreshing];

//                [p_scoreList.tableVC.tableView  reloadData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [p_scoreList.tableVC.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            }
            else
            {
                POPUPINFO(@"分析编辑失败，请重新编辑");
            }
        });
    });
}

/**
 *	@brief	图片分析编辑取消
 *
 *	@param 	sender
 */
- (void)pickerCancelFrom:(id)sender
{
    [self hideKeyBoard];
}
/**
 *	@brief	跳转至给建议页面
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)giveSuggestion:(UIButton *)sender
{
    AdviceFromMeVC *vc = [[AdviceFromMeVC alloc]init];
    
    
    vc.gradeOrScormanager = self.scoreManager;
    
    // vc.VCOwnerId = STRING_fromInt( sender.tag);
    
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *	@brief	跳转至查看别人的建议页面
 *
 *	@param 	sender 	触发按钮 tag=1时为确定
 */
- (void)watchCellAdvice:(NSNumber *)index
{
    UIView *alertView = self.alertView;
    [self.view bringSubviewToFront:alertView];
    alertView.tag = [index intValue];
    
    GradeModel *grade = (GradeModel *)p_scoreList.dataSource[self.alertView.tag] ;
    AdviceModel *advice = grade.advice;
//    if (advice && advice.content && [advice.content length]>0  )
    if (advice && advice.adviceId  )
    {
        if([advice.isView boolValue] == NO)//未看过要扣分呀
        {
            UIViewBeginAnimation(kDuration);
            [alertView setAlpha:1];
            [UIView commitAnimations];
        }
        else
            [self gotoAdviceVC];
    }
    else
    {
        POPUPINFO(@"没有建议时，这里是禁止点的啊，怎么点进来的？");
    }
    
}

- (void)gotoAdviceVC
{
    AdviceFromOtherVC *adviceVC = [[AdviceFromOtherVC alloc]init];
    GradeModel *grade = (GradeModel *)p_scoreList.dataSource[self.alertView.tag];
    
    /*advice/detail
     userId: login user id,
     id: advice id
     */
    AdviceModel *advice = grade.advice;
    NSNumber *adviceId = advice.adviceId;
    if (nil == adviceId)
    {
        POPUPINFO(@"没有建议时，这里是禁止点的啊，怎么点进来的？");
        return;
    }
    NSNumber *userId = [Coordinator userProfile].userId;
    NSDictionary *para = @{@"userId": userId, @"id" : adviceId};
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:AdviceModule_detail andParaDic:para withMethod:AdviceModule_detail_method andRequestId:AdviceModule_detail_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                grade.advice.isView = @YES;//每次回来后刷新了列表，所以这晨不设，不刷则要设

                NSMutableDictionary *adviceDic = [resultDic[@"advice"] mutableCopy];
                [adviceDic renameKey:@"id" withNewName:@"adviceId"];
                [grade.advice assignValue:adviceDic];
                adviceVC.gradeOrScormanager = grade;
                [self.navigationController pushViewController:adviceVC animated:YES];
                
            }
            else
            {
                NSString *popMsg = [NSString stringWithFormat:@"建议详情获取失败，%@",resultDic[@"result"][@"msg"]];
                POPUPINFO(popMsg);
            }

        });
    });
}
- (IBAction)alertViewSelected:(UIButton *)sender {
    [self.alertView setAlpha:0];
    [self gotoAdviceVC];
}
- (IBAction)alertViewCancelled:(UIButton *)sender
{
    [self.alertView setAlpha:0];
}

#pragma mark 私有方法

/**
 *	@brief	检查首次进入
 */
- (void)p_checkFirstEnter
{
    FirstEnterTime *first = [FirstEnterTime shareInstance];
    [FirstEnterTime getUserDefault];
    if (first.isFirstEnterScoreSuccessPage && [first.isFirstEnterScoreSuccessPage boolValue]) {
        [APPDELEGATE.mainVC.view addSubview:self.wizardView];
        if(!DEVICE_versionAfter7_0)
        {
            self.wizardView.top = -20;
        }
        [self.wizardView setHeight:DEVICE_screenHeight];
        self.wizardView.hidden = NO;
        first.isFirstEnterScoreSuccessPage = @NO;
        [FirstEnterTime storeUserDeault];
        
    }
    else
    {
        self.wizardView.hidden = NO;
    }
}
/**
 *	@brief	设置标题
 */
- (void)p_setNavTitle
{
    [self setNavTitle:@"已打分"];
}
/**
 *	@brief	分享
 */
- (void)p_share
{
    //POPUPINFO(@"shareOut");
    
    NSString *shareContent = [NSString stringWithFormat:@"%@分，这照片我给打了%@分，你来看看会给几分？",self.scoreManager.postGrade.grade, self.scoreManager.postGrade.grade];
    ShareStruct shareStruct = {DaFenBaShareTypeGrade, [self.scoreManager.postGrade.gradeId intValue],1};
    
    [[ShareManager shareInstance]showShareListWithPhot:self.scoreManager.postProfile.pic andText:shareContent shareStruct:shareStruct fromVC:self];
}
@end
