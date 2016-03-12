//
//  ScoreMoreReplyVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-11.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "ScoreMoreReplyVC.h"
#import "BigFieldVC.h"
#import "AdviceVC.h"

#import "XHPullRefreshTableViewController.h"
#import "GradeModel.h"
#import "ReplyModel.h"
#import "PostProfile.h"
#import "ScoreCell.h"

#import "ScoreListVC.h"
#import "ScoreSuccessVC.h"


@interface ScoreMoreReplyVC ()<pickerUserDelegate, UITableViewDataSource, UITableViewDelegate,ReplyCellUserDelegate>

@end

@implementation ScoreMoreReplyVC
{
    BigFieldVC *replyEditVC;
    UIView *loadView;
    ScoreCell *headCell;
    
    NSMutableArray *dataSource;
    NSNumber *lastRefreshTime;
    int p_maxPage;
    
    id p_tempReplyTgt;

}
@synthesize tableVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tableVC = [XHPullRefreshTableViewController new];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"回复列表"];
    self.isNeedBackBTN = YES;
    self.isNeedHideTabBar = YES;
    self.view.backgroundColor = ThemeBGColor_gray;
    
    long tempTS = [self.grade.repliesLastRefreshTime longValue];
    lastRefreshTime = [NSNumber numberWithLong:tempTS];
    dataSource = self.grade.replies;
    p_maxPage = (int)ceil([self.grade.repliesCount intValue] /20.0);
    
    tableVC.refreshControlDelegate = tableVC;
    tableVC.tableView.delegate = self;
    tableVC.tableView.dataSource = self;
    tableVC.tableView.backgroundColor = ThemeBGColor_gray;
    [self.view addSubview:tableVC.tableView];
    [tableVC.tableView setHeight:DEVICE_screenHeight - 64 ];
    tableVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (tableVC.pullDownRefreshed) {
        [tableVC setupRefreshControl];
    }
    
    headCell = (ScoreCell *)[[NSBundle mainBundle] loadNibNamed:@"ScoreCellRich" owner:self options:nil][0];
    [headCell assignValue:self.grade];
    headCell.delegate = self;
    [headCell.adviceBtn addTarget:self action:@selector(watchAdvice:) forControlEvents:UIControlEventTouchUpInside];
    tableVC.tableView.tableHeaderView = headCell.contentView;
    
    
    
    
    loadView = tableVC.refreshControl.loadMoreView;
    [self.view addSubview:loadView];
    [loadView setTop:DEVICE_screenHeight - 64 - loadView.height];

    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadDataSource

{
    if (tableVC.requestCurrentPage == 0 && p_maxPage == 0) {
        p_maxPage = 30000;
    }
    if (p_maxPage > 0 && tableVC.requestCurrentPage + 1 > p_maxPage) {

        [tableVC endMoreOverWithMessage:@"没有更多页了"];
        return;
    }
    
    // request para
    NSNumber *userId = [Coordinator userProfile].userId;
    NSNumber *tgtId  = self.grade.gradeId;
    NSNumber *postId = self.grade.post.postId;
    NSDictionary *para = @{@"userId" : userId, @"tgtId" : tgtId, @"postId" : postId, @"pager" : @{@"pageNumber" : NUMBER(tableVC.requestCurrentPage +1), @"pageSize" : @20}, @"lastRefreshTime" : lastRefreshTime};
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:ReplyModule_grade_reply_list andParaDic:para withMethod:ReplyModule_grade_reply_list_method andRequestId:ReplyModule_grade_reply_list_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableVC revokeHsRefresh];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                if(resultDic[@"lastRefreshTime"] != nil)
                {
                    lastRefreshTime = resultDic[@"lastRefreshTime"];
                    if(resultDic[@"pager"][@"pageCount"] != nil)
                        p_maxPage = [resultDic[@"pager"][@"pageCount"] intValue];
                    if(resultDic[@"pager"][@"recordCount"] != nil)
                        self.grade.repliesCount = resultDic[@"pager"][@"recordCount"];
                    
                }
                
                NSArray *repliesArr = resultDic[@"postReplies"];
                ReplyModel *aReply;
                NSMutableArray *newDataSource = [NSMutableArray array];
                for (NSDictionary *aReplyDic in repliesArr)
                {
                    aReply = [ReplyModel new];
                    aReply.replyId = aReplyDic[@"id"];
                    aReply.content = aReplyDic[@"content"];
                    aReply.gradeId = aReplyDic[@"gradeId"];
                    aReply.postId  = aReplyDic[@"postId"];
                    aReply.tgtReplyId = aReplyDic[@"replyId"];
                    
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
                    
                    [newDataSource addObject:aReply];
                }
                if(tableVC.requestCurrentPage == 0)
                {
                    [self.grade.replies removeAllObjects];
                    [self.grade.replies addObjectsFromArray:newDataSource];
                }
                else
                    [self.grade.replies addObjectsFromArray:newDataSource];
                
                //赋值
                [headCell assignValue:self.grade];
                [tableVC.tableView reloadData];

                
            }
            else
            {
                [tableVC revokeHsLoadMore];
                POPUPINFO(@"回复内容加载失败，请重试！");
            }
            
        });
    });
    
}





- (IBAction)watchAdvice:(id)sender
{
//    int index = sender.tag;
//    GradeModel *grade = dataSource[index];
//    AdviceVC *adviceVC = [AdviceVC new];
//    adviceVC.grade = grade;
//    [[self.userDelegate navigationController]pushViewController:adviceVC animated:YES];
 
    //[self.alertView setHidden:NO];
}
#pragma mark - ReplyCellUserDelegate
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
#pragma mark - pickerUserDelegate
/**
 *	@brief	拾取完成 代理机制
 *
 *	@param 	value
 *	@param 	sender
 */
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender
{

    GradeModel *processGrade = self.grade;
    
    
    ReplyType replyType = replyEditVC.id;
    NSDictionary *srcUser, *tgtUser;
    UserProfile *srcUser0, *tgtUser0;
    NSNumber     *gradeId, *replyId, *postId_;
    srcUser0 = [Coordinator userProfile];
    if(replyType == ReplyTypeGrade)
    {
        tgtUser0 = ((GradeModel *)p_tempReplyTgt).user;
        gradeId  = ((GradeModel *)p_tempReplyTgt).gradeId;
        postId_   = ((GradeModel *)p_tempReplyTgt).post.postId;
    }
    else if(replyType == ReplyTypeReply)
    {
        tgtUser0 = ((ReplyModel *)p_tempReplyTgt).srcUser;
        //replyId  = ((ReplyModel *)p_tempReplyTgt).replyId;
        gradeId  = ((ReplyModel *)p_tempReplyTgt).gradeId;
        replyId  = ((ReplyModel *)p_tempReplyTgt).replyId;
        postId_   = ((ReplyModel *)p_tempReplyTgt).postId;
    }
    if (tgtUser0 == nil || srcUser0 == nil) {
        POPUPINFO(@"幽灵客户黑我大iOS！");
        return;
    }
    
    // 用于本地更新列表
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    ReplyModel *newReply = [ReplyModel new];
    newReply.srcUser = srcUser0;
    newReply.tgtUser = tgtUser0;
    newReply.gradeId   = gradeId;
    newReply.postId  = postId_;
    newReply.replyId = replyId;
    newReply.content = value;
    
    
    
    srcUser = @{@"id" : srcUser0.userId, @"name" : srcUser0.name};
    tgtUser = @{@"id": tgtUser0.userId, @"name" : tgtUser0.name};
    
    
    NSNumber     *postId  = processGrade.post.postId;
    
    p_tempReplyTgt   = nil;
    
    
    NSDictionary *para    = @{@"reply" : @{@"postId" : postId, @"content" : value, @"srcUser" : srcUser, @"tgtUser" : tgtUser, @"type" : NUMBER(replyType), @"gradeId" : gradeId}};
    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:ReplyModule_add andParaDic:para withMethod:ReplyModule_add_method andRequestId:ReplyModule_add_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                POPUPINFO(@"回复发送成功！");
                newReply.replyId = resultDic[@"id"];
                // 网络更新
                //                [tableVC startPullDownRefreshing];
                //                [tableVC.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
                if(processGrade.replies == nil)
                    processGrade.replies = [NSMutableArray array];
                processGrade.repliesCount =[NSNumber numberWithInt:([processGrade.repliesCount intValue] + 1)];
                
                [processGrade.replies insertObject:newReply atIndex:0];
                [headCell assignValue:self.grade];
                [tableVC.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
            }
            else
                POPUPINFO(@"回复发送失败！");
        });
    });

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
- (IBAction)alertViewSelected:(UIButton *)sender {
    [self.alertView setHidden:YES];
    if (sender.tag == 1) {
        AdviceVC *vc = [[AdviceVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
-(void)backToPreVC:(id)sender
{
    ScoreListVC *delegateVC = (ScoreListVC *)self.userDelegate;
//    if ([delegateVC.userDelegate isKindOfClass:[ScoreSuccessVC class]]) {
//        ScoreSuccessVC *ssVC = (ScoreSuccessVC *)delegateVC.userDelegate;
//        ssVC.isOmittedCheckPostDetail = YES;
//    }
    [delegateVC.userDelegate setIsOmittedCheckPostDetail:YES];
    [delegateVC refreshGrade:self.grade];
    
    
}
#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [dataSource count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ReplyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell)
        cell = [[UITableViewCell alloc]init];
            
    
    SubReplyView *view = (SubReplyView *)[[[NSBundle mainBundle]loadNibNamed:@"SubReplyView" owner:self options:nil]lastObject];
    [view setX:66];
    [view assignValue:dataSource[indexPath.row]];
    view.delegate = self;
    [cell.contentView addSubview:view];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    
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
