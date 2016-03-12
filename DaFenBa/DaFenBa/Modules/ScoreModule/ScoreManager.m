//
//  ScoreModule.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-19.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ScoreManager.h"
#import "ScoreVC.h"
#import "ScoreSuccessVC.h"
#import "MePhotoDetailVC.h"
#import "HPieChartView.h"
#import "GradeModel.h"
#import "AdviceModel.h"
#import "PostProfile.h"


@implementation ScoreManager
{
    UIButton *scoringBtn;
    UIView *scoreWrapView;
    UIButton *hideBtn;
    HPieChartView *pieview;
    int _value;
}

+ (id)shareInstance
{
    static dispatch_once_t once;
    Class class = [self class];
    static id instance;
    dispatch_once(&once, ^{
        instance = [[class alloc]init];
    });
    return instance;
}

//- (void) resetAll
//{
//    self.postAdvice = nil;
//    self.postGrade = nil;
//}

+ (ScoreManager *)scoreManagerFromPostProfile:(PostProfile *)post;
{
    NSNumber *postId = post.postId;
    
    NSMutableDictionary *para = [@{@"id" : postId} mutableCopy];
    
    NSNumber *userId = [[MemberManager shareInstance]userProfile].userId;
    if(userId == nil)
        userId = @0;
    [para setObject:userId forKey:@"userId"];
    NSDictionary *dic =  [[NetAccess new] passUrl:PostModule_detail andParaDic:para withMethod:PostModule_detail_method andRequestId:PostModule_detail_tag thenFilterKey:nil useSyn:YES dataForm:7];
    NSDictionary *result = dic[@"result"];
    if (!NETACCESS_Success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            POPUPINFO(@"获取照片详情失败");

        });
        return nil;
    }
    else
    {
        NSDictionary *picDic = dic[@"post"];
        
        ScoreManager *scoreManager = [ScoreManager new];
        //postProfile
        PostProfile *postProfile = post;
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
        //post.user
        NSMutableDictionary *postUserM = [dic[@"user"] mutableCopy];
        [postUserM renameKey:@"id" withNewName:@"userId"];
        UserProfile *postUser = [UserProfile new];
        [postUser assignValue:postUserM];
        postProfile.user = postUser;

        
        scoreManager.postProfile = postProfile;
        NSDictionary *postGradeL = dic[@"grade"];
        
        //基于已登录的前提下
        if(postGradeL != nil && [postGradeL count] > 0 )//已打过分
        {
            //赋值 postGrade
            NSMutableDictionary *postGradeM = [postGradeL mutableCopy];
            [postGradeM renameKey:@"id" withNewName:@"gradeId"];
            GradeModel *postGrade = [GradeModel new];
            [postGrade assignValue:postGradeM];
            scoreManager.postGrade = postGrade;
            
            //赋值 postAdvice
            NSMutableDictionary *postAdviceM = [dic[@"advice"] mutableCopy];
            [postAdviceM renameKey:@"id" withNewName:@"adviceId"];
            if(postAdviceM != nil)
            {
                AdviceModel *postAdvice = [AdviceModel new];
                [postAdvice assignValue:postAdviceM];
                scoreManager.postAdvice = postAdvice;
            }
        }
        return scoreManager;
    }
}
/**
 *	@brief	弹出打分页
 *
 *	@param 	paras 	该张照片的相关信息
 *	@param 	startVC 	触发该界面的视图控制器
 */
+ (void)evokeScoreWithPostOrScoreManager:(id)postProfileOrScorManager FromVC:(BaseVC *)startVC
{
    if (postProfileOrScorManager == nil) {
        return;
    }
    else if ([postProfileOrScorManager isKindOfClass:[PostProfile class]])
    {
        BaseVC *toVC;
        PostProfile *postProfile = (PostProfile *)postProfileOrScorManager;
        if (postProfile.postId == nil) {
            POPUPINFO(@"传入的照片没有持有者或者没有postId");
            return;
        }
        
        UserProfile *userProfilePost = postProfile.user;
        UserProfile *userLogin = [Coordinator userProfile];
        //默认跳scoreVC
        ScoreManager *scoreManager = [ScoreManager new];
        toVC = [[ScoreVC alloc]init];
        scoreManager.postProfile = postProfile;
        ((ScoreVC *)toVC).scoreManager = scoreManager;
        
        if(userLogin == nil )//未登录 跳打分页
            [startVC.navigationController pushViewController:toVC animated:YES];
        else if (postProfile.user == nil || postProfile.user.userId == nil) {//post没user 查
            [startVC startAview];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ScoreManager *scoreManager = [self scoreManagerFromPostProfile:postProfile];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [startVC stopAview];
                    [self evokeScoreWithPostOrScoreManager:scoreManager.postProfile FromVC:startVC];
                });
            });
            return;
        }

        else if ([userProfilePost.userId isEqualToNumber: userLogin.userId]) {//该照片是自己发布的
            MePhotoDetailVC *mePhotoDetailVC = [MePhotoDetailVC new];
            mePhotoDetailVC.postProfile = postProfile;
            toVC = mePhotoDetailVC;
            [startVC.navigationController pushViewController:toVC animated:YES];

        }
        else//判断是否已打过分 将赋值照片细节
        {
            [startVC startAview];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ScoreManager *scoreManager = [self scoreManagerFromPostProfile:postProfile];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [startVC stopAview];
                    if (scoreManager == nil || scoreManager.postGrade == nil)
                        [startVC.navigationController pushViewController:toVC animated:YES];
                    else
                        [self evokeScoreWithPostOrScoreManager:scoreManager FromVC:startVC];
                });
            });
        }
/*   上翻下翻的处理， 应在实例方法中实现 以记录 翻转方向 下版本可参考
        if(!self.isToPre)//下翻
            [startVC.navigationController pushViewController:detailPhoto animated:YES];
        else//回翻
        {
            //动画
            self.isToPre = NO;
            CATransition *animation = [CATransition animation];
            [animation setDuration:0.3];
            [animation setType: kCATransitionMoveIn];
            [animation setSubtype: kCATransitionFromLeft];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [startVC.navigationController pushViewController:detailPhoto animated:NO];
            [startVC.navigationController.view.layer addAnimation:animation forKey:nil];
        }
 */

    }
    else if([postProfileOrScorManager isKindOfClass:[ScoreManager class]])
    {
        ScoreSuccessVC *scoreSuccessVC = [ScoreSuccessVC new];
        scoreSuccessVC.scoreManager = (ScoreManager *)postProfileOrScorManager;
        scoreSuccessVC.isOmittedScore = YES;
        [startVC.navigationController pushViewController:scoreSuccessVC animated:YES];
    }
    
}

/**
 *	@brief	提交打分结果
 *
 *	@param 	submitVC 	触发该行为的VC
 */

- (void)submitScore:(BaseVC *)submitVC

{
 
    [submitVC startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *grade = [NSMutableDictionary dictionary];
        [grade setValue:[Coordinator userProfile].userId forKey:@"userId"];
        [grade setValue:_postProfile.postId forKey:@"postId"];
        [grade setValue:_postGrade.grade forKey:@"grade"];
        [grade setValue:_postGrade.colorGrade forKey:@"colorGrade"];
        [grade setValue:_postGrade.sizeGrade forKey:@"sizeGrade"];
        [grade setValue:_postGrade.matchGrade forKey:@"matchGrade"];
        [grade setValue:_postGrade.comment forKey:@"comment"];
        
        NSDictionary *para = @{@"grade" :grade};

        NetAccess *netAccess = [NetAccess new];
        NSDictionary *dic = [netAccess passUrl:GradeModule_add andParaDic:para withMethod:GradeModule_add_method andRequestId:GradeModule_add_tag thenFilterKey:nil useSyn:YES dataForm:7];
        NSDictionary *result = dic[@"result"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [submitVC stopAview];
            if (NETACCESS_Success) {
                UserProfile *userProfile = [Coordinator userProfile];
                if(userProfile.extInfo[@"gradeCount"])
                {
                    int oldCount = [userProfile.extInfo[@"gradeCount"] intValue];
                    [userProfile.extInfo setValue:NUMBER(oldCount + 1) forKey:@"gradeCount"];
                }
                self.postProfile.avgGrade = dic[@"post"][@"avgGrade"];
                self.postProfile.gradeCount = dic[@"post"][@"gradeCount"];
                UINavigationController *nav = submitVC.navigationController;
                [nav popViewControllerAnimated:NO];
                ScoreSuccessVC *successVC = [[ScoreSuccessVC alloc]init];
                
                successVC.scoreManager = self;
                [nav pushViewController:successVC animated:YES];

            }
            else{
                self.postGrade = nil;
                POPUPINFO(@"评分提交失败,"ACCESSFAILEDMESSAGE);
            }

        });
    });
    
}

#pragma mark - 绘制并弹出/隐藏油量表打分界面
/**
 *	@brief	点击三维打分按钮弹出油量表打分界面
 *
 *	@param 	sender 	触发按钮
 *	@param 	value 	设置油量表打分界面的初始值
 */
- (void) popOutScoreView:(UIButton *)sender withValue:(int)value

{
    _value = value;
    MainVC *mainVC = APPDELEGATE.mainVC;
    UINavigationController *nav = (UINavigationController *)mainVC.selectedViewController;
    ScoreVC *vc = (ScoreVC *)nav.topViewController;//能使用该打分按钮，只能是ScoreVC，所以以此方法找到scorevc
    sender.top -= vc.scrollView.contentOffset.y;//按钮纵坐标减去滚动不可见区
    float width = 115;//打分响应区的宽度
    float deltaRad = M_PI/15;//左半区略去的0-10分值外的弧度
    int tag = sender.tag;
    //隐藏按钮
    [self drawHideBtn];
    //三维打分的按钮
    [self drawScoringBtn:sender];
    //打分区容器
    [self drawScoreWrapView:width];
    //打分拨针功能区
    [self drawPieView:deltaRad width:width value:value tag:tag];
    //将打分按钮调到最前面
    [mainVC.view bringSubviewToFront:scoringBtn];
    
   
}
/**
 *	@brief	隐藏油量表打分界面
 *
 *	@param 	sender 	隐藏按钮
 */
- (void)hideAll:(UIButton *)sender
{
    MainVC *mainVC = APPDELEGATE.mainVC;
    UINavigationController *nav = (UINavigationController *)mainVC.selectedViewController;
    ScoreVC *vc = (ScoreVC *)nav.topViewController;
    //将打分按钮置回打分页
    [self clearScoringBtn:vc];
    //将打分功能区容器清除，附带其管理的子视图也被清除
    [self clearScoreWrapView];
    //清除隐藏按钮
    [self clearHideBtn];
    //将结果传回
//    NSString *valueStr = STRING_fromInt(pieview.chart.value);
//    [vc scoreValueChange:sender withValue:valueStr];
}

/**
 *	@brief	添加隐藏功能按钮
 */
- (void)drawHideBtn
{
    //点击背景隐藏油量表打分界面
    hideBtn = [[UIButton alloc]initWithFrame:CGRectMake(-20, -20, 600, 600)];
    hideBtn.alpha = 0.7;
    hideBtn.backgroundColor = [UIColor blackColor];
    [hideBtn addTarget:self action:@selector(hideAll:) forControlEvents:UIControlEventTouchUpInside];
    [APPDELEGATE.mainVC.view addSubview:hideBtn];
}
/**
 *	@brief	将当前三维打分按钮添至屏幕顶层
 *
 *	@param 	sender 	触发按钮
 */
- (void)drawScoringBtn:(UIButton *)sender
{
    scoringBtn = sender;
    scoringBtn.top += 64;
    int index = sender.tag - 101;
    NSArray *btnBgs = @[@"finishDaPei", @"finishSize", @"finishColor"];
    [scoringBtn setImage:nil forState:UIControlStateNormal];
    [scoringBtn setBackgroundImage:[UIImage imageNamed:btnBgs[index]] forState:UIControlStateNormal];
    [scoringBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [scoringBtn setTitle:STRING_fromInt(_value) forState:UIControlStateNormal];
    [scoringBtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
    [scoringBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 15, 22)];
    scoringBtn.userInteractionEnabled = NO;
    [APPDELEGATE.mainVC.view addSubview:scoringBtn];
}

/**
 *	@brief	绘制打分功能区的容器View
 *
 *	@param 	width 	该容器的宽度
 */
- (void)drawScoreWrapView:(float)width

{
    if (scoreWrapView && [scoreWrapView superview] ) {
        [scoreWrapView removeFromSuperview];
    }
    CGPoint center = scoringBtn.center;
    scoreWrapView = [[UIView alloc]initWithFrame:CGRectMake(center.x - width, center.y - width , width, width*2)];
    scoreWrapView.clipsToBounds = YES;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(scoreWrapView.frame.size.width - 80, scoreWrapView.frame.size.height/2 - 160/2 , 80, 160)];
    [imageView setImage:[UIImage imageNamed:@"PieBG"]]; //打分油量表的背景图
    [scoreWrapView addSubview:imageView];
    [APPDELEGATE.mainVC.view addSubview:scoreWrapView];
}

/**
 *	@brief	绘制打分界面的主功能区
 *
 *	@param 	deltaRad 	按钮纵坐标减去滚动不可见区
 *	@param 	width 	打分响应区的宽度
 *	@param 	value 	初始设置值
 *	@param 	tag 	触发按钮的TAG值，决定颜色主题
 */
- (void)drawPieView:(float)deltaRad width:(float)width value:(int)value tag:(int)tag
{
    if (pieview && [pieview superview] ) {
        [pieview removeFromSuperview];
    }
    pieview = [[HPieChartView alloc] initWithFrame:CGRectMake(0, 0, width*2, width*2)  withNum:1 withArray:[NSMutableArray arrayWithArray:@[@"1.0"]] startRad:-M_PI/2 +deltaRad endRad:M_PI/2 - deltaRad];//打分功能扫行区
    [scoreWrapView addSubview:pieview];
    pieview.pinDelegate = self;
    [pieview setPinValue:value];
    //根据点击按钮的不同，设置不同的指针，蒙板颜色
    NSArray *shadowImageNames = @[@"shadowyellow", @"shadowdeepblue", @"shadowblue"];
    NSArray *pinImageNames = @[@"pinyellow", @"pindeepblue", @"pinblue"];
    NSArray *colorThemes = @[ColorRGB(241.0, 195.0, 61.0),ColorRGB(77.0, 78.0, 193.0),ColorRGB(47.0, 151.0, 220.0)];
    int index = tag - 101;
    if(index < 0 || index >= [shadowImageNames count])
        return;
    [pieview.chart setShadowImage:shadowImageNames[index]];
    [pieview.chart setPinImage:pinImageNames[index]];
    pieview.chart.color = colorThemes[index];
}
/**
 *	@brief	清除三维打分按钮，并将其置回打分页面
 *
 *	@param 	vc 	打分页面
 */
- (void)clearScoringBtn:(ScoreVC *)vc
{
    scoringBtn.top += vc.scrollView.contentOffset.y;
    [vc.scrollView addSubview:scoringBtn];
    scoringBtn.userInteractionEnabled = YES;
    scoringBtn.top -= 64;
    scoringBtn = nil;
}

/**
 *	@brief	清除打分功能容器
 */
- (void)clearScoreWrapView

{
    if (scoreWrapView && [scoreWrapView superview]) {
        [scoreWrapView removeFromSuperview];
        scoreWrapView = nil;
    }
}

/**
 *	@brief	清除隐藏按钮
 */
- (void)clearHideBtn

{
    if (hideBtn && [hideBtn superview]) {
        [hideBtn removeFromSuperview];
        hideBtn = nil;
    }
}



#pragma mark - PieChartDelegate
- (void)pinTouchProcessingWithValue:(float)value
{
    MainVC *mainVC = APPDELEGATE.mainVC;
    UINavigationController *nav = (UINavigationController *)mainVC.selectedViewController;
    ScoreVC *vc = (ScoreVC *)nav.topViewController;
    if(![vc isKindOfClass:[ScoreVC class]])return;
    NSString *valueStr = STRING_fromInt((int)round(value/10));
    [scoringBtn setTitle:valueStr forState:UIControlStateNormal];
    [vc scoreValueChange:scoringBtn withValue:valueStr];
    
}
-(void)pinTouchEndWithValue:(float)value
{
    
}


@end
