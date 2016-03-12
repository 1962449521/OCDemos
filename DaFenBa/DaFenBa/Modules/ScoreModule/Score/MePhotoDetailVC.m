//
//  MePhotoDetailVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-10-17.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "MePhotoDetailVC.h"
#import "MePhotoVC.h"
#import "PostProfile.h"
#import "GradeModel.h"
#import "AdviceModel.h"
#import "XHPullRefreshTableViewController.h"
#import "ScoreCellForMePhoto.h"
#import "ScoreVC.h"
#import "AdviceVC.h"
#import "ScoreMoreReplyVC.h"
#import "BigFieldVC.h"

#import "UserProfile.h"

#import "ReplyModel.h"

#import "AdviceFromOtherVC.h"
#import "InviteVC.h"
#import "UIImageView+LK.h"
#import "HomePageVC.h"


#define maxSupportRowCount 2000//支持的最大行数

@interface MePhotoDetailVC ()<pickerUserDelegate, ReplyCellUserDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation MePhotoDetailVC
{

    XHPullRefreshTableViewController *tableVC;
    UIView *loadView;
    NSNumber *lastRefreshTime;
    int p_maxPage;
    NSMutableArray *dataSource;
    
    BigFieldVC *replyEditVC;
    BOOL isStreched_;
    bool isStreched[maxSupportRowCount];     // 每个列表是否展开
    
    id p_tempReplyTgt; // 将要回复的grade对象 或 reply对象
    

}
@synthesize postProfile;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        lastRefreshTime = @0;
        p_maxPage = 8;
        dataSource = [NSMutableArray array];
        self.userDelegate = self;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN = YES;
    [self setNavTitle:@"我的图片"];
    self.isNeedHideTabBar = YES;
    CGRect frame = CGRectMake(35, 10, 20, 20);

    RIGHT_TITLE(frame, nil, nil, @"share", sharePhoto);

    [self.view setBackgroundColor:ThemeBGColor_gray];
    [self.bg1 setImage:areaBgImage];
//    [self.bg2 setImage:areaBgImage forState:UIControlStateNormal];
    tableVC = [[XHPullRefreshTableViewController alloc]init];
    tableVC.refreshControlDelegate = tableVC;
    tableVC.tableView.delegate = self;
    tableVC.tableView.dataSource = self;
    tableVC.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableVC.tableView];
    tableVC.tableView.tableHeaderView = self.headerView;
    [tableVC.tableView setHeight:DEVICE_screenHeight - 64 - 60];
    
    if (tableVC.pullDownRefreshed) {
        [tableVC setupRefreshControl];
    }
    loadView = tableVC.refreshControl.loadMoreView;
    [self.view addSubview:loadView];
    [loadView setTop:DEVICE_screenHeight - 64 - 60 - loadView.height];

    
        if (postProfile.pic
        && postProfile.adviceCount
        && postProfile.gradeCount
        && postProfile.avgGrade
        && postProfile.title
        && postProfile.brand
        && postProfile.texture
        && postProfile.highlight) {
        [self p_assignValueForControls];
        return;
    }

    
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //同步方法获取照片详情
        NSDictionary *dic = [self p_getPostDetailUseSyn:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            [self p_handleNetAccessPostDetailDic:dic];
        });
    });
    
    //图片可缩放观看
    self.photoScrollView.maximumZoomScale = 3.0;
    self.photoScrollView.minimumZoomScale = 1.0;
    self.photoScrollView.delegate = self;

    self.photoImageView.onTouchTapBlock = ^(UIImageView *imageView)
    {
        [self showBigPost:nil];
    };
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_isOmittedCheckPostDetail)
    {
        _isOmittedCheckPostDetail = NO;
        return;
    }
    [tableVC beginPullDownRefreshing];
    
}
-(IBAction)switchStrech:(id)sender
{
//    UIViewBeginAnimation(kDuration);
    UIView *view = tableVC.tableView.tableHeaderView;
    tableVC.tableView.tableHeaderView = nil;
    if (!isStreched_) {
        self.strechIcon.transform = CGAffineTransformMakeRotation(- M_PI);
        isStreched_ = YES;
        [self.postDetailView setHeight:214];
        [self.gradeCountWrapView setTop:self.postDetailView.bottom + 5];
        [view setHeight:self.gradeCountWrapView.bottom];
    }
    else
    {
        self.strechIcon.transform = CGAffineTransformIdentity;
        isStreched_ = NO;
        [self.postDetailView setHeight:30.0];
        [self.gradeCountWrapView setTop:self.postDetailView.bottom + 5];
        [view setHeight:self.gradeCountWrapView.bottom];
    }
    tableVC.tableView.tableHeaderView = view;
    CGRect rect = self.gradeCountWrapView.frame;
    [tableVC.tableView scrollRectToVisible:rect animated:YES];

//    [UIView commitAnimations];
}
- (void)backToPreVC:(id)sender
{
    NSArray *arr = [self.navigationController viewControllers];
    int top = [arr count]-1;
    if ([arr[top -1] isKindOfClass:[ScoreVC class]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *	@brief	给控件赋值
 */
- (void) p_assignValueForControls
{
    
    self.photoImageView.onLoadCompletedBlock = ^(UIImage *image)
    {
        CGSize size = image.size;
        float newHeight = self.photoImageView.width * size.height / size.width;
        if (newHeight < self.photoImageView.height) {//只变小不变大
            float top = self.photoWrapView.top;
            [self.photoImageView setHeight:newHeight];
            [self.photoWrapView setHeight:newHeight];
            [self.photoWrapView setClipsToBounds:YES];
            [self.photoWrapView setTop:top];
            float startY =  self.photoWrapView.bottom + 20.0;
            [self.photoIntroLabel setTop:startY];
            [self.avatarImageView setTop:startY];
            [self.userNameLabel setTop:self.avatarImageView.bottom + 5];
            
            [self.postDetailView setTop:self.photoIntroLabel.bottom +5];
            
            [self.postDetailView setHeight:30.0];
        
            [self.gradeCountWrapView setTop:self.postDetailView.bottom + 5];
            [self.headerView setHeight:self.gradeCountWrapView.bottom];
            tableVC.tableView.tableHeaderView = nil;
            tableVC.tableView.tableHeaderView = self.headerView;
            
        }
    };
    [self.photoImageView setPost:postProfile.pic];
    [self.bigPhotoImageView setPost:postProfile.pic];

    self.scoreCount.text = STRING_fromId( postProfile.gradeCount);
    self.adviceCount.text = STRING_fromId( postProfile.adviceCount);
    if ([postProfile.avgGrade floatValue] >= 10)
        [self.avgScore setText:[NSString stringWithFormat:@"%d", [postProfile.avgGrade intValue]]];
    else
        self.avgScore.text = [NSString stringWithFormat:@"%.1f", [postProfile.avgGrade floatValue]];
    
    [self.avatarImageView setAvartar:[Coordinator userProfile].avatar];
    self.avatarImageView.onTouchTapBlock = ^(UIImageView *imageView){
        [HomePageVC enterHomePageOfUser:[Coordinator userProfile] fromVC:self];
    };
    self.userNameLabel.text = [Coordinator userProfile].srcName;
    self.photoIntroLabel.text = postProfile.comment;
    [self.photoIntroLabel setWidth:232];
    [self.photoIntroLabel sizeToFit];
    if (self.photoIntroLabel.height > 67) {
        [self.postDetailView setTop:self.photoIntroLabel.bottom +5];
    }
    self.titleLabel.text = postProfile.title;
    self.brandLabel.text = postProfile.brand;
    self.textureLabel.text = postProfile.texture;
    self.highlightLabel.text = postProfile.highlight;
    [self.postDetailView setHeight:30.0];
    
    [self.gradeCountWrapView setTop:self.postDetailView.bottom + 5];
    [self.headerView setHeight:self.gradeCountWrapView.bottom];

}
- (id)p_getPostDetailUseSyn:(BOOL)isSyn
{
    NSNumber *postId = postProfile.postId;
    
    NSMutableDictionary *para = [@{@"id" : postId} mutableCopy];
    
    NSNumber *userId = [[MemberManager shareInstance]userProfile].userId;
    if(userId == nil)
        userId = @0;
    [para setObject:userId forKey:@"userId"];
    
    return [self.netAccess passUrl:PostModule_detail andParaDic:para withMethod:PostModule_detail_method andRequestId:PostModule_detail_tag thenFilterKey:nil useSyn:isSyn dataForm:7];
    
}
- (void) p_handleNetAccessPostDetailDic:(NSDictionary *)dic
{
    NSDictionary *result = dic[@"result"];
    if (!NETACCESS_Success)
    {
        POPUPINFO(@"获取照片详情失败");
        return;
    }
    else
    {
        NSDictionary *picDic = dic[@"post"];

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
        
        [self p_assignValueForControls];
        
        
    }
}

#pragma mark - 查看大图
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
    [self.bigPhotoImageView setFrame:self.photoImageView.bounds];
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

- (void) sharePhoto
{

    NSString *shareContent = @"亲，帮我看看这身打扮有几分呗？";
    ShareStruct shareStruct = {DaFenBaShareTypePost, [self.postProfile.postId intValue],2};
    [[ShareManager shareInstance]showShareListWithPhot:self.postProfile.pic andText:shareContent shareStruct: shareStruct fromVC:self];
}


/**
 *	@brief	加载数据
 */
- (void)loadDataSource

{
    if (tableVC.requestCurrentPage == 0 && p_maxPage == 0) {
        p_maxPage = 30000;
    }

    if (tableVC.requestCurrentPage + 1 > p_maxPage) {
        [tableVC endMoreOverWithMessage:@"没有更多页了"];
        return;
    }
    // request para
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithCapacity:0];
    UserProfile *userProfile = [[MemberManager shareInstance]userProfile];
    [para setValue:userProfile.userId forKey:@"userId"];
    
    [para setValue:postProfile.postId forKey:@"postId"];
    
    NSMutableDictionary *childPara= [NSMutableDictionary dictionary];
    [childPara setValue:NUMBER(tableVC.requestCurrentPage + 1) forKey:@"pageNumber"];
    [childPara setObject:@20 forKey:@"pageSize"];
    [para setObject:childPara forKey:@"pager"];
    [para setObject:lastRefreshTime forKey:@"lastRefreshTime"];
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:GradeModule_listForPost andParaDic:para withMethod:GradeModule_listForPost_method andRequestId:GradeModule_listForPost_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.userDelegate stopAview];
            [tableVC revokeHsRefresh];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                if(resultDic[@"lastRefreshTime"] != nil)
                {
                    lastRefreshTime = resultDic[@"lastRefreshTime"];
                    if(resultDic[@"pager"][@"pageCount"] != nil)
                        p_maxPage = [resultDic[@"pager"][@"pageCount"] intValue];
                    
                    
                    self.gradeCountLabel.text = [NSString stringWithFormat:@"所有打分(%d)", [resultDic[@"pager"][@"recordCount"] intValue]];
                    
                }
                
                NSArray *originDSArr = resultDic[@"grades"];
                NSMutableArray *newDataSource = [NSMutableArray array];
                for (id aDic in originDSArr) {
                    
                    
                    GradeModel *aGrade = [GradeModel new];
                    NSMutableDictionary *gradeDic = [aDic[@"grade"] mutableCopy];
                    if (gradeDic != nil && [gradeDic count] > 0)
                    {
                        //post 是否需要创建新的？
                        //                        PostProfile *post = [PostProfile new];
                        //                        NSDictionary *postDic = [self.scoreManager.postProfile dictionary];
                        //                        [post assignValue:postDic];
                        aGrade.post = postProfile;
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
                        //rowsContent ？这个用来做什么 没用！！！
                        //aGrade.rowsCount = aDic[@"rowsCount"];
                        aGrade.repliesCount = aDic[@"grade"][@"replyCount"];
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
                    [newDataSource addObject:aGrade];
                    
                    
                    
                    
                }
                if(tableVC.requestCurrentPage == 0)
                    dataSource = newDataSource;
                else
                    [dataSource addObjectsFromArray:newDataSource];
                
                [tableVC.tableView reloadData];
            }
            else
            {
                [tableVC revokeHsLoadMore];
                POPUPINFO(@"网络访问出错,"ACCESSFAILEDMESSAGE);
            }
        });
    });
    
    
}
#pragma mark - 非页面跳转的用户交互
- (void)shareGrade:(UIButton *)sender
{
    GradeModel *grade = dataSource[sender.tag];
    NSString *text = [NSString stringWithFormat:@"%@分，我这照片被人打了%@分，你来看看有几分呗？",grade.grade, grade.grade];
    ShareStruct shareStruct = {DaFenBaShareTypeGrade, [grade.gradeId intValue],0};
    
    [[ShareManager shareInstance]showShareListWithPhot:grade.post.pic andText:text shareStruct:shareStruct fromVC:self];
}
- (IBAction)InviteComment:(UIButton *)sender {
    InviteType type[] = {TypeInviteScore,TypeInviteAdvice};
    InviteVC *inviteVC = [[InviteVC alloc]init];
    inviteVC.type = type[sender.tag];
    inviteVC.postId = self.postProfile.postId;
    //inviteVC.isHaveSearchBar = YES;
    [self.navigationController pushViewController:inviteVC animated:YES];
}

/**
 *	@brief	查看建议
 *
 *	@param 	sender 	触发按钮，触发前将按钮所在行数赋给TAG
 */
- (void)watchAdvice:(UIButton *)sender
{
    int index = sender.tag;
    UIView *alertView = self.alertView;
    [self.view bringSubviewToFront:alertView];
    alertView.tag = index;
    
    GradeModel *grade = (GradeModel *)dataSource[index] ;
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
    {//邀请建议
        NSNumber *userId = [Coordinator userProfile].userId;
        NSDictionary *para = @{@"userId" : userId , @"userIds" : @[grade.user.userId], @"postId" : self.postProfile.postId};
        [self startAview];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary *resultDic = [self.netAccess passUrl:AdviceModule_invite andParaDic:para withMethod:AdviceModule_invite_method andRequestId:AdviceModule_invite_tag thenFilterKey:nil useSyn:YES dataForm:7];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAview];
                NSDictionary *result = resultDic[@"result"];
                if (NETACCESS_Success) {
                    POPUPINFO(@"邀请发送成功，将扣除相应的分贝。");
                }
                else
                {
                    NSString *str = [NSString stringWithFormat:@"邀请发送失败，%@",result[@"msg"]];
                    POPUPINFO(str);

                }
            });
        });
        
    }
    

}

- (void)gotoAdviceVC
{
    AdviceFromOtherVC *adviceVC = [[AdviceFromOtherVC alloc]init];
    GradeModel *grade = (GradeModel *)dataSource[self.alertView.tag];
    
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
                grade.advice.isView = @YES;//每次回来刷新了列表，不刷则要设
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

/**
 *	@brief	展开回复列表
 *
 *	@param 	sender 	触发按钮
 */
- (void)strechDown:(UIButton *)sender
{
    NSUInteger index = sender.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    GradeModel *grade = dataSource[index];
    if(grade.repliesCount == 0)
        return;
    
    isStreched[indexPath.row] = !isStreched[indexPath.row];
    
    if (isStreched[indexPath.row]) {
        
        GradeModel *grade = dataSource[indexPath.row];
        
        if(grade.replies == nil || [grade.replies count] == 0)
        {
            grade.replies = [NSMutableArray array];
            //MARK: 在列表时使用的数据结构与打分时使用的不一样 若有时间 调整打分时的数据结构？
            NSNumber *userId = [Coordinator userProfile].userId;
            NSNumber *tgtId  = grade.gradeId;
            NSNumber *postId = grade.post.postId;
            NSDictionary *para = @{@"userId" : userId, @"tgtId" : tgtId, @"postId" : postId, @"pager" : @{@"pageNumber" : @1, @"pageSize" : @20}, @"lastRefreshTime" : @0};
            [self startAview];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSDictionary *resultDic = [self.netAccess passUrl:ReplyModule_grade_reply_list andParaDic:para withMethod:ReplyModule_grade_reply_list_method andRequestId:ReplyModule_grade_reply_list_tag thenFilterKey:nil useSyn:YES dataForm:7];
                NSDictionary *result = resultDic[@"result"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopAview];
                    if (NETACCESS_Success) {
                        grade.repliesLastRefreshTime = resultDic[@"lastRefreshTime"];
                        NSArray *repliesArr = resultDic[@"postReplies"];
                        ReplyModel *aReply;
                        for (NSDictionary *aReplyDic in repliesArr) {
                            aReply = [ReplyModel new];
                            aReply.replyId = aReplyDic[@"id"];
                            aReply.content = aReplyDic[@"content"];
                            //                            aReply.tgtId = aReplyDic[@"gradeId"];
                            aReply.gradeId = aReplyDic[@"gradeId"];
                            aReply.adviceId = aReplyDic[@"adviceId"];
                            aReply.postId = grade.post.postId;
                            aReply.tgtReplyId = aReplyDic[@"replyId"];
                            aReply.createTime = aReplyDic[@"createTime"];
                            
                            NSMutableDictionary *srcUserDicM = [aReplyDic[@"srcUser"] mutableCopy];
                            [srcUserDicM renameKey:@"id" withNewName:@"userId"];
                            UserProfile *srcUser = [UserProfile new];
                            [srcUser assignValue:srcUserDicM];
                            
                            NSMutableDictionary *tgtUserDicM = [aReplyDic[@"tgtUser"] mutableCopy];
                            [tgtUserDicM renameKey:@"id" withNewName:@"userId"];
                            UserProfile *tgtUser = [UserProfile new];
                            [tgtUser assignValue:tgtUserDicM];
                            
                            aReply.srcUser = srcUser;
                            aReply.tgtUser = tgtUser;
                            
                            [grade.replies addObject:aReply];
                        }
                        [tableVC.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        
                    }
                    else
                    {
                        isStreched[indexPath.row] = false;
                        POPUPINFO(@"回复内容加载失败，请重试！");
                    }
                    
                });
            });
            
        }
        else
            [tableVC.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else
        [tableVC.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
    
}
/**
 *	@brief	回复打分分析或别人的回复
 *
 *	@param 	info 	传入回复对象的用户ID，用户名
 */
- (void)replyMessage:(id)replyTgt
{
    
    /* 取消注释 禁止给自己发消息
     NSNumber *loginUserId = [Coordinator userProfile].userId;
     if([loginUserId isEqualToNumber:p_tempReplyUserId])
     {
     p_tempReplyUserId = @0;
     p_tempReplyUserName = @"";
     POPUPINFO(@"不能回复自己发的消息");
     }
     */
    
    if (replyEditVC == nil) {
        replyEditVC = [[BigFieldVC alloc]init];
        replyEditVC.userDelegate = self;
        replyEditVC.isUseSmallLayout = YES;
        replyEditVC.isMaskBG = YES;
        
        
        [self addChildViewController:replyEditVC];
        [self.view addSubview:replyEditVC.view];
        
    }
    replyEditVC.value = @"";
    p_tempReplyTgt = replyTgt;
    if ([replyTgt isKindOfClass:[GradeModel class]]) {
        replyEditVC.id = ReplyTypeGrade;
        replyEditVC.placeHolderStr = STRING_joint(@"回复", ((GradeModel *)p_tempReplyTgt).user.srcName);
    }
    else if([replyTgt isKindOfClass:[ReplyModel class]])
    {
        replyEditVC.id = ReplyTypeReply;
        replyEditVC.placeHolderStr = STRING_joint(@"回复", ((ReplyModel *)p_tempReplyTgt).srcUser.srcName);
        
    }
    [replyEditVC show];
}



/**
 *	@brief	拾取完成 代理机制
 *
 *	@param 	value
 *	@param 	sender
 */
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender
{
    int index;
    GradeModel *processGrade;
    
    
    ReplyType replyType = replyEditVC.id;
    NSDictionary *srcUser, *tgtUser;
    UserProfile *srcUser0, *tgtUser0;
    NSNumber     *gradeId, *tgtReplyId, *postId_;
    srcUser0 = [Coordinator userProfile];
    if(replyType == ReplyTypeGrade)
    {
        processGrade = p_tempReplyTgt;
        tgtUser0 = ((GradeModel *)p_tempReplyTgt).user;
        gradeId  = ((GradeModel *)p_tempReplyTgt).gradeId;
        postId_   = ((GradeModel *)p_tempReplyTgt).post.postId;
    }
    else if(replyType == ReplyTypeReply)
    {
        tgtUser0 = ((ReplyModel *)p_tempReplyTgt).srcUser;
        tgtReplyId  = ((ReplyModel *)p_tempReplyTgt).replyId;
        gradeId  = ((ReplyModel *)p_tempReplyTgt).gradeId;
        postId_   = ((ReplyModel *)p_tempReplyTgt).postId;
        for (GradeModel *aModel in dataSource) {
            if([aModel.gradeId isEqualToNumber:gradeId])
            {
                processGrade = aModel;
                break;
            }
        }
    }
    if (tgtUser0 == nil || srcUser0 == nil) {
        POPUPINFO(@"幽灵客户黑我大iOS！");
        return;
    }
    p_tempReplyTgt   = nil;

    // 用于本地更新列表
    index = [dataSource indexOfObject:processGrade];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    ReplyModel *newReply = [ReplyModel new];
    newReply.srcUser = srcUser0;
    newReply.tgtUser = tgtUser0;
    newReply.gradeId = gradeId;
    newReply.postId  = postId_;
    newReply.tgtReplyId = tgtReplyId;
    newReply.content = value;
    
    
    
    srcUser = @{@"id" : srcUser0.userId, @"name" : srcUser0.name};
    tgtUser = @{@"id": tgtUser0.userId, @"name" : tgtUser0.name};
    
    
    NSNumber     *postId  = processGrade.post.postId;
    NSMutableDictionary *para0 = [ @{@"postId" : postId, @"content" : value, @"srcUser" : srcUser, @"tgtUser" : tgtUser, @"type" : NUMBER(replyType), @"gradeId" : gradeId} mutableCopy];
    [para0 setValue:tgtReplyId forKey:@"replyId"];
    
    NSDictionary *para    = @{@"reply" : para0};
    
    
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:ReplyModule_add andParaDic:para withMethod:ReplyModule_add_method andRequestId:ReplyModule_add_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                POPUPINFO(@"回复发送成功！");
                newReply.replyId = resultDic[@"id"];
                //                采用网络刷新
                //                [tableVC startPullDownRefreshing];
                //                [tableVC.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
                if(processGrade.replies == nil)
                    processGrade.replies = [NSMutableArray array];
                processGrade.repliesCount =[NSNumber numberWithInt:([processGrade.repliesCount intValue] + 1)];
                if (isStreched[index] || [processGrade.replies count] > 0 || [processGrade.repliesCount intValue] == 1) {
                    
                    [processGrade.replies insertObject:newReply atIndex:0];
                    
                }
                
                [tableVC.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
            }
            else
                POPUPINFO(@"回复发送失败！");
        });
    });
    
    
}

/**
 *	@brief	拾取取消
 *
 *	@param 	sender
 */
- (void)pickerCancelFrom:(id)sender
{
    [self hideKeyBoard];
}
/**
 *	@brief	刷新某条grade
 *
 *	@param 	grade
 */
- (void)refreshGrade:(GradeModel *)grade
{
    [[self navigationController]popToViewController:self animated:YES];
    int index = [dataSource indexOfObject:grade];
    if(index!=-1 && grade!= nil)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [tableVC.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
}
#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [dataSource count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ScoreCellForMePhoto";
    ScoreCellForMePhoto *cell = (ScoreCellForMePhoto *)[BaseCell cellRegisterNib:cellIdentifier tableView:tableView];

    GradeModel *grade = dataSource[indexPath.row];
    [cell assignValue: grade];
    cell.delegate = self;
    cell.replyBtn.tag= indexPath.row;
    if (isStreched[indexPath.row]) {
        GradeModel *grade = dataSource[indexPath.row];
        [cell strechDown:grade.replies];
    }
    else
        [cell strechUp:nil];
    
    cell.replyBtn.tag = indexPath.row;
    [cell.replyBtn addTarget:self action:@selector(strechDown:) forControlEvents:UIControlEventTouchUpInside];
    cell.adviceBtn.tag = indexPath.row;
    [cell.adviceBtn addTarget:self action:@selector(watchAdvice:) forControlEvents:UIControlEventTouchUpInside];
    cell.shareBtn.tag = indexPath.row;
    [cell.shareBtn addTarget:self action:@selector(shareGrade:) forControlEvents:UIControlEventTouchUpInside];
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


@end
