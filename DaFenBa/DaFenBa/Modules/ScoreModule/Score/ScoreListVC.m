//
//  ScoreListVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-11.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//
#import "XHPullRefreshTableViewController.h"

#import "ScoreListVC.h"
#import "MeCommentVC.h"
#import "AdviceVC.h"
#import "MeHonorVC.h"
#import "ScoreCell.h"
#import "ScoreMoreReplyVC.h"
#import "BigFieldVC.h"

#import "PostProfile.h"
#import "UserProfile.h"

#import "GradeModel.h"
#import "AdviceModel.h"
#import "ReplyModel.h"

#define maxSupportRowCount 2000//支持的最大行数


@interface ScoreListVC ()<pickerUserDelegate, ReplyCellUserDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation ScoreListVC
{
    UIView *loadView;
    
    BigFieldVC *replyEditVC;
    bool isStreched[maxSupportRowCount];     // 每个列表是否展开
    
    NSUInteger p_maxPage;     // 最大页
    NSNumber *lastRefreshTime;// 更新时间
    
    //int toAdviceIndex;        // 看建议的index in dataSource .. 与回复行为共用grade变量
    BigFieldVC *analyseFild;
    
    id p_tempReplyTgt; // 将要回复的grade对象 或 reply对象
    
    
}
@synthesize dataSource;
@synthesize tableVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dataSource = [NSMutableArray arrayWithCapacity:0];
        self.hidesBottomBarWhenPushed = YES;
//        requestCount = 1;
        p_maxPage = 8;
        lastRefreshTime = @0;
        
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    tableVC = [[XHPullRefreshTableViewController alloc]init];
    tableVC.refreshControlDelegate = tableVC;
    tableVC.tableView.delegate = self;
    tableVC.tableView.dataSource = self;
    tableVC.tableView.backgroundColor = ThemeBGColor_gray;
    [self.view addSubview:tableVC.tableView];
    [tableVC.tableView setHeight:DEVICE_screenHeight - 64 - 54];
    
    if (tableVC.pullDownRefreshed) {
        [tableVC setupRefreshControl];
    }
    loadView = tableVC.refreshControl.loadMoreView;
    [self.view addSubview:loadView];
    [loadView setTop:DEVICE_screenHeight - 64 - 54 - loadView.height];
//    [self loadDataSource];
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
    ScoreCell *cell = (ScoreCell *)[BaseCell cellRegisterNib:cellIdentifier tableView:tableView];
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
 
    [para setValue:self.scoreManager.postProfile.postId forKey:@"postId"];

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
                    UILabel *gradCountLabel =  [self.userDelegate performSelector:@selector(gradeCountLabel)];
                    gradCountLabel.text = [NSString stringWithFormat:@"所有打分(%d)", [resultDic[@"pager"][@"recordCount"] intValue]];
                    
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
                        aGrade.post = self.scoreManager.postProfile;
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

/**
 *	@brief	查看建议
 *
 *	@param 	sender 	触发按钮，触发前将按钮所在行数赋给TAG
 */
- (void)watchAdvice:(UIButton *)sender
{
    int index = sender.tag;
//    GradeModel *grade = dataSource[index];
//    AdviceVC *adviceVC = [AdviceVC new];
//    adviceVC.grade = grade;
//    [[self.userDelegate navigationController]pushViewController:adviceVC animated:YES];
//    self.alertView.tag = sender.tag;
//    [self.alertView setHidden:NO];
    SEL sel = NSSelectorFromString(@"watchCellAdvice:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.userDelegate performSelector:sel withObject:NUMBER(index)];
#pragma clang diagnostic pop
    
    
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
            [self.userDelegate startAview];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSDictionary *resultDic = [self.netAccess passUrl:ReplyModule_grade_reply_list andParaDic:para withMethod:ReplyModule_grade_reply_list_method andRequestId:ReplyModule_grade_reply_list_tag thenFilterKey:nil useSyn:YES dataForm:7];
                NSDictionary *result = resultDic[@"result"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.userDelegate stopAview];
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
    [self.userDelegate startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:ReplyModule_add andParaDic:para withMethod:ReplyModule_add_method andRequestId:ReplyModule_add_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userDelegate stopAview];
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
    [[self.userDelegate navigationController]popToViewController:self.userDelegate animated:YES];
    int index = [dataSource indexOfObject:grade];
    if(index!=-1 && grade!= nil)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [tableVC.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
}


@end
