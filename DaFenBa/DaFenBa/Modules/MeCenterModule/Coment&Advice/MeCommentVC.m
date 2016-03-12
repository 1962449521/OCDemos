//
//  MeCommentVCViewController.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-7-31.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//
#define meCommentCellSpace 10.0
// MARK: 如需测试接口 请设置如下宏

#define isMOCKDATADebugger NO
#define SLEEP

#import "MeCommentVC.h"
#import "MeCommentCell.h"
#import "BigFieldVC.h"
#import "AdviceModel.h"
#import "GradeModel.h"
#import "PostProfile.h"
#import "UserProfile.h"

#import "ShareManager.h"

@interface MeCommentVC ()<XHRefreshControlDelegate, MeCommentCellUserDelegate, UIAlertViewDelegate, pickerUserDelegate>

@end
typedef NS_ENUM(int, OperationType) {OperationTypeEdit = 1, OperationTypeDelete};
typedef NS_ENUM(bool, MeCommentEditType) {MeCommentEditTypeComment, MeCommentEditTypeAdvice};

@interface HSAlertView:UIAlertView
@property (nonatomic,assign) int indexWithinDataSource;
@property (nonatomic,assign)    MeCommentEditType editType;
@end
@implementation HSAlertView
@end
@interface HSBigFieldVC:BigFieldVC
@property (nonatomic,assign)    int indexWithinDataSource;
@property (nonatomic,assign)    MeCommentEditType editType;

@end
@implementation HSBigFieldVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    nibNameOrNil = NSStringFromClass([self superclass]);
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

@end

@implementation MeCommentVC
{
    UILabel *countLabel;
    UIView *loadMoreView;
    NSNumber *lastRequestTime;
    HSBigFieldVC *bigFieldVC;
    
    NSInteger tempTargetIndex;//当前操作行
    NSString *tempTargetStr;//编辑的更新内容

}
@synthesize tableVC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tableVC = [[XHPullRefreshTableViewController alloc]init];
        _dataSource = [NSMutableArray array];
        tableVC.refreshControlDelegate = self;
        bigFieldVC = [HSBigFieldVC new];
        bigFieldVC.userDelegate = self;
        bigFieldVC.isMaskBG = YES;
        
        tempTargetIndex = -1;
        lastRequestTime = @0;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setNavTitle:@"给出的打分&建议"];
    self.isNeedBackBTN = YES;
    self.isNeedHideTabBar = YES;
    [self.view setBackgroundColor:ThemeBGColor_gray];
    [tableVC.tableView setBackgroundColor:ColorRGB(255.0, 255.0, 255.0)];
    //tableVC.tableView.allowsSelection = NO;
    [self.view setHeight:DEVICE_screenHeight - 20 - 44];
    
    [self.view addSubview:bigFieldVC.view];
    [bigFieldVC.view setTop:self.view.bottom];
    
    //标题，如“全部图片（）张”
    countLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    countLabel.text = @"全部打分&建议（...）";
    countLabel.font = [UIFont systemFontOfSize:14];
    countLabel.textColor = textGrayColor;
    countLabel.backgroundColor = [UIColor clearColor];
    int countLabelHeight = 28.0 + 5;
    [countLabel sizeToFit];
    [countLabel setWidth:300];
    [countLabel setHeight:countLabelHeight];
    [countLabel setX:12];
    [self.view addSubview:countLabel];
    
    
    [tableVC.tableView setFrame:self.view.bounds];
    [tableVC.tableView setY:countLabelHeight];
    tableVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableVC.tableView setHeight:tableVC.tableView.height - countLabelHeight];
    
    tableVC.tableView.dataSource = self;
    tableVC.tableView.delegate = self;
    [self adaptIOSVersion:tableVC.tableView];
    
    [self.view addSubview:tableVC.tableView];
    
    if (tableVC.pullDownRefreshed) {
        [tableVC setupRefreshControl];
    }
    loadMoreView = tableVC.refreshControl.loadMoreView;
    [loadMoreView setY: self.view.height - loadMoreView.height];

    [tableVC startPullDownRefreshing];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - loadDataSource 重写父类方法 数据获取与显示
- (void)loadDataSource {
    UserProfile *userProfile = [Coordinator userProfile];
    NSNumber *userId = userProfile.userId;
    NSDictionary *pager = @{@"pageNumber" : [NSNumber numberWithInt: (tableVC.requestCurrentPage + 1)], @"pageSize" : @20};
    NSDictionary *para = @{@"userId" : userId, @"pager" : pager, @"lastRefreshTime" : lastRequestTime};
    
    [self.netAccess passUrl:GradeModule_listForMine andParaDic:para withMethod:GradeModule_listForMine_method andRequestId:GradeModule_listForMine_tag thenFilterKey:nil useSyn:NO dataForm:7];
    return;

}
/**
 *	@brief	将新获得的数据源显示至列表
 *
 *	@param 	dataSource
 */
- (void)assignDataSource:(NSArray *)dataSource{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *indexPaths;
        if (tableVC.requestCurrentPage) {
            indexPaths = [[NSMutableArray alloc] initWithCapacity:dataSource.count];
            [dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:_dataSource.count + idx inSection:0]];
            }];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tableVC.requestCurrentPage) {
                if (dataSource == nil) {
                    [tableVC revokeHsRefresh];
                    [tableVC revokeHsLoadMore];
                } else {
                    [_dataSource addObjectsFromArray:dataSource];
                    [tableVC.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    [tableVC endLoadMoreRefreshing];
                }
            } else {
                if (dataSource != nil && [dataSource count] > 0) {
                    [_dataSource removeAllObjects];
                    [_dataSource addObjectsFromArray:dataSource];
                    [tableVC.tableView reloadData];
                }
                
                [tableVC endPullDownRefreshing];
            }
        });
    });
    
}


#pragma mark - UITableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    UserProfile *userProfile = [Coordinator userProfile];
    if(userProfile.extInfo[@"gradeCount"])
    {
        int count = [userProfile.extInfo[@"gradeCount"] intValue];
        countLabel.text = [NSString stringWithFormat: @"全部打分&建议（%d）",count];
    }
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MeCommentCell";
    MeCommentCell *cell = (MeCommentCell *)[BaseCell cellRegisterNib:cellIdentifier tableView:tableView];
    cell.indextWithinDataSource = indexPath.row;
    cell.delegate = self;
    
    GradeModel *dic = self.dataSource[indexPath.row];
    [cell setDataSource:dic];
    
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 188;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.navigationController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


#pragma mark - XHRefreshControl Delegate

- (void)beginPullDownRefreshing {
    tableVC.requestCurrentPage = 0;
    [self loadDataSource];
}

- (void)beginLoadMoreRefreshing {
    tableVC.requestCurrentPage ++;
    [self loadDataSource];
}
- (NSString *)lastUpdateTimeString {
    
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:[lastRequestTime longValue]];
    
    NSString *destDateString = [nowDate timeAgo];
    
    return destDateString;
}
- (BOOL)isPullDownRefreshed {
    return tableVC.pullDownRefreshed;
}
- (BOOL)isLoadMoreRefreshed {
    return tableVC.loadMoreRefreshed;
}

- (XHRefreshViewLayerType)refreshViewLayerType {
    return XHRefreshViewLayerTypeOnScrollViews;
}

- (XHPullDownRefreshViewType)pullDownRefreshViewType {
    return tableVC.refreshViewType;
}

- (NSInteger)autoLoadMoreRefreshedCountConverManual {
    return 3;
}
- (NSString *)displayAutoLoadMoreRefreshedMessage
{
    return @"查看下二十条";
}

#pragma mark - MeCommentCellUserDelegate
- (void)commentClick:(NSInteger)index
{
    tempTargetIndex = index;
    bigFieldVC.editType = MeCommentEditTypeComment;
    bigFieldVC.titlestr =  @"添加分析";
    bigFieldVC.indexWithinDataSource = index;
    [bigFieldVC setValue:@""];
    [bigFieldVC show];
}
- (void)adviceClick:(NSInteger)index
{
    tempTargetIndex = index;

    bigFieldVC.editType = MeCommentEditTypeAdvice;
    bigFieldVC.titlestr = @"添加建议" ;
    bigFieldVC.indexWithinDataSource = index;
    [bigFieldVC setValue:@""];
    [bigFieldVC show];
}

- (void) commentLongClick:(NSInteger)index
{
    tempTargetIndex = index;

    HSAlertView *alertView = [[HSAlertView alloc]initWithTitle:@"分析" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改",@"删除", nil];
    alertView.tag = MeCommentEditTypeComment;
    alertView.indexWithinDataSource = index;
    alertView.delegate = self;
    [alertView show];
}
- (void) adviceLongClick:(NSInteger)index
{
    tempTargetIndex = index;
    
    HSAlertView *alertView = [[HSAlertView alloc]initWithTitle:@"建议" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];

    alertView.tag = MeCommentEditTypeAdvice;
    alertView.indexWithinDataSource = index;
    alertView.delegate = self;
    [alertView show];
}
- (void) postClick:(NSInteger)index
{
    GradeModel *grade = self.dataSource[index];
//    ScoreManager *scoreManager = [ScoreManager new];
//    scoreManager.postProfile   = grade.post;
//    scoreManager.postGrade     = grade;
//    scoreManager.postAdvice    = grade.advice;
    PostProfile *post = grade.post;
    [ScoreManager evokeScoreWithPostOrScoreManager:post FromVC:self];
    
}
- (void) deleteCell:(NSInteger)index
{
    tempTargetIndex = index;
    UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确认删除整条打分和建议？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alerView.tag = 1990;
    [alerView show];
}

- (void) deleteCell0:(NSInteger)index
{
    [self startAview];

    GradeModel *grade = _dataSource[index];
    NSNumber *gradeId = grade.gradeId;
    NSNumber *userId  = [Coordinator userProfile].userId;
    [self.netAccess passUrl:GradeModule_delete andParaDic:@{@"id" : gradeId, @"userId" : userId} withMethod:GradeModule_delete_method andRequestId:GradeModule_delete_tag thenFilterKey:nil useSyn:NO dataForm:7];
    }
- (void) shareCell:(NSInteger)index
{
    GradeModel *grade = _dataSource[index];
    NSString *shareContent = [NSString stringWithFormat:@"%@分，这照片我给打了%@分，你来看看会给几分？",grade.grade, grade.grade];
    ShareStruct shareStruct = {DaFenBaShareTypeGrade, [grade.gradeId intValue],1};
    [[ShareManager shareInstance]showShareListWithPhot:grade.post.pic andText:shareContent shareStruct: shareStruct fromVC:self];
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(HSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1990) {
        if (buttonIndex == 1) {
            [self deleteCell0:tempTargetIndex];
        }
        return;
    }
    int index = alertView.indexWithinDataSource;
    tempTargetIndex = index;
    
    GradeModel *dic = self.dataSource[index];

    NSNumber *userId = [Coordinator userProfile].userId;

    if (userId == nil) userId = @0;
    NSNumber *postId = dic.post.postId;
    if (postId == nil) postId = @0;
    NSNumber *grade   = dic.grade;
    if (grade == nil) grade = @0;
    NSNumber *colorGrade = dic.colorGrade;
    if (colorGrade == nil) colorGrade = @0;
    NSNumber *sizeGrade = dic.sizeGrade;
    if (sizeGrade == nil) sizeGrade = @0;
    NSNumber *matchGrade = dic.matchGrade;
    if (matchGrade == nil) matchGrade = @0;
    NSNumber *adviceId = dic.advice == nil? @-1 : dic.advice.adviceId;
    NSString *comment = dic.comment;

    if(buttonIndex == OperationTypeEdit && alertView.tag == MeCommentEditTypeComment ){
        [bigFieldVC setValue: comment];
        bigFieldVC.editType = alertView.tag;
        bigFieldVC.titlestr = bigFieldVC.editType == MeCommentEditTypeAdvice ? @"修改建议" : @"修改分析";
        bigFieldVC.indexWithinDataSource = index;
        [bigFieldVC show];
        
    }
    else if((buttonIndex == OperationTypeDelete && alertView.tag == MeCommentEditTypeComment)  ||  (buttonIndex == OperationTypeEdit && alertView.tag == MeCommentEditTypeAdvice)){
        tempTargetStr = @"";
        if(alertView.tag == MeCommentEditTypeComment)
        {
            [self startAview];

            NSDictionary *para =  @{@"grade" : @{@"userId" : userId, @"postId" : postId, @"grade" :grade, @"colorGrade" : colorGrade, @"sizeGrade" : sizeGrade, @"matchGrade" : matchGrade, @"comment" : @"" }};
            [self.netAccess passUrl:GradeModule_update andParaDic:para withMethod:GradeModule_update_method andRequestId:GradeModule_update_tag thenFilterKey:nil useSyn:NO dataForm:7];
        }
        else if(alertView.tag == MeCommentEditTypeAdvice)
        {
            [self startAview];
            NSDictionary *para =  @{@"id" : adviceId, @"userId" : userId};
            [self.netAccess passUrl:AdviceModule_delete andParaDic:para withMethod:AdviceModule_delete_method andRequestId:AdviceModule_delete_tag thenFilterKey:nil useSyn:NO dataForm:7];
        }
        
    }
}
#pragma mark - pickerUserDelegate
- (void)pickerFinishedWithValue:(NSString *)value From:(id)sender
{
    int index = bigFieldVC.indexWithinDataSource;//指明操作的数据行
    MeCommentEditType type = bigFieldVC.editType;//指明是编辑分析还是建议

    GradeModel *dic = self.dataSource[index];

    NSNumber *userId = [Coordinator userProfile].userId;
    if (userId == nil) userId = @0;
    NSNumber *postId = dic.post.postId;
    if (postId == nil) postId = @0;
    NSNumber *grade   = dic.grade;
    if (grade == nil) grade = @0;
    NSNumber *colorGrade = dic.colorGrade;
    if (colorGrade == nil) colorGrade = @0;
    NSNumber *sizeGrade = dic.sizeGrade;
    if (sizeGrade == nil) sizeGrade = @0;
    NSNumber *matchGrade = dic.matchGrade;
    if (matchGrade == nil) matchGrade = @0;
    
    tempTargetIndex = index;
    tempTargetStr = value;
    if(type == MeCommentEditTypeComment)
    {
        [self startAview];
        if(value == nil)value = @"";
        NSDictionary *para =  @{@"grade" : @{@"userId" : userId, @"postId" : postId, @"grade" :grade, @"colorGrade" : colorGrade, @"sizeGrade" : sizeGrade, @"matchGrade" : matchGrade, @"comment" : value }};
        [self.netAccess passUrl:GradeModule_update andParaDic:para withMethod:GradeModule_update_method andRequestId:GradeModule_update_tag thenFilterKey:nil useSyn:NO dataForm:7];
    }
    else if (type == MeCommentEditTypeAdvice)
    {
        if ([[value stringByReplacingOccurrencesOfString:@" " withString:@"" ] length] == 0) {
            return;
        }
        [self startAview];

        NSDictionary *para =  @{@"advice" : @{@"userId" : userId, @"postId" : postId, @"cotent" :value, @"address" : @"", @"buyUrl" : @""}};
        [self.netAccess passUrl:AdviceModule_add andParaDic:para withMethod:AdviceModule_add_method andRequestId:AdviceModule_add_tag thenFilterKey:nil useSyn:NO dataForm:7];
    }
}
- (void)pickerCancelFrom:(id)sender
{
    [self hideKeyBoard];
    [bigFieldVC hide];
    
}
#pragma mark - AsynNetAccessDelegate
- (void) receivedObject:(id)receiveObject withRequestId:(NSNumber *)requestId
{
    if([self.aview isAnimating])
        [self stopAview];
    NSDictionary *receiveDic;
    
    if (!TYPE_isDictionary(receiveObject))
    {
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
        if([requestId isEqualToNumber:GradeModule_listForMine_tag])
            [self assignDataSource:nil];
        return;
    }
    else
        receiveDic = (NSDictionary *)receiveObject;
    NSDictionary *result = receiveDic[@"result"];
    if ([requestId isEqualToNumber:GradeModule_listForMine_tag])
    {
        
        if (NETACCESS_Success)
        {
            NSArray *gradesOrigin = receiveDic[@"grades"];
            NSMutableArray *gradesNew = [NSMutableArray array];
            
            for (NSDictionary *aGrade in gradesOrigin) {

                GradeModel *newGradeModel = [GradeModel new];
                NSMutableDictionary *postGrade = [aGrade[@"grade"] mutableCopy];
                if(postGrade != nil && [postGrade count] > 0)
                {
                    [postGrade renameKey:@"id" withNewName:@"gradeId"];
                    [newGradeModel assignValue:postGrade];
                }
                NSMutableDictionary *postProfileM = [aGrade[@"post"] mutableCopy];
                [postProfileM renameKey:@"id" withNewName:@"postId"];
                PostProfile *postprofile = [PostProfile new];
                [postprofile assignValue:postProfileM];
                
//                NSMutableDictionary *userProfileM = [aGrade[@"user"]mutableCopy];
//                [userProfileM renameKey:@"id" withNewName:@"userId"];
//                UserProfile *userProfile = [UserProfile new];
//                [userProfile assignValue:userProfileM];
                
                newGradeModel.user = [Coordinator userProfile];
                newGradeModel.post = postprofile;
                
                NSMutableDictionary *postAdvice = [aGrade[@"advice"] mutableCopy];
                if(postAdvice != nil && [postAdvice count] > 0)
                {
                    [postAdvice renameKey:@"id" withNewName:@"adviceId"];
                    AdviceModel *advice = [AdviceModel new];
                    [advice assignValue:postAdvice];
                    newGradeModel.advice = advice;
                }
                [gradesNew addObject:newGradeModel];
            }
            if (receiveDic[@"lastRefreshTime"])
            {
                lastRequestTime = receiveDic[@"lastRefreshTime"];
                UserProfile *userProfile = [Coordinator userProfile];
                if(!userProfile.extInfo) userProfile.extInfo = [NSMutableDictionary dictionary];
                [userProfile.extInfo setValue:receiveDic[@"pager"][@"recordCount"] forKey:@"gradeCount"];
            }
            [self assignDataSource:gradesNew];
        }
        else
        {
            [self assignDataSource:nil];
            POPUPINFO(STRING_joint(@"列表获取失败", result[@"msg"]));
            
        }
    }
    else if ([requestId isEqualToNumber:GradeModule_delete_tag])
    {
        if (NETACCESS_Success) {
            UserProfile *userProfile = [Coordinator userProfile];
            if(userProfile.extInfo[@"gradeCount"])
            {
                int oldCount = [userProfile.extInfo[@"gradeCount"] intValue];
                [userProfile.extInfo setValue:NUMBER(oldCount - 1) forKey:@"gradeCount"];
            }
            
            int index = tempTargetIndex;
            [self.dataSource removeObjectAtIndex:index];
            [tableVC.tableView reloadData];
            POPUPINFO(@"删除成功");
        }
        else
            POPUPINFO(@"删除失败");

;
    }
    else if ([requestId isEqualToNumber:GradeModule_update_tag])
    {
        if (NETACCESS_Success) {
            int index = tempTargetIndex;
            GradeModel *dic = self.dataSource[index];
            dic.comment = tempTargetStr;
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
            [tableVC.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            POPUPINFO(@"操作成功");
        }
        else
            POPUPINFO(@"操作失败");

    }
    else if ([requestId isEqualToNumber:AdviceModule_delete_tag])
    {
        if (NETACCESS_Success) {
            int index = tempTargetIndex;
            GradeModel *dic = self.dataSource[index];
            dic.advice = nil;
            NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
            [tableVC.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            POPUPINFO(@"删除成功");
        }
        else
            POPUPINFO(@"删除失败");
    }
    else if([requestId isEqualToNumber:AdviceModule_add_tag])
    {
        int index = tempTargetIndex;
        GradeModel *dic = self.dataSource[index];

        AdviceModel *advice = [AdviceModel new];
        advice.adviceId = receiveDic[@"id"];
        advice.content = tempTargetStr;
        
        dic.advice = advice;
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
        [tableVC.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
        POPUPINFO(@"添加成功");

    }
    
}

- (void) netAccessFailedAtRequestId:(NSNumber *)requestId withErro:(NetAccessError)erroId
{
    [tableVC endPullDownRefreshing];
    [tableVC endLoadMoreRefreshing];
    if([self.aview isAnimating])
        [self stopAview];
    if (erroId == ErrorTimeOut)
        POPUPINFO(@"连接超时,请重新连接");
    else
        POPUPINFO(@"服务器故障,"ACCESSFAILEDMESSAGE);
    if([requestId isEqualToNumber:GradeModule_list_tag])
        [self assignDataSource:nil];
    
    
}

    
@end
