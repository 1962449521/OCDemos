//
//  PhotoScoreReplyAdviceVC.m
//  DaFenBa
//
//  Created by 胡 帅 on 14-8-12.
//  Copyright (c) 2014年 胡 帅. All rights reserved.
//

#import "AdviceVC.h"
#import "UserProfile.h"
#import "PostProfile.h"
#import "AdviceModel.h"
#import "GradeModel.h"
#import "ScoreManager.h"
#import "AdviceMsgCell.h"
#import "ReplyModel.h"

static const int maxCharacterNum = 120;
static const int maxReplyCount    = 20;

@interface AdviceVC ()<UITableViewDelegate, UITableViewDelegate, UITextViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@end

@implementation AdviceVC
{
    id currentResponder;
    NSNumber *maxPage;
    NSNumber *lastRefreshTime;
    int requestCurrentCount;
    int sendedUnReplyCount;//在没有收到对方回复的情况下的已发送数目
    BOOL isLoadMoreBtnShowed;
    UIButton *loadMoreBtn;
    NSNumber *tgtReplyId;
//   
}
@synthesize p_isSendOut;
@synthesize dataSource;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dataSource = [NSMutableArray arrayWithCapacity:0];
        sendedUnReplyCount = 0;
        requestCurrentCount = 0;
        sendedUnReplyCount  = 0;
        maxPage = @8;
        lastRefreshTime = @0;
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isNeedBackBTN    = YES;
    self.isNeedHideBack   = YES;
    self.isNeedHideTabBar = YES;
    [self registerKeyBoardObserve];
   
    self.sendTextField.returnKeyType = UIReturnKeyDone;

    //-----------------------------=-----------------------
    //图片可缩放观看
    self.photoScrollView.maximumZoomScale = 3.0;
    self.photoScrollView.minimumZoomScale = 1.0;
    self.photoScrollView.delegate = self;

    self.advice.returnKeyType = UIReturnKeyNext;
    self.buyAddress.returnKeyType = UIReturnKeyNext;
    self.buyUrl.returnKeyType = UIReturnKeyDone;
    self.advice.delegate = self;
    self.buyUrl.delegate = self;
    self.buyAddress.delegate = self;
    self.sendTextField.delegate = self;
    UITapGestureRecognizer *tap;
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideBigPost)];
    [self.bigPhotoImageView addGestureRecognizer:tap];
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerTaped)];
    [self.downView addGestureRecognizer:tap];
//    [self loadMoreAdviceMsgRecords];
    
}
- (void)showLoadMoreBtn
{
    if (isLoadMoreBtnShowed)
        return;
    
    //往上查看更多历史记录
    UIView *view = self.tableView.tableHeaderView;
    self.tableView.tableHeaderView = nil;
    [view addSubview:[self loadMoreBtn]];
    [loadMoreBtn setTop:view.height];
    [view setHeight:loadMoreBtn.bottom];
    self.tableView.tableHeaderView = view;
    
    isLoadMoreBtnShowed = YES;
}
- (UIButton *)loadMoreBtn
{
    if(loadMoreBtn != nil)
        return loadMoreBtn;
    else
    {
        loadMoreBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, DEVICE_screenWidth, 40)];
        [loadMoreBtn setBackgroundImage:[UIImage imageNamed:@"transculent"] forState:UIControlStateNormal];
        loadMoreBtn.backgroundColor = [UIColor whiteColor];
        [loadMoreBtn setTitle:@"查看更多记录" forState:UIControlStateNormal];
        [loadMoreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [loadMoreBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [loadMoreBtn addTarget:self action:@selector(loadMoreAdviceMsgRecords) forControlEvents:UIControlEventTouchUpInside];
    }
    return loadMoreBtn;
}
- (void)hideLoadMoreView
{
    if(!isLoadMoreBtnShowed)
        return;
    //隐藏查看更多记录
    UIView *view = self.tableView.tableHeaderView;
    self.tableView.tableHeaderView = nil;
    [view setHeight:self.downView.bottom];
    self.tableView.tableHeaderView = view;
    isLoadMoreBtnShowed = NO;

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 进到他人主页 或 自己主页

#pragma mark - 加载回复记录
- (void)loadMoreAdviceMsgRecords
{
    requestCurrentCount++;
    if (requestCurrentCount > [maxPage intValue]) {
        POPUPINFO(@"没有更多页了！");
        self.tableView.tableHeaderView = nil;
        return;
    }
    UserProfile *tgtUser = [Coordinator userProfile];//通话一方肯定是自己了
    UserProfile *srcUser ;
    NSNumber *tgtId;
    //从查看别人建议进来  这条建议是别人发的哦
    if ([self.gradeOrScormanager isKindOfClass:[GradeModel class]]) {
        srcUser = ((GradeModel *) self.gradeOrScormanager).user;//通话另一方是建议的拥有者
        tgtId   = ((GradeModel *) self.gradeOrScormanager).advice.adviceId;
    }
    else//从查看自己建议进来  这条建议是我发的哦
    {
        srcUser = tgtUser;//通话另一方是图片的拥有者 这时候这条建议是我发的
        tgtId = ((ScoreManager *)self.gradeOrScormanager).postAdvice.adviceId;
    }
    
    
    if(tgtId == nil) return;
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    [para setValue:srcUser.userId forKey:@"srcUserId"];
    [para setValue:tgtUser.userId forKey:@"tgtUserId"];
    [para setValue:tgtId forKey:@"tgtId"];
    [para setValue:@0 forKey:@"lastRefreshTime"];
    [para setValue:@{@"pageNumber" : NUMBER(requestCurrentCount), @"pageSize" : @20} forKey:@"pager"];
    // !!!:sb了后台，返回数据错了 这两个都没有

    [self startAview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *resultDic = [self.netAccess passUrl:ReplyModule_advice_reply_list andParaDic:para withMethod:ReplyModule_advice_reply_list_method andRequestId:ReplyModule_advice_reply_list_tag thenFilterKey:nil useSyn:YES dataForm:7];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAview];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {

                if (resultDic[@"lastRefreshTime"]) {
                    // !!!:sb了后台，返回数据错了 只有一个

                    lastRefreshTime = resultDic[@"lastRefreshTime"];
                    
                }
                maxPage = resultDic[@"pager"][@"pageCount"];

                if (requestCurrentCount >= [maxPage intValue])
                    [self hideLoadMoreView];
                
                else
                    [self showLoadMoreBtn];
                
                NSArray *repliesArr = resultDic[@"postReplies"];
                ReplyModel *aReply;
                for (NSDictionary *aReplyDic in repliesArr)
                {
                    aReply = [ReplyModel new];
                    aReply.replyId = aReplyDic[@"id"];
                    aReply.content = aReplyDic[@"content"];
                    aReply.gradeId = aReplyDic[@"gradeId"];
                    aReply.postId  = aReplyDic[@"postId"];
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
                    
                    [dataSource insertObject:aReply atIndex:0];
                }
                if (requestCurrentCount == 1) {//查两个，1.最多回了多少 2.上一个聊天对象
                    NSEnumerator *enumerator = [dataSource reverseObjectEnumerator];
                    ReplyModel *aReply;
                    while ((aReply = enumerator.nextObject)!=nil) {
                        if ([aReply.srcUser.userId isEqualToNumber:[Coordinator userProfile].userId]) {
                            sendedUnReplyCount++;
                        }
                        else
                        {
                            tgtReplyId = aReply.replyId;
                            break;
                        }
                    }

                }
                [self.tableView reloadData];
                
            }
            else
            {
                POPUPINFO(@"回复记录加载失败,请返回重试！");
            }
            
        });
    });
}


#pragma mark - 大图预览
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
    float size = self.photoScrollView.zoomScale;
    if (size > 1) {
        [self.photoScrollView setZoomScale:1];
        return;
    }
    UIViewBeginAnimation(kDuration);
    [self.photoScrollView setAlpha:0];
    [self.bigPhotoImageView setFrame:self.postPhoto.bounds];
    [UIView commitAnimations];
    
    
    [self.photoScrollView setZoomScale:1];
}
#pragma mark - 键盘事件
/**
 *	@brief	点击表头隐藏键盘
 */
- (void)headerTaped
{
    [self hideKeyBoard];
}

- (void)registerKeyBoardObserve
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeContentViewPosition:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeContentViewPosition:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
  
}
- (void)removeKeyBoardObserve
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 根据键盘状态，调整_mainView的位置 只在回复建议时使用
- (void) changeContentViewPosition:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        [UIView setAnimationDuration:kDuration];
        [self.sendView setTop:keyBoardEndY - self.sendView.height - 64];
        
        if (!p_isSendOut) {//上滚以显示最新的聊天记录
            float delta = 64 + 44;
            [self.tableView setHeight:keyBoardEndY  - delta];
            [self.tableView setBottom:self.sendView.top];
            CGSize size = self.tableView.contentSize;
            CGRect rect = CGRectMake(5, size.height - 10, 20, 10);
            [self.tableView scrollRectToVisible:rect animated:YES];
        }
        }];
    [UIView commitAnimations];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 20;
    if (p_isSendOut) {
        return 0;
    }
    else
        return [dataSource count];
    }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"AdviceMsgCell";
    AdviceMsgCell *cell = (AdviceMsgCell *)[BaseCell cellRegisterNib:cellIdentifier tableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ReplyModel *reply = dataSource[indexPath.row];
    [cell assignValue:reply];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    currentResponder = textView;
    UIViewBeginAnimation(kDuration);
    [self.upperView setAlpha:0];
    [self.downView setTop:-48];
    [self.tableView scrollsToTop];

    [UIView commitAnimations];
    return YES;
}
- (void)hideKeyBoard
{
    [super hideKeyBoard];
    UIViewBeginAnimation(kDuration);
    [self.upperView setAlpha:1];
    [self.downView setTop:self.upperView.bottom];
    [UIView commitAnimations];

}
//-  (BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
////    UIViewBeginAnimation;
////    [self.downView setTop:self.upperView.bottom];
////    [UIView commitAnimations];
//    [self.buyAddress becomeFirstResponder];
//    return YES;
//}
- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.advice && [textView.text length] != 0)
        self.placeHolderLabel.text = @"";
    else
        self.placeHolderLabel.text = @"点此输入你的宝贵建议噢...";
    
    int maxNum = maxCharacterNum;
    if (maxNum == 0) {
        return;
    }
    NSInteger number = [self.advice.text length];
    if (number > maxNum) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"字符个数不能大于%d",maxNum] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        textView.text = [textView.text substringToIndex:maxNum];
        
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self.buyAddress becomeFirstResponder];
        return NO;
    }
    return YES;
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 911)
    {
        [self registerKeyBoardObserve];
    }else
    {
        UIViewBeginAnimation(kDuration);
        [self.upperView setAlpha:0];
        [self.downView setTop:-108];
        [self.tableView setContentOffset:CGPointZero];
        [UIView commitAnimations];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentResponder = textField;
    if (textField.tag == 911)
        [self removeKeyBoardObserve];
//    else if
//    {
//        UIViewBeginAnimation;
//        [self.downView setTop:self.upperView.bottom];
//        [UIView commitAnimations];
//
//    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 0) {
        [self.buyUrl becomeFirstResponder];
    }
    else if (textField.tag == 1)
        [self hideKeyBoard];
    else if (textField.tag == 911)
        [self hideKeyBoard];
    return YES;
}
#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.bigPhotoImageView;
}
- (IBAction)sendMsg:(id)sender {
    
    if(p_isSendOut)//给建议
    {
        [self hideKeyBoard];
        UserProfile *loginUser = [Coordinator userProfile];
        NSNumber *userId = loginUser.userId;
        NSNumber *postId;
        NSString *content = self.advice.text;
        if ([[STRING_judge(content) stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            POPUPINFO(@"建议内容都不写么？写一点吧，亲");
            return;
        }
        if ([_gradeOrScormanager isKindOfClass:[ScoreManager class]]) {
            postId = ((ScoreManager *)_gradeOrScormanager).postProfile.postId;
            NSMutableDictionary *para0 = [NSMutableDictionary dictionary];
            [para0 setValue:userId forKey:@"userId"];
            [para0 setValue:postId forKey:@"postId"];
            [para0 setValue:content forKey: @"content"];
            [para0 setValue:self.buyAddress.text  forKey:@"address"];
            [para0 setValue:self.buyUrl.text forKey:@"buyUrl"];
            NSDictionary *para = @{@"advice" : para0, @"userId" : userId};
            NSDictionary *resultDic = [self.netAccess passUrl:AdviceModule_add andParaDic:para withMethod:AdviceModule_add_method andRequestId:AdviceModule_add_tag thenFilterKey:nil useSyn:YES dataForm:7];
            NSDictionary *result = resultDic[@"result"];
            if (NETACCESS_Success) {
                if (self &&[self isKindOfClass:[AdviceVC class]]) {
                    AdviceModel *adviceModel = [AdviceModel new];
                    adviceModel.adviceId = resultDic[@"id"];
                    adviceModel.content  = self.advice.text;
                    adviceModel.buyUrl = self.buyUrl.text;
                    adviceModel.address = self.buyAddress.text;
                    ((ScoreManager *)_gradeOrScormanager).postAdvice = adviceModel;
                    NSNumber *decibelGot = resultDic[@"decibel"][@"point"];
                    NSString *alertMsg = [NSString stringWithFormat:@"你的建议已经发给小伙伴了，Thx，还得到了%@分贝哦", decibelGot];
                    UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:alertMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alerView show];
                }
                
            }
            else
            {
                POPUPINFO(@"建议提交错误");
                return;
            }
            
        }
        else
        {
            POPUPINFO(@"数据错误了，找程序猿吧!");
            return;
        }
    }
    else//回复建议或者  回复建议的回复
    {
        if (sendedUnReplyCount >= maxReplyCount) {
            POPUPINFO(@"你发太多条了，等TA回复下你再发哦！");
            return;
        }
        
        ReplyModel *newReply = [ReplyModel new];
        newReply.srcUser = [Coordinator userProfile];

        if ([self.gradeOrScormanager isKindOfClass:[GradeModel class]]) {
            newReply.tgtUser = ((GradeModel *)self.gradeOrScormanager).user;
            newReply.adviceId = ((GradeModel *)self.gradeOrScormanager).advice.adviceId;
            newReply.postId   = ((GradeModel *)self.gradeOrScormanager).post.postId;
//            newReply.gradeId   = ((GradeModel *)self.gradeOrScormanager).gradeId;

        }
        else if([self.gradeOrScormanager isKindOfClass:[ScoreManager class]]){
            newReply.tgtUser = [Coordinator userProfile];
            newReply.adviceId = ((ScoreManager *) self.gradeOrScormanager).postAdvice.adviceId;
//            newReply.gradeId  = ((ScoreManager *) self.gradeOrScormanager).postGrade.gradeId;
            newReply.postId   = ((ScoreManager *) self.gradeOrScormanager).postProfile.postId;
        }
        newReply.content =  self.sendTextField.text;
        
        ReplyType type;
        if ([dataSource count] == 0 || tgtReplyId == nil)
            type = ReplyTypeAdvice;
        
        else
        {
            type = ReplyTypeReply;
            newReply.tgtReplyId = tgtReplyId;
        }
        
        //提交服务器
        NSMutableDictionary *para0 = [NSMutableDictionary dictionary];
        [para0 setValue:newReply.postId forKey:@"postId"];
        [para0 setValue:newReply.content forKey:@"content"];
        NSMutableDictionary *srcUserM = [NSMutableDictionary dictionary];
        [srcUserM setValue:newReply.srcUser.userId forKey:@"id"];
        [srcUserM setValue:newReply.srcUser.name forKey:@"name"];
        [para0 setValue:srcUserM forKey:@"srcUser"];
        NSMutableDictionary *tgtUserM = [NSMutableDictionary dictionary];
        [tgtUserM setValue:newReply.tgtUser.userId forKey:@"id"];
        [tgtUserM setValue:newReply.tgtUser.name forKey:@"name"];
        [para0 setValue:tgtUserM forKey:@"tgtUser"];
        [para0 setValue:NUMBER(type) forKey:@"type"];
//        [para0 setValue:newReply.gradeId forKey:@"gradeId"];
        [para0 setValue:newReply.tgtReplyId forKey:@"replyId"];
        [para0 setValue:newReply.adviceId forKey:@"adviceId"];

        
        NSDictionary *para = @{@"reply" : para0};
//        [self startAview];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary *resultDic = [self.netAccess passUrl:ReplyModule_add andParaDic:para withMethod:ReplyModule_add_method andRequestId:ReplyModule_add_tag thenFilterKey:nil useSyn:YES dataForm:7];
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self stopAview];
                NSDictionary *result = resultDic[@"result"];
                if (NETACCESS_Success) {
                    if (self &&[self isKindOfClass:[AdviceVC class]]) {
                        newReply.replyId = resultDic[@"id"];
                        newReply.createTime = [NSNumber numberWithDouble:  [[NSDate date]timeIntervalSince1970]];
                        [dataSource addObject:newReply];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[dataSource count]-1 inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        self.sendTextField.text = @"";
                        sendedUnReplyCount++;

                    }
                }
                else
                {
                    POPUPINFO(@"回复发送失败，请重试！");
                }

            });
        });
        
        
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self backToPreVC:nil];
}
@end
