//
//  PhotoScoreSuccessVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-11.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ScoreSuccessVC.h"
#import "AdviceVC.h"
#import "BigFieldVC.h"
#import "MeCommentVC.h"
#import "AdviceVC.h"
#import "MeHonorVC.h"
#import "ScoreCell.h"
#import "ScoreMoreReplyVC.h"
#import "BigFieldVC.h"

#import "PostProfile.h"

#import "GradeModel.h"
#import "AdviceModel.h"


@interface ScoreSuccessVC ()<pickerUserDelegate, ReplyCellUserDelegate>

@end

@implementation ScoreSuccessVC
{
    NSMutableArray *dataSource;
    BigFieldVC *replyEditVC;
    bool isStreched[500];//每个列表是否展开
    int count[500];//每个列表的子列表个数
    NSUInteger requestCount;//分页数
    NSUInteger p_maxPage;//最大页
    NSNumber *lastRefreshTime;
    
    int toAdviceIndex;
    BigFieldVC *analyseFild;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dataSource = [NSMutableArray arrayWithCapacity:0];
        self.hidesBottomBarWhenPushed = YES;
        requestCount = 1;
        p_maxPage = 8;
        lastRefreshTime = @0;
        
        for (int i=0; i<500; i++) {
            count[i] = arc4random()%6;
        }
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedHideTabBar = YES;
    self.postId = [self.scoreManager postProfile].postId;
    [super adaptIOSVersion:self.tableView];
    
    [self setNavTitle];
    
    [self.view setBackgroundColor:ThemeBGColor_gray];
    self.isNeedBackBTN = YES;
    // Do any additional setup after loading the view.
//    NSArray *arr = @[@{@"cellCount":@"ab"}, @{@"cellCount":@"ab", @"reply":@[@"1",@"2"]},@{@"cellCount":@"ab"}, @{@"cellCount":@"ab", @"reply":@[@"1",@"2"]}];
//    dataSource = [NSMutableArray arrayWithArray:arr];
    
    //x秒后恭喜获得1分贝消失
    [self getDecibel];
    //导航栏右按键
    CGRect frame = CGRectMake(80, 12, 20, 20);
    if (DEVICE_versionAfter7_0) {
        frame.origin.x = 90;
    }
    RIGHT_TITLE(frame, nil, nil, @"share", share);
    //first enter
    [self checkFirstEnter];
    [self loadDataSource];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    [super viewWillAppear:animated];
}
- (void)configSubViews
{
    [self.analyze setAlpha:0];
    NSString *analyzeStr = [self.scoreManager postGrade].comment;
    if (![STRING_judge(analyzeStr) isEqualToString:@""]) {
        self.analyze.text = analyzeStr;
    }

    [self assignPageValue];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [dataSource count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ScoreCellRich";
    ScoreCell *cell = (ScoreCell *)[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil][0];
    GradeModel *grade = dataSource[indexPath.row];
    [cell assignValue: grade];
    cell.delegate = self;
    cell.replyBtn.tag= indexPath.row;
    if (isStreched[indexPath.row]) {
        
        NSArray *para = [dataSource[indexPath.row] reply];
        [cell strechDown:para];
    }
    else
        [cell strechUp:nil];
   
    cell.replyBtn.tag = indexPath.row;
    [cell.replyBtn addTarget:self action:@selector(strechDown:) forControlEvents:UIControlEventTouchUpInside];
    cell.adviceBtn.tag = indexPath.row;
    [cell.adviceBtn addTarget:self action:@selector(watchAdvice:) forControlEvents:UIControlEventTouchUpInside];
//    if([cellIdentifier isEqualToString: @"ScoreCellRich"])
//        [cell.btn3 addTarget:self action:@selector(moreReply) forControlEvents:UIControlEventTouchUpInside];
//
   
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 接口服务器交互
/**
 *	@brief	加载数据
 */
- (void)loadDataSource

{
    if (requestCount > p_maxPage) {
        [self.loadMoreBtn setTitle:@"没有更多页了" forState:UIControlStateNormal];
        return;
    }
    /*Grade
     list: GET
     ** request: {userId: login user id, postId: post id, pageNo: 1} // if view post grades, give postId, response has no post, and user; else if only userId, it means view the user’s grades.
     ** response: {grades: [{id: grade id, postId: post id, grade: grade, colorGrade: color grade, sizeGrade: size grade, matchGrade: matching grade, styleGrade: style grade, comment: grade comment, createTime: grade create time, <post: {id: post id, pic: pic name, avgGrade: avg. grade},> <advice: {id: adviceId, content, createTime: advice time} // login user’s advice or advice:{id: grade user’s advice id, viewed: login user has viewed advice} // post’s advice> <user: {id: user id, name: user name, avatar: avatar pic url/name}>}, …], pager: {index: 1, size: 20, pageCount: page count. recordCount: record count}, result: {success: true, msg: error message}}
     
     */
    
    
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithCapacity:0];
    UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
    [para setValue:userProfile.userId forKey:@"userId"];
//    [para setValue:@47 forKey:@"userId"];
    [para setValue:self.postId forKey:@"postId"];
//    [para setValue:@85 forKey:@"postId"];
    NSMutableDictionary *childPara= [NSMutableDictionary dictionary];
    [childPara setValue:NUMBER(requestCount) forKey:@"pageNumber"];
    [childPara setObject:@20 forKey:@"pageSize"];
    [para setObject:childPara forKey:@"pager"];
    [para setObject:lastRefreshTime forKey:@"lastRefreshTime"];
    //[para setValue:[[MemberManager shareInstance]infoCenter][@"userId"] forKey:@"userId"];
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:GradeModule_listForPost andParaDic:para withMethod:GradeModule_listForPost_method andRequestId:GradeModule_listForPost_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
        });
        
        NSDictionary *result = resultDic[@"result"];
        if (NETACCESS_Success) {
            NSArray *originDSArr = resultDic[@"grades"];
            for (id aDic in originDSArr) {
                /*
                 [{"advice":{"isView":false},"grade":{"colorGrade":6,"comment":"","createTime":1412930878,"grade":6,"id":96,"matchGrade":6,"postId":76,"sizeGrade":6,"styleGrade":0},"rowsCount":4,"user":{"avatar":"avatar","id":"uid","name":"name"}}
                 */
                //NSMutableDictionary *aDataSourceElement = [NSMutableDictionary dictionary];//构造单条记录
                
                GradeModel *aGrade = [GradeModel new];
                NSMutableDictionary *gradeDic = [aDic[@"grade"] mutableCopy];
                if (gradeDic != nil && [gradeDic count] > 0)
                {
                    //grade
                    [gradeDic renameKey:@"id" withNewName:@"gradeId"];
                    [aGrade assignValue:gradeDic];
                    //user
                    NSMutableDictionary *userDic = [aDic[@"user"] mutableCopy];
                    if (userDic != nil && [userDic count] > 0)
                    {
                        UserProfile *user = [UserProfile new];
                        [userDic renameKey:@"id" withNewName:@"userId"];
                        [user assignValue:userDic];
                        aGrade.user = user;
                    }
                    //rowsContent
                    aGrade.rowsCount = aDic[@"rowsCount"];
                    //advice
                    NSMutableDictionary *adviceDic = [aDic[@"advice"] mutableCopy];
                    if (adviceDic != nil && [adviceDic count] > 0 && adviceDic[@"content"] != nil && [adviceDic[@"content"] length] > 0)
                    {
                        AdviceModel *advice = [AdviceModel new];
                        [adviceDic renameKey:@"id" withNewName:@"adviceId"];
                        [advice assignValue:adviceDic];
                        aGrade.advice = advice;
                    }

                    
                }
                if(dataSource == nil)
                    dataSource = [NSMutableArray array];
                [dataSource addObject:aGrade];
                

                
                
                /*
                 * list: GET
                 ** request: {userId: login user id, postId: post id, type: reply type, tgtId: target id // reply type target id (e.g. grade id, advice id), pageNo: 1}
                 ** response: {result: {success: true, msg: error message}, postReplies: [{id: reply id, postId: post id, content: reply content, srcUserId: source user id, srcName: source user name, tgtUserId: target user id, tgtName: target user name, type: reply type, gradeId: target grade id, adviceId: target advice id, replyId: target reply id, createTime: reply time}, ...], pager: {index: 1, size: 20, pageCount: page count. recordCount: record count}}
                 *///获取打分下的回复
//                UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
//                NSDictionary *para = @{@"userId":userProfile.userId, @"postId" : self.scoreManager.postProfile.postId, @"type" : @0, @"tgtId" : aGrade.gradeId};
//                NSDictionary *resultDic = [self.netAccess passUrl:ReplyModule_list andParaDic:para withMethod:ReplyModule_list_method andRequestId:ReplyModule_list_tag thenFilterKey:nil useSyn:YES dataForm:0];
//                NSDictionary *result = resultDic[@"result"];
//                if (NETACCESS_Success) {
//                    NSArray *postReplies = resultDic[@"postReplies"];
//                    aModel.reply = postReplies;
//                    
//                }
                
                
            }
            requestCount += 1;
            [self.tableView reloadData];
        }
        else
        {
            POPUPINFO(@"网络访问出错,"ACCESSFAILEDMESSAGE);
        }
    });
    
    
}
#pragma mark - 非页面跳转的用户交互
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
 *	@brief	分享
 */
- (void)share
{
    //POPUPINFO(@"shareOut");
    [[ShareManager shareInstance]showShareList:nil];
}
/**
 *	@brief	查看建议
 *
 *	@param 	sender 	触发按钮，触发前将按钮所在行数赋给TAG
 */
- (void)watchAdvice:(UIButton *)sender
{
    toAdviceIndex = sender.tag;
    self.alertView.tag = sender.tag;
    [self.alertView setHidden:NO];
}

/**
 *	@brief	展开回复列表
 *
 *	@param 	sender 	触发按钮
 */
- (void)strechDown:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    isStreched[indexPath.row] = !isStreched[indexPath.row];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
/**
 *	@brief	回复打分分析或别人的回复
 *
 *	@param 	info 	传入回复对象的用户ID，用户名
 */
- (void)replyMessage:(NSDictionary *)info
{
    //NSNumber *userId = info[@"userId"];
    NSString *userName = info[@"userName"];
    if (replyEditVC == nil) {
        replyEditVC = [[BigFieldVC alloc]init];
        replyEditVC.userDelegate = self;
        replyEditVC.isUseSmallLayout = YES;
        replyEditVC.isMaskBG = YES;
        
        
        [self addChildViewController:replyEditVC];
        [self.view addSubview:replyEditVC.view];
        
    }
    replyEditVC.value = @"";
    replyEditVC.placeHolderStr = STRING_joint(@"回复", userName);
    [replyEditVC show];
    
}
/**
 *	@brief	分析信息不为空时，予以显示/ 为空时弹出编辑框
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)popAnalyzeLabel:(id)sender {
    //分析信息不为空
    NSString *txt = [self.scoreManager postGrade].comment;
    if (txt && [txt length] > 0) {
        self.analyze.text = txt;
        UIViewBeginAnimation;
        [self.analyze setAlpha:1];
        [UIView commitAnimations];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fladeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewBeginAnimation;
            [self.analyze setAlpha:0];
            [UIView commitAnimations];
            
        });
        
    }
    //分析信息为空
    else
    {
        if(analyseFild == nil)
            analyseFild = [[BigFieldVC alloc]init];
        analyseFild.userDelegate = self;
        analyseFild.isMaskBG = YES;
        analyseFild.titlestr = @"分析";
        [self.view addSubview:analyseFild.view];
        analyseFild.textView.returnKeyType = UIReturnKeyDone;
        [analyseFild show];
    }
}
/**
 *	@brief	查看更多打分列表
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)loadMore:(id)sender
{
    [self loadDataSource];
}
#pragma mark - 页面跳转
/**
 *	@brief	跳转至给建议页面
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)giveSuggestion:(UIButton *)sender
{
    AdviceVC *vc = [[AdviceVC alloc]init];
    vc.postProfile = [self.scoreManager postProfile];
    vc.isSendOut = NO;
   // vc.VCOwnerId = STRING_fromInt( sender.tag);

    [self.navigationController pushViewController:vc animated:YES];
}
/**
 *	@brief	跳转至我的打分列表页面
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)scoreList:(id)sender
{
    MeCommentVC *vc = [[MeCommentVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
/**
 *	@brief	跳转至我的荣誉页面
 *
 *	@param 	sender 	触发按钮
 */
- (IBAction)watchMyDicibel:(id)sender {
    MeHonorVC *vc = [[MeHonorVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
/**
 *	@brief	跳转至查看建议页面
 *
 *	@param 	sender 	触发按钮 tag=1时为确定
 */
- (IBAction)alertViewSelected:(UIButton *)sender {
    [self.alertView setHidden:YES];
    if (sender.tag == 1) {
        AdviceVC *vc = [[AdviceVC alloc]init];
        vc.isSendOut = YES;
        UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
        vc.VCOwnerId = userProfile.userId;
        vc.photoIntroStr = self.photoIntroLabel.text;
        vc.postPhotoImage = self.photoImageView.image;
        NSDictionary *dic = (NSDictionary *)[dataSource[self.alertView.tag] advice];
        //alertView的tag值为查看建议对象所在数据源的序号
        vc.userNamestr = [dataSource[self.alertView.tag]userName];
        vc.userAvatarUrl = [dataSource[self.alertView.tag]avartar];
        if (dic) {
            vc.buyAddressStr = dic[@"buyAddress"];
            vc.buyUrlStr = dic[@"buyUrl"];
            vc.adviceContent = dic[@"content"];
            
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}



/**
 *	@brief	拾取完成 代理机制
 *
 *	@param 	value
 *	@param 	sender
 */
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender
{
}

/**
 *	@brief	拾取取消
 *
 *	@param 	sender 	<#sender description#>
 */
- (void)pickerCancelFrom:(id)sender
{
    [self hideKeyBoard];
}
#pragma mark - 封装变化？
- (void)setNavTitle
{
    [self setNavTitle:@"已打分"];
}
- (void)getDecibel
{
    if(_isOmittedScore)
        return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fladeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewBeginAnimation;
        [self.scoreFinishView setAlpha:0];
        [UIView commitAnimations];
    });
}
- (void)checkFirstEnter
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
- (void) assignPageValue
{
    ScoreManager *scoreManager = self.scoreManager;
    PostProfile *postProfile = scoreManager.postProfile;
    GradeModel *postGrade = scoreManager.postGrade;
    [self.photoImageView setPost:postProfile.pic];
    self.scoreCount.text = STRING_fromId( postProfile.gradeCount);
    self.meScoreMatch.text = STRING_fromId( postGrade.matchGrade);
    self.meScoreSize.text = STRING_fromId( postGrade.sizeGrade);
    self.meScoreColor.text = STRING_fromId( postGrade.colorGrade);
    self.meScoreGross.text = STRING_fromId( postGrade.grade);
    self.avgScore.text = [NSString stringWithFormat:@"%.1f", [postProfile.avgGrade floatValue]];
    
    
    [self.avatarImageView setAvartar:postProfile.user.avatar];
    //self.avatarImageView.image = [UIImage imageNamed: postProfile.user.avatar];
    self.userNameLabel.text = postProfile.user.name;
    self.photoIntroLabel.text = postProfile.comment;
}

@end
